import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../firebase/data/token_service.dart';
import '../../models/patient_request_token_model.dart';
import '../../models/patient_verify_token_model.dart';

class AuthService {
  final http.Client _client;
  // Instância do Firebase Messaging
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Future<PatientRequestTokenModel> loginPatient(String cpf) async {
    try {
      final cleanCPF = cpf.replaceAll(RegExp(r'\D'), '');

      final String apiUrl = dotenv.env['API_BASE_URL'] ?? '';
      final String authRequestToken = dotenv.env['AUTH_REQUEST_TOKEN'] ?? '';

      if (apiUrl.isEmpty) {
        throw Exception('API_BASE_URL não configurada no arquivo .env');
      }

      if (authRequestToken.isEmpty) {
        throw Exception('AUTH_REQUEST_TOKEN não configurada no arquivo .env');
      }

      final url = Uri.parse(apiUrl + authRequestToken);

      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"cpf": cleanCPF, "recaptcha_token": ""}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final bool success =
            responseBody['success'] ??
            (responseBody['data']?['success'] ?? false);

        if (success) {
          final data = responseBody['data'] ?? responseBody;
          final patientAuth = PatientRequestTokenModel.fromJson(data);
          return patientAuth;
        } else {
          throw Exception(
            responseBody['message'] ?? 'Erro na resposta da API.',
          );
        }
      } else {
        throw Exception('Erro na requisição token: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Falha na requisição do token: $e');
    }
  }

  Future<bool> verifyCode(String cpf, String code) async {
    try {
      final cleanCPF = cpf.replaceAll(RegExp(r'\D'), '');
      final String apiUrl = dotenv.env['API_BASE_URL'] ?? '';
      final String authVerifyToken = dotenv.env['AUTH_VERIFY_TOKEN'] ?? '';

      if (apiUrl.isEmpty || authVerifyToken.isEmpty) {
        throw Exception('Configurações de API ausentes no .env');
      }

      final url = Uri.parse(apiUrl + authVerifyToken);

      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"cpf": cleanCPF, "token": code}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final verifyModel = PatientVerifyTokenModel.fromJson(responseBody);

        if (verifyModel.success && verifyModel.jwt != null) {
          final prefs = await SharedPreferences.getInstance();

          await prefs.setString('patientToken', verifyModel.jwt!);
          if (verifyModel.expiresAt != null) {
            await prefs.setString(
              'patientTokenExpiresAt',
              verifyModel.expiresAt!,
            );
          }

          if (verifyModel.user != null) {
            final user = verifyModel.user!;
            await prefs.setString('patientCpf', user.cpf);
            await prefs.setString('patientName', user.patientName ?? user.name);
            await prefs.setString('email', user.email);

            if (user.patientId != null) {
              await prefs.setString('patientId', user.patientId!);
            }
            if (user.birthDate != null) {
              await prefs.setString('patientBirthDate', user.birthDate!);
            }
            if (user.socialName != null) {
              await prefs.setString('patientSocialName', user.socialName!);
            }
            if (user.cns != null) {
              await prefs.setString('patientCns', user.cns!);
            }
          }
          await prefs.setString('userType', 'patient');

          // FCM
          await _handleFcmRegistration(verifyModel.jwt!);

          return true;
        }
      }
      return false;
    } catch (e) {
      print('Erro na verificação do código: $e');
      return false;
    }
  }

  // Gerencia a obtenção e registro do token FCM
  // Verificar posteriormente se vai ser preciso enviar o JTW nesse momento
  Future<void> _handleFcmRegistration(String jwt) async {
    try {
      // Solicita permissão
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? fcmToken = await _fcm.getToken();

        if (fcmToken != null) {
          final prefs = await SharedPreferences.getInstance();
          // Pega o último token enviado com sucesso para o servidor
          String? lastRegisteredToken = prefs.getString('last_fcm_token');

          // SÓ envia para o servidor se o token mudou OU se nunca foi enviado
          if (fcmToken != lastRegisteredToken) {
            print('FCM TOKEN NOVO OU ALTERADO: $fcmToken. Registrando...');

            final registerService = TokenService();
            await registerService.manageTokenOnServer(
              fcmToken,
              jwt,
              '/register',
            );

            // Salva localmente que este token já foi enviado com sucesso
            await prefs.setString('last_fcm_token', fcmToken);
          } else {
            print(
              'FCM TOKEN já está atualizado no servidor. Pulando registro.',
            );
          }
        }
      } else {
        print('Usuário recusou permissões de notificação.');
      }
    } catch (e) {
      print('Erro ao processar FCM: $e');
    }
  }

  Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('patientToken');
    final expiresAtStr = prefs.getString('patientTokenExpiresAt');

    if (token == null || expiresAtStr == null) return false;

    try {
      final expiresAt = DateTime.parse(expiresAtStr);
      return DateTime.now().isBefore(expiresAt);
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Recupera os dados necessários antes de limpar o storage
      final String? jwt = prefs.getString('patientToken');
      // Usa o token atual do FCM caso o 'last_fcm_token' não exista
      String? fcmToken = prefs.getString('last_fcm_token');

      fcmToken ??= await _fcm.getToken();

      print('Efetuando logout e desvinculando token: $fcmToken');

      // Se tiver os dados, avisamos o servidor para desvincular o token
      if (jwt != null && fcmToken != null) {
        try {
          final registerService = TokenService();
          // Chamada para desvincular o token no backend
          await registerService.manageTokenOnServer(
            fcmToken,
            jwt,
            '/unregister',
          );
        } catch (e) {
          print('Erro ao desregistrar FCM no logout (servidor): $e');
        }
      }
    } catch (e) {
      print('Erro ao processar lógica de logout: $e');
    } finally {
      // Limpa todos os dados locais independentemente de sucesso na API
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('Dados locais limpos.');
    }
  }
}
