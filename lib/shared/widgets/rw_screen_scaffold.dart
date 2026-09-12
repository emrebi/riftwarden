import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/shared/widgets/rw_icon_button.dart';

/// Tum sayfalarin ortak tabani.
///
/// Arka plan gradyani SafeArea disinda (ekranin tumune) yayilir.
/// Icerik, baslik ve butonlar ise guvenli alanda (SafeArea) tutulur.
class RwScreenScaffold extends StatelessWidget {
  const RwScreenScaffold({
    required this.child,
    super.key,
    this.title,
    this.onBack,
    this.trailing,
    this.contentPadding,
    this.bottomBar,
  });

  final Widget child;
  final String? title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final hasHeader = title != null || onBack != null || trailing != null;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppColors.voidDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppGradients.screenBackground,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (hasHeader) _buildHeader(context, isRtl),
              Expanded(
                child: Padding(
                  padding: contentPadding ??
                      const EdgeInsetsDirectional.symmetric(
                        horizontal: AppSpacing.screenGutter,
                      ),
                  child: child,
                ),
              ),
              ?bottomBar,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isRtl) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.screenGutter,
        vertical: AppSpacing.sm,
      ),
      child: SizedBox(
        height: AppSpacing.minTouchTarget,
        child: Row(
          children: <Widget>[
            if (onBack != null)
              RwIconButton(
                icon: isRtl
                    ? Icons.arrow_forward_rounded
                    : Icons.arrow_back_rounded,
                onPressed: onBack,
              )
            else
              const SizedBox(width: AppSpacing.minTouchTarget),
            Expanded(
              child: title != null
                  ? Text(
                      title!,
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.textPrimary,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : const SizedBox.shrink(),
            ),
            if (trailing != null)
              trailing!
            else
              const SizedBox(width: AppSpacing.minTouchTarget),
          ],
        ),
      ),
    );
  }
}
