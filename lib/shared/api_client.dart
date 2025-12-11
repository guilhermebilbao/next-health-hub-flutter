import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  Future<Map<String, dynamic>> post(String service, Map<String, dynamic> requestBody) async {
    final baseUrl = dotenv.env['API_BASE_URL'];
    debugPrint('API Base URL: $baseUrl');
    
    if (baseUrl == null) {
      throw Exception('API_BASE_URL is not configured');
    }
    
    final url = Uri.parse(baseUrl);

    final body = {
      "partner": "app",
      "service": service,
      "request": requestBody,
    };

    debugPrint('Calling Service: $service');
    // debugPrint('Body: ${jsonEncode(body)}'); // Uncomment if needed

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      debugPrint('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Response Body: ${response.body}');
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API Client Error: $e');
      rethrow;
    }
  }
}
