import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'database_service.dart';
import 'supabase_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case SyncService.syncTaskName:
        return SyncService().sincronizarRegistrosPendentes(isBackground: true);
    }
    return Future.value(true);
  });
}

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  static const syncTaskName = "syncPendingPunches";
  final DatabaseService _dbService = DatabaseService();
  final SupabaseService _supabaseService = SupabaseService();
  final Connectivity _connectivity = Connectivity();

  // Inicializa o Workmanager para agendar tarefas em background
  void initializeWorkmanager() {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode, // Usa kDebugMode para verificar o modo de depuração
    );
    // Agendamento de uma tarefa recorrente (a cada 15 minutos)
    Workmanager().registerPeriodicTask(
      "syncTaskUniqueId", 
      syncTaskName,
      // 15 minutos é o intervalo mínimo suportado para Android.
      frequency: const Duration(minutes: 15), 
    );
    print('☁️ Workmanager inicializado e tarefa agendada.');
  }

  // Lógica de sincronização a ser executada em primeiro plano ou em background
  Future<bool> sincronizarRegistrosPendentes({bool isBackground = false}) async {
    if (isBackground) {
      // Re-inicializa os serviços em ambiente de background se necessário
      // O Supabase precisa ser inicializado no isolado do Workmanager
      await SupabaseService.initialize();
      
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
         print('☁️ Sincronização adiada: Sem conexão.');
        return Future.value(true);
      }
    }
    
    try {
      // Usa o serviço de BD local
      final registrosPendentes = await _dbService.buscarRegistrosNaoSincronizados();

      if (registrosPendentes.isEmpty) {
        print('☁️ Nenhuma pendência para sincronizar.');
        return Future.value(true);
      }

      // Envia o lote para o Supabase
      final idsSincronizados = await _supabaseService.sincronizarLoteDeRegistros(registrosPendentes);

      // Atualiza o banco de dados local para marcar os registros como sincronizados
      for (var id in idsSincronizados) {
        await _dbService.marcarComoSincronizado(id);
      }

      print('☁️ Sincronização completa. ${idsSincronizados.length} registros enviados.');
      return Future.value(true);
    } catch (e) {
      print('❌ Erro geral durante a sincronização: $e');
      return Future.value(false); // Workmanager tentará novamente
    }
  }

  // Monitora a conexão em tempo real (apenas para a UI)
  void monitorarConexaoEIniciarSincronizacao() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        // Se a conexão foi restaurada, tenta sincronizar em primeiro plano
        print('🌐 Conexão restaurada. Tentando sincronização em primeiro plano...');
        sincronizarRegistrosPendentes();
      }
    });
  }
}