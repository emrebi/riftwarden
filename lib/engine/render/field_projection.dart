import 'package:flame/components.dart' show Vector2;

/// Normalize (0..1) savas alani koordinatini ekran pikseline cevirir.
///
/// Tum icerik ve simulasyon durumu (`kFieldWidth`/`kFieldHeight` = 1.0
/// uzayinda, bkz. `game_constants.dart`) cihaz boyutundan bagimsiz yazilir.
/// Piksele cevirme SADECE bu sinifta yapilir.
///
/// ## Konum: neden X ve Y BAGIMSIZ olceklenir
/// `screenX = x * size.x`, `screenY = y * size.y`. Yani alan ekrana
/// **yayilir**: portre modda cihazlar farkli en-boy oranina sahiptir ve
/// alanin tum genislik/yuksekligi HER ZAMAN doldurulmasi istenir (letterbox
/// yok). Icerik 0..1 uzayinda yazildigi icin bu esneme kasitlidir — bir
/// rift veya lane waypoint'i her cihazda "ayni orantisal yerde" kalir.
///
/// ## Boyut: neden TEK olcek kullanilir
/// Yaricap, sprite olcegi gibi BOYUT degerleri konum GIBI ayri
/// olceklenirse, kare bir sprite genis/dar ekranlarda ELIPSE doner ve
/// daire seklindeki carpisma alanlari gorsel olarak carpismaz. Bu yuzden
/// TUM boyut donusumleri [toScreenSize] uzerinden TEK bir eksene
/// (`size.x`) dayanir. Genis ekranlarda bu biraz daha kucuk sprite demek
/// olabilir ama sekil hep dogru kalir — bu tercih edilen taviz budur.
class FieldProjection {
  FieldProjection(this.size);

  /// Guncel ekran boyutu (piksel). `RiftwardenGame.onGameResize` ile
  /// guncellenir; render sicak yolu bunu SADECE okur.
  Vector2 size;

  /// Normalize X -> ekran pikseli.
  double toScreenX(double normalizedX) => normalizedX * size.x;

  /// Normalize Y -> ekran pikseli.
  double toScreenY(double normalizedY) => normalizedY * size.y;

  /// Yaricap/olcek gibi BOYUT degerleri icin ekran pikseli. Daima
  /// [size]'in X bilesenine dayanir (bkz. dosya basi "Boyut" yorumu).
  double toScreenSize(double normalizedSize) => normalizedSize * size.x;

  /// Iki simulasyon adimi arasindaki konumu [alpha] ile interpole eder
  /// (bkz. `BattleSimulation.alpha` dosya basi yorumu). Sicak yolda
  /// cagrilir; sadece skaler aritmetik icerir, allocation yapmaz.
  double lerp(double prev, double current, double alpha) =>
      prev + (current - prev) * alpha;
}
