// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'RIFTWARDEN';

  @override
  String get menuPlay => 'OYNA';

  @override
  String get menuStore => 'MAĞAZA';

  @override
  String get menuUpgrades => 'GELİŞTİRMELER';

  @override
  String get menuSettings => 'AYARLAR';

  @override
  String sectorLabel(int number) {
    return 'SEKTÖR $number';
  }

  @override
  String levelLabel(int number) {
    return 'BÖLÜM $number';
  }

  @override
  String get levelLocked => 'KİLİTLİ';

  @override
  String get hudAether => 'Aether';

  @override
  String get hudCore => 'Çekirdek';

  @override
  String hudWave(int current, int total) {
    return 'Dalga $current/$total';
  }

  @override
  String get upgradeChooseTitle => 'BİR GELİŞTİRME SEÇ';

  @override
  String get upgradeReroll => 'Yenile';

  @override
  String get resultVictoryTitle => 'YARIK MÜHÜRLENDİ';

  @override
  String get resultDefeatTitle => 'ÇEKİRDEK ÇÖKTÜ';

  @override
  String get resultRetry => 'TEKRAR DENE';

  @override
  String get resultNextLevel => 'DEVAM';

  @override
  String get resultMainMenu => 'ANA MENÜ';

  @override
  String get resultWatchAdContinue => 'REKLAM İZLE VE DEVAM ET';

  @override
  String get resultDoubleReward => 'ÖDÜLÜ İKİYE KATLA';

  @override
  String get settingsSound => 'Ses';

  @override
  String get settingsMusic => 'Müzik';

  @override
  String get settingsHaptics => 'Titreşim';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsRestorePurchases => 'Satın Alımları Geri Yükle';

  @override
  String get settingsPrivacy => 'Gizlilik Politikası';

  @override
  String get storeRemoveAds => 'Reklamları Kaldır';

  @override
  String get storeRestoreDone => 'Satın alımlar geri yüklendi.';

  @override
  String get storePurchaseFailed => 'Satın alma tamamlanamadı.';

  @override
  String get commonCancel => 'İptal';

  @override
  String get commonClose => 'Kapat';

  @override
  String get commonLoading => 'Yükleniyor...';

  @override
  String get commonRetry => 'Tekrar Dene';

  @override
  String get errorContentLoad => 'Oyun verileri yüklenemedi.';

  @override
  String get menuSubtitle => 'Boyutlar Arasi Otomatik Savas';

  @override
  String get settingsSectionAudio => 'Ses';

  @override
  String get settingsSectionLanguage => 'Dil';

  @override
  String get settingsSectionAccount => 'Hesap';

  @override
  String get levelBoss => 'BOSS';
}
