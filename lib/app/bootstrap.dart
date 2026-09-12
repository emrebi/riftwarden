import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// [bootstrap] ciktisi: acilista kurulmus, senkron erisilmesi gereken
/// servisler.
///
/// Bunlar `main()` icinde `ProviderScope.overrides` listesine cevrilir.
/// Neden dogrudan `List<Override>` donmuyoruz: Riverpod 3'te `Override`
/// tipi public API'dan cikarildi; override listesi `ProviderScope`
/// cagrisinda yerinde kurulur ve tip cikarimi halleder.
class BootstrapResult {
  const BootstrapResult();

  // TODO(adim 3): final SharedPreferences preferences;
  // TODO(adim 6): final ContentRegistry content;
  // TODO(adim 17): final SaveGame save;
}

/// Uygulama baslatma sirasi.
///
/// ## Kural: sira onemlidir, tek yerde durur
/// Yeni bir servis eklenecekse baslatmasi BURAYA girer, `main()`e veya
/// rastgele bir widget'in `initState`ine degil. Boylece acilis maliyeti
/// ve bagimlilik sirasi tek dosyadan gorulur.
///
/// ## Kural: acilisi bloklama
/// Sadece ILK KARE icin gercekten gerekli olanlar burada `await` edilir
/// (kayit dosyasi, icerik, dil). Reklam SDK'si ve IAP baglantisi
/// **bloklamaz** — bunlar ilk kareden sonra arka planda isinir, cunku ag
/// beklemek acilis suresini olculebilir sekilde uzatir.
Future<BootstrapResult> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait kilidi. Oyun yalnizca dikey calisir; manifest/plist tarafinda
  // da kilitli ama uygulama ici gecisler icin burasi da gerekli.
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  // Tam ekran: sistem cubuklari gizli, kenardan cekilince geri gelir.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // TODO(adim 3):  StorageService.init()
  // TODO(adim 3):  AudioService.init()
  // TODO(adim 6):  ContentRegistry.load()
  // TODO(adim 17): SaveRepository.load()
  // TODO(adim 18): AdService.initialize()  -- BLOKLAMADAN (unawaited)
  // TODO(adim 19): IapService.connect()    -- BLOKLAMADAN (unawaited)

  return const BootstrapResult();
}
