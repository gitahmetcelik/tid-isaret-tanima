# Veri

Veri repoya girmez. Her üye kendi makinesinde `data/` klasörüne koyar.

- Ana veri: Kaggle `sttaseen/autsl` → `data/archive (1)/` (`train/`, `val/`, `test/` + `*_labels.csv`).
  Doğrulama (23 Ekim 2026): 28.142 / 4.418 / 3.742 video, 31/6/6 işaretçi, bölmeler kesişmiyor, 226 sınıf.
- Sınıf numarası → Türkçe kelime: `docs/SignList_ClassId_TR_EN.csv` (Hugging Face kopyası; resmi dosyayla karşılaştırılmalı).
- Kullanılmayacak: Kaggle `thtrnphc/autsl` (bölmelerde işaretçiler karışık).
- Lisans: AUTSL yalnızca akademik/araştırma amaçlıdır, ticari kullanım yasaktır.

## Bozuk videolar (24 Ekim 2026)

Kaggle `sttaseen/autsl` kopyasında 11 video açılamıyor (MP4 `moov` bilgisi eksik, dosya yarım). Orijinal veride de böyle olup olmadığı doğrulanmadı. Nokta çıkarımında atlandı:

- test/signer6_sample185_color.mp4
- train/signer15_sample276_color.mp4
- train/signer20_sample424_color.mp4
- train/signer22_sample612_color.mp4
- train/signer2_sample1161_color.mp4
- train/signer36_sample356_color.mp4
- train/signer3_sample152_color.mp4
- train/signer41_sample25_color.mp4
- train/signer42_sample647_color.mp4
- train/signer5_sample618_color.mp4
- train/signer8_sample1406_color.mp4

Sonuç: nokta dosyası sayıları train 28.132 / val 4.418 / test 3.741. Test sonuçları 3.741 video üzerinden raporlanır.
