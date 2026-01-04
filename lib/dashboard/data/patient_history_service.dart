import '../../shared/api_client.dart';
import '../models/history/patient_history_models.dart';

class PatientHistoryService {
  final ApiClient _apiClient;

  PatientHistoryService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<PatientHistoryResponse> getPatientRecordHistory(String patientId) async {
    final Map<String, dynamic> requestBody = {
      "patientId": patientId,
    };

    try {
      final response = await _apiClient.post("getpatientrecordhistory", requestBody);
      return PatientHistoryResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch patient history: $e');
    }
  }
}
