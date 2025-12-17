import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/patient_model.dart';

class AuthService {
  Future<Patient> loginPatient(String cpf) async {
    try {
      final cleanCPF = cpf.replaceAll(RegExp(r'\D'), '');

      final String apiUrl = dotenv.env['API_BASE_URL'] ?? '';
      final String codeProject = dotenv.env['CODEPROJETC_API'] ?? '';
      final String username = dotenv.env['USERNAME_API'] ?? '';
      final String password = dotenv.env['PASSWORD_API'] ?? '';

      if (apiUrl.isEmpty) {
        throw Exception('API_BASE_URL não configurada no arquivo .env');
      }

      final url = Uri.parse(apiUrl);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "partner": "app",
          "service": "authpatient",
          "request": {
            "cpf": cleanCPF,
            "username": username,
            "password": password,
            "codeproject": codeProject,
          },
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        // Verifica statusCode interno da resposta da API
        if (responseBody['statusCode'] == 200) {
          final patientData = responseBody['data'];

          if (patientData == null) {
            throw Exception("Dados de paciente não encontrados na resposta.");
          }

          final patient = Patient.fromJson(patientData, cleanCPF);

          final prefs = await SharedPreferences.getInstance();
          await patient.saveToPreferences(prefs);
          await prefs.setString('userType', 'patient');

          return patient;
        } else {
          throw Exception(
            responseBody['message'] ?? 'Erro na resposta da API.',
          );
        }
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha na autenticação: $e');
    }
  }

  Future<bool> verifyCode(String code) async {
    // TODO: Implementar chamada real ao API Gateway
    await Future.delayed(const Duration(seconds: 2));

    if (code == '1234') {
      return true;
    } else {
      print('false');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
