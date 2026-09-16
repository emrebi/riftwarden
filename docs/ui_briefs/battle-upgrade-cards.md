# GOREV: ESIK KARTI SECIM KATMANI

Once AGENTS.md dosyasini oku. Uygulama YATAY. Hedef en kucuk ekran 640x360 dp.

Once su dosyalari da oku:
- lib/engine/bridge/battle_signals.dart — `upgradeOffer` (UpgradeOffer?: upgradeIds, rerollsLeft)
  ve BattleCommands.chooseUpgrade / rerollUpgrades
- lib/features/battle/viewmodel/upgrade_text.dart — kart basligi, aciklamasi, nadirlik etiketi (DOKUNMA, sadece kullan)
- lib/content/schema/upgrade_config.dart — UpgradeConfig (rarity, family)
- lib/features/battle/view/battle_screen.dart

Dosyalar: yeni lib/features/battle/widgets/upgrade_card_overlay.dart ve battle_screen.dart'a baglanti.

DEGISMEYECEKLER:
- body Stack'teki fit: StackFit.expand, GameWidget errorBuilder/loadingBuilder, BattleScreen public constructor'u.
- Nisan alma katmani ve yetenek dukkani paneli davranisi.

Davranis ve yerlesim:
- signals.upgradeOffer'i ValueListenableBuilder ile dinle. null -> hicbir sey cizme. Dolu -> tam ekran katman.
- Arkada savas alanini karartan yari saydam perde (oyun gorunur kalsin).
- Ustte upgradeChooseTitle.
- Ortada yan yana 3 kart (1-2 kart gelirse ortali). 360 dp yukseklikte tasmadan sigmali.
- Kart: nadirlik rengiyle kenar ve ust serit + rarityLabel; baslik (upgradeTitle); aciklama (upgradeDescription, en fazla 3 satir).
  Nadirlik renkleri: common notr, rare cyan, epic menekse, legendary kehribar. AppColors'ta yoksa yeni token ekle.
- Kartlar alttan yukari kisa animasyonla gelir (<= 300 ms, sirayla hafif gecikme). Zorunlu bekleme yok: animasyon
  bitmeden de dokunulabilir.
- Karta dokununca commands.chooseUpgrade(id).
- Altta reroll butonu: upgradeReroll + upgradeRerollsLeft(count). rerollsLeft == 0 ise pasif gorunur. commands.rerollUpgrades().
- Kart id -> UpgradeConfig icin battle_screen'deki content'i (initState'te zaten ref.read ile alinmis) parametre olarak ver;
  widget provider okumaz.
- Pause butonu teklif acikken islevsiz olabilir; pause katmani kart katmaninin USTUNDE cizilmeli.
- MediaQuery.viewPadding uygula; tam ekran SafeArea KULLANMA.

Kurallar: ref.watch/listen yok; ham renk/fontSize yok; EdgeInsetsDirectional; lib/engine, lib/shared/widgets
ve viewmodel dosyalarina dokunma; terminal komutu calistirma. Yeni metin gerekirse sadece app_en.arb.

Kabul: flutter analyze 0 issue; ui_lint TEMIZ; 640x360'ta tasma yok. Rapor: AGENTS.md formati.
