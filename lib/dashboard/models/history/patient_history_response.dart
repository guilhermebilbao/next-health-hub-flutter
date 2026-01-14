//Modelo macro da resposta da estrutura json getpatientrecordhistory

import 'patient_record.dart';

class PatientHistoryResponse {
  final int statusCode;
  final String message;
  final List<PatientRecord> data;

  PatientHistoryResponse({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }

  factory PatientHistoryResponse.fromJson(Map<String, dynamic> json) {
    return PatientHistoryResponse(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
              ?.map((i) => PatientRecord.fromJson(i))
              .toList() ??
          [],
    );
  }
}
