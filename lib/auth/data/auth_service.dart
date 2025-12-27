import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/patient_model.dart';
import '../../models/patient_request_token_model.dart';
import '../../models/patient_verify_token_model.dart';

class AuthService {
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

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "cpf": cleanCPF,
          "recaptcha_token": "",
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        // Se a resposta contiver 'success' diretamente ou dentro de um campo data
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

      final response = await http.post(
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
          
          // Salva as informações do usuário e o token
          await prefs.setString('patientToken', verifyModel.jwt!);
          if (verifyModel.user != null) {
            await prefs.setString('patientCpf', verifyModel.user!.cpf);
            await prefs.setString('patientName', verifyModel.user!.name);
            await prefs.setString('email', verifyModel.user!.email);
            await prefs.setString('patientId', '9d8e62c4-b798-4d4b-9d03-5763264b9bdf');
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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
