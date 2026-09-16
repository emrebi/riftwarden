import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';

/// Savas/sahne uzerine karartma + hafif doygunluk dusurme katmani.
///
/// DESIGN §13 "darkened, slightly desaturated veil": upgrade overlay
/// (BATTLE-01) ve pause (BATTLE-08) sahneyi tamamen gizlemez, context olarak
/// gorunur kalmasini ister. `child` verilirse veil'in ustunde oldugu gibi
/// (ortalanmadan) dizilir; `null` ise sadece karartma katmani gosterilir.
class RwVeil extends StatelessWidget {
  const RwVeil({
    super.key,
    this.child,
    this.dim = 0.55,
    this.desaturate = 0.35,
    this.onTap,
  });

  /// Veil'in ustunde duran icerik (orn. upgrade karti satiri).
  final Widget? child;

  /// Karartma opaklik miktari (0..1).
  final double dim;

  /// Doygunluk dusurme miktari (0..1). 0 ise `BackdropFilter` hic eklenmez.
  final double desaturate;

  /// Bos alana dokunma geri cagrisi. `null` olsa dahi dokunmalar yutulur ki
  /// altta kalan sahneye gecmesin.
  final VoidCallback? onTap;

  /// Doygunluk azaltma matrisi: kimlik matrisi ile gri tonlama (luminance)
  /// matrisi arasinda `desaturate` orani ile lerp. Build'de bir kez
  /// hesaplanir, `step()` disinda oldugundan allocation kisitlamasina
  /// takilmaz.
  List<double> _desaturationMatrix() {
    // ITU-R BT.709 luminance agirliklari.
    const double lr = 0.2126;
    const double lg = 0.7152;
    const double lb = 0.0722;
    final double t = desaturate.clamp(0.0, 1.0);
    final double it = 1.0 - t;

    double mix(double identity, double gray) => identity * it + gray * t;

    return <double>[
      mix(1.0, lr), mix(0.0, lg), mix(0.0, lb), 0.0, 0.0, //
      mix(0.0, lr), mix(1.0, lg), mix(0.0, lb), 0.0, 0.0, //
      mix(0.0, lr), mix(0.0, lg), mix(1.0, lb), 0.0, 0.0, //
      0.0, 0.0, 0.0, 1.0, 0.0,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final Widget dimLayer = ColoredBox(
      color: AppColors.hudEdge.withValues(alpha: dim),
    );

    final Widget layer = desaturate <= 0.0
        ? dimLayer
        : ClipRect(
            child: BackdropFilter(
              // `ColorFilter` dart:ui'de `ImageFilter`i implemente eder;
              // ekstra bulaniklastirma olmadan dogrudan matris uygulanir.
              filter: ColorFilter.matrix(_desaturationMatrix()),
              child: dimLayer,
            ),
          );

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ExcludeSemantics(
            child: GestureDetector(
              onTap: onTap ?? () {},
              behavior: HitTestBehavior.opaque,
              child: layer,
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}
