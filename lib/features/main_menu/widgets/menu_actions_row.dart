import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';
import 'package:riftwarden/shared/widgets/rw_button.dart';
import 'package:riftwarden/shared/widgets/rw_icon_button.dart';

/// Ana menu ikincil eylemler satiri.
///
/// Magaza, Kalici Gelistirmeler ve Ayarlar dugmelerini barindirir.
/// 360 dp dar ekranda metinlerin tasmamasi icin Magaza ve Gelistirmeler
/// esit genislikte RwButton, Ayarlar ise standart dokunma alanina sahip
/// RwIconButton olarak konumlandirilmistir.
class MenuActionsRow extends StatelessWidget {
  const MenuActionsRow({
    required this.onStore,
    required this.onUpgrades,
    required this.onSettings,
    super.key,
  });

  final VoidCallback onStore;
  final VoidCallback onUpgrades;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: RwButton(
            label: l10n.menuStore,
            variant: RwButtonVariant.secondary,
            isExpanded: true,
            onPressed: onStore,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: RwButton(
            label: l10n.menuUpgrades,
            variant: RwButtonVariant.secondary,
            isExpanded: true,
            onPressed: onUpgrades,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        RwIconButton(
          icon: Icons.settings_rounded,
          tooltip: l10n.menuSettings,
          onPressed: onSettings,
        ),
      ],
    );
  }
}
