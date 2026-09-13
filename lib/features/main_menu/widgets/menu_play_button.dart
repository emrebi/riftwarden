import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';
import 'package:riftwarden/shared/widgets/rw_button.dart';

/// Ana menu PLAY eylem butonu.
///
/// Ekrandaki en baskin ogredir. Hafif ve sakin bir nabiz animasyonuyla
/// oyuncunun dikkatini savasa baslama eylemine ceker.
class MenuPlayButton extends StatefulWidget {
  const MenuPlayButton({
    required this.onPressed,
    super.key,
  });

  final VoidCallback onPressed;

  @override
  State<MenuPlayButton> createState() => _MenuPlayButtonState();
}

class _MenuPlayButtonState extends State<MenuPlayButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: RwButton(
        label: l10n.menuPlay,
        icon: Icons.play_arrow_rounded,
        isExpanded: true,
        height: AppSpacing.minTouchTarget + AppSpacing.md,
        onPressed: widget.onPressed,
      ),
    );
  }
}
