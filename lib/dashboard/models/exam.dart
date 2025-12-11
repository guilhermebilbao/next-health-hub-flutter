//Model da parte solicitacoesExames da estrutura json getpatientrecordhistory


class Exam {
  final String exame;
  final String? medicalRecordNumber;
  final String? codigoAtendimento;

  Exam({
    required this.exame,
    this.medicalRecordNumber,
    this.codigoAtendimento,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      exame: json['exame'] ?? '',
      medicalRecordNumber: json['medicalRecordNumber']?.toString(),
      codigoAtendimento: json['codigoAtendimento']?.toString(),
    );
  }
}
