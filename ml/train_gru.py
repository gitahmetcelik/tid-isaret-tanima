"""10 siniflik (veya verilen alt kume) GRU temel modeli.

Girdi: extract_keypoints.py ciktisi (.npz). Normalizasyon PLAN.md / PDF denklem 1:
omuz ortasina oteleme + omuz genisligine bolme. Test kumesi yalnizca egitim sonunda bir kez olculur.
"""
import argparse
import csv
import json
import time
from pathlib import Path

import numpy as np
import torch
import torch.nn as nn

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
T_FIXED = 64


def normalize(d):
    hands, pose = d["hands"].copy(), d["pose"].copy()
    hok, pok = d["hand_ok"], d["pose_ok"]
    sh_l, sh_r = pose[:, 1, :2], pose[:, 2, :2]  # sol/sag omuz
    center = (sh_l + sh_r) / 2
    scale = np.linalg.norm(sh_l - sh_r, axis=1)
    # omuz bulunamayan kareler: son gecerli degeri tasi, yoksa 1
    good = pok & (scale > 1e-4)
    if not good.any():
        center[:] = 0.5
        scale[:] = 0.3
    else:
        idx = np.where(good, np.arange(len(good)), 0)
        np.maximum.accumulate(idx, out=idx)
        first = np.argmax(good)
        idx[: first + 1] = first
        center, scale = center[idx], scale[idx]
    hands = (hands[..., :2] - center[:, None, None, :]) / scale[:, None, None, None]
    pose = (pose[..., :2] - center[:, None, :]) / scale[:, None, None]
    hands = hands * hok[:, :, None, None]  # eksik el = 0
    return hands.astype(np.float32), pose.astype(np.float32), hok.astype(np.float32)


def resample(x, t_out):
    t = len(x)
    idx = np.linspace(0, t - 1, t_out)
    lo = np.floor(idx).astype(int)
    hi = np.minimum(lo + 1, t - 1)
    w = (idx - lo).reshape(-1, *([1] * (x.ndim - 1)))
    return x[lo] * (1 - w) + x[hi] * w


def featurize(path):
    d = np.load(path)
    hands, pose, hok = normalize(d)
    hands = resample(hands, T_FIXED)
    pose = resample(pose, T_FIXED)
    hok = (resample(hok, T_FIXED) > 0.5).astype(np.float32)
    return hands, pose, hok  # [T,2,21,2], [T,7,2], [T,2]


def to_vec(hands, pose, hok):
    t = len(hands)
    v = np.concatenate([hands.reshape(t, -1), pose.reshape(t, -1), hok], axis=1)  # 84+14+2=100
    return v.astype(np.float32)


def load_split(kp_dir, split, label_map, labels_csv):
    X, y = [], []
    for name, lab in csv.reader(open(labels_csv)):
        lab = int(lab)
        if lab not in label_map:
            continue
        f = Path(kp_dir) / split / f"{name}.npz"
        if f.exists():
            X.append(featurize(f))
            y.append(label_map[lab])
    return X, np.array(y)


def augment(hands, pose, hok, rng):
    """Egitimde: rastgele olcek, +-10 derece donme, kaydirma, zamansal kirpma/hiz."""
    t0 = rng.integers(0, 8)
    t1 = T_FIXED - rng.integers(0, 8)
    hands, pose, hok = hands[t0:t1], pose[t0:t1], hok[t0:t1]
    hands, pose, hok = resample(hands, T_FIXED), resample(pose, T_FIXED), (resample(hok, T_FIXED) > 0.5).astype(np.float32)
    a = np.deg2rad(rng.uniform(-10, 10))
    R = np.array([[np.cos(a), -np.sin(a)], [np.sin(a), np.cos(a)]], np.float32)
    s = rng.uniform(0.9, 1.1)
    shift = rng.normal(0, 0.05, 2).astype(np.float32)
    hands = (hands @ R.T) * s + shift
    pose = (pose @ R.T) * s + shift
    hands = hands * hok[:, :, None, None]
    return hands, pose, hok


