import 'dart:io';
import '../../shared/api_client.dart';

class RegisterTokenService {
  final ApiClient _apiClient;

  RegisterTokenService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
 ///TODO apenas um molde deve ajustar conforme definido no servico
  Future<void> _registerTokenOnServer(String fcmToken) async {
    try {
      final Map<String, dynamic> requestBody = {
        "fcmToken": fcmToken,
        "platform": Platform.isAndroid ? 'android' : 'ios',
      };

      await _apiClient.post("setFCMToken", requestBody);
      print('FCM Token registrado com sucesso via ApiClient.');
    } catch (e) {
      print('Erro ao registrar FCM no servidor: $e');
    }
  }
}