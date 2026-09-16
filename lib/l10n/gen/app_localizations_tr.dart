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
  String upgradeRerollsLeft(int count) {
    return '$count kaldı';
  }

  @override
  String get rarityCommon => 'Sıradan';

  @override
  String get rarityRare => 'Nadir';

  @override
  String get rarityEpic => 'Epik';

  @override
  String get rarityLegendary => 'Efsanevi';

  @override
  String get upgradeArcChain1 => 'Zincir Şimşek';

  @override
  String get upgradeArcChain1Desc => '+1 zincir hedefi';

  @override
  String get upgradeArcChain2 => 'Zincir Aşırı Yük';

  @override
  String get upgradeArcChain2Desc => '+1 zincir hedefi';

  @override
  String get upgradePulsePierce1 => 'Delici Mermiler';

  @override
  String get upgradePulsePierce1Desc => '+2 hasar. Mermiler 1 düşmanı deler';

  @override
  String get upgradePulsePierce2 => 'Derin Delme';

  @override
  String get upgradePulsePierce2Desc => '+1 delme sayısı';

  @override
  String get upgradeArcCrit1 => 'Kritik Odak';

  @override
  String get upgradeArcCrit1Desc => '+%10 kritik şans';

  @override
  String get upgradeArcCrit2 => 'Kritik Yükseliş';

  @override
  String get upgradeArcCrit2Desc => '+%50 kritik hasar';

  @override
  String get upgradeTitanExplosion1 => 'Patlama Yarıçapı';

  @override
  String get upgradeTitanExplosion1Desc => 'Patlama yarıçapı artar';

  @override
  String get upgradeTitanExplosion2 => 'Aşırı Basınç';

  @override
  String get upgradeTitanExplosion2Desc => '+%15 hasar';

  @override
  String get upgradePulseSwarm1 => 'Hızlı Mermiler';

  @override
  String get upgradePulseSwarm1Desc => '+1 hasar';

  @override
  String get upgradePulseSwarm2 => 'Sürü Çılgınlığı';

  @override
  String get upgradePulseSwarm2Desc => '+%10 atış hızı';

  @override
  String get upgradeAetherEconomy1 => 'Taşma Deposu';

  @override
  String get upgradeAetherEconomy1Desc => '+5 Aether geliri';

  @override
  String get upgradeCoreShield1 => 'Yenilenen Kalkan';

  @override
  String get upgradeCoreShield1Desc => '+100 azami can';

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

  @override
  String get resultRewardsTitle => 'ODULLER';

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
  String get battlePauseTitle => 'DURAKLATILDI';

  @override
  String get battleResume => 'DEVAM ET';

  @override
  String get battleAimHint => 'HEDEFE DOKUN';

  @override
  String get hudBossWave => 'BOSS DALGASI';

  @override
  String get rotateTitle => 'Cihazını çevir';

  @override
  String get rotateHint => 'Oynamak için telefonunu yan çevir';

  @override
  String rotateAutoIn(int seconds) {
    return '$seconds sn sonra yataya geçiliyor';
  }

  @override
  String get rotateTapToContinue => 'Devam etmek için dokun';

  @override
  String get hudCastle => 'Kale';

  @override
  String get hudAbilities => 'Yetenekler';

  @override
  String get hudSlotsFull => 'Dolu';

  @override
  String get hudBuy => 'SATIN AL';

  @override
  String get hudOwned => 'SAHİP';

  @override
  String get upgradePulseGuardDualshot => 'Çift Atış';

  @override
  String get upgradePulseGuardDualshotDesc => '+%40 Atış Hızı';

  @override
  String get upgradePulseGuardOvercharge => 'Aşırı Yükleme';

  @override
  String get upgradePulseGuardOverchargeDesc => '+4 Hasar';

  @override
  String get upgradeArcRangerOvercharge => 'Zincir Aşırı Yükleme';

  @override
  String get upgradeArcRangerOverchargeDesc => '+2 Zincir Hedefi';

  @override
  String get upgradeArcRangerFocus => 'Odak';

  @override
  String get upgradeArcRangerFocusDesc => '+%15 Kritik Şans';

  @override
  String get upgradeTitanFrameShockwave => 'Şok Dalgası';

  @override
  String get upgradeTitanFrameShockwaveDesc => 'Patlama Yarıçapı + Geri Tepme';

  @override
  String get upgradeTitanFrameJuggernaut => 'Devbaş';

  @override
  String get upgradeTitanFrameJuggernautDesc => '+10 Hasar, +50 Can';
}
