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

  factory PatientHistoryResponse.fromJson(Map<String, dynamic> json) {
    return PatientHistoryResponse(
      statusCode: json['statusCode'],
      message: json['message'],
      data: (json['data'] as List)
          .map((i) => PatientRecord.fromJson(i))
          .toList(),
    );
  }
}