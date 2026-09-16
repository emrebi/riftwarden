import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';

/// Ayarlar, magaza ve menulerde grup basligi.
class RwSectionHeader extends StatelessWidget {
  const RwSectionHeader({
    required this.title,
    super.key,
    this.subtitle,
    this.trailing,
    this.accentColor,
    this.onDark = false,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  /// Vurgu isaretinin rengi. `null` ise `AppColors.cta` kullanilir.
  final Color? accentColor;

  /// True ise baslik/altyazi rengi koyu zeminde (orn. `AppMaterial.hud`
  /// panel) okunur kalsin diye `textOnDark*` tonlarina gecer. Varsayilan
  /// acik zemin (`textOnLight*`).
  final bool onDark;

  // Vurgu isareti (kucuk murekkep/banner cizgisi) olculeri, DESIGN §3
  // "repeated outlines share a small set of weights" kuraliyla tutarli tek
  // bir yerde sabitlenir.
  static const double _markWidth = 5.0;
  static const double _markHeight = 18.0;
  static const double _markBorderWidth = 1.5;

  @override
  Widget build(BuildContext context) {
    final Color effectiveAccent = accentColor ?? AppColors.cta;
    final Color titleColor =
        onDark ? AppColors.textOnDark : AppColors.textOnLight;
    final Color subtitleColor =
        onDark ? AppColors.textOnDarkSecondary : AppColors.textOnLightSecondary;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              // Start tarafinda kucuk murekkep/banner vurgu isareti.
              DecoratedBox(
                decoration: BoxDecoration(
                  color: effectiveAccent,
                  border: Border.all(
                    color: AppColors.outlineInk,
                    width: _markBorderWidth,
                  ),
                  borderRadius: AppBorderRadii.sm,
                ),
                child: const SizedBox(width: _markWidth, height: _markHeight),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.sectionTitle.copyWith(
                    color: titleColor,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: AppSpacing.md,
              ),
              child: Text(
                subtitle!,
                style: AppTypography.smallLabel.copyWith(
                  color: subtitleColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
