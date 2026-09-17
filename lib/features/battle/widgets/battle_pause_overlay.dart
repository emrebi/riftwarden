import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';
import 'package:riftwarden/shared/widgets/rw_button.dart';
import 'package:riftwarden/shared/widgets/rw_panel.dart';
import 'package:riftwarden/shared/widgets/rw_veil.dart';

/// Savas duraklatildiginda ekrani kaplayan panel.
///
/// Oyuncuya oyunu surdurme veya ana menuye donus secenekleri sunar. Sahne
/// arka planda kalmasi icin karartma `RwVeil` ile saglanir (DESIGN §13);
/// bosluga dokunma reddedilir, sadece butonlar eylem tetikler.
class BattlePauseOverlay extends StatelessWidget {
  const BattlePauseOverlay({
    required this.onResume,
    required this.onExit,
    super.key,
  });

  /// Savasi surdurme eylemi.
  final VoidCallback onResume;

  /// Ana menuye donus eylemi.
  final VoidCallback onExit;

  /// Panel genisligi: dar ekranlarda (640x360) bile rahat sigsin diye
  /// tek noktada sabitlenir (DESIGN §13 "fixed compact width").
  static const double _panelWidth = 320.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final Size screenSize = MediaQuery.sizeOf(context);
    final EdgeInsets viewPadding = MediaQuery.viewPaddingOf(context);
    final double maxHeight = screenSize.height -
        viewPadding.top -
        viewPadding.bottom -
        AppSpacing.xxl;

    return RwVeil(
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: _panelWidth,
              maxHeight: maxHeight,
            ),
            // Dar yukseklikli yuzeylerde (640x360, buyuk metin olcegi) icerik
            // panel yuksekligini asabilir; tasma yerine kaydirilabilir
            // govdeye duser (RwDialog ile ayni desen).
            child: SingleChildScrollView(
              child: RwPanel(
                variant: RwPanelVariant.modal,
                title: l10n.battlePauseTitle,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    RwButton(
                      label: l10n.battleResume,
                      icon: Icons.play_arrow_rounded,
                      variant: RwButtonVariant.primary,
                      isExpanded: true,
                      onPressed: onResume,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    RwButton(
                      label: l10n.resultMainMenu,
                      icon: Icons.home_rounded,
                      variant: RwButtonVariant.ghost,
                      isExpanded: true,
                      onPressed: onExit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
