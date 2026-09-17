// Yatay menu ekranlarinin farkli yuzey boyutlarinda tasma/exception
// uretmedigini dogrulayan duman testi. Nabiz gibi sonsuz animasyonlar
// oldugundan pumpAndSettle KULLANILMAZ; sabit sureli pump yeterlidir.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riftwarden/app/theme/app_theme.dart';
import 'package:riftwarden/content/loader/content_loader.dart';
import 'package:riftwarden/content/registry/content_registry.dart';
import 'package:riftwarden/content/schema/schema.dart';
import 'package:riftwarden/core/services/orientation_service.dart';
import 'package:riftwarden/core/services/service_providers.dart';
import 'package:riftwarden/engine/bridge/battle_signals.dart';
import 'package:riftwarden/features/battle/view/battle_screen.dart';
import 'package:riftwarden/features/battle/widgets/ability_button.dart';
import 'package:riftwarden/features/battle/widgets/battle_top_bar.dart';
import 'package:riftwarden/features/battle/widgets/core_health_bar.dart';
import 'package:riftwarden/features/battle/widgets/unit_spawn_bar.dart';
import 'package:riftwarden/features/battle/widgets/upgrade_choice_overlay.dart';
import 'package:riftwarden/features/boot/view/boot_screen.dart';
import 'package:riftwarden/features/boot/view/widget_gallery.dart';
import 'package:riftwarden/features/level_select/view/level_select_data.dart';
import 'package:riftwarden/features/level_select/view/level_select_screen.dart';
import 'package:riftwarden/features/main_menu/view/main_menu_screen.dart';
import 'package:riftwarden/features/orientation_gate/view/orientation_gate_screen.dart';
import 'package:riftwarden/features/result/view/result_data.dart';
import 'package:riftwarden/features/result/view/result_screen.dart';
import 'package:riftwarden/features/settings/view/settings_screen.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';
import 'package:riftwarden/shared/widgets/rw_art.dart';
import 'package:riftwarden/shared/widgets/rw_button.dart';
import 'package:riftwarden/shared/widgets/rw_card.dart';

class _FakeOrientationService extends OrientationService {
  int lockLandscapeCallCount = 0;

