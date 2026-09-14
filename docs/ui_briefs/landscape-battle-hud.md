# GOREV: YATAY SAVAS HUD'U, SAVASCI ALMA VE YETENEK DUKKANI

Once AGENTS.md dosyasini oku. Uygulama YATAY. Hedef en kucuk ekran 640x360 dp.

Once su dosyayi da oku: lib/engine/bridge/battle_signals.dart
- slots ve abilityShop sinyalleri yeni.
- BattleCommands'a buyAbility eklendi.
- Savas verisi Riverpod'dan DEGIL buradan okunur; her sinyal icin AYRI ValueListenableBuilder kullan.

Dosyalar: lib/features/battle/view/battle_screen.dart ve lib/features/battle/widgets/

KORUNACAKLAR (DEGISTIRME):
- body Stack'teki fit: StackFit.expand — kaldirilirsa ekran sessizce bos gorunur.
- GameWidget'in errorBuilder ve loadingBuilder'i.
- BattleScreen public constructor'u.
- Nisan alma katmani mantigi: dokunus ekran-normalize (0..1) koordinatla castAbilityAt'e gider.

Yeni yerlesim:
- Ust ince serit (yuksekligin ~%12'si): pause | dalga ilerlemesi (boss dalgasi vurgulu) | Aether sayaci (tabular rakam).
- Kale HP bari: ust seridin altinda, sol tarafta (kalenin ustu). Dusuk HP'de (< %25) renk degisimi + hafif nabiz.
- Alt serit (yuksekligin %20'sini GECMEZ):
  - Savasci alma butonlari: signals.unitCosts ve signals.aether ile birlikte signals.slots okunur.
    Buton uzerinde guncel maliyet; yuvalarin dolulugu "4/6" gibi gosterilir.
    Aether yetmezse VEYA bos yuva yoksa buton pasif gorunur ama gizlenmez.
    Basinca commands.requestUnit(unitId).
  - Her savasci butonunun yaninda kucuk "yetenekler" dokunma alani: o savascinin signals.abilityShop
    tekliflerini gosteren kompakt panel acar (sahip olunanlar isaretli, alinamayanlar pasif, maliyetler).
    Satin alma commands.buyAbility(upgradeId). Panel savas alaninin cogunu kapatmamali.
  - Sagda Rift Collapse butonu (dairesel cooldown).
- Pause paneli: mevcut davranis.
- MediaQuery.viewPadding.left/right/top/bottom uygulanmali; tam ekran SafeArea KULLANMA.

Kurallar:
- ref.watch / ref.listen YOK.
- lib/shared/widgets, lib/app/theme ve lib/engine dosyalarina dokunma. Terminal calistirma.
- Yeni metin gerekirse sadece app_en.arb dosyasina ekle ("Kale", "Yetenekler", "Yuva dolu" gibi).

Kabul: flutter analyze 0 issue (yeni l10n anahtarlari haric); ui_lint TEMIZ; 640x360'ta tasma yok.
Rapor: AGENTS.md formati.
