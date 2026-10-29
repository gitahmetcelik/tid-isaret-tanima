# Proje durumu ve devir notu (29 Ekim 2026)

Bu dosya, Ahmet'in ilk haftada yaptıklarını, ölçülen sonuçları, çalışmayan yerleri ve sıradaki işleri anlatır. Yeni gelen biri (Mustafa Göktepe, Mustafa Küpel) sadece bu dosyayı okuyarak devam edebilmelidir. Ayrıntılı plan: [PLAN.md](../PLAN.md). Kurulum: [KURULUM.md](KURULUM.md). Veri notları: [data.md](data.md).

> **Dürüstlük notu.** Aşağıdaki sayılar tek bir bilgisayarda, tek tohumla, tek koşuda alındı. "Ölçüldü" yazan yerler gerçekten ölçüldü; "gözlem" yazanlar bir kişinin elle denemesidir. Doğrulanamayanlar ayrıca işaretlendi. Git geçmişi gerçek tarihlerle başlar (23 Ekim 2026); önceki hazırlık haftalarının kodu/logu yoktur.

## 1. Projenin tek cümlelik özeti

Telefon kamerasından alınan Türk İşaret Dili (AUTSL, 226 kelime) hareketini, MediaPipe ile çıkarılan el ve üst gövde noktalarından bir BiGRU modeliyle sınıflandırıp Türkçe kelime olarak gösteren, internetsiz çalışan Android uygulaması. (PDF: `TID_Tez_Onerisi.pdf`)

## 2. Şu ana kadar yapılanlar

