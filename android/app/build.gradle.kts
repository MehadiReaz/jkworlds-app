plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.jkworlds.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.jkworlds.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    applicationVariants.all {
        outputs.all {
            val output = this as? com.android.build.gradle.internal.api.ApkVariantOutputImpl
            output?.outputFileName = "JKWORLDS.apk"
        }
    }

    androidComponents {
        onVariants { variant ->
            val capitalizedName = variant.name.replaceFirstChar { it.uppercase() }
            val renameTaskName = "renameApk$capitalizedName"
            
            tasks.register(renameTaskName) {
                doLast {
                    val flutterApkDir = layout.buildDirectory.dir("outputs/flutter-apk").get().asFile
                    val variantApkName = if (variant.name == "release") "app-release.apk" else "app-debug.apk"
                    val variantFile = File(flutterApkDir, variantApkName)
                    
                    if (variantFile.exists()) {
                        variantFile.copyTo(File(flutterApkDir, "JKWORLDS.apk"), overwrite = true)
                        println("=== CUSTOM BUILD SUCCESS: JKWORLDS.apk generated from $variantApkName in build/app/outputs/flutter-apk/ ===")
                    } else {
                        println("=== CUSTOM BUILD WARNING: $variantApkName not found in build/app/outputs/flutter-apk/ ===")
                    }
                }
            }
            
            tasks.matching { it.name == "assemble$capitalizedName" }.all {
                finalizedBy(renameTaskName)
            }
        }
    }
}

flutter {
    source = "../.."
}
