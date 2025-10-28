import 'package:flutter/material.dart';
import 'package:registro_ponto_agro_cana_forte/services/supabase_service.dart';
import 'package:registro_ponto_agro_cana_forte/services/sync_service.dart';
import 'pages/home_page.dart';

// O callbackDispatcher deve ser uma função de nível superior (top-level)
// para que o workmanager possa chamá-la em um isolado separado.
export 'package:registro_ponto_agro_cana_forte/services/sync_service.dart' show callbackDispatcher;

void main() async {
  // Garante que os bindings do Flutter sejam inicializados
  WidgetsFlutterBinding.ensureInitialized();
  
  // Garante que quaisquer erros não tratados no Flutter sejam logados/capturados.
  FlutterError.onError = (FlutterErrorDetails details) {
    // Para ambientes de produção, você pode integrar um serviço de log/crash reporting aqui
    FlutterError.presentError(details);
    print('❌ ERRO UNHANDLED no Flutter: ${details.exception}');
  };

  try {
    // Inicializa o Workmanager ANTES de inicializar o Supabase
    SyncService().initializeWorkmanager();

    // Inicializa o Supabase (Se falhar, a exceção é capturada)
    await SupabaseService.initialize();
    
    // Inicia a monitoração de conexão para sincronização em tempo real (em foreground)
    SyncService().monitorarConexaoEIniciarSincronizacao();

    runApp(const AgroCanaForteApp());
  } catch (e, stackTrace) {
    // Se a inicialização crítica falhar (Ex: Supabase não inicializa),
    // rodamos um widget de fallback para evitar a tela preta.
    print('❌ ERRO FATAL NA INICIALIZAÇÃO: $e');
    print(stackTrace);

    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                SizedBox(height: 10),
                Text(
                  'Erro Crítico na Inicialização!',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
                Text('Verifique as configurações (Ex: Supabase) e tente novamente.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AgroCanaForteApp extends StatelessWidget {
  const AgroCanaForteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agro Cana Forte - Registro de Ponto',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}