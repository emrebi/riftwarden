import 'package:flutter/material.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';
import 'package:riftwarden/shared/widgets/rw_icon_button.dart';

/// Ana menu ikincil eylemler satiri.
///
/// DESIGN §15 "backed flows only": magaza ve kalici gelistirmeler backend'i
/// olmadigi icin bu satirda gorunmez (AQ-3); su an sadece rotasi bagli olan
/// Ayarlar akisi barinir.
class MenuActionsRow extends StatelessWidget {
  const MenuActionsRow({
    required this.onSettings,
    super.key,
  });

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        RwIconButton(
          icon: Icons.settings_rounded,
          tooltip: l10n.menuSettings,
          onPressed: onSettings,
        ),
      ],
    );
  }
}
