import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../models/funcionario.dart';
import '../services/database_service.dart';
import '../services/supabase_service.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isLoading = false;
  String? _loadingMessage;

  final DatabaseService _dbService = DatabaseService();
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }
  
  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
       _mostrarErro('Permissão da câmera negada. O scanner não pode funcionar.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR Code'),
        backgroundColor: Colors.green[800],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          _buildQrView(context),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.green,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            Text(
              _loadingMessage ?? 'Processando...',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      if (!_isLoading) {
        _processarQrCode(scanData.code);
      }
    });
  }

  Future<void> _processarQrCode(String? qrCodeData) async {
    if (qrCodeData == null) return;

    controller?.pauseCamera();
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Buscando funcionário...';
    });

    try {
      final funcionario = await _supabaseService.buscarFuncionarioPorQrCode(qrCodeData);

      if (funcionario != null) {
        setState(() {
          _loadingMessage = 'Registrando ponto...';
        });
        
        final tipoRegistro = await _determinarTipoRegistro(funcionario.id);

        final registro = {
          'id': 'reg_${DateTime.now().millisecondsSinceEpoch}',
          'funcionario_id': funcionario.id,
          'matricula': funcionario.matricula,
          'nome_funcionario': funcionario.nome,
          'data_hora': DateTime.now().toIso8601String(),
          'tipo': tipoRegistro,
          'localizacao': 'Roça - Setor A', // Pode ser melhorado com GPS
          'sincronizado': false,
          'qr_code_data': qrCodeData,
        };

        await _dbService.salvarRegistro(registro);

        setState(() {
          _loadingMessage = 'Sincronizando...';
        });
        
        final sincronizado = await _supabaseService.sincronizarRegistro(registro);

        if (sincronizado) {
          await _dbService.salvarRegistro({...registro, 'sincronizado': true});
        }
        
        _mostrarResultado(funcionario, sincronizado, tipoRegistro);

      } else {
        _mostrarErro('Funcionário não encontrado com este QR Code.');
      }
    } catch (e) {
      _mostrarErro('Erro ao processar QR Code: $e');
    }
  }

  Future<String> _determinarTipoRegistro(String funcionarioId) async {
    final ultimoRegistro = await _dbService.buscarUltimoRegistroDoDia(funcionarioId);

    if (ultimoRegistro == null) {
      return 'entrada';
    }

    switch (ultimoRegistro['tipo']) {
      case 'entrada':
        return 'saida_almoco';
      case 'saida_almoco':
        return 'retorno_almoco';
      case 'retorno_almoco':
        return 'saida';
      case 'saida':
        return 'entrada_extra'; // Ou alguma outra lógica para horas extras
      default:
        return 'entrada';
    }
  }

 void _mostrarResultado(Funcionario funcionario, bool sincronizado, String tipo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Ponto Registrado!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${tipo.replaceAll('_', ' ').toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            Text('✅ ${funcionario.nome}'),
            Text('📋 ${funcionario.matricula}'),
            Text('🕒 ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: sincronizado ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: sincronizado ? Colors.green : Colors.orange,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    sincronizado ? Icons.cloud_done : Icons.cloud_off,
                    color: sincronizado ? Colors.green : Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    sincronizado ? 'Sincronizado' : 'Salvo localmente',
                    style: TextStyle(
                      color: sincronizado ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isLoading = false;
                _loadingMessage = null;
              });
              controller?.resumeCamera();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _mostrarErro(String mensagem) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Erro'),
          ],
        ),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
               setState(() {
                _isLoading = false;
                _loadingMessage = null;
              });
              controller?.resumeCamera();
            },
            child: const Text('TENTAR NOVAMENTE'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}