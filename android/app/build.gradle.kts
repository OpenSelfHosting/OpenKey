import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.openselfhosting.openkey"
    // API 36 is the latest SDK supported by AGP 9.0.1.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.openselfhosting.openkey"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Autofill Framework requires API 26+.
        minSdk = maxOf(flutter.minSdkVersion, 26)
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Keep Play / AndroidX / ML Kit string resources only for locales we ship.
        resourceConfigurations += listOf(
            "en", "ar", "bn", "es", "fr", "hi", "pt", "ru", "ur", "zh",
        )
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                // Paths in key.properties are relative to android/ (or absolute).
                storeFile = keystoreProperties["storeFile"]?.let {
                    rootProject.file(it as String)
                }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Prefer upload/release keystore when android/key.properties is present;
            // fall back to debug so `flutter run --release` still works locally.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }

            // Shrink + obfuscate Java/Kotlin (R8). Dart AOT obfuscation is
            // enabled separately via `flutter build --obfuscate` in build_all.sh.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )

            // SYMBOL_TABLE is enough for Play native crashes without ~90 MB of DWARF.
            ndk {
                debugSymbolLevel = "SYMBOL_TABLE"
            }
        }
    }

    packaging {
        jniLibs {
            useLegacyPackaging = true
            excludes += "lib/x86/**"
        }
        resources {
            excludes += listOf(
                "META-INF/*.version",
                "META-INF/*.kotlin_module",
                "DebugProbesKt.bin",
            )
        }
    }

    androidResources {
        ignoreAssetsPattern =
            "!.svn:!.git:!.ds_store:!*.scc:.*:!CVS:!thumbs.db:!picasa.ini:!*~:!*web_worker.dart.js*:!*.js.map"
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.security:security-crypto:1.1.0-alpha06")
    implementation("androidx.credentials:credentials:1.5.0")
    implementation("androidx.biometric:biometric:1.1.0")
    implementation("androidx.autofill:autofill:1.3.0")
}
