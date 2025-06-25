plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // ✅ Google Services plugin added
    id("dev.flutter.flutter-gradle-plugin") // ✅ Flutter plugin (must stay last)
}

android {
    namespace = "com.example.campus_connect"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.campus_connect" // ✅ If you want to change, update Firebase too
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Firebase BoM: always use compatible versions
    implementation(platform("com.google.firebase:firebase-bom:33.15.0"))

    // ✅ Add Firebase SDKs you want to use:
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-functions") // for OpenAI calls via Firebase
}
