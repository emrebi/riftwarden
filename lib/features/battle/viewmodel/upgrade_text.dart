import 'package:riftwarden/content/schema/schema.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';

/// Upgrade metinlerini l10n anahtarlarina baglar.
///
/// Neden switch, neden dogrudan `u.name` degil: `UpgradeConfig.name` ve
/// `.description` icerik JSON'unda (`assets/content/upgrades.json`) zaten
/// bir ARB anahtari YAZAR (orn. "upgradeArcChain1"), ama `AppLocalizations`
/// calisma zamaninda rastgele bir string ile alan okumayi DESTEKLEMEZ
/// (gen-l10n sabit getter'lar uretir, harita degil). Bu yuzden
/// upgrade id -> l10n getter eslemesi burada elle tutulur.
///
/// Yeni bir upgrade eklendiginde (`/rw-add-upgrade`): buraya (title +
/// description) ve gerekiyorsa `app_en.arb`'ye karsilik gelen anahtar
/// eklenir; unutulursa asagidaki `_ =>` dali id'yi oldugu gibi gosterir
/// (kirilmaz ama cirkin gorunur — bu bir hata isaretidir).
String upgradeTitle(AppLocalizations l10n, UpgradeConfig u) => switch (u.id) {
      'arc_chain_1' => l10n.upgradeArcChain1,
      'arc_chain_2' => l10n.upgradeArcChain2,
      'pulse_pierce_1' => l10n.upgradePulsePierce1,
      'pulse_pierce_2' => l10n.upgradePulsePierce2,
      'arc_crit_1' => l10n.upgradeArcCrit1,
      'arc_crit_2' => l10n.upgradeArcCrit2,
      'titan_explosion_1' => l10n.upgradeTitanExplosion1,
      'titan_explosion_2' => l10n.upgradeTitanExplosion2,
      'pulse_swarm_1' => l10n.upgradePulseSwarm1,
      'pulse_swarm_2' => l10n.upgradePulseSwarm2,
      'aether_economy_1' => l10n.upgradeAetherEconomy1,
      'core_shield_1' => l10n.upgradeCoreShield1,
      'pulse_guard_dualshot' => l10n.upgradePulseGuardDualshot,
      'pulse_guard_overcharge' => l10n.upgradePulseGuardOvercharge,
      'arc_ranger_overcharge' => l10n.upgradeArcRangerOvercharge,
      'arc_ranger_focus' => l10n.upgradeArcRangerFocus,
      'titan_frame_shockwave' => l10n.upgradeTitanFrameShockwave,
      'titan_frame_juggernaut' => l10n.upgradeTitanFrameJuggernaut,
      _ => u.id,
    };

/// [upgradeTitle] ile AYNI esleme deseni, aciklama metni icin.
String upgradeDescription(AppLocalizations l10n, UpgradeConfig u) => switch (u.id) {
      'arc_chain_1' => l10n.upgradeArcChain1Desc,
      'arc_chain_2' => l10n.upgradeArcChain2Desc,
      'pulse_pierce_1' => l10n.upgradePulsePierce1Desc,
      'pulse_pierce_2' => l10n.upgradePulsePierce2Desc,
      'arc_crit_1' => l10n.upgradeArcCrit1Desc,
      'arc_crit_2' => l10n.upgradeArcCrit2Desc,
      'titan_explosion_1' => l10n.upgradeTitanExplosion1Desc,
      'titan_explosion_2' => l10n.upgradeTitanExplosion2Desc,
      'pulse_swarm_1' => l10n.upgradePulseSwarm1Desc,
      'pulse_swarm_2' => l10n.upgradePulseSwarm2Desc,
      'aether_economy_1' => l10n.upgradeAetherEconomy1Desc,
      'core_shield_1' => l10n.upgradeCoreShield1Desc,
      'pulse_guard_dualshot' => l10n.upgradePulseGuardDualshotDesc,
      'pulse_guard_overcharge' => l10n.upgradePulseGuardOverchargeDesc,
      'arc_ranger_overcharge' => l10n.upgradeArcRangerOverchargeDesc,
      'arc_ranger_focus' => l10n.upgradeArcRangerFocusDesc,
      'titan_frame_shockwave' => l10n.upgradeTitanFrameShockwaveDesc,
      'titan_frame_juggernaut' => l10n.upgradeTitanFrameJuggernautDesc,
      _ => '',
    };

/// Nadirlik etiketi (kart kenar rengiyle birlikte gosterilir, bkz.
/// `docs/ui_briefs/battle-upgrade-cards.md`).
String rarityLabel(AppLocalizations l10n, UpgradeRarity r) => switch (r) {
      UpgradeRarity.common => l10n.rarityCommon,
      UpgradeRarity.rare => l10n.rarityRare,
      UpgradeRarity.epic => l10n.rarityEpic,
      UpgradeRarity.legendary => l10n.rarityLegendary,
    };
