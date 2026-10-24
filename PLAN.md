# TİD Tanıma Bitirme Projesi: Uygulama Planı


> Kaynak: `TID_Tez_Onerisi.pdf` (Eylül 2026). Bu plan PDF'in yerine geçmez; PDF'in hafta numaralarını (Hf1 = 28 Eylül) korur ve hedefleri **5 Ekim başlangıcına** göre yeniden dağıtır.
> Durum: **TASLAK v0.2** (23 Ekim 2026). `[?]` ile işaretli yerler ekip kararı bekliyor.
> Donanım: Mustafa KÜPEL'in makinesinde **RTX 5000 serisi (Blackwell)** GPU var; ana eğitim makinesi olarak o öneriliyor `[?]`. Diğer üyelerin donanımı `[?]`.

## 0. Önce dürüst durum tespiti

| | PDF planı | Gerçek durum |
|---|---|---|
| Başlangıç | 28 Eylül | **5 Ekim** (1 hafta kayma) |
| Hf2-3 (5-18 Eki) | Hazırlık, literatür, veri ve test verisi arama, dağıtım | Planlandı ama **koda veya repoya dönüşmedi**; yalnızca düşünsel hazırlık |
| Bugün (23 Ekim) | Veri hazır, model geliştirme başlamış olmalıydı | Kod, repo, veri yok |
| Ara sınav | 9-15 Kasım, sadece arka plan eğitim | Aynı |
| Ara rapor | 16-20 Kasım | Aynı |
| Tez teslimi | 1 Ocak 2027 | Aynı |

**Kayıt kuralı:** Git geçmişi gerçek tarihleriyle başlar; commit tarihleri **geriye çekilmez**. 5-23 Ekim arasındaki hazırlık dönemi `docs/worklog/` altında "geriye dönük özet" olarak, yazıldığı gerçek tarihle ve öyle etiketlenerek eklenir. Danışmana da böyle anlatılır: ilk iki hafta hazırlık, kodlama 23 Ekim'de başladı.

Sonuç: ara sınavdan önce **15 gün** var (23 Ekim → 7 Kasım). PDF'teki "yedek süre" (21 Aralık - 3 Ocak) planın güvenlik payı olarak kalıyor, ona dokunmuyoruz. Kayan zaman veri hazırlama ve model geliştirmenin paralel yürütülmesiyle geri alınacak.

## 1. Kilometre taşları

| Kod | Tarih | Çıktı | Ölçülebilir kabul ölçütü |
|---|---|---|---|
| **M0** | Per 29 Eki | Altyapı hazır (toplantı öncesi) | Repo, ortam, AUTSL erişimi, 3 kişinin kod çalıştırabildiği doğrulandı |
| **T1** | **Cum 30 Eki** | **Danışman toplantısı** | Aşağıdaki Bölüm 2.1'deki gündem ve gösterilecekler |
| **M1** | **Cum 6 Kas (son gün 7 Kas)** | Ara sınav öncesi dikey dilim | Tüm AUTSL için nokta dosyaları üretildi; GRU temel modeli eğitildi (doğruluk raporlandı); telefonda kamera + el/poz noktaları canlı görünüyor; 1. fp32 `.tflite` telefonda çalışıyor (doğruluğu düşük olabilir); ara rapor ilk taslağı (Giriş, Literatür, Yöntem) hazır |
| **M2** | Cum 20 Kas (hedef Çar 18 Kas) | Ara rapor teslimi | Danışmana PDF olarak teslim |
| **M3** | Cum 4 Ara | Model dondurma | Seçilmiş model, 8-bit nicemleme yapılmış, AUTSL test ≥ %85 veya nedeni açıklanmış |
| **M4** | Cum 11 Ara | Uygulama tamam | 3 ekran çalışıyor, uçak modunda test edildi, ölçülen FPS ≥ 15 |
| **M5** | Cum 18 Ara (PDF: 20 Ara) | Özellik dondurma ve test bitişi | Gönüllü testi bitti, tüm Tablo 2 ölçütleri ölçüldü |
| **M6** | Cum 25 Ara | Tez taslağı | Tamamı yazıldı, Turnitin ön yüklemesi yapıldı |
| **M7** | Salı 29 Ara (son: 1 Oca) | Tez teslimi | Danışmana teslim + Turnitin |
| — | 4 Oca haftası | Sunum | Bölümün belirleyeceği tarih |

## 2. Haftalık takvim (hafta numaraları PDF Gantt'ı ile aynı)

