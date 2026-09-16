// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'RIFTWARDEN';

  @override
  String get menuPlay => 'PLAY';

  @override
  String get menuStore => 'STORE';

  @override
  String get menuUpgrades => 'UPGRADES';

  @override
  String get menuSettings => 'SETTINGS';

  @override
  String sectorLabel(int number) {
    return 'SECTOR $number';
  }

  @override
  String levelLabel(int number) {
    return 'LEVEL $number';
  }

  @override
  String get levelLocked => 'LOCKED';

  @override
  String get hudAether => 'Aether';

  @override
  String get hudCore => 'Core';

  @override
  String hudWave(int current, int total) {
    return 'Wave $current/$total';
  }

  @override
  String get upgradeChooseTitle => 'CHOOSE AN UPGRADE';

  @override
  String get upgradeReroll => 'Reroll';

  @override
  String upgradeRerollsLeft(int count) {
    return '$count left';
  }

  @override
  String get rarityCommon => 'Common';

  @override
  String get rarityRare => 'Rare';

  @override
  String get rarityEpic => 'Epic';

  @override
  String get rarityLegendary => 'Legendary';

  @override
  String get upgradeArcChain1 => 'Chain Lightning';

  @override
  String get upgradeArcChain1Desc => '+1 chain target';

  @override
  String get upgradeArcChain2 => 'Chain Overload';

  @override
  String get upgradeArcChain2Desc => '+1 chain target';

  @override
  String get upgradePulsePierce1 => 'Piercing Rounds';

  @override
  String get upgradePulsePierce1Desc => '+2 damage. Shots pierce 1 enemy';

  @override
  String get upgradePulsePierce2 => 'Deep Pierce';

  @override
  String get upgradePulsePierce2Desc => '+1 pierce count';

  @override
  String get upgradeArcCrit1 => 'Critical Focus';

  @override
  String get upgradeArcCrit1Desc => '+10% critical chance';

  @override
  String get upgradeArcCrit2 => 'Critical Surge';

  @override
  String get upgradeArcCrit2Desc => '+50% critical damage';

  @override
  String get upgradeTitanExplosion1 => 'Blast Radius';

  @override
  String get upgradeTitanExplosion1Desc => 'Larger explosion radius';

  @override
  String get upgradeTitanExplosion2 => 'Overpressure';

  @override
  String get upgradeTitanExplosion2Desc => '+15% damage';

  @override
  String get upgradePulseSwarm1 => 'Rapid Rounds';

  @override
  String get upgradePulseSwarm1Desc => '+1 damage';

  @override
  String get upgradePulseSwarm2 => 'Swarm Frenzy';

  @override
  String get upgradePulseSwarm2Desc => '+10% attack speed';

  @override
  String get upgradeAetherEconomy1 => 'Overflow Storage';

  @override
  String get upgradeAetherEconomy1Desc => '+5 Aether income';

  @override
  String get upgradeCoreShield1 => 'Regenerating Shield';

  @override
  String get upgradeCoreShield1Desc => '+100 max HP';

  @override
  String get resultVictoryTitle => 'RIFT SEALED';

  @override
  String get resultDefeatTitle => 'CORE DESTABILIZED';

  @override
  String get resultRetry => 'RETRY';

  @override
  String get resultNextLevel => 'NEXT';

  @override
  String get resultMainMenu => 'MAIN MENU';

  @override
  String get resultWatchAdContinue => 'WATCH AD TO CONTINUE';

  @override
  String get resultDoubleReward => 'DOUBLE REWARD';

  @override
  String get settingsSound => 'Sound';

  @override
  String get settingsMusic => 'Music';

  @override
  String get settingsHaptics => 'Vibration';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsRestorePurchases => 'Restore Purchases';

  @override
  String get settingsPrivacy => 'Privacy Policy';

  @override
  String get storeRemoveAds => 'Remove Ads';

  @override
  String get storeRestoreDone => 'Purchases restored.';

  @override
  String get storePurchaseFailed => 'Purchase could not be completed.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonRetry => 'Retry';

  @override
  String get errorContentLoad => 'Game data could not be loaded.';

  @override
  String get menuSubtitle => 'Dimensional Auto-Battle';

  @override
  String get settingsSectionAudio => 'Audio';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get settingsSectionAccount => 'Account';

  @override
  String get levelBoss => 'BOSS';

  @override
  String get resultRewardsTitle => 'REWARDS';

  @override
  String get resultRewardShards => 'Rift Shard';

  @override
  String get resultRewardCells => 'Aether Cell';

  @override
  String get unitPulseGuard => 'Pulse Guard';

  @override
  String get unitArcRanger => 'Arc Ranger';

  @override
  String get unitTitanFrame => 'Titan Frame';

  @override
  String get battlePauseTitle => 'PAUSED';

  @override
  String get battleResume => 'RESUME';

  @override
  String get battleAimHint => 'TAP TARGET TO CAST';

  @override
  String get hudBossWave => 'BOSS WAVE';

  @override
  String get rotateTitle => 'Rotate your device';

  @override
  String get rotateHint => 'Turn your phone sideways to play';

  @override
  String rotateAutoIn(int seconds) {
    return 'Switching to landscape in ${seconds}s';
  }

  @override
  String get rotateTapToContinue => 'Tap to continue';

  @override
  String get hudCastle => 'Castle';

  @override
  String get hudAbilities => 'Abilities';

  @override
  String get hudSlotsFull => 'Full';

  @override
  String get hudBuy => 'BUY';

  @override
  String get hudOwned => 'OWNED';

  @override
  String get upgradePulseGuardDualshot => 'Dual Shot';

  @override
  String get upgradePulseGuardDualshotDesc => '+40% Attack Speed';

  @override
  String get upgradePulseGuardOvercharge => 'Overcharge';

  @override
  String get upgradePulseGuardOverchargeDesc => '+4 Damage';

  @override
  String get upgradeArcRangerOvercharge => 'Chain Overcharge';

  @override
  String get upgradeArcRangerOverchargeDesc => '+2 Chain Targets';

  @override
  String get upgradeArcRangerFocus => 'Focus';

  @override
  String get upgradeArcRangerFocusDesc => '+15% Critical Chance';

  @override
  String get upgradeTitanFrameShockwave => 'Shockwave';

  @override
  String get upgradeTitanFrameShockwaveDesc => 'Explosion radius + Knockback';

  @override
  String get upgradeTitanFrameJuggernaut => 'Juggernaut';

  @override
  String get upgradeTitanFrameJuggernautDesc => '+10 Damage, +50 HP';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'RIFTWARDEN';

  @override
  String get menuPlay => 'PLAY';

  @override
  String get menuStore => 'STORE';

  @override
  String get menuUpgrades => 'UPGRADES';

  @override
  String get menuSettings => 'SETTINGS';

  @override
  String sectorLabel(int number) {
    return 'SECTOR $number';
  }

  @override
  String levelLabel(int number) {
    return 'LEVEL $number';
  }

  @override
  String get levelLocked => 'LOCKED';

  @override
  String get hudAether => 'Aether';

  @override
  String get hudCore => 'Core';

  @override
  String hudWave(int current, int total) {
    return 'Wave $current/$total';
  }

  @override
  String get upgradeChooseTitle => 'CHOOSE AN UPGRADE';

  @override
  String get upgradeReroll => 'Reroll';

  @override
  String upgradeRerollsLeft(int count) {
    return '$count left';
  }

  @override
  String get rarityCommon => 'Common';

  @override
  String get rarityRare => 'Rare';

  @override
  String get rarityEpic => 'Epic';

  @override
  String get rarityLegendary => 'Legendary';

  @override
  String get upgradeArcChain1 => 'Chain Lightning';

  @override
  String get upgradeArcChain1Desc => '+1 chain target';

  @override
  String get upgradeArcChain2 => 'Chain Overload';

  @override
  String get upgradeArcChain2Desc => '+1 chain target';

  @override
  String get upgradePulsePierce1 => 'Piercing Rounds';

  @override
  String get upgradePulsePierce1Desc => '+2 damage. Shots pierce 1 enemy';

  @override
  String get upgradePulsePierce2 => 'Deep Pierce';

  @override
  String get upgradePulsePierce2Desc => '+1 pierce count';

  @override
  String get upgradeArcCrit1 => 'Critical Focus';

  @override
  String get upgradeArcCrit1Desc => '+10% critical chance';

  @override
  String get upgradeArcCrit2 => 'Critical Surge';

  @override
  String get upgradeArcCrit2Desc => '+50% critical damage';

  @override
  String get upgradeTitanExplosion1 => 'Blast Radius';

  @override
  String get upgradeTitanExplosion1Desc => 'Larger explosion radius';

  @override
  String get upgradeTitanExplosion2 => 'Overpressure';

  @override
  String get upgradeTitanExplosion2Desc => '+15% damage';

  @override
  String get upgradePulseSwarm1 => 'Rapid Rounds';

  @override
  String get upgradePulseSwarm1Desc => '+1 damage';

  @override
  String get upgradePulseSwarm2 => 'Swarm Frenzy';

  @override
  String get upgradePulseSwarm2Desc => '+10% attack speed';

  @override
  String get upgradeAetherEconomy1 => 'Overflow Storage';

  @override
  String get upgradeAetherEconomy1Desc => '+5 Aether income';

  @override
  String get upgradeCoreShield1 => 'Regenerating Shield';

  @override
  String get upgradeCoreShield1Desc => '+100 max HP';

  @override
  String get resultVictoryTitle => 'RIFT SEALED';

  @override
  String get resultDefeatTitle => 'CORE DESTABILIZED';

  @override
  String get resultRetry => 'RETRY';

  @override
  String get resultNextLevel => 'NEXT';

  @override
  String get resultMainMenu => 'MAIN MENU';

  @override
  String get resultWatchAdContinue => 'WATCH AD TO CONTINUE';

  @override
  String get resultDoubleReward => 'DOUBLE REWARD';

  @override
  String get settingsSound => 'Sound';

  @override
  String get settingsMusic => 'Music';

  @override
  String get settingsHaptics => 'Vibration';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsRestorePurchases => 'Restore Purchases';

  @override
  String get settingsPrivacy => 'Privacy Policy';

  @override
  String get storeRemoveAds => 'Remove Ads';

  @override
  String get storeRestoreDone => 'Purchases restored.';

  @override
  String get storePurchaseFailed => 'Purchase could not be completed.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonRetry => 'Retry';

  @override
  String get errorContentLoad => 'Game data could not be loaded.';

  @override
  String get menuSubtitle => 'Dimensional Auto-Battle';

  @override
  String get settingsSectionAudio => 'Audio';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get settingsSectionAccount => 'Account';

  @override
  String get levelBoss => 'BOSS';

  @override
  String get resultRewardsTitle => 'REWARDS';

  @override
  String get resultRewardShards => 'Rift Shard';

  @override
  String get resultRewardCells => 'Aether Cell';

  @override
  String get unitPulseGuard => 'Pulse Guard';

  @override
  String get unitArcRanger => 'Arc Ranger';

  @override
  String get unitTitanFrame => 'Titan Frame';

  @override
  String get battlePauseTitle => 'PAUSED';

  @override
  String get battleResume => 'RESUME';

  @override
  String get battleAimHint => 'TAP TARGET TO CAST';

  @override
  String get hudBossWave => 'BOSS WAVE';

  @override
  String get rotateTitle => 'Rotate your device';

  @override
  String get rotateHint => 'Turn your phone sideways to play';

  @override
  String rotateAutoIn(int seconds) {
    return 'Switching to landscape in ${seconds}s';
  }

  @override
  String get rotateTapToContinue => 'Tap to continue';

  @override
  String get hudCastle => 'Castle';

  @override
  String get hudAbilities => 'Abilities';

  @override
  String get hudSlotsFull => 'Full';

  @override
  String get hudBuy => 'BUY';

  @override
  String get hudOwned => 'OWNED';

  @override
  String get upgradePulseGuardDualshot => 'Dual Shot';

  @override
  String get upgradePulseGuardDualshotDesc => '+40% Attack Speed';

  @override
  String get upgradePulseGuardOvercharge => 'Overcharge';

  @override
  String get upgradePulseGuardOverchargeDesc => '+4 Damage';

  @override
  String get upgradeArcRangerOvercharge => 'Chain Overcharge';

  @override
  String get upgradeArcRangerOverchargeDesc => '+2 Chain Targets';

  @override
  String get upgradeArcRangerFocus => 'Focus';

  @override
  String get upgradeArcRangerFocusDesc => '+15% Critical Chance';

  @override
  String get upgradeTitanFrameShockwave => 'Shockwave';

  @override
  String get upgradeTitanFrameShockwaveDesc => 'Explosion radius + Knockback';

  @override
  String get upgradeTitanFrameJuggernaut => 'Juggernaut';

  @override
  String get upgradeTitanFrameJuggernautDesc => '+10 Damage, +50 HP';
}
