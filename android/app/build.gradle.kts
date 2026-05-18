import java.text.SimpleDateFormat
import java.util.Date
import java.util.Properties

// Carrega as credenciais da keystore de produção (se existirem)
val keystorePropertiesFile = rootProject.file("app/key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.canutobr.lembreplus"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    // Atualiza para Java 17 para evitar avisos de opções obsoletas (-source/-target 8)
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.canutobr.lembreplus"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Google Sign-In/Drive funcionam com minSdk >= 23
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                // Fallback para debug durante desenvolvimento
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}


flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

val appDisplayName = "LembrePlus"

tasks.register("renameReleaseApk") {
    group = "build"
    description = "Copia o APK de release com nome padronizado"
    dependsOn("assembleRelease")
    doLast {
        val manifest = project.file("src/main/AndroidManifest.xml").readText()
        val labelMatch = Regex("android:label=\"([^\"]+)\"").find(manifest)
        val appName = labelMatch?.groupValues?.get(1) ?: appDisplayName
        val text = rootProject.file("../pubspec.yaml").readText()
        val r = Regex("version:\\s*([\\w\\.\\-\\+]+)")
        val m = r.find(text)
        val raw = m?.groupValues?.get(1) ?: "0.0.0+1"
        val ver = raw.split('+').first()
        val ts = SimpleDateFormat("yyyyMMdd_HHmmss").format(Date())
        val newName = "$appName-$ver-$ts.apk"

        val outputsDir = layout.buildDirectory.dir("outputs/apk/release").get().asFile
        val srcApk = outputsDir.resolve("app-release.apk")
        if (srcApk.exists()) {
            srcApk.copyTo(outputsDir.resolve(newName), overwrite = true)
        }

        val flutterApkDir = rootProject.layout.buildDirectory.dir("app/outputs/flutter-apk").get().asFile
        val flutterApk = flutterApkDir.resolve("app-release.apk")
        if (flutterApk.exists()) {
            flutterApk.copyTo(flutterApkDir.resolve(newName), overwrite = true)
        }
    }
}

afterEvaluate {
    tasks.findByName("assembleRelease")?.finalizedBy(tasks.findByName("renameReleaseApk"))
}
