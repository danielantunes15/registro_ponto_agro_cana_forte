plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// CÓDIGO ADICIONADO AQUI - Início
// Carrega as propriedades do arquivo key.properties
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = java.util.Properties()
if (keyPropertiesFile.exists()) {
    keyProperties.load(java.io.FileInputStream(keyPropertiesFile))
}
// CÓDIGO ADICIONADO AQUI - Fim

android {
    namespace = "com.example.registro_ponto_agro_cana_forte"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    // CÓDIGO ADICIONADO AQUI - Início
    // Configuração da assinatura digital para a versão de release
    signingConfigs {
        create("release") {
            keyAlias = keyProperties["keyAlias"] as String?
            keyPassword = keyProperties["keyPassword"] as String?
            storeFile = if (keyProperties["storeFile"] != null) file(keyProperties["storeFile"] as String) else null
            storePassword = keyProperties["storePassword"] as String?
        }
    }
    // CÓDIGO ADICIONADO AQUI - Fim

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.registro_ponto_agro_cana_forte"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            
            // CÓDIGO MODIFICADO AQUI
            // Aponta para a configuração de assinatura 'release' que criamos acima
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}