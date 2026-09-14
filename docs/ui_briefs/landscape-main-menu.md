# GOREV: ANA MENUYU YATAYA UYARLA

Once AGENTS.md dosyasini oku. Uygulama artik YATAY. Hedef en kucuk ekran 640x360 dp.

Dosyalar: lib/features/main_menu/view/main_menu_screen.dart ve lib/features/main_menu/widgets/
MainMenuScreen'in public constructor'u DEGISMEZ.

Yeni yerlesim:
- Sol yarim: logo, alt baslik (menuSubtitle) ve sektor/level ilerleme paneli.
- Sag yarim: en baskin oge PLAY butonu; altinda STORE, UPGRADES ve SETTINGS eylemleri.
- Sag ust: Shard ve Cell para gostergeleri.
- 360 dp yukseklikte hicbir sey tasmamali. Logo boyutunu yuksekligi asmayacak sekilde olcekle.
- MediaQuery.viewPadding.left/right uygulanmali.

Kurallar:
- PLAY tartismasiz en baskin oge olarak kalmali.
- Mevcut animasyonlar (logo belirme, PLAY nabzi) korunur.
- lib/shared/widgets ve lib/app/theme dosyalarina dokunma. Terminal calistirma.
- Yeni metin gerekirse sadece app_en.arb dosyasina ekle.

Kabul: flutter analyze 0 issue; ui_lint TEMIZ. Rapor: AGENTS.md formati.
