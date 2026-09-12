---
name: rw-add-level
description: RIFTWARDEN'a yeni level veya sektör ekler ya da mevcut level'ları dengeler. "Level 51 ekle", "sektör 11 ekle", "level 23 çok zor" gibi isteklerde kullan. Sadece içerik JSON'una dokunur, Dart kodu değişmez.
---

# Level ekleme / dengeleme

**Kural: bu iş Dart dosyası değiştirmez.** Değişirse bir şey yanlış gidiyordur.

## Dokunulacak dosyalar
- `assets/content/levels/sector_NN.json` — level'ların kendisi
- `assets/content/sectors.json` — yeni sektör ekleniyorsa

Şema: `docs/CONTENT_SCHEMA.md` → "levels/sector_NN.json" bölümü. Önce onu oku.

## Level numaralandırma
Sektör N → level `(N-1)*5 + 1` … `N*5`. Her sektör tam 5 level.
Boss level'ları: 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 (her sektörün sonuncusu).

## Zorluk eğrisi
| Level aralığı | difficultyMultiplier | Yeni gelen |
|---|---|---|
| 1–5 | 1.00 → 1.10 | Tek rift, tek lane, sadece drifter + ilk upgrade'ler |
| 6–10 | 1.10 → 1.30 | skitter, iki lane |
| 11–20 | 1.30 → 1.80 | bulwark/splitter, elite sistemi (`eliteChance` 0.05→0.20) |
| 21–30 | 1.80 → 2.60 | phaseborn/leech, battlefield modifier'lar |
| 31–40 | 2.60 → 3.80 | 3 rift, spawner, eşzamanlı çoklu yön |
| 41–49 | 3.80 → 5.50 | Büyük karışık swarm, yoğun elite |
| 50 | 6.50 | Final: özel battlefield, çok rift, 3 fazlı boss |

Level süresi hedefi **2–5 dakika**. İlk level'lar daha kısa, boss level'ları daha uzun.
Toplam `count` × `interval` bunu belirler; dalga sayısı 5–9 arası tut.

## Kompozisyon kuralı
Zorluğu SADECE HP çarpanıyla yükseltme. Düşman tipleri birbirini tamamlasın:
- Bulwark önden ateş gücünü çekerken arkadan Skitter sızar
- Spawner korunurken Drifter swarm gelir
- Splitter + hızlı düşman = alan kontrolü baskısı

## Kapasite
`maxEnemies`: aynı anda ekranda olabilecek en yüksek sayı + %20 pay.
Kaba hesap: en yoğun dalganın `count` toplamı × 0.6 (bir kısmı zaten ölmüş olur).
Fazla yüksek = boşuna bellek. Düşük = spawn'lar sessizce atlanır (oyun bozulmaz ama dalga hafifler).

## Bitirdikten sonra
```bash
flutter test test/content_validation_test.dart
```
Bu test şunları yakalar: bilinmeyen enemy/lane/rift id'si, `lane.from` ↔ `rift.id` uyumsuzluğu,
negatif değer, level numarası boşluğu/çakışması, eksik sprite atfı.
