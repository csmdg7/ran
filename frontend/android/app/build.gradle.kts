plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.net_fence_ai_frontend"
    compileSdk = 36  // Updated for plugin compatibility
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
        freeCompilerArgs = listOf(
            "-Xno-param-assertions",
            "-Xno-receiver-assertions",
            "-Xno-call-assertions"
        )
    }

    signingConfigs {
        create("release") {
            storeFile = file("release.keystore")
            storePassword = System.getenv("KEYSTORE_PASSWORD") ?: "password"
            keyAlias = System.getenv("KEY_ALIAS") ?: "netfence"
            keyPassword = System.getenv("KEY_PASSWORD") ?: "password"
            enableV1Signing = true
            enableV2Signing = true
        }
    }

    defaultConfig {
        applicationId = "com.example.net_fence_ai_frontend"
        minSdk = 24  // Android 7.0 minimum support
        targetSdk = 35  // Target latest Android 15
        versionCode = 1
        versionName = "1.0.0"
        
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        vectorDrawables.useSupportLibrary = true
    }

    buildFeatures {
        buildConfig = true
        aidl = false
        renderScript = false
        resValues = true
        shaders = false
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            isDebuggable = false
            
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            buildConfigField("String", "BUILD_TYPE", "\"release\"")
            resValue("string", "app_name", "Net-Fence AI")
        }
        
        debug {
            isMinifyEnabled = false
            isDebuggable = true
            buildConfigField("String", "BUILD_TYPE", "\"debug\"")
            resValue("string", "app_name", "Net-Fence AI (Debug)")
        }
    }

    lint {
        checkReleaseBuilds = false
        abortOnError = false
        warningsAsErrors = false
        disable.addAll(listOf(
            "MissingTranslation",
            "ExtraTranslation",
            "MissingDimensionResource",
            "GoogleAppIndexingWarning"
        ))
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.0")  // Updated for compatibility
}

flutter {
    source = "../.."
}
