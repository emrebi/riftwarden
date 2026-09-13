import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';

/// Ayarlar ekraninda acma/kapama secenegi satiri.
///
/// Dokunma alanini genis tutmak icin tum satir tiklanabilir yapildi;
/// boylece kucuk ekranlarda da anahtari tetiklemek kolaylasir.
class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
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
              Switch(
                value: value,
                onChanged: onChanged,
                // Flutter 3.31'den sonra `activeColor` kaldirildi.
                activeThumbColor: AppColors.aetherCyan,
                activeTrackColor: AppColors.aetherCyanDim,
                inactiveThumbColor: AppColors.textDisabled,
                inactiveTrackColor: AppColors.surfaceRaised,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
