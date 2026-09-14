# GOREV: LEVEL SECIMI YATAY HARITAYA DONUSTUR

Once AGENTS.md dosyasini oku. Uygulama artik YATAY. Hedef en kucuk ekran 640x360 dp.

Dosyalar: lib/features/level_select/view/level_select_screen.dart ve lib/features/level_select/widgets/
(sector_card, level_node, node_connector). LevelSelectScreen'in public constructor'u ve
level_select_data.dart dosyasindaki veri tipleri DEGISMEZ.

Yeni yerlesim: oyuncu soldan saga, boyutlar arasinda ilerleyen bir harita.
- Sektorler SOLDAN SAGA dizilir; ListView.builder ile scrollDirection: Axis.horizontal.
- Her sektor bir kart; icinde 5 level dugumu ve aralarinda baglantilar.
- Kart yuksekligi 360 dp'ye sigmali.
- Acilista `current` dugumun bulundugu sektor gorunur alanda olmali (ScrollController ile konumla).
- Nabiz animasyonu SADECE current dugumde calisir.
- Boss dugumleri gorsel olarak farkli kalir.
- Ust ince seritte geri butonu ve Shard gostergesi; MediaQuery.viewPadding.left/right uygulanmali.

Kurallar:
- lib/shared/widgets ve lib/app/theme dosyalarina dokunma. Terminal calistirma.
- Yeni metin gerekirse sadece app_en.arb dosyasina ekle.

Kabul: flutter analyze 0 issue; ui_lint TEMIZ. Rapor: AGENTS.md formati.