class GRUNet(nn.Module):
    def __init__(self, n_cls, in_dim=100, hidden=128):
        super().__init__()
        self.inp = nn.Sequential(nn.Linear(in_dim, hidden), nn.ReLU(), nn.Dropout(0.2))
        self.gru = nn.GRU(hidden, hidden, num_layers=2, batch_first=True, bidirectional=True, dropout=0.2)
        self.out = nn.Linear(hidden * 2, n_cls)

    def forward(self, x):
        h, _ = self.gru(self.inp(x))
        return self.out(h.mean(1))


def batches(X, y, bs, rng, train):
    order = rng.permutation(len(X)) if train else np.arange(len(X))
    for i in range(0, len(X), bs):
        ids = order[i : i + bs]
        vecs = []
        for j in ids:
            h, p, k = X[j]
            if train:
                h, p, k = augment(h, p, k, rng)
            vecs.append(to_vec(h, p, k))
        yield torch.tensor(np.stack(vecs)), torch.tensor(y[ids])


@torch.no_grad()
def evaluate(model, X, y, dev):
    model.eval()
    correct = 0
    for xb, yb in batches(X, y, 128, np.random.default_rng(0), False):
        correct += (model(xb.to(dev)).argmax(1).cpu() == yb).sum().item()
    return correct / len(y)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--classes", default="30,175,65,86,196,211,83,52,14,20")
    ap.add_argument("--kp", default=str(ROOT / "data" / "keypoints_10"))
    ap.add_argument("--data", default=str(ROOT / "data" / "archive (1)"))
    ap.add_argument("--epochs", type=int, default=40)
    ap.add_argument("--seed", type=int, default=0)
    ap.add_argument("--name", default="gru10")
    a = ap.parse_args()

    torch.manual_seed(a.seed)
    rng = np.random.default_rng(a.seed)
    classes = [int(c) for c in a.classes.split(",")]
    label_map = {c: i for i, c in enumerate(classes)}
    data = {s: load_split(a.kp, s, label_map, Path(a.data) / f"{s}_labels.csv") for s in ("train", "val", "test")}
    for s, (X, y) in data.items():
        print(s, len(X), flush=True)

    dev = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = GRUNet(len(classes)).to(dev)
    opt = torch.optim.AdamW(model.parameters(), lr=2e-3, weight_decay=1e-2)
    sched = torch.optim.lr_scheduler.CosineAnnealingLR(opt, a.epochs)
    best, best_state = 0.0, None
    t0 = time.time()
    for ep in range(1, a.epochs + 1):
        model.train()
        tot = 0.0
        for xb, yb in batches(*data["train"], 64, rng, True):
            opt.zero_grad()
            loss = nn.functional.cross_entropy(model(xb.to(dev)), yb.to(dev), label_smoothing=0.1)
            loss.backward()
            opt.step()
            tot += loss.item() * len(yb)
        sched.step()
        va = evaluate(model, *data["val"], dev)
        if va > best:
            best, best_state = va, {k: v.cpu().clone() for k, v in model.state_dict().items()}
        print(f"ep {ep:02d} loss {tot / len(data['train'][1]):.3f} val {va:.3f}", flush=True)

    model.load_state_dict(best_state)
    test = evaluate(model, *data["test"], dev)
    print(f"EN IYI val {best:.3f} | TEST {test:.3f} | sure {time.time() - t0:.0f}s")
    out = ROOT / "experiments"
    out.mkdir(exist_ok=True)
    (out / f"{time.strftime('%Y%m%d')}_{a.name}.json").write_text(
        json.dumps(dict(model="BiGRU-2x128", classes=classes, epochs=a.epochs, seed=a.seed,
                        n_train=len(data["train"][1]), best_val=best, test=test, device=str(dev)), indent=2),
        encoding="utf-8")


if __name__ == "__main__":
    main()
