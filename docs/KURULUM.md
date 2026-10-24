# Kurulum (Windows, PowerShell)

Repo private. Önce GitHub kullanıcı adınızı Ahmet'e iletin, davet gelince kabul edin.

## 1. Git kimliği (log'da kim ne yaptı görünsün diye şart)

Kendi adınız ve GitHub'a bağlı e-postanızla:

```bash
git config --global user.name "Ad Soyad"
git config --global user.email "github-hesabindaki-eposta@ornek.com"
```

İki Mustafa olduğu için adın soyadla birlikte olması önemli (ör. `Mustafa Göktepe`, `Mustafa Küpel`).

## 2. Repoyu klonla

```bash
git clone https://github.com/gitahmetcelik/tid-isaret-tanima.git
cd tid-isaret-tanima
```

## 3. Python 3.12 ortamı (uv ile)

`uv` kurulu değilse: https://docs.astral.sh/uv/ adresindeki Windows kurulum komutunu çalıştırın.

```bash
uv venv --python 3.12 ml/.venv
uv pip install --python ml/.venv/Scripts/python.exe -r ml/requirements.txt
```

Eğitim için PyTorch (NVIDIA kartı için; RTX 5000 serisi dahil `cu128` uygundur):

```bash
uv pip install --python ml/.venv/Scripts/python.exe torch --index-url https://download.pytorch.org/whl/cu128
```

Kontrol (GPU görünmeli):

```bash
ml/.venv/Scripts/python.exe -c "import torch; print(torch.__version__, torch.cuda.is_available(), torch.cuda.get_device_name(0))"
```

Küpel: `nvidia-smi` çıktısını (GPU modeli ve VRAM) Ahmet'e gönder.

## 4. MediaPipe modelleri

```bash
mkdir -p ml/models
curl -L -o ml/models/hand_landmarker.task https://storage.googleapis.com/mediapipe-models/hand_landmarker/hand_landmarker/float16/latest/hand_landmarker.task
curl -L -o ml/models/pose_landmarker_lite.task https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_lite/float16/latest/pose_landmarker_lite.task
```

## 5. Veri (repoya girmez)

Kaggle hesabınızla giriş yapıp `sttaseen/autsl` verisini indirin (~13 GB). Komut satırı için Kaggle → Settings → API'den token oluşturun, dosyayı `C:\Users\<kullanıcı>\.kaggle\` içine koyun (token'ı kimseye göndermeyin):

```bash
pip install kaggle
kaggle datasets download -d sttaseen/autsl -p "data/archive (1)" --unzip
```

İndirme bitince klasör yapısı şöyle olmalı (betikler varsayılan olarak `data/archive (1)` bekler; başka yere koyarsanız `--data <yol>` verin):

```
data/archive (1)/train/*.mp4   (28.142 dosya)
data/archive (1)/val/*.mp4     (4.418)
data/archive (1)/test/*.mp4    (3.742)
data/archive (1)/{train,val,test}_labels.csv
```

Kaggle `thtrnphc/autsl` kullanılmaz (işaretçiler bölmelerde karışık).

## 6. Hızlı deneme (10 sınıf, birkaç dakika)

```bash
ml/.venv/Scripts/python.exe ml/extract_keypoints.py --split train --classes 30,175,65,86,196,211,83,52,14,20 --workers 4 --out data/keypoints_10
```

(`val` ve `test` için `--split` değiştirin.) Sonra:

```bash
ml/.venv/Scripts/python.exe ml/train_gru.py --epochs 30
```

Beklenen: 10 sınıfta doğrulama ~%95, test ~%94 (Ahmet'in makinesinde).

## 7. Çalışma düzeni

- `main`'e doğrudan push yapmayın. Dal açın: `git checkout -b kisi/ip-konu` (örn. `mustafa-k/ip3-transformer`).
- Commit mesajı İP numarasıyla başlasın: `ip3: transformer modeli eklendi`.
- Dalı itin, GitHub'da Pull Request açın, bir kişi onaylasın.
- Büyük dosyalar (video, `.npz`, `.pth`) repoya girmez.
- Her cuma `docs/worklog/<ad>.md` dosyasına 5 satır: ne yaptım, ne bloklu.

## 8. İlk görevler

| Kim | Görev |
|---|---|
| Mustafa Küpel | Kurulumu bitir, `nvidia-smi` gönder. Tüm veri nokta çıkarımı Ahmet'in makinesinde sürüyor; senin makinen eğitim için (RTX 5060) kullanılacak. 10 sınıflık denemeyi çalıştır, sonucu `docs/worklog/` içine yaz. |
| Mustafa Göktepe | Kurulumu bitir, 10 sınıflık denemeyi çalıştır. `ml/train_gru.py` üzerinde Transformer / 1B-CNN modelini ekleme çalışmasını başlat (`ip3-transformer` dalı). |
