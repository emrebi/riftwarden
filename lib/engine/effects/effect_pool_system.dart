import 'package:riftwarden/engine/effects/effect_entity.dart';
import 'package:riftwarden/engine/simulation/battle_simulation.dart';
import 'package:riftwarden/engine/simulation/battle_system.dart';

/// `aetherMote` parcaciginin yukari suzulme ivmesi (birim/s^2, normalize
/// alan uzayinda). Y ekseni asagi buyudugu icin (Core alanin altinda,
/// bkz. `BattleWorld.coreY` = 0.86) "yukari" NEGATIF y demektir.
const double kAetherMoteLift = 0.06;

/// Hiz sonumleme orani (1/s). Her adimda `vx`/`vy` bu oranla azalir; parcacik
/// zamanla yavaslar (brief: "yercekimi/surukleme gibi basit hareket").
const double kEffectDrag = 2.5;

/// Gorsel efekt parcaciklarinin omru ve ekran sarsintisi sonumu.
///
/// [SystemPhase.effects]: combat/economy'den SONRA, compaction'dan ONCE.
/// Bu faz SIMULASYON SONUCUNU DEGISTIRMEZ (bkz. `SystemPhase.effects`
/// dosya basi yorumu) — sadece `BattleWorld.effects` havuzundaki
/// parcaciklarin yasini ilerletir ve `ScreenShake`i sonumler. Diger
/// sistemler (`CombatSystem`, `MovementSystem`, `AbilitySystem`) olay
/// aninda `BattleWorld.emitEffect` ile parcacik talep eder; bu sistem
/// SADECE zaten var olanlari yaslandirir.
class EffectSystem implements BattleSystem {
  @override
  SystemPhase get phase => SystemPhase.effects;

  @override
  void onBattleStart(BattleSimulation sim) {}

  @override
  void step(BattleSimulation sim, double dt) {
    final world = sim.world;
    final effects = world.effects;

    for (var i = 0; i < effects.activeCount; i++) {
      final effect = effects[i];
      if (effect.pendingRemove) continue;

      effect.age += dt;
      if (effect.age >= effect.lifetime) {
        effect.pendingRemove = true;
        continue;
      }

      effect.prevX = effect.x;
      effect.prevY = effect.y;

      if (effect.kind == EffectKind.aetherMote) {
        effect.vy -= kAetherMoteLift * dt;
      }

      // Sonumleme: `1 - drag*dt` cok buyuk dt'lerde negatife dusebilir diye
      // 0'da kirpilir (bkz. `kFixedTimeStep` 1/60'ta pratikte hicbir zaman
      // olmaz, ama savunmaci kalinir).
      final dragFactor = (1 - kEffectDrag * dt).clamp(0.0, 1.0);
      effect.vx *= dragFactor;
      effect.vy *= dragFactor;

      effect.x += effect.vx * dt;
      effect.y += effect.vy * dt;
    }

    // Ekran sarsintisi burada sonumlenir: bu faz "gorsel, simulasyonu
    // etkilemez" ilkesiyle birebir ayni kategoridedir (bkz. dosya basi
    // yorumu) ve sabit adimla calistigi icin sarsinti deterministiktir.
    world.screenShake.update(dt);
  }

  @override
  void onBattleEnd(BattleSimulation sim) {}
}
