import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../shared/api_client.dart';
import '../models/exam/patient_exam_response.dart';

class PatientExamService {
  final ApiClient _apiClient;

  PatientExamService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<PatientExamResponse> getPatientExams(String patientId) async {
    final username = dotenv.env['USERNAME_API'];
    final password = dotenv.env['PASSWORD_API'];
    final codeproject = dotenv.env['CODEPROJETC_API'];

    final requestBody = {
      "patientId": patientId,
      "username": username,
      "password": password,
      "codeproject": codeproject,
    };

    try {
      final response = await _apiClient.post("getreportsbypatientid", requestBody);
      return PatientExamResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch patient exams: $e');
    }
  }
}
