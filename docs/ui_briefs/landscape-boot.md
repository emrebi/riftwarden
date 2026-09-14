# GOREV: BOOT EKRANINI YATAYA UYARLA

Once AGENTS.md dosyasini oku; yatay kurallar guncellendi. Uygulama artik YATAY calisiyor. Hedef en kucuk ekran 640x360 dp.

Dosya: lib/features/boot/view/boot_screen.dart
Bu ekran gecici gelistirici menusu. Su an dar dikey bir kolon; 360 dp yukseklikte tasiyor.

Yeni yerlesim:
- Sol yarim: RIFTWARDEN basligi ve altinda "Loading" metni, dikeyde ortali.
- Sag yarim: mevcut butonlar 2 sutunlu grid halinde, dikeyde kaydirilabilir.
- MediaQuery.viewPadding.left/right uygulanmali.

Kurallar:
- Butonlarin davranisini, navigasyonunu ve ornek verilerini DEGISTIRME. Sadece yerlesim.
- lib/shared/widgets ve lib/app/theme dosyalarina dokunma.
- Terminal komutu calistirma.
- Yeni metin gerekirse sadece lib/l10n/arb/app_en.arb dosyasina ekle.

Kabul: flutter analyze 0 issue; python tools/ui_lint.py TEMIZ; 640x360'ta tasma yok.
Rapor: AGENTS.md rapor formati.
