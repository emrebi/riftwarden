// Icerik JSON dosyalarinin semaya ve capraz referanslara uydugunu dogrular.
//
// Neden bu test var: icerik artik koddan ayri (`assets/content/*.json`).
// Bir level dosyasinda yazim hatasi (var olmayan enemy id'si, castle id'si
// vb.) derleme zamaninda YAKALANMAZ, sadece calisma zamaninda patlar. Bu
// test o hatalari CI'da/analyze asamasinda yakalar.
import 'package:flutter_test/flutter_test.dart';
import 'package:riftwarden/content/loader/content_loader.dart';
import 'package:riftwarden/content/registry/content_registry.dart';
import 'package:riftwarden/content/schema/schema.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ContentRegistry registry;

  setUpAll(() async {
    registry = await const ContentLoader().load();
  });

  test('tum dosyalar hatasiz parse edilir', () {
    // setUpAll icinde ContentLoader().load() zaten atmadan tamamlandiysa
    // parse basarili demektir. Registry'nin bos olmadigini dogrula.
    expect(registry.units, isNotEmpty);
    expect(registry.enemies, isNotEmpty);
    expect(registry.upgrades, isNotEmpty);
    expect(registry.abilities, isNotEmpty);
    expect(registry.sectors, isNotEmpty);
    expect(registry.levels, isNotEmpty);
    expect(registry.castles, isNotEmpty);
    expect(registry.environments, isNotEmpty);
  });

  test('her level.castle.id castles.json icinde tanimli ve en az 1 yuvasi var', () {
    for (final level in registry.levels.values) {
      expect(
        registry.castles.containsKey(level.castle.id),
        isTrue,
        reason: 'level ${level.levelId}: bilinmeyen castle "${level.castle.id}"',
      );
      final castle = registry.castle(level.castle.id);
      expect(
        castle.slots, isNotEmpty,
        reason: 'castle "${castle.id}": en az 1 yuva olmali',
      );
    }
  });

  test('castle.wallX < level.defenseLineX < 1 ve 0 < wallX', () {
    for (final level in registry.levels.values) {
      final castle = registry.castle(level.castle.id);
      expect(
        castle.wallX > 0,
        isTrue,
        reason: 'castle "${castle.id}": wallX 0dan buyuk olmali',
      );
      expect(
        castle.wallX < level.defenseLineX,
        isTrue,
        reason: 'level ${level.levelId}: wallX (${castle.wallX}) < '
            'defenseLineX (${level.defenseLineX}) olmali',
      );
      expect(
        level.defenseLineX < 1,
        isTrue,
        reason: 'level ${level.levelId}: defenseLineX 1den kucuk olmali',
      );
    }
  });

  test('spawn.yMin < yMax, 0..1 icinde; grup band\'lari bu aralikta', () {
    for (final level in registry.levels.values) {
      final spawn = level.spawn;
      expect(spawn.yMin >= 0, isTrue, reason: 'level ${level.levelId}: yMin >= 0 olmali');
      expect(
        spawn.yMin < spawn.yMax,
        isTrue,
        reason: 'level ${level.levelId}: yMin < yMax olmali',
      );
      expect(spawn.yMax <= 1, isTrue, reason: 'level ${level.levelId}: yMax <= 1 olmali');

      for (final wave in level.waves) {
        for (final group in wave.groups) {
          final band = group.band;
          if (band == null) continue;
          expect(
            band.$1 >= spawn.yMin && band.$2 <= spawn.yMax && band.$1 < band.$2,
            isTrue,
            reason: 'level ${level.levelId}, dalga ${wave.id}: grup band '
                '$band spawn araligi [${spawn.yMin}, ${spawn.yMax}] disinda',
          );
        }
      }
    }
  });

  test('terrain.type slow veya cover; slow icin 0<factor<1, cover icin 0<damageTakenMul<1', () {
    for (final level in registry.levels.values) {
      for (final zone in level.terrain) {
        expect(
          zone.type == 'slow' || zone.type == 'cover',
          isTrue,
          reason: 'level ${level.levelId}: gecersiz terrain type "${zone.type}"',
        );
        if (zone.type == 'slow') {
          expect(
            zone.factor != null && zone.factor! > 0 && zone.factor! < 1,
            isTrue,
            reason: 'level ${level.levelId}: slow terrain icin 0<factor<1 olmali',
          );
        } else {
          expect(
            zone.damageTakenMul != null &&
                zone.damageTakenMul! > 0 &&
                zone.damageTakenMul! < 1,
            isTrue,
            reason: 'level ${level.levelId}: cover terrain icin 0<damageTakenMul<1 olmali',
          );
        }
      }
    }
  });

  test('level.environmentId environments.json icinde tanimli', () {
    for (final level in registry.levels.values) {
      expect(
        registry.environments.containsKey(level.environmentId),
        isTrue,
        reason: 'level ${level.levelId}: bilinmeyen environment '
            '"${level.environmentId}"',
      );
    }
  });

  test('her group.enemy enemies.json icinde tanimli', () {
    for (final level in registry.levels.values) {
      for (final wave in level.waves) {
        for (final group in wave.groups) {
          expect(
            registry.enemies.containsKey(group.enemy),
            isTrue,
            reason: 'level ${level.levelId}, dalga ${wave.id}: bilinmeyen '
                'enemy "${group.enemy}"',
          );
        }
      }
    }
  });

  test('her upgrade.stats[].target unit id, all, core, economy veya ability', () {
    const specialTargets = {'all', 'core', 'economy', 'ability'};
    for (final upgrade in registry.upgrades.values) {
      for (final stat in upgrade.stats) {
        final isValid = specialTargets.contains(stat.target) ||
            registry.units.containsKey(stat.target);
        expect(
          isValid,
          isTrue,
          reason: 'upgrade "${upgrade.id}": gecersiz stat target '
              '"${stat.target}"',
        );
      }
    }
  });

  test('her unit.targetPriority gecerli bir TargetPriority degeridir', () {
    for (final unit in registry.units.values) {
      expect(
        TargetPriority.values.contains(unit.targetPriority),
        isTrue,
        reason: 'unit "${unit.id}": targetPriority tanimsiz',
      );
    }
  });

  test(
    'shop upgrade\'lerinde cost > 0 ve unit var olan bir birlik; '
    'card upgrade\'lerinde cost yok',
    () {
      for (final upgrade in registry.upgrades.values) {
        if (upgrade.source == UpgradeSource.shop) {
          expect(
            upgrade.cost != null && upgrade.cost! > 0,
            isTrue,
            reason: 'upgrade "${upgrade.id}": shop icin cost > 0 olmali',
          );
          expect(
            upgrade.unit != null && registry.units.containsKey(upgrade.unit),
            isTrue,
            reason: 'upgrade "${upgrade.id}": shop icin gecerli bir "unit" olmali',
          );
        } else {
          expect(
            upgrade.cost,
            isNull,
            reason: 'upgrade "${upgrade.id}": card icin cost olmamali',
          );
        }
      }
    },
  );

  test('her upgrade.requires[] var olan bir upgrade id\'sine isaret eder', () {
    for (final upgrade in registry.upgrades.values) {
      for (final requiredId in upgrade.requires) {
        expect(
          registry.upgrades.containsKey(requiredId),
          isTrue,
          reason: 'upgrade "${upgrade.id}": bilinmeyen requires "$requiredId"',
        );
      }
    }
  });

  test('level id\'leri sektor araligiyla tutarli ve bosluksuz', () {
    for (final sectorId in registry.sectors.keys) {
      final expectedIds = List<int>.generate(5, (i) => (sectorId - 1) * 5 + 1 + i);
      final actualIds = registry.levelsOfSector(sectorId).map((l) => l.levelId).toList();
      expect(
        actualIds,
        expectedIds,
        reason: 'sektor $sectorId: level id\'leri beklenen aralikla '
            'esmesmiyor (beklenen: $expectedIds, bulunan: $actualIds)',
      );
    }
  });

  test('negatif hp/cost/count degeri yok', () {
    for (final unit in registry.units.values) {
      expect(unit.hp, greaterThanOrEqualTo(0), reason: 'unit "${unit.id}" hp');
      expect(unit.cost, greaterThanOrEqualTo(0), reason: 'unit "${unit.id}" cost');
    }
    for (final enemy in registry.enemies.values) {
      expect(enemy.hp, greaterThanOrEqualTo(0), reason: 'enemy "${enemy.id}" hp');
    }
    for (final level in registry.levels.values) {
      expect(level.coreHp, greaterThanOrEqualTo(0), reason: 'level ${level.levelId} coreHp');
      expect(
        level.startingAether,
        greaterThanOrEqualTo(0),
        reason: 'level ${level.levelId} startingAether',
      );
      for (final wave in level.waves) {
        for (final group in wave.groups) {
          expect(
            group.count,
            greaterThanOrEqualTo(0),
            reason: 'level ${level.levelId}, dalga ${wave.id}: grup count',
          );
        }
      }
    }
  });

  test('abilities.json her id gecerli sekilde cozulur', () {
    for (final id in registry.abilities.keys) {
      expect(registry.ability(id).id, id);
    }
  });

  test(
    'upgradeKillThresholds bos degil, pozitif, kesin artan, son esik '
    'toplam dusmanin %75\'ini gecmez',
    () {
      for (final level in registry.levels.values) {
        final thresholds = level.upgradeKillThresholds;
        expect(
          thresholds, isNotEmpty,
          reason: 'level ${level.levelId}: upgradeKillThresholds bos olamaz',
        );

        var totalEnemies = 0;
        for (final wave in level.waves) {
          for (final group in wave.groups) {
            totalEnemies += group.count;
          }
        }

        var previous = 0;
        for (final threshold in thresholds) {
          expect(
            threshold > 0,
            isTrue,
            reason: 'level ${level.levelId}: esik pozitif olmali ($threshold)',
          );
          expect(
            threshold > previous,
            isTrue,
            reason: 'level ${level.levelId}: esikler kesin artan olmali '
                '($thresholds)',
          );
          previous = threshold;
        }

        expect(
          thresholds.last <= totalEnemies * 0.75,
          isTrue,
          reason: 'level ${level.levelId}: son esik (${thresholds.last}) '
              'toplam dusmanin ($totalEnemies) %75\'ini gecmemeli',
        );
      }
    },
  );

  test('level.modifiers referanslari modifiers.json icinde cozulur', () {
    for (final level in registry.levels.values) {
      for (final modifierId in level.modifiers) {
        expect(
          registry.modifiers.containsKey(modifierId),
          isTrue,
          reason: 'level ${level.levelId}: bilinmeyen modifier "$modifierId"',
        );
      }
    }
  });
}
