class Medicamento {
  final String medicamento;
  final String quantidade;
  final String posologia;

  Medicamento({
    required this.medicamento,
    required this.quantidade,
    required this.posologia,
  });

  factory Medicamento.fromJson(Map<String, dynamic> json) {
    return Medicamento(
      medicamento: json['medicamento'] ?? '',
      quantidade: json['quantidade'] ?? '',
      posologia: json['posologia'] ?? '',
    );
  }
}