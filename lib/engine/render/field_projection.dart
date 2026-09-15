import 'package:flame/components.dart' show Vector2;
import 'package:riftwarden/core/constants/game_constants.dart';

/// Izotropik motor koordinatini (y 0..1, x 0..`kFieldAspect`) ekran
/// pikseline cevirir.
///
/// ## Neden izotropik
/// Motor dunyasi artik x/y'yi bagimsiz olceklemez: yukseklik HER ZAMAN 1
/// birim, genislik HER ZAMAN `kFieldAspect` (16/9) birimdir. Ekrana
/// cevirirken TEK olcek (`scale = size.y`) kullanilir; alan ekranin
/// ortasina yerlestirilir, artan yatay bosluk (`offsetX`) iki yana esit
/// dagilir (letterbox). Boylece ekranda cizilen bir daire oyun
/// mantigindaki bir daireyle BIREBIR ortusur (genis/dar ekranlarda
/// elipse donmez) ve kale hicbir zaman centik/kenar tarafindan kesilmez.
///
/// Piksele cevirme SADECE bu sinifta yapilir; icerik ve simulasyon durumu
/// cihaz boyutundan bagimsiz yazilir.
class FieldProjection {
  FieldProjection(this.size);

  /// Guncel ekran boyutu (piksel). `RiftwardenGame.onGameResize` ile
  /// guncellenir; render sicak yolu bunu SADECE okur.
  Vector2 size;

  /// Tum eksenler icin TEK olcek: alan yuksekligi ekran yuksekligine
  /// esitlenir. Boyut donusumleri (yaricap, sprite olcegi) de bu degere
  /// dayanir ki sekiller genis/dar ekranlarda BOZULMASIN.
  double get scale => size.y;

  /// Alan genisligi (`kFieldAspect * scale`) ekran genisliginden dar
  /// kaldiginda arta kalan yatay bosluk, iki yana esit dagitilir.
  double get offsetX => (size.x - kFieldAspect * scale) / 2;

  /// Normalize (izotropik) X -> ekran pikseli.
  double toScreenX(double normalizedX) => normalizedX * scale + offsetX;

  /// Normalize (izotropik) Y -> ekran pikseli.
  double toScreenY(double normalizedY) => normalizedY * scale;

  /// Yaricap/olcek gibi BOYUT degerleri icin ekran pikseli.
  double toScreenSize(double normalizedSize) => normalizedSize * scale;

  /// Ekran-normalize (0..1, ekranin kendi genisligine gore) X -> izotropik
  /// dunya X'i. `BattleController.castAbilityAt` gibi UI'dan gelen dokunma
  /// koordinatlari EKRAN-normalizedir (ekranin genisligine gore 0..1);
  /// bu yuzden once piksele, sonra letterbox/olcek geri alinarak dunya
  /// koordinatina cevrilir (bkz. sinif dosya basi yorumu).
  double toWorldX(double normalizedScreenX) =>
      (normalizedScreenX * size.x - offsetX) / scale;

  /// Ekran-normalize (0..1, ekranin kendi yuksekligine gore) Y -> izotropik
  /// dunya Y'si. Y'de letterbox olmadigi icin sadece olcek geri alinir.
  double toWorldY(double normalizedScreenY) => normalizedScreenY * size.y / scale;

  /// Iki simulasyon adimi arasindaki konumu [alpha] ile interpole eder
  /// (bkz. `BattleSimulation.alpha` dosya basi yorumu). Sicak yolda
  /// cagrilir; sadece skaler aritmetik icerir, allocation yapmaz.
  double lerp(double prev, double current, double alpha) =>
      prev + (current - prev) * alpha;
}
