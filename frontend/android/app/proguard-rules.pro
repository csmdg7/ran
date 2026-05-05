# Flutter & Dart rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep Flutter specific classes
-keep class com.example.net_fence_ai_frontend.** { *; }

# Kotlin rules
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}

# AndroidX rules
-keep class androidx.** { *; }
-keep interface androidx.** { *; }
-dontwarn androidx.**

# HTTP & Network libraries
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

-keep class com.squareup.okhttp.** { *; }
-keep interface com.squareup.okhttp.** { *; }
-dontwarn com.squareup.okhttp.**

-keep class org.apache.commons.codec.** { *; }
-keep interface org.apache.commons.codec.** { *; }
-dontwarn org.apache.commons.codec.**

-keep class org.apache.commons.logging.** { *; }
-keep interface org.apache.commons.logging.** { *; }
-dontwarn org.apache.commons.logging.**

-keep class com.google.code.gson.** { *; }
-dontwarn com.google.code.gson.**

# Geolocation & Maps
-keep class com.google.android.gms.** { *; }
-keep interface com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Work Manager (background tasks)
-keep class androidx.work.** { *; }
-keep interface androidx.work.** { *; }
-dontwarn androidx.work.**

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom application classes
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends androidx.work.Worker

# Keep constructors required by serialization/deserialization
-keepclassmembers class * {
    public <init>(android.content.Context);
}

# Keep view constructors for inflation
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}

# Optimization options
-optimizationpasses 5
-dontusemixedcaseclassnames
-verbose

# Logging
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# BuildConfig and related
-keep class **.BuildConfig { *; }
-keep class **.R$* {
    *;
}