  @override
  Future<void> lockLandscape() async {
    lockLandscapeCallCount++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const surfaces = <(String, Size)>[
    ('640x360', Size(1920, 1080)),
    ('800x360', Size(2400, 1080)),
  ];

  void noop() {}

  Widget wrap(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.build(const Locale('en')),
        locale: const Locale('en'),
        home: child,
      ),
    );
  }

  const sampleSectors = <SectorData>[
    SectorData(
      sectorId: 1,
      name: 'Fractured Edge',
      isLocked: false,
      completedCount: 2,
      levels: <LevelNodeData>[
        LevelNodeData(levelId: 1, state: LevelNodeState.completed, isBoss: false),
        LevelNodeData(levelId: 2, state: LevelNodeState.completed, isBoss: false),
        LevelNodeData(levelId: 3, state: LevelNodeState.current, isBoss: false),
        LevelNodeData(levelId: 4, state: LevelNodeState.locked, isBoss: false),
        LevelNodeData(levelId: 5, state: LevelNodeState.locked, isBoss: true),
      ],
    ),
  ];

  for (final (label, physicalSize) in surfaces) {
    group('$label yuzeyinde', () {
      setUp(() {});

      Future<void> setSurface(WidgetTester tester) async {
        final view = tester.view;
        view.physicalSize = physicalSize;
        view.devicePixelRatio = 3.0;
        addTearDown(view.resetPhysicalSize);
        addTearDown(view.resetDevicePixelRatio);
      }

      testWidgets('BootScreen tasmiyor', (WidgetTester tester) async {
        await setSurface(tester);
        await tester.pumpWidget(wrap(const BootScreen()));
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
        final scaffoldSize = tester.getSize(find.byType(Scaffold).first);
        expect(scaffoldSize, physicalSize / 3.0);
      });

      testWidgets('MainMenuScreen tasmiyor', (WidgetTester tester) async {
        await setSurface(tester);
        await tester.pumpWidget(
          wrap(
            MainMenuScreen(
              sectorNumber: 1,
              levelNumber: 3,
              sectorProgress: 0.45,
              shards: 120,
              cells: 5,
              onPlay: noop,
              onStore: noop,
              onUpgrades: noop,
              onSettings: noop,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
        final scaffoldSize = tester.getSize(find.byType(Scaffold).first);
        expect(scaffoldSize, physicalSize / 3.0);
      });

      testWidgets('SettingsScreen tasmiyor', (WidgetTester tester) async {
        await setSurface(tester);
        await tester.pumpWidget(
          wrap(
            SettingsScreen(
              soundEnabled: true,
              musicEnabled: true,
              hapticsEnabled: false,
              currentLanguageLabel: 'Turkce',
              versionLabel: 'v1.0.0',
              onSoundChanged: (bool value) {},
              onMusicChanged: (bool value) {},
              onHapticsChanged: (bool value) {},
              onLanguageTap: noop,
              onRestorePurchases: noop,
              onPrivacyTap: noop,
              onBack: noop,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
        final scaffoldSize = tester.getSize(find.byType(Scaffold).first);
        expect(scaffoldSize, physicalSize / 3.0);
      });

      testWidgets('LevelSelectScreen tasmiyor', (WidgetTester tester) async {
        await setSurface(tester);
        await tester.pumpWidget(
          wrap(
            LevelSelectScreen(
              sectors: sampleSectors,
              shards: 120,
              onLevelTap: (int levelId) {},
              onBack: noop,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
        final scaffoldSize = tester.getSize(find.byType(Scaffold).first);
        expect(scaffoldSize, physicalSize / 3.0);
      });

      testWidgets('ResultScreen (zafer) tasmiyor', (WidgetTester tester) async {
        await setSurface(tester);
        await tester.pumpWidget(
          wrap(
            ResultScreen(
              data: const BattleResultData(
                kind: BattleResultKind.victory,
                levelNumber: 3,
                shardsEarned: 25,
                cellsEarned: 3,
                wavesCleared: 8,
                totalWaves: 8,
                canWatchAd: true,
              ),
              onPrimary: noop,
              onWatchAd: noop,
              onMainMenu: noop,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
        final scaffoldSize = tester.getSize(find.byType(Scaffold).first);
        expect(scaffoldSize, physicalSize / 3.0);
      });

      testWidgets('ResultScreen (yenilgi) tasmiyor', (WidgetTester tester) async {
        await setSurface(tester);
        await tester.pumpWidget(
          wrap(
            ResultScreen(
              data: const BattleResultData(
                kind: BattleResultKind.defeat,
                levelNumber: 3,
                shardsEarned: 0,
                cellsEarned: 0,
                wavesCleared: 6,
                totalWaves: 8,
                canWatchAd: true,
              ),
              onPrimary: noop,
              onWatchAd: noop,
              onMainMenu: noop,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
        final scaffoldSize = tester.getSize(find.byType(Scaffold).first);
        expect(scaffoldSize, physicalSize / 3.0);
      });
    });
  }

  group('OrientationGateScreen', () {
    Future<void> setSurface(WidgetTester tester, Size physicalSize) async {
      final view = tester.view;
      view.physicalSize = physicalSize;
      view.devicePixelRatio = 3.0;
      addTearDown(view.resetPhysicalSize);
      addTearDown(view.resetDevicePixelRatio);
    }

    Widget wrapWithService(Widget child, OrientationService service) {
      return ProviderScope(
        overrides: [
          orientationServiceProvider.overrideWithValue(service),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.build(const Locale('en')),
          locale: const Locale('en'),
          home: child,
        ),
      );
    }

    testWidgets('360x640 DIKEY yuzeyde tasma yok', (WidgetTester tester) async {
      const physicalSize = Size(1080, 1920);
      await setSurface(tester, physicalSize);

      final service = _FakeOrientationService();
      await tester.pumpWidget(
        wrapWithService(OrientationGateScreen(onReady: noop), service),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      final scaffoldSize = tester.getSize(find.byType(Scaffold).first);
      expect(scaffoldSize, physicalSize / 3.0);
    });

    testWidgets('640x360 YATAY yuzeyde onReady cagrilir', (WidgetTester tester) async {
      const physicalSize = Size(1920, 1080);
      await setSurface(tester, physicalSize);

      final service = _FakeOrientationService();
      var onReadyCalled = false;
      await tester.pumpWidget(
        wrapWithService(
          OrientationGateScreen(onReady: () => onReadyCalled = true),
          service,
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(onReadyCalled, isTrue);
      expect(service.lockLandscapeCallCount, 1);
    });
  });

  group('BattleScreen', () {
    late ContentRegistry content;

    setUpAll(() async {
      content = await const ContentLoader().load();
    });

    Future<void> setSurface(WidgetTester tester, Size physicalSize) async {
      final view = tester.view;
      view.physicalSize = physicalSize;
      view.devicePixelRatio = 3.0;
      addTearDown(view.resetPhysicalSize);
      addTearDown(view.resetDevicePixelRatio);
    }

    Widget wrapBattle() {
      return ProviderScope(
        overrides: [
          contentRegistryProvider.overrideWithValue(content),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.build(const Locale('en')),
          locale: const Locale('en'),
          home: BattleScreen(levelId: 1, onExit: noop),
        ),
      );
    }

    const battleSurfaces = <(String, Size)>[
      ('640x360', Size(1920, 1080)),
      ('800x360', Size(2400, 1080)),
    ];

    for (final (label, physicalSize) in battleSurfaces) {
      testWidgets('$label yuzeyinde tasmiyor', (WidgetTester tester) async {
        await setSurface(tester, physicalSize);
        await tester.pumpWidget(wrapBattle());
        await tester.pump(const Duration(milliseconds: 200));

        final stackSize = tester.getSize(find.byType(Stack).first);
        expect(stackSize, physicalSize / 3.0);

        const hudTypes = <Type>[
          AbilityButton,
          BattleTopBar,
          CoreHealthBar,
          UnitSpawnBar,
        ];
        for (final hudType in hudTypes) {
          final finder = find.byWidgetPredicate(
            (Widget widget) => widget.runtimeType == hudType,
          );
          expect(finder, findsOneWidget, reason: '$hudType agacta bulunamadi');
          final size = tester.getSize(finder);
          expect(size.width, greaterThan(0.0), reason: '$hudType genisligi 0');
        }

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('WidgetGallery', () {
    const gallerySurfaces = <(String, Size)>[
      ('640x360', Size(1920, 1080)),
      ('800x360', Size(2400, 1080)),
    ];
    const galleryLocales = <Locale>[Locale('en'), Locale('ar')];

    Future<void> setSurface(WidgetTester tester, Size physicalSize) async {
      final view = tester.view;
      view.physicalSize = physicalSize;
      view.devicePixelRatio = 3.0;
      addTearDown(view.resetPhysicalSize);
      addTearDown(view.resetDevicePixelRatio);
    }

    Widget wrapGallery(Locale locale) {
      return ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.build(locale),
          locale: locale,
          home: const WidgetGallery(),
        ),
      );
    }

    for (final (label, physicalSize) in gallerySurfaces) {
      for (final locale in galleryLocales) {
        testWidgets(
          '$label yuzeyinde (${locale.languageCode}) tasma/exception yok',
          (WidgetTester tester) async {
            await setSurface(tester, physicalSize);
            await tester.pumpWidget(wrapGallery(locale));
            await tester.pump(const Duration(milliseconds: 300));

            expect(tester.takeException(), isNull);

            if (locale.languageCode == 'ar') {
              final directionality = tester.widget<Directionality>(
                find
                    .ancestor(
                      of: find.byType(WidgetGallery),
                      matching: find.byType(Directionality),
                    )
                    .first,
              );
              expect(directionality.textDirection, TextDirection.rtl);
            }

            final scrollableFinder = find.byType(Scrollable).first;

            // Galerinin tum bolumlerinin build edildigini garanti etmek
            // icin asagi dogru tekrar tekrar surukle; her adimda exception
            // ve overflow kontrolu yapilir.
            for (var i = 0; i < 12; i++) {
              await tester.drag(scrollableFinder, const Offset(0, -400));
              await tester.pump(const Duration(milliseconds: 100));
              expect(tester.takeException(), isNull);
            }

            await tester.pump(const Duration(milliseconds: 300));
            expect(tester.takeException(), isNull);
          },
        );
      }
    }

    testWidgets('RwArt eksik id icin fallback gosterir', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const Center(
            child: RwArt(
              group: RwArtGroup.icons,
              id: 'definitely_missing',
              fallback: SizedBox(key: ValueKey('rwart-fallback')),
            ),
          ),
        ),
      );

      // Image.asset hata callback'i asenkron cozulur; bir kac pump ile
      // microtask/timer kuyrugunun bosalmasini bekle.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('rwart-fallback')), findsOneWidget);
    });
  });

  group('UpgradeChoiceOverlay', () {
    late ContentRegistry content;
    late List<String> cardUpgradeIds;

    setUpAll(() async {
      content = await const ContentLoader().load();
      // Sadece esik karti (source == card) havuzundan id secilir; shop
      // aileleri bu katmanda hic gorunmez (bkz. UpgradeSource dokumani).
      cardUpgradeIds = content.upgrades.values
          .where((config) => config.source == UpgradeSource.card)
          .map((config) => config.id)
          .toList(growable: false);
    });

    Future<void> setSurface(WidgetTester tester, Size physicalSize) async {
      final view = tester.view;
      view.physicalSize = physicalSize;
      view.devicePixelRatio = 3.0;
      addTearDown(view.resetPhysicalSize);
      addTearDown(view.resetDevicePixelRatio);
    }

    Widget wrapOverlay(Widget child, Locale locale) {
      return ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.build(locale),
          locale: locale,
          home: Scaffold(body: child),
        ),
      );
    }

    const overlaySurfaces = <(String, Size)>[
      ('640x360', Size(1920, 1080)),
      ('800x360', Size(2400, 1080)),
    ];
    const overlayLocales = <Locale>[Locale('en'), Locale('ar')];

    for (final (label, physicalSize) in overlaySurfaces) {
      for (final locale in overlayLocales) {
        testWidgets(
          '$label yuzeyinde (${locale.languageCode}) 3 kartli teklif tasmiyor',
          (WidgetTester tester) async {
            await setSurface(tester, physicalSize);
            final offer = ValueNotifier<UpgradeOffer?>(
              UpgradeOffer(
                upgradeIds: cardUpgradeIds.take(3).toList(growable: false),
                rerollsLeft: 1,
              ),
            );
            addTearDown(offer.dispose);

            await tester.pumpWidget(
              wrapOverlay(
                UpgradeChoiceOverlay(
                  offer: offer,
                  upgrades: content.upgrades,
                  onChoose: (String id) {},
                  onReroll: () {},
                ),
                locale,
              ),
            );
            await tester.pump(const Duration(milliseconds: 400));

            expect(tester.takeException(), isNull);
            expect(find.byType(RwCard), findsNWidgets(3));
          },
        );
      }
    }

    testWidgets('tek kartli teklif ortalanmis sekilde gosterilir', (
      WidgetTester tester,
    ) async {
      await setSurface(tester, const Size(1920, 1080));
      final offer = ValueNotifier<UpgradeOffer?>(
        UpgradeOffer(
          upgradeIds: cardUpgradeIds.take(1).toList(growable: false),
          rerollsLeft: 0,
        ),
      );
      addTearDown(offer.dispose);

      await tester.pumpWidget(
        wrapOverlay(
          UpgradeChoiceOverlay(
            offer: offer,
            upgrades: content.upgrades,
            onChoose: (String id) {},
            onReroll: () {},
          ),
          const Locale('en'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.takeException(), isNull);
      expect(find.byType(RwCard), findsOneWidget);
    });

    testWidgets('kart secimi tam bir kez onChoose tetikler, ikinci dokunus yok sayilir', (
      WidgetTester tester,
    ) async {
      await setSurface(tester, const Size(1920, 1080));
      final offer = ValueNotifier<UpgradeOffer?>(
        UpgradeOffer(
          upgradeIds: cardUpgradeIds.take(3).toList(growable: false),
          rerollsLeft: 1,
        ),
      );
      addTearDown(offer.dispose);
      final chosen = <String>[];

      await tester.pumpWidget(
        wrapOverlay(
          UpgradeChoiceOverlay(
            offer: offer,
            upgrades: content.upgrades,
            onChoose: chosen.add,
            onReroll: () {},
          ),
          const Locale('en'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      final firstCard = find.byType(RwCard).first;
      await tester.tap(firstCard);
      await tester.pump();
      await tester.tap(firstCard);
      await tester.pump();

      expect(chosen, <String>[cardUpgradeIds[0]]);
    });

    testWidgets(
      'softlock duzeltmesi: ayni teklif tekrar geldiginde secim tekrar calisir',
      (WidgetTester tester) async {
        await setSurface(tester, const Size(1920, 1080));
        final offer = ValueNotifier<UpgradeOffer?>(
          UpgradeOffer(
            upgradeIds: cardUpgradeIds.take(3).toList(growable: false),
            rerollsLeft: 1,
          ),
        );
        addTearDown(offer.dispose);
        final chosen = <String>[];

        await tester.pumpWidget(
          wrapOverlay(
            UpgradeChoiceOverlay(
              offer: offer,
              upgrades: content.upgrades,
              onChoose: chosen.add,
              onReroll: () {},
            ),
            const Locale('en'),
          ),
        );
        await tester.pump(const Duration(milliseconds: 400));

        await tester.tap(find.byType(RwCard).first);
        await tester.pump();
        expect(chosen, <String>[cardUpgradeIds[0]]);

        // Motor secim sonrasi teklifi null yapar.
        offer.value = null;
        await tester.pump();
        expect(find.byType(RwCard), findsNothing);

        // Ayni id'lerle (esit) yeni bir teklif geri gelir (BATTLE-01 senaryosu).
        offer.value = UpgradeOffer(
          upgradeIds: cardUpgradeIds.take(3).toList(growable: false),
          rerollsLeft: 1,
        );
        await tester.pump(const Duration(milliseconds: 400));

        await tester.tap(find.byType(RwCard).first);
        await tester.pump();

        expect(chosen, <String>[cardUpgradeIds[0], cardUpgradeIds[0]]);
      },
    );

    testWidgets('reroll hakki varken buton onReroll tetikler', (
      WidgetTester tester,
    ) async {
      await setSurface(tester, const Size(1920, 1080));
      final offer = ValueNotifier<UpgradeOffer?>(
        UpgradeOffer(
          upgradeIds: cardUpgradeIds.take(3).toList(growable: false),
          rerollsLeft: 2,
        ),
      );
      addTearDown(offer.dispose);
      var rerollCount = 0;

      await tester.pumpWidget(
        wrapOverlay(
          UpgradeChoiceOverlay(
            offer: offer,
            upgrades: content.upgrades,
            onChoose: (String id) {},
            onReroll: () => rerollCount++,
          ),
          const Locale('en'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.byType(RwButton));
      await tester.pump();

      expect(rerollCount, 1);
    });

    testWidgets('reroll hakki yokken buton onReroll tetiklemez', (
      WidgetTester tester,
    ) async {
      await setSurface(tester, const Size(1920, 1080));
      final offer = ValueNotifier<UpgradeOffer?>(
        UpgradeOffer(
          upgradeIds: cardUpgradeIds.take(3).toList(growable: false),
          rerollsLeft: 0,
        ),
      );
      addTearDown(offer.dispose);
      var rerollCount = 0;

      await tester.pumpWidget(
        wrapOverlay(
          UpgradeChoiceOverlay(
            offer: offer,
            upgrades: content.upgrades,
            onChoose: (String id) {},
            onReroll: () => rerollCount++,
          ),
          const Locale('en'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.byType(RwButton));
      await tester.pump();

      expect(rerollCount, 0);
    });

    testWidgets('teklif null iken katman hicbir kart cizmez', (
      WidgetTester tester,
    ) async {
      await setSurface(tester, const Size(1920, 1080));
      final offer = ValueNotifier<UpgradeOffer?>(null);
      addTearDown(offer.dispose);

      await tester.pumpWidget(
        wrapOverlay(
          UpgradeChoiceOverlay(
            offer: offer,
            upgrades: content.upgrades,
            onChoose: (String id) {},
            onReroll: () {},
          ),
          const Locale('en'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.takeException(), isNull);
      expect(find.byType(RwCard), findsNothing);
    });
  });
}
