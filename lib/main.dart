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
  
  // Inicializa o Workmanager ANTES de inicializar o Supabase
  SyncService().initializeWorkmanager();

  // Inicializa o Supabase
  await SupabaseService.initialize();
  
  // Inicia a monitoração de conexão para sincronização em tempo real (em foreground)
  SyncService().monitorarConexaoEIniciarSincronizacao();


  runApp(const AgroCanaForteApp());
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