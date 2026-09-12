import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/shared/widgets/rw_button.dart';

/// Onay, hata ve satin alma gibi durumlar icin modal iletisim penceresi.
///
/// 1 veya 2 eylem butonu kabul eder. Tum dokunma hedefleri standart sinirlara uygundur.
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
      barrierColor: AppColors.voidDeep.withValues(alpha: 0.75),
      builder: (BuildContext dialogContext) => RwDialog(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppGradients.panel,
          borderRadius: AppBorderRadii.lg,
          border: AppBorders.subtle,
          boxShadow: AppShadows.panel,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      bottom: AppSpacing.md,
                    ),
                    child: icon!,
                  ),
                ),
              ],
              Text(
                title,
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              if (message != null) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message!,
                  style: AppTypography.bodyMedium,
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
    );
  }

  Widget _buildActions() {
    if (secondaryActionLabel != null && secondaryActionOnPressed != null) {
      return Row(
        children: <Widget>[
          Expanded(
            child: RwButton(
              label: secondaryActionLabel!,
              onPressed: secondaryActionOnPressed,
              variant: secondaryActionVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: RwButton(
              label: primaryActionLabel,
              onPressed: primaryActionOnPressed,
              variant: primaryActionVariant,
            ),
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
