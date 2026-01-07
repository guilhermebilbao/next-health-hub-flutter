import 'dart:async';
import '../../shared/api_client.dart';
import '../models/exam/patient_exam_response.dart';

class PatientExamService {
  final ApiClient _apiClient;

  PatientExamService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<PatientExamResponse> getPatientExams(String patientId) async {
    final Map<String, dynamic> requestBody = {
      "patientId": patientId,
    };

    try {
      final response = await _apiClient.post(
        "getreportsbypatientid",
        requestBody,
        timeout: const Duration(seconds: 60),
      );

      return PatientExamResponse.fromJson(response);
    } on TimeoutException {
      throw Exception('O servidor demorou muito para responder. Por favor, '
          'verifique sua conexão ou tente novamente mais tarde.');
    } catch (e) {
      throw Exception('Não foi possível carregar os exames: $e');
    }
  }
}
