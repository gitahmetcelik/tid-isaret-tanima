"""Agirliklari Keras GRU modeline tasir, LiteRT (.tflite) fp32 ve 8-bit (dinamik aralik) uretir,
test setinde PyTorch referansiyla ve dogrulukla karsilastirir.

ml/.venv-convert (tensorflow) ile calisir. Girdi: export_weights.py ciktilari.
Neden Keras: ai-edge-torch Windows'ta kurulamadi; PyTorch GRU kapi sirasi (r,z,n) Keras'in (z,r,h)
sirasina cevrilerek agirliklar birebir tasinir (reset_after=True ayni formul).
"""
import argparse
import os
from pathlib import Path

os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "2")
import numpy as np
import tensorflow as tf

ROOT = Path(__file__).resolve().parent.parent
ap = argparse.ArgumentParser()
ap.add_argument("--name", default="gru226")
a = ap.parse_args()

W = np.load(ROOT / "checkpoints" / f"{a.name}_weights.npz")
H = int(W["hidden"])
T, F = 64, 100
n_cls = W["out__weight"].shape[0]


def reorder(m):  # PyTorch (r,z,n) -> Keras (z,r,h), son eksende
    r, z, n = np.split(m, 3, axis=-1)
    return np.concatenate([z, r, n], axis=-1)


def gru_weights(layer, suffix):
    wih = reorder(W[f"gru__weight_ih_l{layer}{suffix}"].T)
    whh = reorder(W[f"gru__weight_hh_l{layer}{suffix}"].T)
    bih = reorder(W[f"gru__bias_ih_l{layer}{suffix}"])
    bhh = reorder(W[f"gru__bias_hh_l{layer}{suffix}"])
    return [wih, whh, np.stack([bih, bhh])]


inp = tf.keras.Input((T, F))
x = tf.keras.layers.Dense(H, activation="relu")(inp)
bi = []
for l in range(2):
    b = tf.keras.layers.Bidirectional(
        tf.keras.layers.GRU(H, return_sequences=True, reset_after=True, unroll=True))
    x = b(x)
    bi.append(b)
x = tf.keras.layers.GlobalAveragePooling1D()(x)
logits = tf.keras.layers.Dense(n_cls)(x)
model = tf.keras.Model(inp, logits)

model.layers[1].set_weights([W["inp__0__weight"].T, W["inp__0__bias"]])
for l, b in enumerate(bi):
    b.forward_layer.set_weights(gru_weights(l, ""))
    b.backward_layer.set_weights(gru_weights(l, "_reverse"))
model.layers[-1].set_weights([W["out__weight"].T, W["out__bias"]])

D = np.load(ROOT / "data" / "export" / f"{a.name}_test.npz")
x_test, y, ref = D["x"], D["y"], D["ref"]
keras_out = model.predict(x_test[:256], verbose=0)
print("Keras-PyTorch en buyuk fark (256 ornek):", np.abs(keras_out - ref[:256]).max())

out = ROOT / "ml" / "export"
out.mkdir(exist_ok=True)


def run_tflite(path, n=None):
    it = tf.lite.Interpreter(model_path=str(path), num_threads=4)
    it.allocate_tensors()
    i, o = it.get_input_details()[0]["index"], it.get_output_details()[0]["index"]
    xs = x_test if n is None else x_test[:n]
    res = []
    for k in range(len(xs)):
        it.set_tensor(i, xs[k:k + 1])
        it.invoke()
        res.append(it.get_tensor(o)[0].copy())
    return np.stack(res)


conv = tf.lite.TFLiteConverter.from_keras_model(model)
fp32 = conv.convert()
(out / f"{a.name}_fp32.tflite").write_bytes(fp32)
conv = tf.lite.TFLiteConverter.from_keras_model(model)
conv.optimizations = [tf.lite.Optimize.DEFAULT]  # agirliklar 8 bit (dinamik aralik)
int8 = conv.convert()
(out / f"{a.name}_int8.tflite").write_bytes(int8)
print(f"boyut fp32 {len(fp32)/1e6:.2f} MB, int8 {len(int8)/1e6:.2f} MB")

for name in ("fp32", "int8"):
    p = out / f"{a.name}_{name}.tflite"
    r = run_tflite(p)
    print(f"{name}: test dogrulugu {(r.argmax(1) == y).mean():.4f}  (PyTorch {(ref.argmax(1) == y).mean():.4f}), "
          f"torch ile ayni tahmin orani {(r.argmax(1) == ref.argmax(1)).mean():.4f}")
