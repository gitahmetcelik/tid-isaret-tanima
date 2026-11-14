# TİD İşaret Tanıma

Telefon kamerasından alınan Türk İşaret Dili hareketini (AUTSL, 226 kelime) MediaPipe ile çıkarılan el ve
üst gövde noktalarından sınıflandırıp Türkçe kelime olarak gösteren, internetsiz çalışan Android uygulaması.
Erciyes Üniversitesi Bilgisayar Mühendisliği bitirme projesi.

Ekip: Ahmet Çelik, Mustafa Göktepe, Mustafa Küpel.

## Durum (Kasım 2026, ara rapor)

| Ölçüt | Hedef | Ölçülen |
|---|---|---|
| Test doğruluğu, BiGRU (226 sınıf) | ≥ %85 | %88,24 |
| Test doğruluğu, 1B-CNN + Transformer | ≥ %85 | %88,83 |
| Model boyutu (BiGRU, int8 LiteRT) | ≤ 10 MB | 3,19 MB |
| Python ↔ telefon tahmin uyumu | — | %99,5 |
| Uçtan uca hız (telefon) | ≥ 15 FPS | ~9 FPS |

Açık sorunlar: canlı kamerada tahmin güveni kayıtlı veriye göre çok düşük, hız hedefi tutmuyor.
Ayrıntı: [docs/DURUM.md](docs/DURUM.md).

## Klasörler

```
ml/            nokta çıkarımı, eğitim, değerlendirme, LiteRT dönüşümü (ml/README.md)
app/           Flutter + Kotlin uygulaması (CameraX, MediaPipe, LiteRT)
experiments/   deney kayıtları (JSON) ve grafikler
docs/          durum, kurulum, veri notları, ara rapor (docs/vize/rapor-latex), worklog
PLAN.md        ayrıntılı plan, riskler, ölçüm tabloları
```

Veri (`data/`), eğitim ağırlıkları (`checkpoints/`) ve Flutter SDK repoya girmez.

## Hızlı başlangıç

Kurulum: [docs/KURULUM.md](docs/KURULUM.md). Ortam hazırsa:

```bash
# hazır ağırlıkla test kümesinde örnek tahminler ve doğruluk
ml/.venv/bin/python ml/demo.py --name cnn_transformer_all_s0

# 10 sınıfta birkaç dakikalık eğitim denemesi
ml/.venv/bin/python ml/train_gru.py --model cnn_transformer --classes 30,175,65,86,196,211,83,52,14,20 --epochs 5 --name deneme
```

VS Code kullananlar için aynı adımlar Çalıştır ve Hata Ayıkla menüsünde hazır (`.vscode/launch.json`).
Windows'ta Python yolu `ml/.venv/Scripts/python.exe`.
