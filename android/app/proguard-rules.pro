# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.**

# In-app purchase (Play Billing)
-keep class com.android.billingclient.** { *; }

# --- androidx.startup / WorkManager / Room ---
# google_mobile_ads WorkManager kullaniyor; WorkManager da Room uzerinden
# calisiyor. Room'un urettigi *_Impl siniflari REFLECTION ile bulunur, bu
# yuzden R8 onlari "kullanilmiyor" sanip siliyor ve uygulama acilista
# "Failed to create an instance of androidx.work.impl.WorkDatabase" ile
# cokuyor. Asagidaki kurallar o zinciri korur.
-keep class androidx.startup.InitializationProvider { *; }
-keep class * implements androidx.startup.Initializer { *; }

-keep class androidx.work.** { *; }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-dontwarn androidx.work.**

-keep class androidx.room.** { *; }
-keep class * extends androidx.room.RoomDatabase { *; }
-keep @androidx.room.Entity class * { *; }
-keep class androidx.sqlite.** { *; }
-dontwarn androidx.room.paging.**
