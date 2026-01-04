import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/patient_model.dart';
import '../../models/patient_request_token_model.dart';
import '../../models/patient_verify_token_model.dart';

class AuthService {
  final http.Client _client;

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
        body: jsonEncode({
          "cpf": cleanCPF,
          "recaptcha_token": "",
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final bool success = responseBody['success'] ?? (responseBody['data']?['success'] ?? false);
        
        if (success) {
          final data = responseBody['data'] ?? responseBody;
          final patientAuth = PatientRequestTokenModel.fromJson(data);
          return patientAuth;
        } else {
          throw Exception(responseBody['message'] ?? 'Erro na resposta da API.');
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
        body: jsonEncode({
          "cpf": cleanCPF,
          "token": code,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final verifyModel = PatientVerifyTokenModel.fromJson(responseBody);

        if (verifyModel.success && verifyModel.jwt != null) {
          final prefs = await SharedPreferences.getInstance();
          
          await prefs.setString('patientToken', verifyModel.jwt!);
          if (verifyModel.expiresAt != null) {
            await prefs.setString('patientTokenExpiresAt', verifyModel.expiresAt!);
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
          
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Erro na verificação do código: $e');
      return false;
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
