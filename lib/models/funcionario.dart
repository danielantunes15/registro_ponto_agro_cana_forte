class Funcionario {
  final String id;
  final String nome;
  final String matricula;
  final String funcao;
  final String qrCode;

  Funcionario({
    required this.id,
    required this.nome,
    required this.matricula,
    required this.funcao,
    required this.qrCode,
  });

  factory Funcionario.fromJson(Map<String, dynamic> json) {
    return Funcionario(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      matricula: json['matricula'] ?? '',
      funcao: json['funcao'] ?? '',
      qrCode: json['qr_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'matricula': matricula,
      'funcao': funcao,
      'qr_code': qrCode,
    };
  }

  @override
  String toString() {
    return 'Funcionario: $nome ($matricula) - $funcao';
  }
}