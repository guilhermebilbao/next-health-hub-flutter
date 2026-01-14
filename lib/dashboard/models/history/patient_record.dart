//Modelo do data da resposta da estrutura json getpatientrecordhistory

import 'procedure.dart';
import 'medicine.dart';
import 'exam.dart';

class PatientRecord {
  final String medicalRecordNumber;
  final String codigoAtendimento;
  final String dataAtendimento;
  final String anamnese;
  final String exameFisico;
  final String? conduta;
  final List<Procedimento> procedimentos;
  final List<Medicamento> medicamentos;
  final List<Exam> solicitacoesExames;

  PatientRecord({
    required this.medicalRecordNumber,
    required this.codigoAtendimento,
    required this.dataAtendimento,
    required this.anamnese,
    required this.exameFisico,
    this.conduta,
    required this.procedimentos,
    required this.medicamentos,
    required this.solicitacoesExames,
  });

  Map<String, dynamic> toJson() {
    return {
      'medicalRecordNumber': medicalRecordNumber,
      'codigoAtendimento': codigoAtendimento,
      'dataAtendimento': dataAtendimento,
      'anamnese': anamnese,
      'exameFisico': exameFisico,
      'conduta': conduta,
      'procedimentos': procedimentos.map((i) => i.toJson()).toList(),
      'medicamentos': medicamentos.map((i) => i.toJson()).toList(),
      'solicitacoesExames': solicitacoesExames.map((i) => i.toJson()).toList(),
    };
  }

  factory PatientRecord.fromJson(Map<String, dynamic> json) {
    return PatientRecord(
      medicalRecordNumber: json['medicalRecordNumber'] ?? '',
      codigoAtendimento: json['codigoAtendimento'] ?? '',
      dataAtendimento: json['dataAtendimento'] ?? '',
      anamnese: json['anamnese'] ?? '',
      exameFisico: json['exameFisico'] ?? '',
      conduta: json['conduta'],
      procedimentos: (json['procedimentos'] as List?)
              ?.map((i) => Procedimento.fromJson(i))
              .toList() ??
          [],
      medicamentos: (json['medicamentos'] as List?)
              ?.map((i) => Medicamento.fromJson(i))
              .toList() ??
          [],
      solicitacoesExames: (json['solicitacoesExames'] as List?)
              ?.map((i) => Exam.fromJson(i))
              .toList() ??
          [],
    );
  }
}