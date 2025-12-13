import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../shared/api_client.dart';

class PatientExamAttachmentService {
  final ApiClient _apiClient;

  PatientExamAttachmentService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> getExamAttachment(String attachmentId) async {
    final username = dotenv.env['USERNAME_API'];
    final password = dotenv.env['PASSWORD_API'];
    final codeproject = dotenv.env['CODEPROJETC_API'];

    final requestBody = {
      "attachmentId": attachmentId,
      "username": username,
      "password": password,
      "codeproject": codeproject,
    };

    try {
      final response = await _apiClient.post("getreportattachementbyid", requestBody);
      return response;
    } catch (e) {
      throw Exception('Failed to fetch exam attachment: $e');
    }
  }
}
