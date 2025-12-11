import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../shared/api_client.dart';
import '../models/patient_history_models.dart';

class PatientHistoryService {
  final ApiClient _apiClient;

  PatientHistoryService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<PatientHistoryResponse> getPatientRecordHistory(String patientId) async {
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
      final response = await _apiClient.post("getpatientrecordhistory", requestBody);
      return PatientHistoryResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch patient history: $e');
    }
  }
}
