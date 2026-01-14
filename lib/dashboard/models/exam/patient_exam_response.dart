import 'patient_exam.dart';

class PatientExamResponse {
  final int statusCode;
  final String message;
  final List<PatientExam> data;

  PatientExamResponse({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  // Método adicionado
  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }

  factory PatientExamResponse.fromJson(Map<String, dynamic> json) {
    return PatientExamResponse(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List?)?.map((e) => PatientExam.fromJson(e)).toList() ?? [],
    );
  }
}
