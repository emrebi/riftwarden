import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';

/// Yataya cevirme animasyonlu telefon silueti ve yon oku.
///
/// Oyuncuya cihazi dikeyden saga 90 derece yatay konuma cevirmesi gerektigini
/// anlatan gorsel gosterge. Resim asset'i yerine hafif CustomPaint ile cizilir.
class RotatingPhoneIndicator extends StatelessWidget {
  const RotatingPhoneIndicator({
    required this.animation,
    super.key,
  });

  /// Dikeyden (0) yataya (pi/2) donus acisini veren animasyon.
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size.square(AppSpacing.xxxl * 2),
          painter: _PhoneIndicatorPainter(angle: animation.value),
        );
      },
    );
  }
}

/// Telefon silueti ve kavisli donus okunu cizen ressam.
class _PhoneIndicatorPainter extends CustomPainter {
  const _PhoneIndicatorPainter({required this.angle});

  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Kavisli donus oku: telefonun ust-saginda saat yonunde donus yayini gosterir.
    final arrowRadius = size.width * 0.42;
    const startAngle = -math.pi * 0.42;
    const sweepAngle = math.pi * 0.38;
    const endAngle = startAngle + sweepAngle;

    final endPoint = Offset(
      center.dx + arrowRadius * math.cos(endAngle),
      center.dy + arrowRadius * math.sin(endAngle),
    );

    // Ok ucu tegeti: yayin bitis noktasinda saat yonunde ileri bakar.
    const tangentAngle = endAngle + math.pi / 2;
    const arrowHeadLength = 7.0;
    const spreadAngle = 0.5;

    final wing1 = Offset(
      endPoint.dx - arrowHeadLength * math.cos(tangentAngle - spreadAngle),
      endPoint.dy - arrowHeadLength * math.sin(tangentAngle - spreadAngle),
    );
    final wing2 = Offset(
      endPoint.dx - arrowHeadLength * math.cos(tangentAngle + spreadAngle),
      endPoint.dy - arrowHeadLength * math.sin(tangentAngle + spreadAngle),
    );

    final arrowPath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: arrowRadius),
        startAngle,
        sweepAngle,
      )
      ..moveTo(wing1.dx, wing1.dy)
      ..lineTo(endPoint.dx, endPoint.dy)
      ..lineTo(wing2.dx, wing2.dy);

    // Ok parlama katmani
    final arrowGlowPaint = Paint()
      ..color = AppColors.aetherCyanDim.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.drawPath(arrowPath, arrowGlowPaint);

    // Ok keskin hat katmani
    final arrowPaint = Paint()
      ..color = AppColors.aetherCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(arrowPath, arrowPaint);

    // Telefon silueti: merkez etrafinda dikeyden saga 90 derece doner.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final phoneRect = Rect.fromCenter(
      center: Offset.zero,
      width: 34.0,
      height: 58.0,
    );
    final phoneRRect = RRect.fromRectAndRadius(
      phoneRect,
      const Radius.circular(AppRadius.md),
    );

    // Telefon arka plan yuzey dolgusu
    final bodyFillPaint = Paint()
      ..color = AppColors.surfaceRaised.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(phoneRRect, bodyFillPaint);

    // Telefon kenar parlamasi
    final bodyGlowPaint = Paint()
      ..color = AppColors.aetherCyanDim.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawRRect(phoneRRect, bodyGlowPaint);

    // Telefon cerceve hatti
    final bodyOutlinePaint = Paint()
      ..color = AppColors.aetherCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(phoneRRect, bodyOutlinePaint);

    // Holografik ic ekran alani
    final screenRect = Rect.fromCenter(
      center: Offset.zero,
      width: 26.0,
      height: 40.0,
    );
    final screenRRect = RRect.fromRectAndRadius(
      screenRect,
      const Radius.circular(AppRadius.sm),
    );
    final screenFillPaint = Paint()
      ..color = AppColors.aetherCyan.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(screenRRect, screenFillPaint);

    final screenBorderPaint = Paint()
      ..color = AppColors.aetherCyanDim.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(screenRRect, screenBorderPaint);

    // Ust hoparlor yarik gostergesi
    final speakerRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: const Offset(0.0, -23.0),
        width: 10.0,
        height: 2.0,
      ),
      const Radius.circular(AppRadius.pill),
    );
    final speakerPaint = Paint()
      ..color = AppColors.aetherCyanDim
      ..style = PaintingStyle.fill;
    canvas.drawRRect(speakerRRect, speakerPaint);

    // Alt navigasyon cizgisi
    final homeRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: const Offset(0.0, 23.0),
        width: 12.0,
        height: 2.0,
      ),
      const Radius.circular(AppRadius.pill),
    );
    final homePaint = Paint()
      ..color = AppColors.aetherCyanDim
      ..style = PaintingStyle.fill;
    canvas.drawRRect(homeRRect, homePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PhoneIndicatorPainter oldDelegate) =>
      oldDelegate.angle != angle;
}
