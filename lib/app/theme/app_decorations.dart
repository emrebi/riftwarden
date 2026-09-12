import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';

/// Tekrar eden gorsel dokular icin gradyan token'lari.
abstract final class AppGradients {
  /// Sayfa arka plani: merkezden disari derin void tonlari.
  static const RadialGradient screenBackground = RadialGradient(
    center: Alignment(0.0, -0.35),
    radius: 1.2,
    colors: <Color>[
      AppColors.surface,
      AppColors.voidBase,
      AppColors.voidDeep,
    ],
    stops: <double>[0.0, 0.55, 1.0],
  );

  /// Panel ve kart yuzeyleri icin ustten alta hafif ton gecisi.
  static const LinearGradient panel = LinearGradient(
    begin: AlignmentDirectional.topCenter,
    end: AlignmentDirectional.bottomCenter,
    colors: <Color>[
      AppColors.surfaceRaised,
      AppColors.surface,
    ],
  );

  /// Ana eylem butonu: cyan enerji gradyani.
  static const LinearGradient primaryButton = LinearGradient(
    begin: AlignmentDirectional.topCenter,
    end: AlignmentDirectional.bottomCenter,
    colors: <Color>[
      AppColors.aetherCyan,
      AppColors.coreTeal,
    ],
  );

  /// Tehlike ve iptal butonu: kirmizi ve macenta tonlari.
  static const LinearGradient dangerButton = LinearGradient(
    begin: AlignmentDirectional.topCenter,
    end: AlignmentDirectional.bottomCenter,
    colors: <Color>[
      AppColors.danger,
      AppColors.riftMagenta,
    ],
  );
}

/// Arayuz golge ve parlama token'lari.
abstract final class AppShadows {
  /// Enerji parlamasi: verilen renkte yumusak dis isik.
  static List<BoxShadow> glow(
    Color color, {
    double blurRadius = 16.0,
    double spreadRadius = 0.0,
  }) =>
      <BoxShadow>[
        BoxShadow(
          color: color.withValues(alpha: 0.4),
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        ),
      ];

  /// Yukseltilmis paneller icin derin zemin golgesi.
  static const List<BoxShadow> panel = <BoxShadow>[
    BoxShadow(
      color: AppColors.voidDeep,
      blurRadius: 16.0,
      offset: Offset(0.0, 8.0),
    ),
  ];
}

/// Kenarlik token'lari.
abstract final class AppBorders {
  /// Paneller ve kartlar icin ince ayirici kenarlik.
  static const Border subtle = Border.fromBorderSide(
    BorderSide(
      color: AppColors.surfaceRaised,
      width: 1.0,
    ),
  );

  /// Vurgu rengine sahip kenarlik.
  static Border accent(Color color, {double width = 1.0}) =>
      Border.fromBorderSide(
        BorderSide(
          color: color,
          width: width,
        ),
      );
}

/// Kose yaricaplari icin hazir BorderRadius token'lari.
abstract final class AppBorderRadii {
  static const BorderRadius sm = BorderRadius.all(
    Radius.circular(AppRadius.sm),
  );
  static const BorderRadius md = BorderRadius.all(
    Radius.circular(AppRadius.md),
  );
  static const BorderRadius lg = BorderRadius.all(
    Radius.circular(AppRadius.lg),
  );
  static const BorderRadius xl = BorderRadius.all(
    Radius.circular(AppRadius.xl),
  );
  static const BorderRadius pill = BorderRadius.all(
    Radius.circular(AppRadius.pill),
  );
}
