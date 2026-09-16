---
name: rw-ui-integrate
description: LEGACY — kullanma. RIFTWARDEN UI işleri docs/DESIGN.md ve docs/UI_MIGRATION_PLAN.md üzerinden yürür.
---

> **LEGACY:** Gemini tasarim entegrasyonu emekliye ayrildi. UI isleri artik
> `docs/DESIGN.md` (gorsel otorite) ve `docs/UI_MIGRATION_PLAN.md` (is sirasi)
> uzerinden yurur.

# UI tasarımını koda bağlama

## Sıra (bu sırayı bozma)
1. **Token'ları güncelle** — `lib/app/theme/` (4 dosya)
   Tasarımdaki renk/ölçü/tipografi değerleri önce token'a girer.
2. **Ortak widget'ları güncelle** — `lib/shared/widgets/`
   Buton, panel, kart, dialog gibi birden fazla ekranda görünenler.
3. **Ekranı güncelle** — `lib/features/<ekran>/view/`
   Sadece bu ekrana özgü düzen.

Tersten gidersen (önce ekran) aynı stil beş yere kopyalanır ve sonraki revizyon acı verir.

## Kurallar
- **Ham değer yasak.** `Color(0xFF...)`, `EdgeInsets.all(13)`, elde kurulmuş
  `TextStyle` görmek istemiyoruz. Hepsi `AppColors` / `AppSpacing` / `AppTypography`'den.
- **RTL.** `EdgeInsets.only(left:)` yerine `EdgeInsetsDirectional.only(start:)`.
  `Row` içinde `MainAxisAlignment.start` zaten yön duyarlıdır, elle `left` verme.
  Arapça'da test etmesi gereken kullanıcıdır ama kodu doğru yazmak senin işin.
- **Metin literali yasak.** Her kullanıcıya görünen metin `AppLocalizations`'tan.
  Yeni metin gerekiyorsa `lib/l10n/arb/app_en.arb`'ye ekle (açıklamasıyla birlikte),
  diğer ARB'lere de anahtarı ekle, sonra `flutter gen-l10n`.
- **Safe area.** Tam ekran sayfalar `SafeArea` kullanır. Savaş HUD'u `SafeArea`
  yerine `MediaQuery.viewPadding` okur — çünkü arka plan çentiğin altına uzanmalı,
  sadece butonlar güvenli alanda kalmalı.
- **Dokunma hedefi** `AppSpacing.minTouchTarget` (48 dp) altına inmez.

## Savaş HUD'una özel
- HUD `ValueListenableBuilder` ile `BattleSignals`'ı dinler.
  `ref.watch` ile savaş state'i okuma — 60 fps'te ağacı yeniden kurar.
- Her sinyal için **ayrı** `ValueListenableBuilder` kullan; tek bir builder'a
  hepsini sarmak Aether değişince tüm HUD'u yeniden çizer.
- HUD savaş alanının büyük kısmını kapatmamalı. Alt şerit ekran yüksekliğinin
  %22'sini geçmesin.

## Bitirdikten sonra
```bash
flutter gen-l10n      # ARB değiştiyse
flutter analyze
```
