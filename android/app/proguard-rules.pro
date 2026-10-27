# OpenKey — keep Flutter / JNI / plugin entry points when R8 shrinks & obfuscates.

# Flutter embedding
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Play Core / deferred components (referenced by Flutter tooling)
-dontwarn com.google.android.play.core.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Kotlin / coroutines noise
-dontwarn kotlinx.coroutines.**
-dontwarn kotlin.**

# AndroidX Security / Credentials / Biometric used by the app
-keep class androidx.security.crypto.** { *; }
-keep class androidx.credentials.** { *; }
-keep class androidx.biometric.** { *; }
-keep class androidx.autofill.** { *; }

# Gson / reflection-style models if any plugin uses them
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
