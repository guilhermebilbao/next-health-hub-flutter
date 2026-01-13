import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:device_info_plus/device_info_plus.dart';

class TokenService {
  final http.Client _client;

  TokenService({http.Client? client}) : _client = client ?? http.Client();

  /// Gerencia o token no servidor
  Future<void> manageTokenOnServer(
    String fcmToken,
    String jwt,
    String endpoint,
  ) async {
    try {
      // 1. Monta a URL dinamicamente
      final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
      final String notificationPath = dotenv.env['API_NOTIFICATIONS'] ?? '';
      final url = Uri.parse('$baseUrl$notificationPath$endpoint');

      // 2. Define o corpo da requisição condicionalmente
      Map<String, dynamic> body;

      if (endpoint == '/unregister') {
        // Para unregister, envia apenas o fcmToken
        body = {"fcmToken": fcmToken};
      } else {
        // Para registro, coletam os dados completos do dispositivo
        final deviceInfo = DeviceInfoPlugin();
        String deviceId = '';
        String deviceModel = '';

        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id;
          deviceModel = androidInfo.model;
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor ?? 'unknown';
          deviceModel = iosInfo.utsname.machine;
        }

        body = {
          "fcmToken": fcmToken,
          "platform": Platform.isAndroid ? "android" : "ios",
          "deviceId": deviceId,
          "deviceModel": deviceModel,
          "appVersion": dotenv.env['APP_VERSION'] ?? "1.0.0",
        };
      }

      // 3. Executa a chamada HTTP (POST para registro, DELETE para unregister)
      final http.Response response;
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      };

      if (endpoint == '/unregister') {
        response = await _client.delete(
          url,
          headers: headers,
          body: jsonEncode(body),
        );
      } else {
        response = await _client.post(
          url,
          headers: headers,
          body: jsonEncode(body),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Sucesso ao executar $endpoint no servidor.');
      } else {
        print(
          'Falha ao executar $endpoint: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Erro crítico no RegisterTokenService ao acessar $endpoint: $e');
    }
  }
}
