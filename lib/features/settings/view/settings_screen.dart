import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/features/settings/widgets/settings_action_row.dart';
import 'package:riftwarden/features/settings/widgets/settings_switch_row.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';
import 'package:riftwarden/shared/widgets/rw_panel.dart';
import 'package:riftwarden/shared/widgets/rw_screen_scaffold.dart';
import 'package:riftwarden/shared/widgets/rw_section_header.dart';

/// Ayarlar ekrani.
///
/// Oyuncunun ses, titresim ve dil tercihlerini yonettigi ekran.
/// Yatay duzende iki sutunlu yapi: sol sutunda ses ve titresim ayarlari,
/// sag sutunda dil ve hesap/yasal baglantilari yer alir.
/// 360 dp yukseklikte her sutun bagimsiz dikey kaydirilabilir.
///
/// Stateless ve veri bagimsizdir; tum durumlar ve degisiklikler
/// disaridan parametrelerle iletilir.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.soundEnabled,
    required this.musicEnabled,
    required this.hapticsEnabled,
    required this.currentLanguageLabel,
    required this.versionLabel,
    required this.onSoundChanged,
    required this.onMusicChanged,
    required this.onHapticsChanged,
    required this.onLanguageTap,
    required this.onRestorePurchases,
    required this.onPrivacyTap,
    required this.onBack,
    super.key,
  });

  final bool soundEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final String currentLanguageLabel;
  final String versionLabel;
  final ValueChanged<bool> onSoundChanged;
  final ValueChanged<bool> onMusicChanged;
  final ValueChanged<bool> onHapticsChanged;
  final VoidCallback onLanguageTap;

  /// AQ-3: satin alma geri yukleme akisinin gercek bir backend baglantisi
  /// yok; satir bu yuzden gizlenir. Parametre uyumluluk icin korunur.
  final VoidCallback onRestorePurchases;
  final VoidCallback onPrivacyTap;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return RwScreenScaffold(
      title: l10n.menuSettings,
      onBack: onBack,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Sol sutun: Ses ayarlari paneli (bagimsiz kaydirilabilir)
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsetsDirectional.only(
                bottom: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  RwSectionHeader(
                    title: l10n.settingsSectionAudio,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  RwPanel(
                    padding: EdgeInsetsDirectional.zero,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SettingsSwitchRow(
                          label: l10n.settingsSound,
                          value: soundEnabled,
                          onChanged: onSoundChanged,
                        ),
                        Divider(
                          height: 1.0,
                          thickness: 1.0,
                          color: AppMaterials.edge(AppMaterial.parchment),
                        ),
                        SettingsSwitchRow(
                          label: l10n.settingsMusic,
                          value: musicEnabled,
                          onChanged: onMusicChanged,
                        ),
                        Divider(
                          height: 1.0,
                          thickness: 1.0,
                          color: AppMaterials.edge(AppMaterial.parchment),
                        ),
                        SettingsSwitchRow(
                          label: l10n.settingsHaptics,
                          value: hapticsEnabled,
                          onChanged: onHapticsChanged,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),

          // Sag sutun: Dil, Hesap ve Surum etiketi (bagimsiz kaydirilabilir)
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsetsDirectional.only(
                bottom: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Dil secimi grubu. Aksiyon satiri kendi RwButton
                  // ikincil yuzeyini tasidigi icin ayrica panele
                  // sarilmaz (cift cerceve olusmasin diye).
                  RwSectionHeader(
                    title: l10n.settingsSectionLanguage,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SettingsActionRow(
                    label: l10n.settingsLanguage,
                    value: currentLanguageLabel,
                    onTap: onLanguageTap,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Hesap ve yasal islemler grubu. Satin alma geri yukleme
                  // satiri AQ-3 geregi gizlenir (bkz. onRestorePurchases
                  // dokumantasyonu); yalnizca gizlilik baglantisi kalir.
                  RwSectionHeader(
                    title: l10n.settingsSectionAccount,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SettingsActionRow(
                    label: l10n.settingsPrivacy,
                    onTap: onPrivacyTap,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Surum etiketi (sag sutunun en altinda)
                  Text(
                    versionLabel,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
