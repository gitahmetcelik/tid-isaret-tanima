# Vize Hazırlık — Durum ve Tutarlılık Notu

**Tarih:** 3 Kasım 2026
**Kaynaklar:** repo (`docs/DURUM.md`, `PLAN.md`, `experiments/*.json`), `Deneme.pdf`, `TID_Tez_Onerisi.pdf`, `TID_Bitirme_Projesi_Vize_Ilerleme_Raporu-v11.docx`

Bu not, vize/ara rapor öncesi "hangi belge ne diyor, gerçekte ne var" farkını kapatmak için çıkarıldı.

---

## 1. Gerçek durum (repodaki kanıtlarla)

| Ölçüt | Hedef | Gerçekleşen | Kanıt |
|---|---|---|---|
| Test doğruluğu (226 sınıf) | ≥ %85 | **%88,0** | `experiments/20261024_gru226.json` |
| Doğrulama doğruluğu | — | **%89,9** | aynı dosya |
| Model boyutu | ≤ 10 MB | **3,19 MB** (int8) | `ml/export/gru226_int8.tflite` |
| Python ↔ telefon paritesi | — | **%99,5 aynı tahmin** | `docs/DURUM.md` |
| Çıkarım süresi | ≥ 15 FPS | **~48 ms/örnek** (tekil), uygulamada **~9 FPS** | `docs/DURUM.md` |
| Uçak modu testi | Tam çalışma | **Yapılmadı** (uygulama internet kullanmıyor ama test edilmedi) | `docs/DURUM.md` |
| Gerçek ortam doğruluğu | ≥ %75 (30 işaret) | **Ölçülmedi**, canlı kamerada belirgin düşüş var | `docs/DURUM.md` |

Veri: train 28.142 / val 4.418 / test 3.741 video (resmî bölmeler, işaretçi kesişimi yok), 11 bozuk video atlandı.

---

## 2. v11 raporda düzeltilmesi gereken yerler

Rapor, repodaki gerçek durumun **gerisinde** kalmış. Hoca iki belgeyi yan yana koyarsa tutarsızlık hemen görünür.

| v11'de yazan | Doğrusu |
|---|---|
| "PyTorch iskeleti yazıldı, veri seti hazırlandığında eğitime başlanacak" | Eğitim yapıldı: val %89,9 / test %88,0 |
| "10 MB altı hedefleniyor, LiteRT INT8 araştırılıyor" | int8 dönüşüm tamam, model **3,19 MB** |
| "MedyaPipe ile koordinat çıkarma aşamasına geçiliyor" | Tüm veri işlendi, `.npz` nokta dosyaları hazır (~1,1 GB) |
| "36.300 videoluk AUTSL" | Resmî toplam 38.336; bölmelerin toplamı 36.301; 11 bozuk çıkarıldı |
| "Model ile görüntüyü bağlamak sıradaki adım" | Uygulama modeli çalıştırıyor, öz-testte %99,5 parite alındı |

Ayrıca:
- **Sayısal kanıt yok.** Tablo/şekil eklenmeli (kayıp eğrisi, karışıklık matrisi, model boyutu, FPS).
- **İş bölümü anlatımı** repodaki gerçek iş yüküyle uyuşmuyor gibi; herkes kendi bölümünü repo geçmişine göre kontrol etsin (Ahmet'in `DURUM.md`'si 29 Ekim'de tek başına yaptığı işi anlatıyor).
- **"Neler Yaptım" dili** fazla genel ("mimarisini oluşturdum"). Somut sayı ve dosya adı ile değiştirilmeli.

> Not: `Deneme.pdf` v11'den çok daha güncel ve doğru (88,00 / 3,19 MB / 48 ms). Ara rapor metni büyük ölçüde ondan türetilebilir; sadece ekip bölümleri ve tarihler güncellenmeli.

---

## 3. Vize öncesi kapatılması gereken açıklar

1. **Canlı kamera doğruluğu** — en büyük risk. Kaydedilmiş veride %91,5, canlıda güven %3-20. Sebep bilinmiyor; sunumda "bilinen sorun + plan" olarak dürüstçe anlatılmalı.
2. **FPS 9 → 15** — hız hedefi tutmuyor. GPU/CPU, kare seyreltme, model girişi küçültme seçenekleri.
3. **Uçak modu testi** — en kolay kazanım, 10 dakikalık iş, hedefi doğrudan karşılıyor.
4. **Gönüllü testi + KVKK rıza formu** — vizeye yetişmezse "planlandı" olarak anlatılır, ama taslağı hazır olmalı.
5. **Ara rapor biçimi** — bölüm şablonu, IEEE kaynakça, Turnitin.

---

## 4. Önerilen sunum akışı (8-10 slayt, ~12 dk)

1. Problem ve motivasyon (1 slayt, kısa)
2. Literatürdeki yer / yenilik: TİD + mobil + çevrimdışı
3. Sistem mimarisi (eğitim hattı / telefon hattı — tek şekil)
4. Veri: AUTSL, resmî bölmeler, temizlik, MediaPipe özellikleri
5. Model: 2 katmanlı BiGRU, 2,1 M parametre, eğitim ayarları
6. Sonuçlar: %88,0 test, %89,9 val; karışıklık matrisi / en çok karışan sınıflar
7. Mobil: 3,19 MB int8, %99,5 parite, ~48 ms; arayüz ekran görüntüleri
8. Dürüst değerlendirme: FPS ~9, canlı kamera düşüşü, uçak modu testi
9. Sıradaki adımlar + riskler (tarihli)
10. Sorular

---

## 5. Bu hafta (3-9 Kasım) yapılacaklar

- [ ] v11 raporunu yukarıdaki düzeltmelerle güncelle
- [ ] Deneme.pdf'teki sayıları repo ile son kez karşılaştır
- [ ] Sunum iskeletini çıkar, her slayta 3-4 madde
- [ ] Uçak modu testi (ekran kaydı ile kanıt)
- [ ] FPS ölçümünü tekrar al, tabloya yaz
- [ ] Herkes kendi bölümünü yazsın, Cuma birleştirme