| Alan | Durum | Ölçülen sonuç | Nerede |
|---|---|---|---|
| Veri | Kaggle `sttaseen/autsl` indirildi, resmi sayılarla doğrulandı | train 28.142 / val 4.418 / test 3.741 video (31/6/6 işaretçi, kesişim yok); 11 bozuk video atlandı | [data.md](data.md) |
| Nokta çıkarımı | Tüm veri işlendi (MediaPipe Tasks API, el + 7 gövde noktası) | süre kesin ölçülmedi, tahminden (7-8 saat) çok kısa sürdü | `ml/extract_keypoints.py` |
| Model | BiGRU 2×256, PyTorch, zamansal seyreltme artırmalı | **val %89,9, test %88,0** (hedef ≥ %85), ~2,1 M parametre | `ml/train_gru.py`, `experiments/` |
| Dönüşüm | PyTorch → Keras → LiteRT (`ai-edge-torch` Windows'ta kurulamadı) | fp32 9,43 MB %88,0; **int8 3,19 MB %88,0** (PyTorch ile %99,5 aynı tahmin) | `ml/export_weights.py`, `ml/convert_tflite.py` |
| Kotlin/Python parite | Gömülü 200 test örneği telefonda koşturuldu | Python ile **%99,5 aynı tahmin**, ~48 ms/örnek | `ml/export_selftest.py`, uygulama "öz-test" |
| Uygulama | Flutter + Kotlin: CameraX, MediaPipe el/poz, kaydet-tanı, sürekli mod, güven eşiği | ~9 FPS (Redmi Note 10 Pro, ön kamera, el GPU/poz CPU) | `app/` |
| Reddetme eşiği | Güven eşiği kalibre edildi | eşik 0,6: kabul edilenlerin %75'i, bunlarda doğruluk %96,8 (test) | `ml/calibrate_threshold.py` |

## 3. Bilinen sorunlar (dürüstçe)

1. **Canlı kamerada doğruluk, kaydedilmiş veriden çok düşük.** Öz-test (kaydedilmiş noktalar) %91,5; canlı kullanımda çoğu tahminin güveni %3-20. Sebebi **bilinmiyor.** Denenenler:
   - *Kaydet-tanı modu* ("yaklaşık doğru", Ahmet'in gözlemi, sayısal ölçüm yok).
   - *Sürekli mod, ~70 segment:* segment sayısı doğru (5 bilinen klip → 5 segment), ama top-1 güven %3-20 ve istenen kelimeler çıkmadı.
   - *Ekrandan kameraya (5 bilinen test klibi):* 1/5 doğru (teşekkür %51), kalan %4-15. **Ekran çevrimi elleri küçülttüğü için bu deney sebebi ayırmıyor.**
   - *Video dosyası doğrudan telefondaki MediaPipe zincirinden (kamerasız):* 14 videodan 10'u doğru (%71), ama **telefon aşırı ısındığı için yarıda kesildi** (46,7 °C). Python'da aynı 60 klipte %81,7 çıkıyordu. Yeterli örnek yok, sonuç **kesin değil.**
   - Not: 10 FPS'e seyreltilmiş AUTSL kliplerinde segmentleme simülasyonu (ml/tune_segmentation.py) doğruluğu bozmuyor (bulunan segmentlerde %89-90). Yani segment kuralları tek başına sorun gibi görünmüyor.
2. **Hız hedefi tutmuyor.** ~9 FPS (hedef ≥ 15). CPU modu uzun süre kullanılamayacak kadar ısıtıyor.
3. **Sözlük dışı hareketi gerçekten reddedip reddetmediğimiz ölçülmedi.** Sahte negatiflerle (eller yok, karışık kareler) eşik 0,7'de %0-17 yanlış kabul var, bu gerçek değildir.
4. **Cümle kurma yok** (PDF kapsamı dışı, "gelecek çalışma"). Sürekli mod yalnızca kelimeleri art arda dizer.
5. **Gönüllü testi, KVKK/etik, Turnitin, ara rapor henüz başlamadı.**
6. **Diğer iki üyenin çalışması henüz repoda yok.** Git log'da yalnızca Ahmet var.

## 4. Neyi nasıl yeniden çalıştırırsınız

Kurulum için önce [KURULUM.md](KURULUM.md). Ek notlar:

- **Nokta dosyaları (1,1 GB) repoya girmez.** Ya `ml/extract_keypoints.py --shard k/3` ile üç makinede üretin (~2,6 saat/makine), ya da Ahmet'ten Drive linki isteyin ve `data/keypoints/{train,val,test}/` altına açın.
- **Eğitilmiş model ağırlığı** `ml/export/gru226.pt` (8,5 MB, repoda). Scriptler `checkpoints/` bekler: `mkdir checkpoints && cp ml/export/gru226.pt checkpoints/`.
- 226 sınıflı eğitim (~16 dk, RTX 3050): `ml/.venv/Scripts/python.exe ml/train_gru.py --epochs 60 --name gru226`
- Dönüşüm: `ml/.venv/Scripts/python.exe ml/export_weights.py` sonra `ml/.venv-convert/Scripts/python.exe ml/convert_tflite.py` (ml/.venv-convert için: `uv venv --python 3.12 ml/.venv-convert; uv pip install --python ml/.venv-convert/Scripts/python.exe tensorflow numpy`).
- Eşik kalibrasyonu: `ml/calibrate_threshold.py`. Segmentleme simülasyonu: `ml/tune_segmentation.py`.
- Uygulama: `cd app; flutter build apk --profile`, sonra `adb install -r build/app/outputs/flutter-apk/app-profile.apk`. MediaPipe `.task` dosyaları ve `selftest.bin` repoda değil: `ml/README.md` ve `ml/export_selftest.py`.
- Telefon testleri adb ile tetiklenebilir (sonuç logcat'te): `--ez selftest true` (etiket `TIDSELFTEST`), `--es videotest <0|1|2>` (etiket `TIDVTEST`, videoları `/sdcard/Android/data/tr.edu.erciyes.tid_app/files/vtest/<ad>__<sınıf>.mp4` içine koyun). **Video testi telefonu ısıtır, 10-20 videodan fazlasını tek seferde koşturmayın.**

## 5. Sıradaki işler (öneri, taslak)

Rol dağılımı PDF'teki gibi korunur; yedekler önerilmiştir. Karar toplantıda netleşmeli.

| Kim | Öncelikli iş | Çıktı |
|---|---|---|
| **Mustafa Göktepe** (İP3) | `ml/train_gru.py` üzerinde 1B-CNN + küçük Transformer modeli ekleyip BiGRU ile karşılaştırmak; farklı tohumlarla aralık (en az 3 koşu); gerekirse sınıf/özellik iyileştirmeleri | `experiments/` altında JSON, ara rapora karşılaştırma tablosu |
| **Mustafa Küpel** (İP2) | Kurulum, `nvidia-smi` çıktısını paylaşmak; tüm veri çıkarımını kendi makinesinde yeniden doğrulamak (örneğin `--shard 1/3`); **canlı-çevrimdışı farkını araştırmak**: aynı videoları hem Python'da hem telefonda çıkarıp noktaları sayısal karşılaştırmak (P-01) | Nokta farkı ölçümü, rapora parite bölümü |
| **Ahmet Çelik** (İP5) | Canlı doğruluk sorununu daraltmak (ekran-çevrimi yerine kayıtlı video + Android çıkarımı, GPU/CPU karşılaştırması, daha az ısınan test); hız optimizasyonu; metin ekranı | Sebep raporu, FPS ölçümü |
| **Hepsi** | Gönüllü test protokolü + rıza formu (KVKK), ara rapor taslağı (kendi bölümünüzü yazın), `docs/worklog/<ad>.md` her cuma | Ara rapor 20 Kasım'a kadar |

Kısa vadeli takvim (PLAN.md Bölüm 1-2): **30 Ekim** danışman toplantısı; **6-7 Kasım** M1; **9-15 Kasım** ara sınav (yalnızca arka plan eğitim); **16-20 Kasım** ara rapor teslimi; tez teslimi **1 Ocak 2027**.

## 6. 30 Ekim toplantısında hocaya bildirilecekler

1. Başlangıç 5 Ekim, kodlama 23 Ekim'de başladı (hazırlık dönemi için kod/log yok).
2. TensorFlow/Keras yerine **PyTorch** ile eğitim (RTX 5060/Blackwell gerekçesi); dönüşüm Keras üzerinden LiteRT'ye yapıldı, kayıpsız.
3. Hedefler: test %88,0 (≥ %85 sağlandı), model 3,19 MB (≤ 10 MB sağlandı), **FPS ~9 (≥ 15 sağlanmadı)**, uçak modu doğrulanmadı (uygulama internet kullanmıyor ama bilinçli test yapılmadı), gerçek ortam doğruluğu **ölçülmedi, canlı kullanımda belirgin düşüş gözlendi.**
4. Soruları: AUTSL resmi erişimi ve test etiketleri; üniversite GPU'su; KVKK/etik kurul gereksinimi; test telefonu olarak kendi telefonlarımız; ara rapor biçimi; haftalık toplantı günü.

## 7. Dosya haritası

```
PLAN.md               Ayrıntılı plan, riskler, ölçüm tabloları (ana belge)
docs/DURUM.md         Bu dosya
docs/KURULUM.md       Kurulum ve çalışma düzeni
docs/data.md          Veri notları, bozuk videolar
docs/SignList_ClassId_TR_EN.csv   Sınıf no -> kelime (Hugging Face kopyası, resmî dosyayla karşılaştırılmalı)
experiments/          Deney sonuçları (JSON)
ml/                   Nokta çıkarımı, eğitim, dönüşüm, kalibrasyon betikleri
ml/export/            gru226.pt (ağırlık), gru226_fp32/int8.tflite
app/                  Flutter + Kotlin uygulaması (CameraX, MediaPipe, LiteRT)
```

## 8. Çalışma kuralları (hatırlatma)

- `main`'e doğrudan push yapmayın; kendi adınızla dal açın (`ad/ip3-konu`), Pull Request ile birleştirin.
- Commit mesajı İP numarasıyla başlasın (`ip3: ...`). Kendi adınızla commit atın (`git config user.name/email`).
- Büyük dosyalar (video, `.npz`, ham modeller) repoya girmez. Deney sonuçlarını `experiments/*.json` olarak ekleyin.
- Her cuma `docs/worklog/<ad>.md` dosyasına 5 satır: ne yaptım, ne bloklu.
