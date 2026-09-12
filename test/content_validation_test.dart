// Icerik JSON dosyalarinin semaya ve capraz referanslara uydugunu dogrular.
//
// Neden bu test var: icerik artik koddan ayri (`assets/content/*.json`).
// Bir level dosyasinda yazim hatasi (var olmayan lane id'si, enemy id'si vb.)
// derleme zamaninda YAKALANMAZ, sadece calisma zamaninda patlar. Bu test
// o hatalari CI'da/analyze asamasinda yakalar.
import 'package:flutter_test/flutter_test.dart';
import 'package:riftwarden/content/loader/content_loader.dart';
import 'package:riftwarden/content/registry/content_registry.dart';

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
  });

  test('her lane.from var olan bir rift.id\'ye isaret eder', () {
    for (final level in registry.levels.values) {
      final riftIds = level.rifts.map((r) => r.id).toSet();
      for (final lane in level.lanes) {
        expect(
          riftIds.contains(lane.from),
          isTrue,
          reason: 'level ${level.levelId}: lane "${lane.id}" bilinmeyen rift '
              '"${lane.from}" isaret ediyor',
        );
      }
    }
  });

  test('her group.lane var olan bir lane.id\'ye isaret eder', () {
    for (final level in registry.levels.values) {
      final laneIds = level.lanes.map((l) => l.id).toSet();
      for (final wave in level.waves) {
        for (final group in wave.groups) {
          expect(
            laneIds.contains(group.lane),
            isTrue,
            reason: 'level ${level.levelId}, dalga ${wave.id}: grup bilinmeyen '
                'lane "${group.lane}" isaret ediyor',
          );
        }
      }
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
