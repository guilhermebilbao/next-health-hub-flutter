import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
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
    // --- VERIFICAÇÃO PROATIVA DE REDE ---
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      debugPrint('AuthService: Bloqueando tentativa de login - Sem internet.');
      throw Exception(
        'Sem conexão com a internet. Verifique seu Wi-Fi ou dados móveis.',
      );
    }
    debugPrint(
      'AuthService: Iniciando solicitação de login para CPF: ${cpf.substring(0, 3)}.***.***-${cpf.substring(cpf.length - 2)}',
    );
    try {
      final cleanCPF = cpf.replaceAll(RegExp(r'\D'), '');

      final String apiUrl = dotenv.env['API_BASE_URL'] ?? '';
      final String authRequestToken = dotenv.env['AUTH_REQUEST_TOKEN'] ?? '';

      if (apiUrl.isEmpty) {
        debugPrint('AuthService ERROR: API_BASE_URL não configurada');
        throw Exception('Erro de configuração do servidor.');
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
          debugPrint('AuthService: Código 2FA enviado com sucesso.');
          final data = responseBody['data'] ?? responseBody;
          final patientAuth = PatientRequestTokenModel.fromJson(data);
          return patientAuth;
        } else {
          debugPrint(
            'AuthService: API retornou erro no corpo: ${responseBody['message']}',
          );
          throw Exception(
            responseBody['message'] ?? 'Falha ao processar login.',
          );
        }
      } else {
        debugPrint('AuthService ERROR: Status Code ${response.statusCode}');
        throw Exception(
          'O servidor encontrou um problema. Tente novamente mais tarde.',
        );
      }
    } catch (e) {
      debugPrint('AuthService Catch: $e');
      if (e is Exception) rethrow;
      throw Exception('Não foi possível conectar ao servidor.');
    }
  }

  Future<bool> verifyCode(String cpf, String code) async {
    debugPrint('AuthService: Verificando código 2FA...');
    try {
      final cleanCPF = cpf.replaceAll(RegExp(r'\D'), '');
      final String apiUrl = dotenv.env['API_BASE_URL'] ?? '';
      final String authVerifyToken = dotenv.env['AUTH_VERIFY_TOKEN'] ?? '';

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
          debugPrint(verifyModel.jwt);
          debugPrint(
            'AuthService: Token JWT recebido. Salvando credenciais...',
          );
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

              debugPrint(user.patientId!);
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

          debugPrint(
            'AuthService: Login verificado com sucesso. Iniciando registro FCM...',
          );
          // FCM
          await _handleFcmRegistration(verifyModel.jwt!);

          return true;
        } else {
          debugPrint(
            'AuthService: Falha na validação do código - Resposta negativa do servidor.',
          );
        }
      } else {
        debugPrint(
          'AuthService ERROR: Status code na verificação: ${response.statusCode}',
        );
      }
      return false;
    } catch (e) {
      debugPrint('AuthService ERROR na verificação: $e');
      return false;
    }
  }

  // Gerencia a obtenção e registro do token FCM
  Future<void> _handleFcmRegistration(String jwt) async {
    try {
      debugPrint('AuthService: Solicitando permissões de notificação...');
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? fcmToken = await _fcm.getToken();

        debugPrint(fcmToken);
        debugPrint('AuthService: Token FCM obtido.');

        if (fcmToken != null) {
          final prefs = await SharedPreferences.getInstance();
          String? lastRegisteredToken = prefs.getString('last_fcm_token');

          if (fcmToken != lastRegisteredToken) {
            debugPrint(
              'AuthService: Registrando novo token FCM no servidor...',
            );
            final registerService = TokenService();
            await registerService.manageTokenOnServer(
              fcmToken,
              jwt,
              '/register',
            );
            await prefs.setString('last_fcm_token', fcmToken);
          } else {
            debugPrint('AuthService: Token FCM já registrado anteriormente.');
          }
        }
      } else {
        debugPrint('AuthService: Usuário recusou permissões de notificação.');
      }
    } catch (e) {
      debugPrint('AuthService ERROR no processamento FCM: $e');
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
    debugPrint('AuthService: Iniciando processo de logout...');
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? jwt = prefs.getString('patientToken');
      String? fcmToken = prefs.getString('last_fcm_token');
      fcmToken ??= await _fcm.getToken();

      if (jwt != null && fcmToken != null) {
        try {
          debugPrint('AuthService: Solicitando desvinculação de token FCM...');
          final registerService = TokenService();
          await registerService.manageTokenOnServer(
            fcmToken,
            jwt,
            '/unregister',
          );
        } catch (e) {
          debugPrint('AuthService: Erro ao desregistrar FCM no logout: $e');
        }
      }
    } catch (e) {
      debugPrint('AuthService ERROR no logout: $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint('AuthService: Dados locais limpos. Logout concluído.');
    }
  }
}
