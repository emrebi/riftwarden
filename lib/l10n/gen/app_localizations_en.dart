// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
}
