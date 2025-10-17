class RegistroPonto {
  final String? id;
  final String funcionarioId;
  final String matricula;
  final String nomeFuncionario;
  final DateTime dataHora;
  final String tipo; // 'entrada' ou 'saida'
  final String localizacao;
  final bool sincronizado;
  final String? qrCodeData;

  RegistroPonto({
    this.id,
    required this.funcionarioId,
    required this.matricula,
    required this.nomeFuncionario,
    required this.dataHora,
    required this.tipo,
    required this.localizacao,
    this.sincronizado = false,
    this.qrCodeData,
  });

  // Converter para JSON (para salvar no banco)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'funcionario_id': funcionarioId,
      'matricula': matricula,
      'nome_funcionario': nomeFuncionario,
      'data_hora': dataHora.toIso8601String(),
      'tipo': tipo,
      'localizacao': localizacao,
      'sincronizado': sincronizado,
      'qr_code_data': qrCodeData,
    };
  }

  // Criar objeto a partir de JSON (converte 0/1 do SQLite para bool)
  factory RegistroPonto.fromJson(Map<String, dynamic> json) {
    bool isSincronizado = false;
    final syncValue = json['sincronizado'];
    if (syncValue is int) {
      isSincronizado = syncValue == 1;
    } else if (syncValue is bool) {
      isSincronizado = syncValue;
    }

    return RegistroPonto(
      id: json['id'],
      funcionarioId: json['funcionario_id'],
      matricula: json['matricula'],
      nomeFuncionario: json['nome_funcionario'],
      dataHora: DateTime.parse(json['data_hora']),
      tipo: json['tipo'],
      localizacao: json['localizacao'],
      sincronizado: isSincronizado,
      qrCodeData: json['qr_code_data'],
    );
  }

  // Métodos úteis
  String get dataFormatada {
    final dia = dataHora.day.toString().padLeft(2, '0');
    final mes = dataHora.month.toString().padLeft(2, '0');
    final ano = dataHora.year.toString();
    return '$dia/$mes/$ano';
  }

  String get horaFormatada {
    final hora = dataHora.hour.toString().padLeft(2, '0');
    final minuto = dataHora.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }
}