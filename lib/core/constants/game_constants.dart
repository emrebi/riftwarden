/// Oyun genelinde sabit, calisma aninda degismeyen degerler.
///
/// Burasi *ayar* dosyasi degildir. Oyuncunun degistirebildigi seyler
/// `data/models/settings`, icerik dengeleme degerleri `assets/content/*.json`
/// icindedir. Buraya sadece motorun yapisal sabitleri girer.
library;

/// Simulasyon sabit adim suresi (saniye). 60 Hz.
///
/// Simulasyon HER ZAMAN bu adimla kosar; ekran kac fps olursa olsun
/// davranis ayni kalir. Render iki adim arasini [BattleSimulation.alpha]
/// ile interpole eder.
const double kFixedTimeStep = 1.0 / 60.0;

/// Bir karede kapatilabilecek maksimum simulasyon adimi.
///
/// Cihaz takildiginda (GC, uygulama arka plandan donduginde) birikmis
/// zamani kovalamaya calisip "olum sarmali"na girmemek icin tavan.
/// Asilan zaman atilir; oyun yavaslar ama donmaz.
const int kMaxStepsPerFrame = 5;

/// Savas alani izotropik motor koordinat uzayi.
///
/// Motor dunyasi y ekseninde [0, 1], x ekseninde [0, kFieldAspect]
/// araligindadir (yukseklik = 1 birim, genislik = 16/9). Boylece bir daire
/// ekranda da daire kalir, elipse donmez (bkz. `FieldProjection` dosya
/// basi yorumu). Icerik JSON'larindaki tum konumlar yine 0..1 yazilir;
/// motor kurulumunda (`BattleWorld.create`) x degerleri bu sabitle
/// carpilir. Piksele cevirme sadece render katmaninda yapilir.
const double kFieldAspect = 16 / 9;
const double kFieldWidth = kFieldAspect;
const double kFieldHeight = 1.0;

/// Birliklerin hedef tazeleme araligi (saniye).
///
/// Her karede hedef aramak pahali. Birlikler `id % kTargetingStagger` ile
/// farkli karelere dagitilir, boylece is yuku duzlesir.
const double kRetargetInterval = 0.1;
const int kTargetingStagger = 6;

/// Spatial hash grid hucre boyutu (normalize birim).
///
/// Kabaca en uzun menzilin ~2 kati olmali: cok kucuk olursa cok hucre
/// taranir, cok buyuk olursa hucre basina cok aday duser. Kale savunmasi
/// kurgusunda savasci menzilleri yuvadan sinira kadar uzaniyor (0.7-1.3
/// yukseklik birimi), bu yuzden deger 0.08'den 0.25'e cikarildi.
const double kSpatialCellSize = 0.25;

/// Tek bir spatial sorgunun dondurebilecegi maksimum aday sayisi.
/// Scratch buffer boyutu; asilirsa sonuc kirpilir (davranis bozulmaz).
const int kMaxQueryResults = 256;

/// Ayni anda sahada bulunabilecek maksimum dost birlik.
///
/// Neden level config'de degil: dusman sayisini dalga tasarimi belirler
/// (bu yuzden `LevelConfig.maxEnemies` var), ama birlik sayisini oyuncunun
/// Aether harcamasi belirler — level'a gore degismez, motor geneli bir
/// tavandir.
///
/// Deger secimi: "swarm army" build'i ucuz birlikten cok sayida uretmek
/// uzerine kurulu; upgrade'lerle maliyet dustugunde oyuncu bu tavana
/// yaklasabilmeli, yoksa build'in vaadi tutmaz.
const int kUnitPoolCapacity = 128;

/// HUD'a surekli degerlerin (Aether, Core HP) gonderilme araligi (saniye).
///
/// Kesikli olaylar (upgrade teklifi, boss girisi, level sonu) bu
/// throttle'a tabi DEGILDIR, aninda gonderilir.
const double kHudThrottleInterval = 0.1;

/// Ayni anda alanda bulunabilecek maksimum gorsel efekt (parcacik, hasar
/// sayisi, patlama) sayisi.
///
/// Deger secimi: en yogun senaryo, `kUnitPoolCapacity` (128) birligin ayni
/// anda ates etmesiyle olusan vurus kivilcimlaridir; buna dusman olum
/// efektleri (deathPuff + aetherMote, dusman basina iki parcacik) eklenir.
/// 256, bu iki kaynagi rahat karsilar; havuz yine de dolarsa `emitEffect`
/// sessizce atlar (bkz. `EntityPool.spawn` sozlesmesi) — en yogun anda bir
/// iki parcacigin kaybolmasi oynanisi etkilemez, sadece gorseldir.
const int kEffectPoolCapacity = 256;

/// Upgrade karti acilirken uygulanan slow-motion rampasi (saniye) ve
/// rampa sonundaki zaman olcegi. Rampa bitince oyun tam pause olur.
const double kUpgradeSlowMoRamp = 0.15;
const double kUpgradeSlowMoScale = 0.15;

/// Savas basina ucretsiz esik karti reroll hakki.
///
/// Odullu reklamla artacak (adim 18, bkz. `UpgradeSystem`/`BattleController`
/// yorumlari); simdilik sabit 1.
const int kFreeRerollsPerBattle = 1;
