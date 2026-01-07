import '../../shared/api_client.dart';

class PatientExamAttachmentService {
  final ApiClient _apiClient;

  PatientExamAttachmentService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> getExamAttachment(String attachmentId) async {

    final requestBody = {
      "attachmentId": attachmentId,
    };

    try {
      final response = await _apiClient.post("getreportattachementbyid", requestBody);
      return response;
    } catch (e) {
      throw Exception('Failed to fetch exam attachment: $e');
    }
  }
}
