# Flutter specific ProGuard rules
# Keep Flutter wrapper classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep video_player plugin classes
-keep class com.google.android.exoplayer2.** { *; }

# Keep shared_preferences plugin classes
-keep class com.google.android.gms.** { *; }

# Suppress warnings for missing classes
-dontwarn io.flutter.**
-dontwarn com.google.android.gms.**
