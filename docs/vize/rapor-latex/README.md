# Ara rapor (LaTeX)

Bu klasör, Erciyes Üniversitesi Bilgisayar Mühendisliği bitirme projesi şablonunun
(`erciyes.cls`) ara rapor için düzenlenmiş halidir.

- `thesis.tex` — ana dosya. Sadece kullanılan paketler bırakıldı.
- `chapter1.tex` ... `chapter6.tex` — sırasıyla Özet, Motivasyon, Yenilik,
  Yöntem, Proje Planı, Sonuç.
- `defination.tex` — kapaktaki isimler, danışman, tarih, başlık.
- `referanslar.bib` — kaynaklar (AUTSL ve MediaPipe eklendi).
- `derle.sh` — `pdflatex` + `bibtex` zincirini çalıştırır.

## Derleme

```bash
./derle.sh
```

veya Overleaf'te: yeni proje → bu klasördeki dosyaları yükle → derleyici
**pdfLaTeX** → `thesis.tex` ana dosya.

## Notlar

- Şablon `utf8x`/`T1` kullanıyor, yani pdfLaTeX ile derleniyor. XeLaTeX'e
  geçilirse `erciyes.cls` içindeki `inputenc`/`fontenc` satırlarının
  değiştirilmesi gerekir.
- Tablo ve şekil numaraları `\thetable` / `\thefigure` üzerinden düz sayıya
  çevrildi; şablon bölüm numarası kullanmadığı için aksi halde "Tablo 0.1"
  görünüyordu.
- Yeni bölüm eklerken `\section{...}` kullanın; şablonun kendi başlık düzeni
  `\chapter` ile çalışmıyor.
