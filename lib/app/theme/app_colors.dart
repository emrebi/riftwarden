import 'package:flutter/material.dart';

/// Renk token'lari.
///
/// ## Sozlesme
/// Gorsel otorite `docs/DESIGN.md`. Ekranlar `Color(0xFF...)` gibi ham
/// deger KULLANMAZ — her zaman buradan okur. Boylece tema tek dosyadan
/// degisir ve tasarim revizyonu tum ekranlara tek seferde yayilir.
///
/// ## LEGACY token'lar
/// Asagida "LEGACY" notu tasiyan token'lar eski neon sanat yonune aittir;
/// UI-CLEAN gorevinde kaldirilir. `@Deprecated` isaretlenmezler (flutter
/// analyze 0 issue kapisini bozmamak icin).
abstract final class AppColors {
  // --- Zemin katmanlari (arkadan one) ---
  /// LEGACY (neon yon, UI-CLEAN'de kaldirilir)
  static const Color voidDeep = Color(0xFF07060F);
  /// LEGACY (neon yon, UI-CLEAN'de kaldirilir)
  static const Color voidBase = Color(0xFF0E0C1C);
  static const Color surface = Color(0xFF16132A);
  static const Color surfaceRaised = Color(0xFF1F1B39);
  /// LEGACY (neon yon, UI-CLEAN'de kaldirilir)
  static const Color surfaceOverlay = Color(0xE60E0C1C);

  // --- Oyuncu / enerji ---
  static const Color aetherCyan = Color(0xFF3FE0FF);
  /// LEGACY (neon yon, UI-CLEAN'de kaldirilir)
  static const Color aetherCyanDim = Color(0xFF1B7F96);
  /// LEGACY (neon yon, UI-CLEAN'de kaldirilir)
  static const Color coreTeal = Color(0xFF2BF5C8);

  // --- Riftborn / dusman ---
  static const Color riftViolet = Color(0xFF9B5CFF);
  /// LEGACY (neon yon, UI-CLEAN'de kaldirilir)
  static const Color riftMagenta = Color(0xFFE84AC4);
  /// LEGACY (neon yon, UI-CLEAN'de kaldirilir)
  static const Color riftGlow = Color(0xFFC77DFF);

  // --- Kaynak ---
  static const Color aether = Color(0xFFFFC44D);
  static const Color shard = Color(0xFF7FE3FF);
  static const Color cell = Color(0xFFFF8A3D);

  // --- Durum ---
  static const Color danger = Color(0xFFFF4D5E);
  static const Color warning = Color(0xFFFFB020);
  static const Color success = Color(0xFF44E08A);

  // --- Metin ---
  static const Color textPrimary = Color(0xFFF2F0FF);
  static const Color textSecondary = Color(0xFFA8A2C8);
  static const Color textDisabled = Color(0xFF5D587A);

  // --- Rarity (upgrade kartlari) ---
  static const Color rarityCommon = Color(0xFF8E8AA8);
  static const Color rarityRare = Color(0xFF3FA9FF);
  static const Color rarityEpic = Color(0xFF9B5CFF);
  static const Color rarityLegendary = Color(0xFFFFA63D);

  /// Rarity id'sinden renk. Bilinmeyen id common'a duser.
  static Color rarity(String id) => switch (id) {
        'rare' => rarityRare,
        'epic' => rarityEpic,
        'legendary' => rarityLegendary,
        _ => rarityCommon,
      };

  // --- Dunya / sahne ---
  // Baslangic degerleri onaylanan referans yonu takip eder; nihai degerler
  // cihaz ciktilariyla tune edilecek.
  static const Color background = Color(0xFFB9DBFF);

  // --- Anlam (semantik) ---
  static const Color rift = Color(0xFF9D5ADA);
  static const Color health = Color(0xFF63C45F);
  static const Color cta = Color(0xFFE5A53F);
  static const Color reward = Color(0xFFE2A23D);
  static const Color selection = Color(0xFFF2B640);

  // --- Yuzeye gore metin ---
  static const Color textOnLight = Color(0xFF2E2419);
  static const Color textOnLightSecondary = Color(0xFF6B5A47);
  static const Color textOnLightDisabled = Color(0xFF9E9486);
  static const Color textOnDark = Color(0xFFF6EEDC);
  static const Color textOnDarkSecondary = Color(0xFFCFC3AD);

  // --- Malzemeler ---
  static const Color parchmentBase = Color(0xFFF1DFC0);
  static const Color parchmentEdge = Color(0xFFDEC49A);
  static const Color woodFace = Color(0xFFC98A4B);
  static const Color woodEdge = Color(0xFF7A4E2A);
  static const Color stoneFace = Color(0xFF8E8A82);
  static const Color stoneEdge = Color(0xFF5A5650);
  static const Color hudFace = Color(0xFF2B2A33);
  static const Color hudEdge = Color(0xFF17161C);
  static const Color outlineInk = Color(0xFF2A1D14);
  static const Color shadowWarm = Color(0x66402A1A);
}
