import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/sync_service.dart';
import '../services/database_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Carregando...',
    packageName: '',
    version: '...',
    buildNumber: '...',
  );
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  int _pendingRecordsCount = 0;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    _initConnectivityAndSyncStatus();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Future<void> _initConnectivityAndSyncStatus() async {
    // 1. Connectivity Status
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = result;
    });

    // 2. Pending Records Count
    await _updatePendingRecordsCount();
    
    // 3. Listen for changes in connectivity
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _connectivityResult = result;
        if (result != ConnectivityResult.none) {
           _updatePendingRecordsCount();
        }
      });
    });
  }

  Future<void> _updatePendingRecordsCount() async {
    final pendingRecords = await DatabaseService().buscarRegistrosNaoSincronizados();
    setState(() {
      _pendingRecordsCount = pendingRecords.length;
    });
  }

  Future<void> _triggerManualSync() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Iniciando sincronização manual...')),
    );
    final success = await SyncService().sincronizarRegistrosPendentes();
    
    // Após a sincronização, atualiza a contagem
    await _updatePendingRecordsCount();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? '✅ Sincronização concluída!' : '❌ Falha na sincronização.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = _connectivityResult != ConnectivityResult.none;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('👤 Meu Perfil e Status'),
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Status de Conexão ---
              Card(
                color: isOnline ? Colors.green.shade50 : Colors.red.shade50,
                child: ListTile(
                  leading: Icon(
                    isOnline ? Icons.wifi : Icons.wifi_off,
                    color: isOnline ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                  title: Text('Status da Conexão', style: theme.textTheme.titleMedium),
                  subtitle: Text(isOnline ? 'Online - Sincronização Ativa' : 'Offline - Salvo Localmente'),
                ),
              ),
              const SizedBox(height: 20),

              // --- Status de Sincronização ---
              Card(
                color: _pendingRecordsCount > 0 ? Colors.orange.shade50 : Colors.green.shade50,
                child: ListTile(
                  leading: Icon(
                    _pendingRecordsCount > 0 ? Icons.cloud_off : Icons.cloud_done,
                    color: _pendingRecordsCount > 0 ? Colors.orange.shade700 : Colors.green.shade700,
                  ),
                  title: Text('Registros Pendentes', style: theme.textTheme.titleMedium),
                  subtitle: Text('Há $_pendingRecordsCount registros aguardando sincronização.'),
                  trailing: _pendingRecordsCount > 0
                      ? IconButton(
                          icon: const Icon(Icons.sync, color: Colors.orange),
                          onPressed: _triggerManualSync,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 30),

              Text('Informações do Aplicativo', style: theme.textTheme.titleLarge!.copyWith(color: Colors.green[700])),
              const Divider(),

              ListTile(
                title: const Text('Nome do App'),
                subtitle: Text(_packageInfo.appName),
              ),
              ListTile(
                title: const Text('Versão'),
                subtitle: Text(_packageInfo.version),
              ),
              ListTile(
                title: const Text('Build Number'),
                subtitle: Text(_packageInfo.buildNumber),
              ),
              ListTile(
                title: const Text('ID do Pacote'),
                subtitle: Text(_packageInfo.packageName),
              ),

              const SizedBox(height: 30),
              // Botão de Sincronização Manual (em caso de falha na automação)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _triggerManualSync,
                  icon: const Icon(Icons.sync),
                  label: const Text('Sincronização Manual'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}