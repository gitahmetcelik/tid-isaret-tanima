# İP3 Vize Planı — Mustafa Göktepe

**Kapsam:** vizede benim payıma düşen kısım = model tarafı (İP3) + dönüşümün model ayağı (İP4).
Mobil taraf (Ahmet) ve veri hattı (Küpeli) ayrı bölümler; ben onlara sadece sayı sağlıyorum.

**Hedef çıktı:** ara raporun "Model" bölümü (4-5 sayfa) + sunumda 6 slayt + `experiments/` altında tekrar
üretilebilir deney kayıtları.

---

## 1. Vize için model tarafında ne lazım

| # | İş | Neden vizede lazım | Çıktı |
|---|---|---|---|
| 1 | 226 sınıf, BiGRU, 3 tohum | Tek koşu şans eseri olabilir; aralık göstermek gerek | 3 JSON + ortalama/ss |
| 2 | 226 sınıf, 1D-CNN+Transformer, 3 tohum | Tez önerisinde "karşılaştırılacak" dedik | 3 JSON + tablo |
| 3 | Karşılaştırma tablosu | Raporun en görünür tablosu | markdown → Word |
| 4 | Eğitim eğrisi (loss/val) | Modelin gerçekten öğrendiğini gösterir | PNG, 2 grafik |
| 5 | Karışıklık matrisi + en çok karışan 10 sınıf | "Sonuç %88" demek yetmiyor, nerede hata var | PNG + tablo |
| 6 | int8 sonrası doğruluk (zaten 88,0) | İP4 ile bağım | tablo satırı |
| 7 | Sınıf bazında F1 (en kötü 10 sınıf) | Hata analizi bölümü | tablo |
| 8 | Deney kaydı düzeni | "Kim hangi deneyi yaptı" görünsün | `experiments/*.json` |
| 9 | Model bölümü metni | Rapor | `docs/vize/model-bolumu.md` |
| 10 | 6 slayt | Sunum | `docs/vize/slaytlar.md` |

İsteğe bağlı (zaman kalırsa, puan getirir): artırma aç/kapa ablasyonu, T=64 vs T=32, gizli birim 128 vs 256.

---

## 2. Takvim (bugün 3 Kasım Salı, teslim 16-20 Kasım)

### Hafta 1 — 3-8 Kasım: ortam + ilk gerçek koşular
- **3 Kas (bugün):** keypoint verisini yerleştir, `ml/.venv` kur, 5 epoch'luk 226 sınıf denemesi.
  Amaç: boru hattı gerçek veride de çalışıyor mu?
- **4 Kas:** 5 epoch sonucuna bak. Val anlamlı yükseliyorsa 60 epoch'a geç.
  Yükselmiyorsa veri/label eşleşmesini kontrol et (en sık hata burada).
- **5-6 Kas:** BiGRU 3 tohumu başlat (gece koşusu, ~16 dk/koşu CUDA'da).
- **7 Kas:** CNN+Transformer 3 tohumu başlat.
- **8 Kas:** iki modelin ilk tablosunu çıkar, danışmana gösterilecek hale getir.

### Hafta 2 — 9-15 Kasım: ara sınav haftası (kod yazmıyoruz, koşular arkada)
- Uzun koşuları bu haftaya **önceden** bırak. Sınavdan dönünce sonuç hazır olsun.
- Sırada: karışıklık matrisi ve F1 betiği (`ml/error_analysis.py`) — 1-2 saatlik iş.
- Rapor bölümünün iskeletini boş sayfa olarak aç, başlıkları yaz.

### Hafta 3 — 16-20 Kasım: yazma + sunum
- **16-17 Kas:** grafikler, tablolar, model bölümü metni.
- **18 Kas:** slaytlar (6 slayt), Ahmet'le birleştirme.
- **19 Kas:** prova; "neden BiGRU, neden Transformer, neden %88" sorularına cevap.
- **20 Kas:** teslim.

> Not: 16-20 Kasım aynı zamanda teslim haftası. Raporu son güne bırakmamak için metin 17'sinde bitmeli.

---

## 3. Deney listesi (komutlar hazır)

```bash
# tek koşu, hızlı kontrol (5 epoch)
ml/.venv/bin/python ml/train_gru.py --epochs 5 --name kontrol

# 3 tohum x 2 model, 60 epoch (asıl tablo)
ml/.venv/bin/python ml/compare_models.py --seeds 0,1,2 --epochs 60
```

| Deney | Amaç | Süre (RTX 3050) |
|---|---|---|
| kontrol (5 epoch) | boru hattı sağlam mı | ~2 dk |
| gru × seed 0,1,2 | temel sonuç + aralık | ~48 dk |
| cnn_transformer × seed 0,1,2 | karşılaştırma | ~60 dk |
| artırma kapalı (gru, seed 0) | artırmanın katkısı | ~16 dk |
| T=32 (gru, seed 0) | dizi uzunluğu etkisi | ~10 dk |

Mac'te MPS ile aynı komutlar çalışır ama süre 3-5 katı olur; gece koşusu için uygun.

---

## 4. Rapor bölümü iskeleti (benim yazacağım kısım)

1. **Model yaklaşımı** — neden nokta tabanlı, neden GRU, neden ikinci model
2. **BiGRU mimarisi** — 2 katman, 256 gizli, 2,0 M parametre, giriş 100 boyut
3. **1D-CNN + Transformer** — neden ekledik (paralel eğitim, uzun bağımlılık), 1,42 M parametre
4. **Eğitim düzeni** — 60 epoch, AdamW 2e-3, cosine, label smoothing 0.1, batch 128
5. **Sonuçlar** — tablo (3 tohum ort. ± ss), eğitim eğrisi, int8 sonrası
6. **Hata analizi** — karışıklık matrisi, en çok karışan sınıflar, nedenleri
7. **Sınırlar** — canlı kamera düşüşü, FPS; "bu bir model sorunu mu, hat sorunu mu" tartışması

Uzunluk hedefi: 4-5 sayfa. Şekil 3, tablo 3.

---

## 5. Engeller

- **Veri:** keypoint arşivi Drive'da oturum istiyor. İndirilince `data/keypoints/` altına açılacak.
- **Push:** Muzzers hesabının repoda yazma yetkisi yok → fork + PR ya da collaborator daveti.
- **GPU:** bu Mac'te MPS var, tam koşu uzun sürer; ekip makinesinde (CUDA) 1 saatte biter.
