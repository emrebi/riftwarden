import 'package:riftwarden/content/schema/level_config.dart';
import 'package:riftwarden/domain/rules/rng_source.dart';

/// Bir dusman spawn olayi. Level basindan itibaren gecen sureye ("time")
/// gore sicaklama tablosuna yazilir; motor bu listeyi zaman sirasiyla
/// tuketir.
class SpawnEvent {
  const SpawnEvent({
    required this.time,
    required this.enemyId,
    required this.laneId,
    required this.isElite,
    required this.waveIndex,
  });

  final double time;
  final String enemyId;
  final String laneId;
  final bool isElite;

  /// `level.waves` icindeki 0-tabanli konum (wave id DEGIL — waveId icerik
  /// yazarinin verdigi keyfi bir numaradir, HUD'daki "Wave X / Y" ise
  /// listedeki SIRAYA gore sayilir). WaveSystem bunu ilerleme ve zafer
  /// kontrolu icin kullanir; SpawnEvent'te bu bilgi olmadan motor "su an
  /// hangi dalgadayiz" sorusunu spawn zamanindan tersine cikarmak zorunda
  /// kalirdi.
  final int waveIndex;
}

/// `LevelConfig`'i calistirilabilir bir spawn takvimine cevirir.
///
/// Bu sadece bir level baslarken (veya yeniden denenirken) bir kez calisir;
/// motor sonucu (siralanmis `List<SpawnEvent>`) tuketir, kendisi savas
/// dongusunun bir parcasi degildir.
abstract final class WavePlanner {
  const WavePlanner._();

  static List<SpawnEvent> plan(LevelConfig level, RngSource rng) {
    final events = <SpawnEvent>[];

    // Dalgalar sirali kosar: bir dalganin TUM spawn'lari bitmeden sonraki
    // dalganin delay'i baslamaz. Bu yuzden "bir sonraki dalganin baslangic
    // zamani" o ana kadarki en gec spawn zamanindan hesaplanir.
    var waveCursor = 0.0;

    for (var waveIndex = 0; waveIndex < level.waves.length; waveIndex++) {
      final wave = level.waves[waveIndex];
      final waveStart = waveCursor + wave.delay;
      var latestEventEnd = waveStart;

      for (final group in wave.groups) {
        final groupStart = waveStart + group.delay;
        var latestInGroup = groupStart;

        for (var i = 0; i < group.count; i++) {
          final spawnTime = groupStart + group.interval * i;
          final isElite = group.eliteChance > 0 && rng.chance(group.eliteChance);

          events.add(SpawnEvent(
            time: spawnTime,
            enemyId: group.enemy,
            laneId: group.lane,
            isElite: isElite,
            waveIndex: waveIndex,
          ));

          latestInGroup = spawnTime;
        }

        if (latestInGroup > latestEventEnd) {
          latestEventEnd = latestInGroup;
        }
      }

      waveCursor = latestEventEnd;
    }

    events.sort((a, b) => a.time.compareTo(b.time));
    return events;
  }
}