| Hf | Tarih | Odak | Durum / çıktı |
|---|---|---|---|
| 2 | 5-11 Eki | Hazırlık: kapsam, literatür taraması, iş dağılımı | *Geçti, kayıt yok* |
| 3 | 12-18 Eki | Eğitim ve test verisi arama, kaynak seçimi, patent fikri | *Geçti, kayıt yok* |
| **4** | **19-25 Eki** (şu an) | **Planı kesinleştir + AUTSL'yi birlikte bul + altyapı** | Bu plan, veri kaynağı kararı, repo, ortam (3 kişi), AUTSL erişimi, **parite deneyi** (P-01), 10 işaretlik küçük veri ile uçtan uca boru hattı |
| 5 | 26 Eki - 1 Kas | **Veri + iskelet** | Tüm AUTSL nokta çıkarımı (3 makinede paralel), CameraX + MediaPipe Tasks iskeleti, GRU eğitim betiği |
| 6 | 2-8 Kas | **Dikey dilim (M1)** | GRU sonucu, 1D-CNN+Transformer ilk koşusu, fp32 `.tflite` telefonda, ara rapor taslağı, hız sweep'leri hazır |
| 7 | 9-15 Kas | **Ara sınav** | Yalnızca arka planda çalışan eğitim koşuları (betikler Hf6'da hazır olacak); yeni geliştirme başlatılmaz |
| 8 | 16-20 Kas | Ara rapor | M2; sınav sonrası model kıyas sonuçları rapora girer |
| 9 | 23-29 Kas | Model iyileştirme + nicemleme | Veri artırma ablation'ları, 8-bit nicemleme, doğruluk kaybı ölçümü |
| 10 | 30 Kas - 6 Ara | Model dondurma (M3) + uygulama ekranları | Kayan tampon, güven eşiği, metin biriktirme ekranı, işaret listesi; gönüllü test protokolü + rıza formu hazır |
| 11 | 7-13 Ara | Uygulama tamam (M4) + gönüllü testi başlar | FPS/bellek/pil ölçümleri, gönüllü oturumları |
| 12 | 14-20 Ara | Test bitişi (M5) | Tüm ölçümler, hata analizi |
| 13 | 21-27 Ara | Tez yazımı + yedek | M6 |
| 14 | 28 Ara - 1 Oca | Teslim | M7 |

Kural: **Hf6 sonunda M1 kaçırılırsa** (Cuma 6 Kas toplantısında karar) öncelik sırası: (1) temel model + telefonda çalışan demo, (2) ara rapor, (3) Transformer karşılaştırması ertelenir.

### 2.1 Danışman toplantısı: Cuma 30 Ekim

Bugünden toplantıya 7 gün var. Toplantıda "ilk iki hafta hazırlıktı, kodlama 23 Ekim'de başladı" şeklinde dürüst bir tablo sunulur; aşağıdakiler hazır olursa bu savunulabilir olur.

**Toplantıya kadar yapılacaklar (Çar 28 Eki akşamı hazır olmalı)**
- Repo kurulu, `main` korumalı, 3 kişi collaborator, ilk issue'lar açık (kim ne yapıyor görünür).
- AUTSL erişimi: başvuru yapılmış ya da veri indirilmiş.
- Parite deneyi (P-01) veya en azından 10 işaretlik küçük örnekte Python'da nokta çıkarımı çalışıyor: **bir ekran görüntüsü / kısa video**.
- Telefonda CameraX + el noktaları iskeleti açılıyor (en azından kamera görüntüsü).
- Eğitim ortamı kararı (PyTorch ve TF) ve dönüşüm hattının 1 küçük modelle denemesi.
- `docs/worklog/` ilk kayıtlar, `PLAN.md` v1.0.

**Hocaya sorulacak / bildirilecek kararlar**
1. 5 Ekim başlangıcı ve 1 haftalık kayma; M1 (6 Kas) hedefi.
2. TensorFlow yerine PyTorch + `ai-edge-torch` kullanımı (Blackwell GPU gerekçesi): PDF'ten sapma sayılır mı?
3. Veri: AUTSL erişimi için üniversiteden/hocadan resmi bir yol var mı? Test etiketleri sorunu (P-03).
4. Eğitim için üniversite GPU'su gerekir mi, yoksa Küpel'in makinesi yeterli mi?
5. Gönüllü testi için KVKK/etik kurul gereksinimi var mı (P-08)?
6. Ara rapor formatı ve 16-20 Kasım teslim şekli; LaTeX şablonu uygun mu?
7. Test telefonu: kendi telefonlarımız kabul mü?
8. Haftalık toplantı günü: Cuma önerilir; log'u (worklog + PR geçmişi) o toplantıda göstermek ister mi?

**Toplantıda gösterilecek:** bu plan (1 sayfa özet), repo ve issue panosu, çalışan ilk nokta çıkarımı, risk tablosu (P-01, P-02, P-03).

## 3. İş paketleri (PDF Tablo 3'ün güncellenmiş hali)

Sorumlular PDF'teki gibi **ana sahip**, her pakete bir **yedek** eklenir (bus factor). Atamalar `[?]` ile ekip kararı bekliyor, çünkü üyelerin ML/mobil deneyimi bilinmiyor.

| İP | Kapsam | Ana sahip (PDF) | Yedek `[?]` | Bağımlılık |
|---|---|---|---|---|
| İP1 | Literatür, patent taraması, AUTSL erişimi, işaret sözlüğü (226 sınıf) | Tüm ekip (bölüşülmüş) | — | — |
| İP2 | MediaPipe nokta çıkarımı, normalizasyon, veri artırma | M. KÜPEL | A. ÇELİK | İP1 (veri erişimi) |
| İP3 | GRU ve 1D-CNN+Transformer eğitimi, karşılaştırma | M. GÖKTEPE | M. KÜPEL | İP2 çıktısı |
| İP4 | LiteRT dönüşümü + 8 bit nicemleme | M. GÖKTEPE + A. ÇELİK | — | İP3 modeli |
| İP5 | Flutter + Kotlin: kamera, MediaPipe, çıkarım döngüsü, ekranlar | A. ÇELİK | M. GÖKTEPE | İP4 (gerçek model), önce sahte modelle başlanır |
| İP6 | AUTSL testi, gönüllü testi, telefon ölçümleri | Tüm ekip | — | İP3-5 |
| İP7 | Ara rapor, tez, sunum | Her İP sahibi kendi bölümünü yazar | — | — |

Yük dengesi uyarısı: A. ÇELİK hem tüm mobil işi (İP5) hem İP4'ün yarısını taşıyor, **darboğaz o**. M. KÜPEL'in İP2'si Hf5'te biter; sonrasında İP5'e (Kotlin tarafı) ve İP6 test altyapısına kaydırılması önerilir `[?]`.

### Ekibe öneri: Hf4 için kişiye özel görevler

- **M. KÜPEL**: AUTSL erişimi + indirme, `extract_keypoints.py` iskeleti, 10 işaretlik alt küme.
- **M. GÖKTEPE**: Eğitim ortamı (Bölüm 5), GRU eğitim şablonu, deney kayıt formatı.
- **A. ÇELİK**: Flutter + Android Studio kurulumu, CameraX + HandLandmarker iskeleti, test telefonunun belirlenmesi.
- **Hepsi**: Bölüm 6'daki okuma listesinden payına düşen 3 makale için 5 satırlık özet (`docs/literature/`).

## 4. Riskler ve problemler (öncelik sırasıyla)

| # | Problem | Etki | Önlem / karar |
|---|---|---|---|
| **P-01** | **Eğitim-telefon uyuşmazlığı.** PDF "aynı MediaPipe modeli" diyor. Android'de `HandLandmarker` + `PoseLandmarker` (Tasks API) var; Python'da klasik `mp.solutions.holistic` farklı model ve farklı nokta numaralandırması verir. Eğitimi eski API ile yapıp telefonda Tasks kullanırsak doğruluk sessizce düşer. | **Kritik.** Proje başarısını belirler | Python tarafında da **Tasks API** (`mediapipe.tasks.python.vision`) kullan; `.task` model dosyalarını sürümle birlikte sabitle. Hf4'de 20 videoluk parite deneyi: aynı video hem Python hem Android'de çıkarılsın, nokta farkı ölçülsün |
| **P-02** | **Python 3.14 (bu makinede) TensorFlow ile uyumlu olmayabilir**, Windows'ta TF ≥ 2.11 yerel GPU desteği yok, ayrıca Küpel'in RTX 5000 serisi kartı (Blackwell) için TF desteği ayrıca doğrulanmalı. Dönüşüm hattı Keras/LiteRT sürümlerine hassas. | Yüksek | Sürümleri doğrulayıp `pyproject`/`requirements.lock` ile sabitle. Blackwell nedeniyle eğilim: eğitimi **PyTorch'ta** yapıp `ai-edge-torch` ile LiteRT'ye çevirmek (PDF'te TensorFlow/Keras yazıyor, danışmana bildirilir); alternatif WSL2 + TF/Keras. Dönüşüm hattı Hf4'te 1 küçük modelle denenip karar verilir. **KARAR (24 Ekim): eğitim PyTorch ile** (`torch 2.11+cu128` kuruldu, bu makinedeki RTX 3050'de CUDA çalışıyor; cu128 Blackwell/RTX 5060 için de uygun, TensorFlow desteği ise doğrulanamadı). LiteRT dönüşümü (`ai-edge-torch` veya ONNX üzerinden) **henüz denenmedi**, 1 küçük modelle erken test edilecek; çalışmazsa karar yeniden açılır. PDF'teki TensorFlow/Keras ifadesinden sapma 30 Ekim toplantısında danışmana bildirilir. |
| **P-03** | **AUTSL erişimi.** Veri seti resmi sayfada form/şifre gerektirebilir; test etiketleri yarışma sonrası ayrı yayınlanmış olabilir. Erişim gecikmesi tüm zinciri durdurur. | Yüksek | İlk gün başvur (Hf4 Pzt). Yedek: Kaggle'daki kopyalar ve BosphorusSign22k (sadece yedek, kapsam değil). Test kümesi etiketleri yoksa doğrulama kümesini ayır, tezde belirt. **Doğrulandı (23 Ekim, siteler tarayıcıda açıldı):** cvml.ankara.edu.tr/datasets sayfası indirmeyi ChaLearn 2021 sayfasına (chalearnlap.cvc.uab.cat/dataset/40) yönlendiriyor; kendisi yalnızca `examples.zip` veriyor ve verinin yalnızca akademik/araştırma amaçlı olduğunu belirtiyor (ticari kullanım yasak). ChaLearn sürümü: 36.302 örnek (eğitim 28.142 / doğrulama 4.418 / test 3.742), 31/6/6 işaretçi; Ankara sayfası 38.336 diyor, indirilen sürüm 36.302'lik dengeli test seti olanıdır. **İndirme dosya sayfası giriş istiyor** (kayıt/hesap, ekipten biri kendisi açmalı); dosyalar şifreli (7z, bölünmüş `.zip.001`), eğitim/doğrulama/test ve etiket şifreleri ChaLearn veri sayfalarında yazıyor. Doğrulama ve test etiketleri de ayrı dosya olarak sunuluyor, yani işaretçiden bağımsız test mümkün. Dosya boyutları giriş yapılınca görülecek |
| **P-04** | **Veri hacmi ve işlem süresi.** 38 bin video; her karede MediaPipe çalıştırmak CPU'da saatler sürer. Disk gereksinimi onlarca GB. | Orta | Veriyi 3 makineye böl (shard), `.npz` çıktıları önbelleğe al, işlenmiş noktalar küçük olduğu için paylaş. Her kişi için disk durumu kontrol edilmeli `[?]` |
| **P-05** | **Flutter + canlı kamera + MediaPipe performansı.** Her kareyi platform kanalıyla Dart'a taşımak 15 FPS hedefini öldürür. | Yüksek | Kamera, MediaPipe ve LiteRT çıkarımı **tamamen Kotlin'de** (CameraX). Flutter yalnızca UI; sonuçlar `EventChannel` ile metin/olay olarak gelsin. Görüntü ön izlemesi `PlatformView` ile |
| **P-06** | **Hedef telefon belirsiz.** "Orta segment" tanımsız; ölçümler cihaza göre değişir. | Orta | Ölçüm cihazını Hf4'de sabitle, modelini tezde yaz. Ek olarak ikinci bir cihaz (üye telefonu) |
| **P-07** | **Sahada doğruluk düşüşü.** AUTSL stüdyo benzeri çekim; telefonun ön kamerası, ışık, ayna görüntüsü, soldaki/sağdaki el karışması. | Yüksek | Eğitimde yatay çevirme (el yer değişimiyle birlikte), ışık/gürültü etkisi için nokta jitter'ı, el kaybolan karelere dayanıklılık (maskeleme). Ön/arka kamera için ayrı sınama |
| **P-08** | **Gönüllü testi KVKK/etik.** Açık rıza, veri saklama. Sadece nokta saklanacak, ama süreç yazılı olmalı. | Orta | Hf10'de rıza formu ve protokol; danışmandan onay al. Görüntü kaydı yapılmaz. Gönüllü bulma Hf9'den başlar |
| **P-09** | **%85 Top-1 hedefi.** Hafif nokta-tabanlı yöntemler literatürde üst seviye değildir; hedef tutmayabilir. | Orta | Hedefin tutmama senaryosunu rapora baştan koy: "ulaşılan sonuç + hata analizi" de kabul edilebilir. Veri artırma ve topluluk (ensemble) YOK, ama dikkat/pozisyonel kodlama denenebilir |
| **P-10** | **Nicemleme kaybı.** 8-bit sonrası doğruluk beklenenden fazla düşebilir; GRU/Transformer operatörleri LiteRT'de sorunlu olabilir. | Orta | Hf6'te fp32 dönüşümü zorunlu ilk adım; GRU'yu ilk gün LiteRT'ye çevirip test et. Gerekirse dinamik aralık nicemleme veya sadece ağırlık nicemleme |
| **P-11** | **Ara sınav haftası boşluğu.** Kimse çalışamaz; eğitim koşusu çökerse bir hafta kaybolur. | Orta | Hf6 sonunda tüm betikler checkpoint'li ve otomatik devam edecek şekilde olmalı; koşular yedek bir makinede de başlatılabilmeli |
| **P-12** | **Patent taraması unutulur.** PDF'te vaat edilmiş. | Düşük | Tek issue, Hf4, 1 saat. Ekran görüntüsü + tarih rapora |
| **P-13** | **İki Mustafa.** Log, issue ve commit kayıtlarında karışıklık. | Düşük | Rozet/etiketlerde `mgoktepe` / `mkupel` kullan, her kişi kendi `git config user.name/email` ayarını doğrulasın, `.mailmap` ekle |

### 4.1 Veri kaynağı alternatifleri (23 Ekim taraması, sayfalar tarayıcıda açılarak kontrol edildi)

| Kaynak | İçerik | Erişim | Not |
|---|---|---|---|
| **AUTSL resmi** (ChaLearn) | 226 işaret, 43 işaretçi, 36.302 video | Hesap gerekir; kayıtta 500 hatası alındı | Ana hedef; akademik kullanım şartı |
| **Kaggle AUTSL kopyaları** (`sttaseen/autsl` ~13 GB RGB + CSV, `thtrnphc/autsl` ~7 GB, `ngphmng/autsl-dataset`) | Topluluk yüklemeleri, train/val/test klasörleri | Kaggle hesabı ile | Resmi olmayan kopya. Lisans etiketleri tutarsız (Unknown / Apache 2.0) ama orijinal lisans akademik kullanımla sınırlı. Eksik/bozuk olabilir; etiketler ve örnek sayısı indirince doğrulanmalı |
| **Kaggle AUTSL MediaPipe landmark** (`trnvngquct/austl-processed-dataset-mediapipe-landmarks`) | Hazır landmark dosyaları, train/val/test + CSV | Kaggle hesabı | Hızlı başlangıç için. Hangi MediaPipe sürümü/nokta seti belli değil: P-01 nedeniyle **ana veri olarak kullanılmaz**, yalnızca model boru hattını erken denemek için |
| **TurkSign446** (Zenodo 17267294) | 446 kelime, 10 kişi × 10 tekrar, 44.600 video, MediaPipe Holistic 1.662 özellik/kare (NumPy), CC BY 4.0 | Kayıt herkese açık, **dosyalar kısıtlı: erişim talebi gerekir** | Yazarlar Cumhur Torun, Abdulkadir Karacı. CNN+GRU ile %97,88 (kendi testlerinde), gerçek zamanlı kullanıcıdan bağımsız %80,27. Tam bizim yönteme yakın; hem veri hem kıyas olarak değerli. 10 işaretçi, 226 sınıf değil |
| **BosphorusSign22k** | 744 işaret, 6 işaretçi, 22.542 video, OpenPose noktaları hazır | EULA yazarlara gönderilir | Yedek / ek değerlendirme |
| **E-TSL** (arXiv 2405.02984) | Sürekli TİD, 11 işaretçi, ~24 saat, eğitim videoları | Doğrulanmadı | Kapsam dışı (sürekli işaret), gelecek çalışma için |

**KARAR (23 Ekim): İki Kaggle verisiyle devam edilir** `[?]` hangi ikisi olduğu doğrulanacak; varsayım: `sttaseen/autsl` (RGB video + CSV, asıl veri) ve `trnvngquct/austl-processed-dataset-mediapipe-landmarks` (hazır landmark, yalnızca erken deneme/kıyas). Veriler `D:\claude\bitirme-data\` altında tutulur (git dışı; C: diskinde 24 GB yer var, D:'de ~390 GB). Resmi ChaLearn kaydı ve TurkSign446 talebi arka planda sürer. İndirmeden sonra kontrol: örnek sayısı, etiket-dosya eşleşmesi, `examples.zip` ile çapraz doğrulama, işaretçi bölmesinin resmi 31/6/6 ile uyumu.

**DOĞRULAMA SONUCU (23 Ekim, `D:\claude\bitirme\data` incelendi):**
- `archive (1)` = Kaggle `sttaseen/autsl` ile uyumlu: `train` 28.142 / `val` 4.418 / `test` 3.742 `.mp4` (toplam **36.302**, resmi ChaLearn sayısıyla birebir), her bölme için `*_labels.csv` var, etiketli satırların hepsinin videosu mevcut (eksik 0), 226 sınıf, işaretçiler **31 / 6 / 6 ve birbirleriyle kesişmiyor**. Videolar 512×512, 30 FPS, 41-61 kare (örnek), ortalama ~0,4 MB. Yani resmi AUTSL bölmesi ve test etiketleri elimizde; **ana veri bu**.
- `archive` = `thtrnphc/autsl` (AUTSL_custom_preprocessing): sınıf klasörlerinde kare dizileri, bölmeler 23.064 / 5.880 / 7.346 (toplam 36.290, resmi sayıyla uyuşmuyor) ve **işaretçiler bölmeler arasında karışıyor** (ör. işaretçi 11 hem test'te hem resmi val'de). İşaretçiden bağımsız değerlendirme için **kullanılmaz**, silinebilir veya yalnızca denemelik tutulur.
- Eksik: sınıf numarası → Türkçe kelime eşlemesi (ChaLearn "Class Ids correspondence" dosyası). Uygulama Türkçe metin gösterecek, bu dosya şart. Hesap gerektiriyorsa kayıt sorunu çözülünce alınır; yoksa Kaggle kopyasında bulunup bulunmadığına bakılır. `[?]`
- Henüz doğrulanmadı: `examples.zip` ile video eşleşmesi, videoların bozuk olup olmadığı (yalnızca 3 örnek açıldı).

Karar önerisi: (1) ChaLearn kaydını çöz ve resmi AUTSL'yi al; (2) paralelde TurkSign446 erişim talebi gönder; (3) resmi AUTSL gecikirse Kaggle RGB kopyasından başla ve tezde kaynağını açıkça yaz; (4) nokta çıkarımını her durumda kendimiz yaparız (P-01).

## 5. Teknik tasarım (kısa)

Boru hattı PDF Şekil 1'deki gibi; ek olarak şu kararlar öneriliyor:

1. **Nokta kümesi**: PDF'e uygun, 2 el × 21 + 7 gövde = 49 nokta × (x, y; z isteğe bağlı) → kare başına 98 ya da 147 değer. Eksik el = sıfır + maske kanalı. Normalizasyon PDF denklem 1.
2. **Dizi uzunluğu**: sabit T (örn. 64) kareye örnekleme; AUTSL klipleri değişken uzunlukta. `[?]` T değeri deneyle seçilir.
3. **Modeller**: GRU temel; 1D-CNN + küçük Transformer. Parametre bütçesi < 2-3 M (10 MB sınırı nicemlemeden önce zaten aşılmasın).
4. **Eğitim ortamı** (P-02): WSL2 + CUDA + TF/Keras öneriliyor; Ana eğitim makinesi Küpel'in RTX 5060 kartı (Blackwell, bildirilen 12 GB VRAM henüz doğrulanmadı) olur; nokta dizileri küçük olduğu için VRAM sorun değil. **Dikkat:** Blackwell yeni olduğundan CUDA 12.8+ ve güncel sürücü gerekir, TensorFlow'un kararlı sürümlerinin bu kartı destekleyip desteklemediği **doğrulanmadı** (P-02). Eğitim PyTorch ise destek daha rahat; TF seçilirse NVIDIA'nın hazır TF konteyneri ya da nightly gerekebilir. Model eğitimi Göktepe'nin sorumluluğunda olduğu için Küpel'in makinesine uzaktan erişim ya da eğitimi Küpel'in başlatması gerekir `[?]`.
5. **Deney izleme**: her koşu `experiments/<tarih>_<kişi>_<model>.json` (seed, parametreler, metrikler) olarak repoya girer. W&B gerekmez. Böylece "kim hangi deneyi yaptı" log'dan görünür.
6. **Veri bölme**: AUTSL'nin resmi eğitim/doğrulama/test bölmesi, işaretçiden bağımsız. Rastgele bölme **yapılmaz**.
7. **Telefon çıkarım döngüsü**: kamera → MediaPipe → normalizasyon → kayan tampon (T kare) → LiteRT → güven eşiği + ardışık kare oylaması → metin. Normalizasyon kodu Python ve Kotlin'de birebir aynı olmalı; **birim testi** ile ortak test vektörü kullanılır.

## 6. Kaynaklar (Hf3'de seçildiği varsayılan liste)

> Bağlantı ve ayrıntılar yazmadan önce doğrulanmalı; aşağıdakiler PDF'te geçenler ve bilinen öneriler.

**Veri**
- AUTSL (Sincan & Keleş, IEEE Access 2020): ana veri seti, PDF kaynak [3].
- BosphorusSign22k (PDF [4]): yalnızca yedek / ek değerlendirme için.

**Makaleler (okuma listesi, her biri 5 satır özet)**
- ChaLearn 2021 AUTSL yarışma özeti (PDF [2]), tüm ekip.
- SAM-SLR (Jiang ve ark., 2021): AUTSL'de skeleton tabanlı güçlü yöntem `[?]` doğrulanacak; M. GÖKTEPE.
- Google ASL Signs (Kaggle, PDF [5]) 1. çözüm yazısı: nokta + 1B-CNN + Transformer + TFLite; mimari için en yakın örnek. M. GÖKTEPE + A. ÇELİK.
- MediaPipe (PDF [6]), M. KÜPEL.
- GRU ve Transformer temel makaleleri (kısaca), rapor için.

**Belgeler (çalışma sırasında)**
- MediaPipe Tasks: Hand Landmarker ve Pose Landmarker, hem Python hem Android.
- Google AI Edge LiteRT: dönüşüm, nicemleme, Android çıkarımı (PDF [7]).
- Flutter: Platform Channels, `EventChannel`, `PlatformView`; Android CameraX.

**Resmî evraklar**
- Erciyes Üniv. akademik takvimi (PDF [8]) ve bitirme ödevi uygulama esasları (PDF [9]).
- TÜRKPATENT ve Google Patents (İP1).

**Araçlar**: Python 3.11/3.12 (WSL2), TensorFlow/Keras, MediaPipe, OpenCV, NumPy, Android Studio, Flutter SDK, Kotlin, CameraX, LaTeX (zip'teki şablon, Overleaf ya da yerel).

## 7. GitHub tasarımı

**Repo**: `tid-isaret-tanima` `[?]` (private; 3 kişi collaborator; sonra isteğe bağlı public, PDF açık kaynak vaat ediyor).

```
/ml          Python: extract/, train/, convert/, tests/
/app         Flutter + android/ (Kotlin)
/report      LaTeX (ara rapor, tez); her İP sahibi ayrı bölüm dosyası
/docs        PLAN.md, literature/, worklog/<ad>.md, KVKK/
/experiments Deney JSON'ları
/scripts     contributions.py (katkı özeti)
```

**Çalışma düzeni**
- `main` korumalı; doğrudan push yok. Herkes `kisi/ip-konu` dalı açar (örn. `ahmet/ip5-camerax`), PR ile birleştirir, **1 onay** gerekir (kendi PR'ını onaylayamaz). Merge: **squash**, böylece yazar korunur ve geçmiş temiz kalır.
- Commit biçimi: `ip2: omuz ortası normalizasyonu eklendi` (İP numarası öne).
- `CODEOWNERS`: `/ml/extract` → KÜPEL, `/ml/train` → GÖKTEPE, `/app` → ÇELİK; PR'da otomatik inceleyici.
- **Issue = iş birimi**: her issue bir İP etiketi (`ip1`…`ip7`), bir sorumlu, bir kilometre taşı (M0-M7) taşır. GitHub Projects panosu: Yapılacak / Sürüyor / İncelemede / Bitti. Bu plan Bölüm 3-4'ten ilk issue'lar üretilir.
- Büyük dosyalar (video, nokta dizileri, `.tflite` ham sürümleri) repoya girmez; ortak bir Drive/disk klasörü + `docs/data.md` içinde yolu. Sadece son model Release olarak eklenir.

**"Kim ne yaptı?" nasıl görünür**
1. `git shortlog -sne` ve GitHub Insights → Contributors (commit sayısı), PR geçmişi (inceleme dahil).
2. Squash edilmiş PR'lar + issue sorumluları = iş bazında kayıt.
3. `docs/worklog/<ad>.md`: her cuma 5 satır (ne yaptım, ne bloklu). Eğitim koşusu gibi commit'e yansımayan işler için bu şart.
4. `experiments/*.json` ile deney sahipliği.
5. `scripts/contributions.py`: tarih aralığı verince kişi başına commit, PR, kapanan issue ve satır özeti üretir; ara rapor ve tezdeki "iş bölümü" tablosuna bu çıktı girer.

**Haftalık ritim**: Pzt 15 dk kısa durum; Cum danışman toplantısı (PDF'te haftalık ilerleme toplantısı vaat ediliyor) → o hafta kapanan issue'lar ve worklog danışmana gösterilir.

## 7.1 Kayıt: 24 Ekim ilerleme notu

- 10 sınıflık alt küme (ben, sen, evet, hayır, teşekkür, yardım, hastane, doktor, anne, baba) için nokta çıkarımı bitti: train 1.232 / val 195 / test 157 video, hata 0. Ortalama 60,6 kare/video (26-119).
- El bulunma oranı: sol %82, sağ %86; hiç el bulunmayan kare oranı %3,7; gövde noktası her karede bulundu.
- Sol/sağ el etiketi, poz sol/sağ bileğiyle %98 uyumlu (28.689 el-kare). AUTSL videoları aynalanmamış. Telefon ön kamerası görüntüsü aynalı olabilir: Android'de aynı kontrol yapılmadan model kullanılmaz (P-07).

### Telefon hız ölçümü (24 Ekim, Redmi Note 10 Pro / M2101K6G, profil sürümü, arka kamera, 24 Ekim)

Yalnızca MediaPipe el + poz (model henüz yok), kare başına:

| Yapılandırma | FPS | Toplam | El | Poz |
|---|---|---|---|---|
| Debug, CPU, ardışık | ~5 | 200-300 ms | 150-180 | 70-80 |
| Profil, hepsi GPU, paralel | 7 | 120-130 ms | 90-120 | ~100 |
| Profil, mod belirtilmedi (büyük olasılıkla "El GPU / Poz CPU"), paralel | 9 | 110-120 ms | 70-90 | 80-100 |

- Hedef ≥ 15 FPS (Tablo 2) bu telefonda **şu an tutmuyor** (~9 FPS). Ölçümde sınıflandırma modeli yok; modelin kendisi küçük olacağı için asıl yük MediaPipe.
- Sol/sağ el etiketi ve ön kamera denemeleri henüz kayıtlı değil.
- Önlem adayları (denenmedi): pozu 2-3 karede bir çalıştırıp aradakileri ara değerle doldurmak, analiz görüntüsünü küçültmek, el ve poz için bağımsız (eşzamansız) kare akışı. Kare hızı düşük kalırsa **eğitimde zamansal seyreltme artırması** (30 FPS yerine ~10 FPS'e benzer örnekleme) eklenmeli; model zaten sabit 64 kareye yeniden örnekleniyor.
- Karar: 30 Ekim toplantısında "çıkarım hızı hedefin altında, çözüm yolları yukarıda" diye bildirilir; hedef sayısı tezde ölçülen değerle revize edilebilir.

## 8. Ekip kararı bekleyen açık sorular

1. `[?]` Eğitim: WSL2 + TensorFlow mu, PyTorch + `ai-edge-torch` mi (P-02)?
2. `[?]` İP yedekleri ve Küpel'in Hf5 sonrası yeni rolü (Bölüm 3).
3. `[?]` Test telefonu: hangi model, kimin? Ek cihaz var mı?
4. `[?]` Küpel'in GPU'su RTX 5060, 12 GB olarak bildirildi; bilinen RTX 5060 modelleri 8 GB olduğu için `nvidia-smi` çıktısıyla **doğrulanmalı**. Diğer iki üyenin GPU/disk durumu (P-04). Eğitim Küpel'in makinesinde mi çalışacak, Göktepe uzaktan mı bağlanacak?
5. `[?]` Danışmanla 7 Kasım öncesi bir toplantı gerekir mi? (M1 çıktılarını gösterme fırsatı)
6. `[?]` Repo adı ve görünürlüğü; her üyenin GitHub kullanıcı adı.
7. `[?]` Dil: commit/issue Türkçe mi İngilizce mi? (Öneri: kod ve commit İngilizce, belgeler Türkçe.)
