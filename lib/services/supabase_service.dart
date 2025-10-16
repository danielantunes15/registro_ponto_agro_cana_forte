import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/funcionario.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final _supabase = Supabase.instance.client;

  // Método para inicializar o Supabase no main.dart
  static Future<void> initialize() async {
    await Supabase.initialize(
      // TODO: Substitua pelas suas credenciais do Supabase
      url: 'https://fwkybhfzfrovjausuqgn.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ3a3liaGZ6ZnJvdmphdXN1cWduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg1MDI4OTgsImV4cCI6MjA3NDA3ODg5OH0.M7fN2ML2C4Lc1skLZx9YWyA9CUq813V6DNXP2QdTV0E',
    );
  }

  // Busca um funcionário pelo QR Code no banco de dados do Supabase
  Future<Funcionario?> buscarFuncionarioPorQrCode(String qrCode) async {
    print('🔍 Buscando funcionário com QR: $qrCode');
    try {
      final response = await _supabase
          .from('app_funcionarios') // <-- NOME DA TABELA ALTERADO AQUI
          .select()
          .eq('qr_code', qrCode) 
          .single();

        return Funcionario.fromJson(response);
    } catch (e) {
      print('❌ Erro ao buscar funcionário no Supabase: $e');
      return null;
    }
  }

  // Envia um registro de ponto para o Supabase
  Future<bool> sincronizarRegistro(Map<String, dynamic> registro) async {
    print('☁️ Tentando sincronizar com Supabase: $registro');
    try {
      // Remove o campo 'id' local para que o Supabase gere um novo
      final registroParaEnviar = Map<String, dynamic>.from(registro)..remove('id');

      await _supabase
          .from('app_registros_ponto') // <-- NOME DA TABELA ALTERADO AQUI
          .insert(registroParaEnviar);
      
      print('✅ Registro sincronizado com sucesso!');
      return true;
    } catch (e) {
      print('❌ Erro ao sincronizar com Supabase: $e');
      return false;
    }
  }
}