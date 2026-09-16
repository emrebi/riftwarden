import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/shared/widgets/rw_button.dart';
import 'package:riftwarden/shared/widgets/rw_panel.dart';
import 'package:riftwarden/shared/widgets/rw_veil.dart';

/// Onay, hata ve satin alma gibi durumlar icin modal iletisim penceresi.
///
/// 1 veya 2 eylem butonu kabul eder. Tum dokunma hedefleri standart sinirlara
/// uygundur. Govde `RwPanel(variant: modal, material: parchment)` uzerine
/// kurulur (DESIGN §8 "Modal: strongest depth, clear title area, dimmed
/// context behind it"); dimmed context `RwVeil` ile saglanir.
class RwDialog extends StatelessWidget {
  const RwDialog({
    required this.title,
    required this.primaryActionLabel,
    required this.primaryActionOnPressed,
    super.key,
    this.message,
    this.content,
    this.icon,
    this.primaryActionVariant = RwButtonVariant.primary,
    this.secondaryActionLabel,
    this.secondaryActionOnPressed,
    this.secondaryActionVariant = RwButtonVariant.ghost,
  });

  final String title;
  final String? message;
  final Widget? content;
  final Widget? icon;
  final String primaryActionLabel;
  final VoidCallback primaryActionOnPressed;
  final RwButtonVariant primaryActionVariant;
  final String? secondaryActionLabel;
  final VoidCallback? secondaryActionOnPressed;
  final RwButtonVariant secondaryActionVariant;

  /// Kolayca iletisim penceresi acmak icin yardimci metod.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String primaryActionLabel,
    required VoidCallback primaryActionOnPressed,
    String? message,
    Widget? content,
    Widget? icon,
    RwButtonVariant primaryActionVariant = RwButtonVariant.primary,
    String? secondaryActionLabel,
    VoidCallback? secondaryActionOnPressed,
    RwButtonVariant secondaryActionVariant = RwButtonVariant.ghost,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      // Karartma + doygunluk dusurme `RwVeil` icinde uygulanir (DESIGN §13);
      // bariyerin kendisi seffaf birakilir ki cift katman olusmasin.
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) => RwVeil(
        onTap: barrierDismissible
            ? () => Navigator.of(dialogContext).pop()
            : null,
        child: RwDialog(
          title: title,
          message: message,
          content: content,
          icon: icon,
          primaryActionLabel: primaryActionLabel,
          primaryActionOnPressed: primaryActionOnPressed,
          primaryActionVariant: primaryActionVariant,
          secondaryActionLabel: secondaryActionLabel,
          secondaryActionOnPressed: secondaryActionOnPressed,
          secondaryActionVariant: secondaryActionVariant,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final EdgeInsets viewPadding = MediaQuery.viewPaddingOf(context);
    final double maxWidth = (screenSize.width * 0.6).clamp(280.0, 480.0);
    final double maxHeight = screenSize.height -
        viewPadding.top -
        viewPadding.bottom -
        AppSpacing.xxl;

    return SafeArea(
      child: Center(
        child: GestureDetector(
          // Panelin ustune dokunma bosluga dokunma sayilmasin (RwVeil'in
          // onTap'i tetiklenmesin).
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 240.0,
              maxWidth: maxWidth,
              maxHeight: maxHeight,
            ),
            // Kaydirma panelin DISINDA yapilir: baslik + ayirici + govde dolgusu
            // dahil butun panel kaydirilabilir alan icinde kalir, boylece
            // `RwPanel`in ic govdesine ayrica bir yukseklik siniri (maxHeight)
            // vermeye gerek kalmaz — dis `ConstrainedBox` zaten sinirlar.
            child: SingleChildScrollView(
              child: RwPanel(
                variant: RwPanelVariant.modal,
                material: AppMaterial.parchment,
                title: title,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (icon != null) ...<Widget>[
                      Center(child: icon!),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    if (message != null) ...<Widget>[
                      Text(
                        message!,
                        style: AppTypography.onMaterial(
                          AppTypography.bodyMedium,
                          AppMaterial.parchment,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (content != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.md),
                      content!,
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    if (secondaryActionLabel != null && secondaryActionOnPressed != null) {
      // Dar ekranda/uzun locale metninde tasmasin diye `OverflowBar`
      // kullanilir (DESIGN §22, §23): sigarsa tek satir, sigmazsa alt
      // satira gecer.
      return OverflowBar(
        alignment: MainAxisAlignment.center,
        overflowAlignment: OverflowBarAlignment.center,
        spacing: AppSpacing.md,
        overflowSpacing: AppSpacing.sm,
        children: <Widget>[
          RwButton(
            label: secondaryActionLabel!,
            onPressed: secondaryActionOnPressed,
            variant: secondaryActionVariant,
          ),
          RwButton(
            label: primaryActionLabel,
            onPressed: primaryActionOnPressed,
            variant: primaryActionVariant,
          ),
        ],
      );
    }

    return RwButton(
      isExpanded: true,
      label: primaryActionLabel,
      onPressed: primaryActionOnPressed,
      variant: primaryActionVariant,
    );
  }
}
