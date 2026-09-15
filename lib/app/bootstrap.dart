import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:riftwarden/content/loader/content_loader.dart';
import 'package:riftwarden/content/registry/content_registry.dart';
import 'package:riftwarden/core/services/audio_service.dart';
import 'package:riftwarden/core/services/haptic_service.dart';
import 'package:riftwarden/core/services/orientation_service.dart';
import 'package:riftwarden/core/services/storage_service.dart';

/// [bootstrap] ciktisi: acilista kurulmus, senkron erisilmesi gereken
/// servisler.
///
/// Bunlar `main()` icinde `ProviderScope.overrides` listesine cevrilir.
/// Neden dogrudan `List<Override>` donmuyoruz: Riverpod 3'te `Override`
/// tipi public API'dan cikarildi; override listesi `ProviderScope`
/// cagrisinda yerinde kurulur ve tip cikarimi halleder.
class BootstrapResult {
  const BootstrapResult({
    required this.storage,
    required this.audio,
    required this.haptics,
    required this.orientation,
    required this.content,
  });

  final StorageService storage;
  final AudioService audio;
  final HapticService haptics;
  final OrientationService orientation;
  final ContentRegistry content;

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

  // Acilista dikey de serbest: manifest fullUser, plist portrait+landscape.
  // Yon kapisi (orientation_gate) telefon yatirilinca ya da 10 sn dolunca
  // OrientationService.lockLandscape() ile yataya kilitler.
  final orientation = OrientationService();
  await orientation.allowPortraitAndLandscape();

  // Tam ekran: sistem cubuklari gizli, kenardan cekilince geri gelir.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Sira onemli: audio ve haptics acilis tercihini storage'dan okur.
  final storage = await StorageService.init();

  final audio = AudioService();
  await audio.init(storage);

  final haptics = HapticService();
  await haptics.init(storage);

  // Icerik dosyalari bozuksa oyun zaten oynanamaz; acilista yuklenip
  // erken patlamasi, oyun ici belirsiz bir crash'ten daha iyidir.
  final content = await const ContentLoader().load();

  // TODO(adim 17): SaveRepository.load()
  // TODO(adim 18): AdService.initialize()  -- BLOKLAMADAN (unawaited)
  // TODO(adim 19): IapService.connect()    -- BLOKLAMADAN (unawaited)

  return BootstrapResult(
    storage: storage,
    audio: audio,
    haptics: haptics,
    orientation: orientation,
    content: content,
  );
}
