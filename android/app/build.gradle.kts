plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// IMPORTAÇÕES ADICIONADAS PARA RESOLVER O ERRO DE COMPILAÇÃO
import java.util.Properties
import java.io.FileInputStream

// CÓDIGO ADICIONADO AQUI - Início
// Carrega as propriedades do arquivo key.properties
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties() // Corrigido: usando a importação Properties
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile)) // Corrigido: usando a importação FileInputStream
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
            // CÓDIGO MODIFICADO AQUI - Habilita a minificação e aponta para o arquivo de regras
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro" 
            )
            // Aponta para a configuração de assinatura 'release' que criamos acima
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}