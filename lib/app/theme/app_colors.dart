import 'package:flutter/material.dart';

/// Renk token'lari.
///
/// ## Gemini UI icin sozlesme
/// Arayuz tasarimi bu token'lari DEGISTIREBILIR, ama ekranlar
/// `Color(0xFF...)` gibi ham deger KULLANMAZ — her zaman buradan okur.
/// Boylece tema tek dosyadan degisir ve tasarim revizyonu tum ekranlara
/// tek seferde yayilir.
///
/// ## Sanat yonu
/// Boyutlar arasi bosluk: derin mor-lacivert zemin, uzerinde enerji
/// isiklari. Oyuncu tarafi cyan/teal, Riftborn tarafi menekse/macenta,
/// kaynak (Aether) kehribar. Tehlike icin kirmizi bilincli olarak az
/// kullanilir ki Core hasari uyarisi gercekten dikkat ceksin.
abstract final class AppColors {
  // --- Zemin katmanlari (arkadan one) ---
  static const Color voidDeep = Color(0xFF07060F);
  static const Color voidBase = Color(0xFF0E0C1C);
  static const Color surface = Color(0xFF16132A);
  static const Color surfaceRaised = Color(0xFF1F1B39);
  static const Color surfaceOverlay = Color(0xE60E0C1C);

  // --- Oyuncu / enerji ---
  static const Color aetherCyan = Color(0xFF3FE0FF);
  static const Color aetherCyanDim = Color(0xFF1B7F96);
  static const Color coreTeal = Color(0xFF2BF5C8);

  // --- Riftborn / dusman ---
  static const Color riftViolet = Color(0xFF9B5CFF);
  static const Color riftMagenta = Color(0xFFE84AC4);
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
}
