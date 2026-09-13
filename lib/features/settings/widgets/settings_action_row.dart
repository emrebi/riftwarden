import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';

/// Ayarlar ekraninda alt sayfaya veya harici aksiyona yonlendiren satir.
///
/// RTL destege gore ok yonu dinamik ayarlanir; dokunma hedefi min 48 dp
/// kuralina uygun sekilde genisletildi.
class SettingsActionRow extends StatelessWidget {
  const SettingsActionRow({
    required this.label,
    required this.onTap,
    super.key,
    this.value,
    this.showArrow = true,
  });

  final String label;
  final VoidCallback onTap;
  final String? value;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final arrowIcon =
        isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppSpacing.minTouchTarget,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (value != null) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                Text(
                  value!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (showArrow) ...<Widget>[
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  arrowIcon,
                  color: AppColors.textSecondary,
                  size: AppSpacing.screenGutter,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
