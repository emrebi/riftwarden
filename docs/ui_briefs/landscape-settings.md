# GOREV: AYARLAR EKRANINI YATAYA UYARLA

Once AGENTS.md dosyasini oku. Uygulama artik YATAY. Hedef en kucuk ekran 640x360 dp.

Dosyalar: lib/features/settings/view/settings_screen.dart ve lib/features/settings/widgets/
SettingsScreen'in public constructor'u DEGISMEZ.

Yeni yerlesim:
- Iki sutun: sol sutunda SES paneli; sag sutunda DIL ve HESAP panelleri.
- Yukseklik 360 dp oldugu icin her sutun kendi icinde dikey kaydirilabilir olmali.
- Surum etiketi sag sutunun en altinda.
- Baslik ve geri butonu ustte, ince bir seritte.
- MediaQuery.viewPadding.left/right uygulanmali.

Kurallar:
- lib/shared/widgets ve lib/app/theme dosyalarina dokunma. Terminal calistirma.
- Yeni metin gerekirse sadece app_en.arb dosyasina ekle.

Kabul: flutter analyze 0 issue; ui_lint TEMIZ. Rapor: AGENTS.md formati.
