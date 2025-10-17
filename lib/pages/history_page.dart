import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/registro_ponto.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<RegistroPonto>> _registrosFuture;
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _registrosFuture = _carregarRegistros();
  }

  Future<List<RegistroPonto>> _carregarRegistros() async {
    final registrosMap = await _dbService.buscarRegistros();
    // Converte a lista de Map<String, dynamic> para List<RegistroPonto>
    return registrosMap.map((map) => RegistroPonto.fromJson(map)).toList();
  }

  // Mapeia o tipo de registro para uma cor
  Color _getColorForTipo(String tipo) {
    switch (tipo) {
      case 'entrada':
        return Colors.blue.shade700;
      case 'saida_almoco':
        return Colors.orange.shade700;
      case 'retorno_almoco':
        return Colors.green.shade700;
      case 'saida':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Histórico de Pontos'),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _registrosFuture = _carregarRegistros();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<RegistroPonto>>(
        future: _registrosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar registros: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Nenhum registro de ponto encontrado localmente.',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          final registros = snapshot.data!;
          // Agrupa os registros por data
          final Map<String, List<RegistroPonto>> registrosPorDia = {};
          final dateFormatter = DateFormat('dd/MM/yyyy');
          for (var registro in registros) {
            final data = dateFormatter.format(registro.dataHora);
            if (!registrosPorDia.containsKey(data)) {
              registrosPorDia[data] = [];
            }
            registrosPorDia[data]!.add(registro);
          }

          final dias = registrosPorDia.keys.toList();

          return ListView.builder(
            itemCount: dias.length,
            itemBuilder: (context, index) {
              final dia = dias[index];
              final registrosDoDia = registrosPorDia[dia]!;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Dia: $dia',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900]),
                      ),
                    ),
                    const Divider(height: 1),
                    ...registrosDoDia.map((registro) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getColorForTipo(registro.tipo),
                          child: Text(
                            registro.tipo[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          registro.nomeFuncionario,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${registro.tipo.replaceAll('_', ' ').toUpperCase()} | Matrícula: ${registro.matricula}',
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(registro.horaFormatada,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Icon(
                              registro.sincronizado ? Icons.cloud_done : Icons.cloud_off,
                              color: registro.sincronizado ? Colors.green : Colors.orange,
                              size: 16,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}