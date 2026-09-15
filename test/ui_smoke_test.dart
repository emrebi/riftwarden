// Yatay menu ekranlarinin farkli yuzey boyutlarinda tasma/exception
// uretmedigini dogrulayan duman testi. Nabiz gibi sonsuz animasyonlar
// oldugundan pumpAndSettle KULLANILMAZ; sabit sureli pump yeterlidir.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riftwarden/app/theme/app_theme.dart';
import 'package:riftwarden/content/loader/content_loader.dart';
import 'package:riftwarden/content/registry/content_registry.dart';
import 'package:riftwarden/core/services/orientation_service.dart';
import 'package:riftwarden/core/services/service_providers.dart';
import 'package:riftwarden/features/battle/view/battle_screen.dart';
import 'package:riftwarden/features/battle/widgets/ability_button.dart';
import 'package:riftwarden/features/battle/widgets/battle_top_bar.dart';
import 'package:riftwarden/features/battle/widgets/core_health_bar.dart';
import 'package:riftwarden/features/battle/widgets/unit_spawn_bar.dart';
import 'package:riftwarden/features/boot/view/boot_screen.dart';
import 'package:riftwarden/features/level_select/view/level_select_data.dart';
import 'package:riftwarden/features/level_select/view/level_select_screen.dart';
import 'package:riftwarden/features/main_menu/view/main_menu_screen.dart';
import 'package:riftwarden/features/orientation_gate/view/orientation_gate_screen.dart';
import 'package:riftwarden/features/result/view/result_data.dart';
import 'package:riftwarden/features/result/view/result_screen.dart';
import 'package:riftwarden/features/settings/view/settings_screen.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';

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
}
