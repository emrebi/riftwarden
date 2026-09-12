# RIFTWARDEN

Portrait-only iOS/Android oyunu.
**Auto-battle + swarm defense + roguelite upgrade.**

Boyut yarıklarından gelen Riftborn sürülerini, savaş sırasında giderek büyüttüğün
otomatik savaşan bir orduyla durdur. Düşmanları öldürerek Aether kazan, yeni birlik
üret, güçlü upgrade kombinasyonları kur.

Flutter + Flame. Paket `riftwarden`, bundle id `com.riftwarden.game`.

---

## Dokümanlar

| Dosya | Ne var |
|---|---|
| `CLAUDE.md` | Çalışma protokolü + değişmez mimari kuralları |
| `docs/ARCHITECTURE.md` | Tam mimari plan ve yol haritası |
| `docs/CONTENT_MAP.md` | "Hangi iş için hangi dosya" indeksi |
| `docs/CONTENT_SCHEMA.md` | İçerik JSON şemaları |
| `docs/ASSET_PROMPTS.md` | Gemini asset prompt şablonları |
| `tools/assetkit/README.md` | Asset pipeline kullanımı |

## Geliştirme

```bash
flutter pub get
flutter gen-l10n          # lib/l10n/arb/ değiştiyse
flutter analyze           # kalite kapısı: 0 issue
flutter run --release     # gerçek cihazda
```

## Platform

Sadece **iOS ve Android telefon**. Masaüstü ve web platform klasörleri bilerek
kaldırılmıştır, geri eklenmez. Portrait kilidi hem uygulama içinde hem
`AndroidManifest.xml` / `Info.plist` tarafında.

## Diller

15 dil: en, tr, ja, ko, zh-Hans, zh-Hant, de, fr, es, it, pt-BR, ru, ar, th, id.
Varsayılan sistem dili; desteklenmiyorsa İngilizce.

## Reklam / Satın alma

Şu an Google'ın **test** reklam kimlikleri gömülüdür. Yayın öncesi değiştirilecek
yerler `TODO(store)` ve `TODO` ile işaretli:
`android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`,
`android/app/build.gradle.kts` (signing config).
