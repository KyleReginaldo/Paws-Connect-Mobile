plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.File

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    namespace = "com.example.paws_connect"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.paws_connect"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = if (keystoreProperties["storeFile"] != null)
                file(keystoreProperties["storeFile"] as String) else null
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    implementation("com.google.android.play:core:1.10.3")
    implementation("com.google.android.play:core-ktx:1.8.1")
}

flutter {
    source = "../.."
}

/* ------------------------------------------------------------------
   🔑 Rename the APK after assembleRelease so Flutter's wrapper
   (which always outputs app-release.apk) is copied to a custom name
------------------------------------------------------------------- */
// tasks.register("renameReleaseApk") {
//     doLast {
//         val outputsDir = File(project.layout.buildDirectory.asFile.get(), "outputs/apk/release")
//         val src = File(outputsDir, "app-release.apk")
//         if (!src.exists()) {
//             logger.warn("Source APK not found: ${src.absolutePath}")
//             return@doLast
//         }

//         val appName = "pawsconnect"
//         val versionName = android.defaultConfig.versionName ?: "unknown"
//         val versionCode = android.defaultConfig.versionCode ?: 0
//         val destName = "${appName}-${versionName}(${versionCode})-release.apk"
//         val dest = File(outputsDir, destName)

//         src.copyTo(dest, overwrite = true)
//         println("✅ Renamed APK -> ${dest.absolutePath}")
//     }
// }

// run automatically after assembleRelease
// afterEvaluate {
//     tasks.findByName("assembleRelease")?.finalizedBy("renameReleaseApk")
// }
