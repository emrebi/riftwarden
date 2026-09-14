# Bilinen Açıklar

Bilerek ertelenmiş işler. Hata değil, **zamanlaması sonraya bırakılmış** kararlar.
Her madde neden ertelendiğini ve ne zaman kapatılacağını söyler.

Yeni bir açık fark edilirse buraya yazılır. Kapatılınca satır silinir.

---

## İçerik / denge

### 1. Level tempo ayarı bekliyor
**Durum:** Yatay kale savunması kurgusuna (M2.5) geçildi; dalga/süre dengesi henüz
oynanarak doğrulanmadı.
**Hedef:** 5-9 dalga, 2-5 dakika (bkz. `docs/ARCHITECTURE.md` oyun süresi).
**Neden ertelendi:** Harita render + geçici asset (P13) bitip savaş alanı gerçek
haliyle görülmeden tempo ayarı körlemesine olur.
**Ne zaman:** P13 (harita render) sonrası, oynanarak ayarlanacak.
**Nerede:** `assets/content/levels/sector_01.json`

### 2. Upgrade ailelerinde 2 üye var
**Durum:** 12 upgrade, aile başına 2 (economy/core'da 1).
**Hedef:** Aile başına en az 3 — synergy'nin hissedilmesi için gerekli
(bkz. `.claude/skills/rw-add-upgrade/SKILL.md`).
**Neden ertelendi:** Upgrade sistemi (adım 14) çalışmadan hangi ailenin
güçlendirilmesi gerektiği bilinemez.
**Ne zaman:** Adım 14 sonrası içerik genişletmesiyle.
**Nerede:** `assets/content/upgrades.json`

### 3. Mermi özellikleri koda gömülü
**Durum:** `combat_system.dart` içinde `kProjectileSpeed`, `kProjectileRadius`,
`kProjectileLifetime` sabitleri. Tüm mermiler aynı davranıyor.
**Sorun:** `CLAUDE.md` madde 8'e aykırı (içerik koda gömülmez). Oynanış açısından
da kayıp: Arc Ranger'ın uzun mızrağı ile Pulse Guard'ın bolt'u aynı hissettiriyor.
**Çözüm:** `assets/content/projectiles.json` + `ProjectileConfig` şeması +
`UnitConfig.projectile` bu id'ye işaret etsin.
**Ne zaman:** Adım 11 (render) sonrası — mermi görünürken ayarlamak anlamlı olur.

### 4. Render'da kare başına `RSTransform` allocation'ı
**Durum:** Renderer'lar entity başına `RSTransform.fromComponents(...)` üretiyor.
Flame'in `SpriteBatch.addTransform` API'si bunu gerektiriyor.
**Ölçek:** 500 düşman × 60 fps ≈ saniyede 30 bin küçük nesne. Dart'ın genç kuşak
GC'si bunu ucuz toplar, ama swarm hedefinde ölçülmesi gereken bir kalem.
**Çözüm (gerekirse):** `SpriteBatch` yerine doğrudan `Canvas.drawRawAtlas` +
önceden ayrılmış `Float32List` tamponları — sıfır allocation.
**Neden şimdi yapılmadı:** Profil almadan optimize etmek tahmin olur. Önce gerçek
cihazda 200+ düşmanla FPS ölçülecek (bkz. `docs/ARCHITECTURE.md` doğrulama bölümü).
**Ne zaman:** Adım 23 performans geçişi, ölçüm sonucuna göre.

---

## Yatay kale savunması (M2.5)

### Arapça rakamlar
**Durum:** Sayılar ham `'$deger'` interpolasyonuyla yazılıyor (ör. Aether, HP).
**Sorun:** `ar` locale'i için Batı Arap rakamları yerine yerel basamak biçimi gerekir;
ham interpolasyon bunu atlar.
**Çözüm:** `intl` paketinin `NumberFormat`'ı ile locale'e duyarlı biçimlendirme.
**Ne zaman:** Adım 21 (çeviri + font).

### Sektör arka plan resmi
**Durum:** Şu an `MapRenderer` prosedürel bir zemin gradyanı çiziyor, gerçek
arka plan resmi yok.
**Ne zaman:** Adım 22 (gerçek asset), `docs/ASSET_PROMPTS.md` Parti 8.

### Release doğrulaması
**Durum:** `flutter analyze` geçmesi uygulamanın gerçek cihazda çalıştığını
GÖSTERMEZ. Görsel adımlarda release APK cihazda/emülatörde açılıp kontrol edilmeli.
**Örnekler:** `Stack`'in tüm çocukları `Positioned*` ise `fit: StackFit.expand`
olmadan `0x0`'a çöküp ekran sessizce boş görünür; R8'in `androidx.work`/`Room`
sınıflarını silip açılışta çökertmesi (keep kuralları eksikse).
**Ne zaman:** Her görsel adımdan sonra kullanıcı manuel kontrolü.

---

## Lokalizasyon

### 5. 14 dil İngilizce placeholder
**Durum:** Sadece `en` ve `tr` gerçek. Diğer 14 locale İngilizce değer taşıyor.
**Neden ertelendi:** Ekranlar yazıldıkça yeni anahtar çıkıyor; her seferinde
15 dile çevirmek israf. Anahtar seti oturunca tek seferde yapılacak.
**Ne zaman:** Tüm ekranlar bitince (adım 21 civarı).
**Nerede:** `lib/l10n/arb/app_*.arb`

### 6. Fontlar bundle edilmedi
**Durum:** `AppFonts.bodyFamilyFor` her locale için `null` dönüyor — sistem fontu.
**Sorun:** CJK, Tayca ve Arapça'da görünüm cihazdan cihaza değişir.
**Ne zaman:** M5 cila aşaması. `pubspec.yaml` içinde `fonts:` bloğu hazır, yorumlu.

---

## Yayın öncesi zorunlu

### 7. Reklam ve IAP kimlikleri TEST kimliği
`AndroidManifest.xml`, `Info.plist` ve ileride `AdConfig` içinde Google'ın test
kimlikleri gömülü. **Yayına çıkmadan mutlaka gerçek AdMob kimlikleriyle
değiştirilecek.** TODO ile işaretli.

### 8. Release imzalama yapılandırması yok
`android/app/build.gradle.kts` içinde release derlemesi **debug key** ile
imzalanıyor (`TODO(store)`). Yayın öncesi gerçek keystore bağlanacak.

### 9. İsim taraması yapılmadı
RIFTWARDEN çalışma adı. App Store / Google Play'de çakışma ve marka taraması
yapılmadı. Bundle id (`com.riftwarden.game`) isme bağlı — isim değişirse
Android `applicationId`/`namespace`, iOS bundle id ve Kotlin paket yolu birlikte
değişmeli.
