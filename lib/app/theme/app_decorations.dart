import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';

/// Sus (dekorasyon) token'lari.
///
/// ## Sozlesme
/// Gorsel otorite `docs/DESIGN.md`. Yorumlar Turkce ASCII; neden var
/// oldugunu aciklar, ne oldugunu degil (kod zaten okunabiliyor).
///
/// ## Malzeme yonu (DESIGN §3, §8)
/// El yapimi cizgi film yonu dort malzeme uzerinden kurulur: `AppMaterial`
/// ve `AppMaterials` bu malzemelerin yuzey/kenar/metin renklerini verir.
/// Sonraki bilesenler (RwMaterialSurface, butonlar, paneller) bu API'yi
/// kullanacak; bu dosyadaki degisiklik saf ekleme, mevcut cagrilar bozulmaz.
///
/// Riftwarden'daki dort yuzey malzemesi (DESIGN §3, §8).
enum AppMaterial {
  /// Okuma agirlikli panel govdeleri, aciklamalar, upgrade metinleri.
  parchment,

  /// Ana navigasyon, buyuk CTA cercevesi, yukleme rayi, yapisal kirisler.
  wood,

  /// Kale bagli slotlar, yetenek cerceveleri, kilitli/dayaniklilik durumu.
  stone,

  /// Savas sanati uzerinde kontrast koruyan koyu-notr HUD yuzeyi.
  hud,
}

/// Arayuz golge ve parlama token'lari.
abstract final class AppShadows {
  /// Normal durum: dar, sicak temas golgesi (DESIGN §21 "narrow dark
  /// contact shadow"). Deger baslangic noktasi, cihazda tune edilecek.
  static const List<BoxShadow> contact = <BoxShadow>[
    BoxShadow(
      color: AppColors.shadowWarm,
      blurRadius: 2.0,
      offset: Offset(0.0, 1.0),
    ),
  ];

  /// Yukseltilmis durum: 2-4 dp kalkis hissi icin alt kenarda guclu golge
  /// (DESIGN §21 "2-4 dp visual lift"). Deger baslangic noktasi, cihazda
  /// tune edilecek.
  static const List<BoxShadow> raised = <BoxShadow>[
    BoxShadow(
      color: AppColors.shadowWarm,
      blurRadius: 4.0,
      offset: Offset(0.0, 3.0),
    ),
  ];

  /// Basili durum: golge azalir, yuzey geri cekilmis gibi gorunur
  /// (DESIGN §21 "reduced/removed lower shadow"). Deger baslangic
  /// noktasi, cihazda tune edilecek.
  static const List<BoxShadow> pressed = <BoxShadow>[
    BoxShadow(
      color: AppColors.shadowWarm,
      blurRadius: 1.0,
      offset: Offset(0.0, 1.0),
    ),
  ];

  /// Aether/Rift gibi enerji vurgulari icin dar kenar isigi. Genis panel
  /// parlamasi DEGIL — DESIGN §21 "tight cyan edge light... never a broad
  /// panel glow" kuralini korur. Deger baslangic noktasi, cihazda tune
  /// edilecek.
  static List<BoxShadow> energy(Color color) => <BoxShadow>[
        BoxShadow(
          color: color.withValues(alpha: 0.35),
          blurRadius: 6.0,
          spreadRadius: 0.0,
        ),
      ];
}

/// Kenarlik token'lari.
abstract final class AppBorders {
  /// Vurgu rengine sahip kenarlik.
  static Border accent(Color color, {double width = 1.0}) =>
      Border.fromBorderSide(
        BorderSide(
          color: color,
          width: width,
        ),
      );
}

/// `AppMaterial` icin yuzey/kenar/metin renkleri ve ortak kenarlik
/// agirliklari (DESIGN §3 "repeated outlines share a small set of
/// weights"). Saf, allocation-free statik yardimcilar; her cagri sadece
/// mevcut `const` renk token'ini dondurur.
abstract final class AppMaterials {
  /// Malzeme yuzey (dolgu) rengi.
  static Color face(AppMaterial m) => switch (m) {
        AppMaterial.parchment => AppColors.parchmentBase,
        AppMaterial.wood => AppColors.woodFace,
        AppMaterial.stone => AppColors.stoneFace,
        AppMaterial.hud => AppColors.hudFace,
      };

  /// Malzeme kenar (govde disi) rengi.
  static Color edge(AppMaterial m) => switch (m) {
        AppMaterial.parchment => AppColors.parchmentEdge,
        AppMaterial.wood => AppColors.woodEdge,
        AppMaterial.stone => AppColors.stoneEdge,
        AppMaterial.hud => AppColors.hudEdge,
      };

  /// Kalin dis hat (keyline) rengi. Aydinlik malzemelerde tek bir
  /// koyu murekkep tonu kullanilir; HUD kendi koyu kenarini kullanir
  /// (DESIGN §3 "bold dark keyline").
  static Color keyline(AppMaterial m) => switch (m) {
        AppMaterial.parchment => AppColors.outlineInk,
        AppMaterial.wood => AppColors.outlineInk,
        AppMaterial.stone => AppColors.outlineInk,
        AppMaterial.hud => AppColors.hudEdge,
      };

  /// Malzeme uzerindeki birincil metin rengi.
  static Color text(AppMaterial m) => switch (m) {
        AppMaterial.parchment => AppColors.textOnLight,
        AppMaterial.wood => AppColors.textOnLight,
        AppMaterial.stone => AppColors.textOnLight,
        AppMaterial.hud => AppColors.textOnDark,
      };

  /// Malzeme uzerindeki ikincil (soluk) metin rengi.
  static Color textSecondary(AppMaterial m) => switch (m) {
        AppMaterial.parchment => AppColors.textOnLightSecondary,
        AppMaterial.wood => AppColors.textOnLightSecondary,
        AppMaterial.stone => AppColors.textOnLightSecondary,
        AppMaterial.hud => AppColors.textOnDarkSecondary,
      };

  /// Dis hat (keyline) kalinligi. Tum malzemeler ayni agirligi paylasir.
  static const double keylineWidth = 2.5;

  /// Ic derz (seam) kalinligi. Keyline'dan ince, ikincil detay hatti.
  static const double seamWidth = 1.5;
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
