// `TextStyle` `dart:ui` VE `package:flutter/painting.dart` icinde IKI FARKLI
// sinif olarak var: `TextSpan.style` painting.dart'inkini bekler. Bu yuzden
// dart:ui'dan gizlenip painting.dart'tan alinir (bkz. asagidaki import'lar).
import 'dart:ui' hide TextStyle;

import 'package:flame/components.dart' show Component;
import 'package:flame/sprite.dart' show SpriteBatch;
import 'package:flutter/painting.dart' show TextPainter, TextSpan, TextStyle;
import 'package:riftwarden/engine/effects/effect_entity.dart';
import 'package:riftwarden/engine/render/atlas_registry.dart';
import 'package:riftwarden/engine/render/field_projection.dart';
import 'package:riftwarden/engine/simulation/battle_simulation.dart';
import 'package:riftwarden/engine/simulation/battle_world.dart';

/// Gorsel efekt render'i: parcacik sprite'lari + hasar sayilari.
///
/// [BattleWorld]'u SADECE OKUR; `swarm_renderer.dart` deseninin birebir
/// ayni sekilde izlenmesi (tek [SpriteBatch] ornegi, component omru
/// boyunca yeniden kullanilir) burada da gecerlidir.
class EffectRenderer extends Component {
  EffectRenderer({
    required this.world,
    required this.sim,
    required this.atlas,
    required this.projection,
  });

  final BattleWorld world;
  final BattleSimulation sim;
  final AtlasRegistry atlas;
  final FieldProjection projection;

  static const double _frameSize = 128;

  /// Efekt basina buyume orani: yasi ilerledikce sprite ne kadar
  /// buyuyecegi (1.0 = degismez, 2.0 = iki katina cikar). Vurus
  /// kivilcimlari sabit kalir (ani, "pop" hissi); patlama/olum efektleri
  /// genisleyerek soner (bir sok dalgasi hissi).
  static const Map<EffectKind, double> _growthByKind = <EffectKind, double>{
    EffectKind.hitSpark: 1.1,
    EffectKind.deathPuff: 1.8,
    EffectKind.aetherMote: 1.0,
    EffectKind.coreImpact: 1.6,
    EffectKind.abilityBlast: 1.15,
  };

  /// Rift Collapse'in donen bir "girdap" hissi vermesi icin (bkz.
  /// `EffectEntity.rotation` dosya basi yorumu); diger turler donmez.
  static const double _abilityBlastAngularSpeed = 2.2;

  static const Color _hitNumberColor = Color(0xFFFFFFFF);
  static const Color _critNumberColor = Color(0xFFFFD43B);
  static const double _hitNumberFontSize = 13;
  static const double _critNumberFontSize = 19;

  /// Sayi yukari kayma hizi (normalize alan uzayi / saniye). Sayi okunsun
  /// diye vurus noktasindan yavasca yukari suzulur.
  static const double _numberRiseSpeed = 0.05;

  late final SpriteBatch _batch = SpriteBatch(atlas.imageOf('fx'));

  /// Hasar sayisi `TextPainter` onbellegi, havuz SLOT'una (dizin) gore
  /// indekslenir — entity KIMLIGINE gore degil.
  ///
  /// ## Neden bu sekilde onbellekleme
  /// Bir efektin `value`/`isCritical` degeri SADECE dogumunda belirlenir
  /// ve omru boyunca (tipik olarak 0.2-0.7s, yani ~12-40 kare) degismez.
  /// `TextPainter` her karede yeniden `layout()` etmek bu kadar kisa
  /// omurlerde bile onemli bir maliyet biriktirir (yuzlerce vurus/saniye
  /// olabilecek bir savasta). Havuz DIZINI (0..capacity-1) sabit sayida
  /// slot oldugu ve her slot ayni anda tek bir canli entity tasidigi icin,
  /// "bu slotta hala ayni deger mi cizili?" kontrolu (deger+kritiklik
  /// esitligi) `Map<Entity, Painter>` gibi bir kimlik tablosu tutmadan,
  /// basit bir dizi ile yapilabilir: slot yeni bir entity ile
  /// doldugunda (ya da ayni entity'nin degeri "degistiginde" — pratikte
  /// olmuyor ama savunmaci kalindi) painter yeniden kurulur, aksi halde
  /// AYNI painter nesnesi yeniden kullanilir. Bu, "entity basina bir kez
  /// layout()" ile "her karede layout()" arasindaki en ucuz yol: ekstra
  /// veri yapisi (LRU, hash map) gerektirmez, sadece havuzun zaten dizinli
  /// olma ozelligine dayanir.
  late final List<TextPainter?> _numberCache =
      List<TextPainter?>.filled(world.effects.capacity, null);
  late final List<int> _cachedValue = List<int>.filled(world.effects.capacity, 0);
  late final List<bool> _cachedCritical = List<bool>.filled(world.effects.capacity, false);
  late final List<bool> _cacheValid = List<bool>.filled(world.effects.capacity, false);

