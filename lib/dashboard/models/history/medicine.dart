//Model da parte medicamentos da estrutura json getpatientrecordhistory

class Medicamento {
  final String medicamento;
  final String quantidade;
  final String posologia;
  final String? medicalRecordNumber;
  final String? codigoAtendimento;
  final String? dataAtendimento;

  Medicamento({
    required this.medicamento,
    required this.quantidade,
    required this.posologia,
    this.medicalRecordNumber,
    this.codigoAtendimento,
    this.dataAtendimento,
  });

  Map<String, dynamic> toJson() {
    return {
      'medicamento': medicamento,
      'quantidade': quantidade,
      'posologia': posologia,
      'medicalRecordNumber': medicalRecordNumber,
      'codigoAtendimento': codigoAtendimento,
      'dataAtendimento': dataAtendimento,
    };
  }


  factory Medicamento.fromJson(Map<String, dynamic> json) {
    return Medicamento(
      medicamento: json['medicamento'] ?? '',
      quantidade: json['quantidade'] ?? '',
      posologia: json['posologia'] ?? '',
      medicalRecordNumber: json['medicalRecordNumber']?.toString(),
      codigoAtendimento: json['codigoAtendimento']?.toString(),
      dataAtendimento: json['dataAtendimento']?.toString(),
    );
  }
}
