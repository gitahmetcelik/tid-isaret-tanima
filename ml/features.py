"""Nokta dosyasindan (.npz) model girdisine giden yol: normalizasyon, sabit uzunluk, artirma, batch.

Girdi extract_keypoints.py ciktisidir. Normalizasyon PLAN.md / PDF denklem 1: omuz ortasina oteleme +
omuz genisligine bolme. Telefondaki on isleme (LandmarkPipeline.kt) bu dosyadaki adimlarin aynisidir;
burada bir sey degisirse orada da degismeli.
"""
import csv
from pathlib import Path

import numpy as np
import torch

ROOT = Path(__file__).resolve().parent.parent
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


def fix_length(hands, pose, hok):
    return (resample(hands, T_FIXED).astype(np.float32), resample(pose, T_FIXED).astype(np.float32),
            (resample(hok, T_FIXED) > 0.5).astype(np.float32))


def featurize(path):
    """Normalize edilmis ham dizi (degisken uzunluk); sabit uzunluga batch sirasinda getirilir."""
    return normalize(np.load(path))  # [T,2,21,2], [T,7,2], [T,2]


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
    """Egitimde: zamansal seyreltme (telefonun dusuk kare hizini taklit eder), kirpma,
    rastgele olcek, +-10 derece donme, kaydirma."""
    t = len(hands)
    stride = int(rng.choice([1, 1, 2, 3]))  # 30 FPS / 15 FPS / 10 FPS
    idx = np.arange(int(rng.integers(0, stride)), t, stride)
    if len(idx) >= 8:
        hands, pose, hok = hands[idx], pose[idx], hok[idx]
    t = len(hands)
    cut = int(t * 0.1)
    t0 = int(rng.integers(0, cut + 1)); t1 = t - int(rng.integers(0, cut + 1))
    hands, pose, hok = fix_length(hands[t0:t1], pose[t0:t1], hok[t0:t1])
    a = np.deg2rad(rng.uniform(-10, 10))
    R = np.array([[np.cos(a), -np.sin(a)], [np.sin(a), np.cos(a)]], np.float32)
    s = rng.uniform(0.9, 1.1)
    shift = rng.normal(0, 0.05, 2).astype(np.float32)
    hands = (hands @ R.T) * s + shift
    pose = (pose @ R.T) * s + shift
    hands = hands * hok[:, :, None, None]
    return hands, pose, hok


def batches(X, y, bs, rng, train):
    order = rng.permutation(len(X)) if train else np.arange(len(X))
    for i in range(0, len(X), bs):
        ids = order[i : i + bs]
        vecs = []
        for j in ids:
            h, p, k = X[j]
            h, p, k = augment(h, p, k, rng) if train else fix_length(h, p, k)
            vecs.append(to_vec(h, p, k))
        yield torch.tensor(np.stack(vecs)), torch.tensor(y[ids])


def load_sign_names(csv_path):
    """Sinif no -> Turkce kelime (docs/SignList_ClassId_TR_EN.csv)."""
    names = {}
    if not Path(csv_path).exists():
        return names
    with open(csv_path, encoding="utf-8") as f:
        for row in csv.DictReader(f):
            names[int(row["ClassId"])] = row["TR"]
    return names
