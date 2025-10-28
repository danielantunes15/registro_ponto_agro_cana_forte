# Arquivo: android/app/proguard-rules.pro
#
# Regras personalizadas do ProGuard/R8 para garantir que plugins críticos
# não sejam removidos/otimizados na compilação de release.

# Regras gerais para Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Regras para o plugin workmanager (Essencial para tarefas em background)
-keep class androidx.work.** { *; }
-keep class com.dexterous.flutterlocalnotifications.receivers.* { *; }
-dontwarn androidx.work.**

# Regras para Sqflite e suas dependências (Banco de dados local)
-keep class net.sqlcipher.** { *; }
-keep class org.sqlite.** { *; }
-dontwarn net.sqlcipher.**
-dontwarn org.sqlite.**

# Regras para o plugin Supabase e suas dependências de rede (okhttp/retrofit)
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-keep class retrofit2.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn retrofit2.**

# Regras para o plugin camera (Impede que o código da câmera seja removido)
-keep class io.flutter.plugins.camera.** { *; }
-dontwarn io.flutter.plugins.camera.**

# Regras para o plugin qr_code_scanner_plus/permission_handler
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**