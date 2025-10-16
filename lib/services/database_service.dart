import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'agro_cana_forte.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE registros(
        id TEXT PRIMARY KEY,
        funcionario_id TEXT,
        matricula TEXT,
        nome_funcionario TEXT,
        data_hora TEXT,
        tipo TEXT,
        localizacao TEXT,
        sincronizado INTEGER,
        qr_code_data TEXT
      )
    ''');
  }

  // Salvar um registro de ponto no banco de dados local
  Future<void> salvarRegistro(Map<String, dynamic> registro) async {
    final db = await database;
    await db.insert(
      'registros',
      {
        ...registro,
        'sincronizado': (registro['sincronizado'] as bool) ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('📁 Registro salvo localmente: $registro');
  }

  // Buscar o último registro de um funcionário no dia atual
  Future<Map<String, dynamic>?> buscarUltimoRegistroDoDia(String funcionarioId) async {
    final db = await database;
    final hoje = DateTime.now();
    final inicioDoDia = DateTime(hoje.year, hoje.month, hoje.day).toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'registros',
      where: 'funcionario_id = ? AND data_hora >= ?',
      whereArgs: [funcionarioId, inicioDoDia],
      orderBy: 'data_hora DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }


  // Buscar todos os registros locais
  Future<List<Map<String, dynamic>>> buscarRegistros() async {
    final db = await database;
    final result = await db.query('registros', orderBy: 'data_hora DESC');
     print('📁 Buscando registros locais...');
    return result;
  }
}