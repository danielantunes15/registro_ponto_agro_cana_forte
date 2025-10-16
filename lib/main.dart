import 'package:flutter/material.dart';
import 'package:registro_ponto_agro_cana_forte/services/supabase_service.dart';
import 'pages/home_page.dart';

void main() async {
  // Garante que os bindings do Flutter sejam inicializados
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa o Supabase
  await SupabaseService.initialize();

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