  @override
  void render(Canvas canvas) {
    _batch.clear();

    final effects = world.effects;
    final alpha = sim.alpha;

    for (var i = 0; i < effects.activeCount; i++) {
      final effect = effects[i];
      final ageRatio = effect.lifetime > 0 ? (effect.age / effect.lifetime).clamp(0.0, 1.0) : 1.0;

      final screenX = projection.toScreenX(projection.lerp(effect.prevX, effect.x, alpha));
      final screenY = projection.toScreenY(projection.lerp(effect.prevY, effect.y, alpha));

      final growth = _growthByKind[effect.kind] ?? 1.0;
      final currentScale = effect.scale * (1 + (growth - 1) * ageRatio);
      final visualSize = projection.toScreenSize(currentScale * 2);
      final spriteScale = visualSize / _frameSize;

      final rotation = effect.kind == EffectKind.abilityBlast
          ? effect.rotation + ageRatio * _abilityBlastAngularSpeed
          : effect.rotation;

      final source = atlas.rectOf('fx', effect.spriteIndex);
      // Yasi ilerledikce soluklas: `1 - ageRatio` dogrusal solma, "abartma"
      // kuralina uygun basit ve ucuz bir egri.
      final alphaByte = (255 * (1 - ageRatio)).round().clamp(0, 255);

      _batch.addTransform(
        source: source,
        transform: RSTransform.fromComponents(
          rotation: rotation,
          scale: spriteScale,
          anchorX: source.width / 2,
          anchorY: source.height / 2,
          translateX: screenX,
          translateY: screenY,
        ),
        color: Color.fromARGB(alphaByte, 255, 255, 255),
      );

      if (effect.value != 0) {
        _drawDamageNumber(canvas, i, effect, screenX, screenY, ageRatio);
      }
    }

    // Batch'teki her ogeye renk (alpha solma) verildigi icin `modulate`
    // gerekir (bkz. `swarm_renderer.dart` ayni gerekce).
    _batch.render(canvas, blendMode: BlendMode.modulate);
  }

  void _drawDamageNumber(
    Canvas canvas,
    int slot,
    EffectEntity effect,
    double screenX,
    double screenY,
    double ageRatio,
  ) {
    final valid = _cacheValid[slot] &&
        _cachedValue[slot] == effect.value &&
        _cachedCritical[slot] == effect.isCritical;

    final TextPainter painter;
    if (valid) {
      painter = _numberCache[slot]!;
    } else {
      painter = TextPainter(
        text: TextSpan(
          text: effect.value.toString(),
          style: TextStyle(
            color: effect.isCritical ? _critNumberColor : _hitNumberColor,
            fontSize: effect.isCritical ? _critNumberFontSize : _hitNumberFontSize,
            fontWeight: effect.isCritical ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      _numberCache[slot] = painter;
      _cachedValue[slot] = effect.value;
      _cachedCritical[slot] = effect.isCritical;
      _cacheValid[slot] = true;
    }

    // Sayi metni yeniden CIZILMEZ (bkz. onbellek yorumu); sadece cizim
    // konumu kaydirilir — yukari suzulme ve hafif solma bu yuzden
    // `Canvas.saveLayer` yerine dogrudan `Paint` ile degil, ofset ile
    // uygulanir (metin rengi sabit kalir, sadece dikey konum degisir).
    final riseOffset = projection.toScreenSize(_numberRiseSpeed * ageRatio * effect.lifetime);
    painter.paint(
      canvas,
      Offset(screenX - painter.width / 2, screenY - painter.height / 2 - riseOffset),
    );
  }
}
