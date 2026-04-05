plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.vidbee.vidbee_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.vidbee.vidbee_flutter"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24 // extractor 插件要求 API 24+
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keystorePath = System.getenv("KEYSTORE_PATH")
            val keystorePassword = System.getenv("KEYSTORE_PASSWORD") ?: "android"
            val alias = System.getenv("KEY_ALIAS") ?: "androiddebugkey"
            val password = System.getenv("KEY_PASSWORD") ?: "android"
            
            // 如果有环境变量，使用环境变量中的 keystore；否则使用本地 debug.keystore
            val keystoreFile = if (keystorePath != null && keystorePath.isNotEmpty()) {
                file(keystorePath)
            } else {
                // 本地编译时，使用用户目录下的 debug.keystore
                val userHome = System.getProperty("user.home")
                file("$userHome/.android/debug.keystore")
            }
            
            storeFile = keystoreFile
            storePassword = keystorePassword
            keyAlias = alias
            keyPassword = password
        }
    }

    buildTypes {
        release {
            // 使用 release 签名配置（如果有），否则用 debug 签名
            signingConfig = signingConfigs.findByName("release") ?: signingConfigs.getByName("debug")
            // Disable code shrinking and obfuscation to prevent crashes
            isMinifyEnabled = false
            isShrinkResources = false
            // Add ProGuard rules
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.2")
}

flutter {
    source = "../.."
}
