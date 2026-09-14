import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';
import 'package:riftwarden/shared/widgets/rw_button.dart';
import 'package:riftwarden/shared/widgets/rw_panel.dart';

/// Savas duraklatildiginda ekrani kaplayan panel.
///
/// Oyuncuya oyunu surdurme veya ana menuye donus secenekleri sunar.
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      color: AppColors.voidDeep.withValues(alpha: 0.75),
      alignment: AlignmentDirectional.center,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320.0),
          child: RwPanel(
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
    );
  }
}
