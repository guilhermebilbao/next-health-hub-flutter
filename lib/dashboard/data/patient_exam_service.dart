import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../shared/api_client.dart';
import '../models/exam/patient_exam_response.dart';

class PatientExamService {
  final ApiClient _apiClient;

  PatientExamService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<PatientExamResponse> getPatientExams(String patientId) async {
    final requestBody = {
      "patientId": patientId,
      "username": dotenv.env['USERNAME_API'],
      "password": dotenv.env['PASSWORD_API'],
      "codeproject": dotenv.env['CODEPROJETC_API'],
    };

    try {
      final response = await _apiClient.post(
        "getreportsbypatientid",
        requestBody,
        timeout: const Duration(seconds: 60),
      );

      return PatientExamResponse.fromJson(response);
    } on TimeoutException {
      throw Exception('O servidor demorou muito para responder. Por favor, verifique sua conexão ou tente novamente mais tarde.');
    } catch (e) {
      throw Exception('Não foi possível carregar os exames: $e');
    }
  }
}