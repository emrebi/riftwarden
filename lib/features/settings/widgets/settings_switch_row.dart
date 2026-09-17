import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/shared/widgets/rw_toggle.dart';

/// Ayarlar ekraninda acma/kapama secenegi satiri.
///
/// Dokunma alanini genis tutmak icin tum satir tiklanabilir yapildi;
/// boylece kucuk ekranlarda da anahtari tetiklemek kolaylasir. Gorsel
/// anahtar `RwToggle`dir (SEC-02); metin rengi satirin icinde durdugu
/// panelin malzemesine gore secilir ki parchment govde uzerinde okunur
/// kalsin.
class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
    this.material = AppMaterial.parchment,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  /// Satirin uzerinde durdugu panelin malzemesi. Metin rengini belirler.
  final AppMaterial material;

  @override
  Widget build(BuildContext context) {
    // Tek Semantics dugumu: baslik ve anahtarin ayri ayri anons edilmesini
    // (ciftlenmeyi) onlemek icin butun satir tek bir toggle dugumune
    // indirgenir; RwToggle'in kendi Semantics'i bu sayede disaridan
    // ezilir (excludeSemantics disariya tasar).
    return Semantics(
      toggled: value,
      label: label,
      // excludeSemantics cocuk GestureDetector'in eylemini de sildigi icin
      // ekran okuyucu etkinlestirmesi burada ayrica baglanir.
      onTap: () => onChanged(!value),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
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
                    style: AppTypography.onMaterial(
                      AppTypography.bodyLarge,
                      material,
                    ),
                  ),
                ),
                RwToggle(
                  value: value,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
