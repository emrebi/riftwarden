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

/// Savas alani normalize koordinat uzayi.
///
/// Tum icerik JSON'lari (rift konumlari, lane waypoint'leri) 0..1 arasinda
/// tanimlanir. Boylece icerik ekran boyutundan tamamen bagimsizdir.
/// Piksele cevirme sadece render katmaninda yapilir.
const double kFieldWidth = 1.0;
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
/// taranir, cok buyuk olursa hucre basina cok aday duser.
const double kSpatialCellSize = 0.08;

/// Tek bir spatial sorgunun dondurebilecegi maksimum aday sayisi.
/// Scratch buffer boyutu; asilirsa sonuc kirpilir (davranis bozulmaz).
const int kMaxQueryResults = 256;

/// HUD'a surekli degerlerin (Aether, Core HP) gonderilme araligi (saniye).
///
/// Kesikli olaylar (upgrade teklifi, boss girisi, level sonu) bu
/// throttle'a tabi DEGILDIR, aninda gonderilir.
const double kHudThrottleInterval = 0.1;

/// Upgrade karti acilirken uygulanan slow-motion rampasi (saniye) ve
/// rampa sonundaki zaman olcegi. Rampa bitince oyun tam pause olur.
const double kUpgradeSlowMoRamp = 0.15;
const double kUpgradeSlowMoScale = 0.15;
