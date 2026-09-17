import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riftwarden/engine/bridge/battle_signals.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';
import 'package:riftwarden/shared/widgets/rw_ability_frame.dart';

/// Savas ekraninda Rift Collapse aktif yetenek butonu.
///
/// Yetenek hazir degilken `RwAbilityFrame` bekleme maskesi ile kalan sureyi
/// gosterir. Hazirken veya nisan alirken dokunuldugunda nisan alma modunu
/// acar/kapatir; kapatma komutunu ekran (battle_screen) yonetir.
class AbilityButton extends StatelessWidget {
  const AbilityButton({
    required this.ability,
    required this.onToggleAiming,
    super.key,
    this.height = _defaultHeight,
    this.artId,
  });

  /// Yetenek durumu sinyali (cooldown, hazirlik, nisan durumu).
  final ValueListenable<AbilityState> ability;

  /// Nisan modunu acip kapatan eylem.
  final VoidCallback onToggleAiming;

  /// Buton yuksekligi (cerceve kenar uzunlugu).
  final double height;

  /// Opsiyonel yetenek raster sanat kimligi (AQ-2 `assets/images/ui_art/icons/<artId>.webp`).
  final String? artId;

  // Alt seridin %20 yukseklik sinirina (DESIGN §10) sigmasi icin varsayilan
  // kucultuldu; RwAbilityFrame kendi alt siniri olan 48 dp'nin altina inmez.
  static const double _defaultHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ValueListenableBuilder<AbilityState>(
      valueListenable: ability,
      builder: (BuildContext context, AbilityState state, _) {
        final RwAbilityState frameState = state.isAiming
            ? RwAbilityState.targeting
            : state.isReady
                ? RwAbilityState.ready
                : RwAbilityState.cooldown;

        return RwAbilityFrame(
          state: frameState,
          artId: artId,
          cooldownProgress: state.cooldownRatio,
          remainingSeconds: state.cooldownRemaining.ceilToDouble(),
          onTap: frameState == RwAbilityState.cooldown ? null : onToggleAiming,
          size: height,
          semanticLabel: l10n.battleAimHint,
        );
      },
    );
  }
}
