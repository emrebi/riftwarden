// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

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
