# Google Mobile Ads / Play Billing / Flutter plugins
-keep class com.google.android.gms.ads.** { *; }
-keep class com.android.billingclient.** { *; }
-keep class com.dexterous.** { *; }
-dontwarn com.google.android.play.core.**

# Room databases are instantiated by reflection (`<Name>_Impl`). WorkManager, which the
# Google Mobile Ads SDK starts at app launch, uses one; without this rule R8 strips it and
# the app crashes on start ("Failed to create an instance of androidx.work.impl.WorkDatabase").
-keep class * extends androidx.room.RoomDatabase { <init>(); }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }

# flutter_local_notifications stores scheduled notifications with Gson (generic types).
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
