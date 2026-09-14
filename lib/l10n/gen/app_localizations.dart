import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('ru'),
    Locale('th'),
    Locale('tr'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// Game title. Proper noun - do not translate.
  ///
  /// In en, this message translates to:
  /// **'RIFTWARDEN'**
  String get appTitle;

  /// Main menu primary button
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get menuPlay;

  /// Main menu button opening the store
  ///
  /// In en, this message translates to:
  /// **'STORE'**
  String get menuStore;

  /// Main menu button opening permanent upgrades
  ///
  /// In en, this message translates to:
  /// **'UPGRADES'**
  String get menuUpgrades;

  /// Main menu button opening settings
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get menuSettings;

  /// Sector heading on the level select screen
  ///
  /// In en, this message translates to:
  /// **'SECTOR {number}'**
  String sectorLabel(int number);

  /// Level heading
  ///
  /// In en, this message translates to:
  /// **'LEVEL {number}'**
  String levelLabel(int number);

  /// Shown on a level the player cannot enter yet
  ///
  /// In en, this message translates to:
  /// **'LOCKED'**
  String get levelLocked;

  /// In-run currency name. Proper noun of the game world.
  ///
  /// In en, this message translates to:
  /// **'Aether'**
  String get hudAether;

  /// Short label for the Aether Core structure the player defends
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get hudCore;

  /// Wave progress indicator during battle
  ///
  /// In en, this message translates to:
  /// **'Wave {current}/{total}'**
  String hudWave(int current, int total);

  /// Header above the three upgrade cards
  ///
  /// In en, this message translates to:
  /// **'CHOOSE AN UPGRADE'**
  String get upgradeChooseTitle;

  /// Button that replaces the offered upgrade cards
  ///
  /// In en, this message translates to:
  /// **'Reroll'**
  String get upgradeReroll;

  /// Shown when the player clears a level
  ///
  /// In en, this message translates to:
  /// **'RIFT SEALED'**
  String get resultVictoryTitle;

  /// Shown when the Core is destroyed
  ///
  /// In en, this message translates to:
  /// **'CORE DESTABILIZED'**
  String get resultDefeatTitle;

  /// Restart the level
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get resultRetry;

  /// Continue to the next level
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get resultNextLevel;

  /// Return to main menu
  ///
  /// In en, this message translates to:
  /// **'MAIN MENU'**
  String get resultMainMenu;

  /// Rewarded ad revive offer after defeat
  ///
  /// In en, this message translates to:
  /// **'WATCH AD TO CONTINUE'**
  String get resultWatchAdContinue;

  /// Rewarded ad offer that doubles level rewards
  ///
  /// In en, this message translates to:
  /// **'DOUBLE REWARD'**
  String get resultDoubleReward;

  /// Toggle for sound effects
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get settingsSound;

  /// Toggle for background music
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get settingsMusic;

  /// Toggle for haptic feedback
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settingsHaptics;

  /// Language picker label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Re-applies previously bought non-consumable items
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get settingsRestorePurchases;

  /// Opens the privacy policy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacy;

  /// Non-consumable purchase that disables interstitial ads
  ///
  /// In en, this message translates to:
  /// **'Remove Ads'**
  String get storeRemoveAds;

  /// Confirmation after a successful restore
  ///
  /// In en, this message translates to:
  /// **'Purchases restored.'**
  String get storeRestoreDone;

  /// Generic purchase failure message
  ///
  /// In en, this message translates to:
  /// **'Purchase could not be completed.'**
  String get storePurchaseFailed;

  /// Dismiss a dialog without acting
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Close a panel
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// Shown while content is loading
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// Retry a failed operation
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// Fatal error when content JSON fails to parse
  ///
  /// In en, this message translates to:
  /// **'Game data could not be loaded.'**
  String get errorContentLoad;

  /// Tagline under the game logo on the main menu. Describes the genre.
  ///
  /// In en, this message translates to:
  /// **'Dimensional Auto-Battle'**
  String get menuSubtitle;

  /// Settings screen: audio section heading
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get settingsSectionAudio;

  /// Settings screen: language section heading
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsSectionLanguage;

  /// Settings screen: account and legal section heading
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsSectionAccount;

  /// Badge on boss level nodes in level select
  ///
  /// In en, this message translates to:
  /// **'BOSS'**
  String get levelBoss;

  /// Victory screen: rewards panel heading
  ///
  /// In en, this message translates to:
  /// **'REWARDS'**
  String get resultRewardsTitle;

  /// Victory screen: soft meta currency name
  ///
  /// In en, this message translates to:
  /// **'Rift Shard'**
  String get resultRewardShards;

  /// Victory screen: hard currency name, first-clear bonus
  ///
  /// In en, this message translates to:
  /// **'Aether Cell'**
  String get resultRewardCells;

  /// Unit name for Pulse Guard
  ///
  /// In en, this message translates to:
  /// **'Pulse Guard'**
  String get unitPulseGuard;

  /// Unit name for Arc Ranger
  ///
  /// In en, this message translates to:
  /// **'Arc Ranger'**
  String get unitArcRanger;

  /// Unit name for Titan Frame
  ///
  /// In en, this message translates to:
  /// **'Titan Frame'**
  String get unitTitanFrame;

  /// Title of the pause overlay dialog during battle
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get battlePauseTitle;

  /// Button to resume the battle from pause overlay
  ///
  /// In en, this message translates to:
  /// **'RESUME'**
  String get battleResume;

  /// Hint displayed when ability aiming mode is active
  ///
  /// In en, this message translates to:
  /// **'TAP TARGET TO CAST'**
  String get battleAimHint;

  /// Label displayed on boss waves
  ///
  /// In en, this message translates to:
  /// **'BOSS WAVE'**
  String get hudBossWave;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'id',
    'it',
    'ja',
    'ko',
    'pt',
    'ru',
    'th',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
