//Model da parte procedimentos da estrutura json getpatientrecordhistory

class Procedimento {
  final String medicalRecordNumber;
  final String codigoAtendimento;
  final String procedimento;

  Procedimento({
    required this.medicalRecordNumber,
    required this.codigoAtendimento,
    required this.procedimento,
  });

  factory Procedimento.fromJson(Map<String, dynamic> json) {
    return Procedimento(
      medicalRecordNumber: json['medicalRecordNumber'] ?? '',
      codigoAtendimento: json['codigoAtendimento'] ?? '',
      procedimento: json['procedimento'] ?? ' ',
    );
  }
}
