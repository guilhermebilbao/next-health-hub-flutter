import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  Future<Map<String, dynamic>> post(
    String service,
    Map<String, dynamic> requestBody, {
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final baseUrl = dotenv.env['API_BASE_URL'];
    final proxy = dotenv.env['PROXY'] ?? '';
    
    debugPrint('API Base URL: $baseUrl');

    if (baseUrl == null) {
      throw Exception('API_BASE_URL is not configured');
    }

    final url = Uri.parse('$baseUrl$proxy');

    // Adiciona credenciais comuns se não for o serviço de anexo
    if (service != "getreportattachementbyid") {
      requestBody.addAll({
        "username": dotenv.env['USERNAME_API'],
        "password": dotenv.env['PASSWORD_API'],
        "codeproject": dotenv.env['CODEPROJETC_API'],
      });
    }

    final body = {"partner": "app", "service": service, "request": requestBody};

    debugPrint('Calling Service: $service');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('patientToken');

      final headers = {
        "Content-Type": "application/json",
      };

      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }

      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(timeout);

      debugPrint('Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Response Body: ${response.body}');
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      debugPrint('Network Error: $e');
      rethrow;
    } catch (e) {
      debugPrint('API Client Error: $e');
      rethrow;
    }
  }
}
