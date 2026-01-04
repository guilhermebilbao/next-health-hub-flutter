import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:next_health_hub/auth/data/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Este arquivo não precisa de mocks complexos do Mockito por enquanto porque SharedPreferences.setMockInitialValues é suficiente.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService - isTokenValid', () {
    test('deve retornar false se não houver token salvo', () async {
      SharedPreferences.setMockInitialValues({});
      final authService = AuthService();
      
      final isValid = await authService.isTokenValid();
      
      expect(isValid, isFalse);
    });

    test('deve retornar true se o token ainda não expirou', () async {
      // Configura um token que expira amanhã
      final tomorrow = DateTime.now().add(const Duration(days: 1)).toIso8601String();
      SharedPreferences.setMockInitialValues({
        'patientToken': 'meu_jwt_valido',
        'patientTokenExpiresAt': tomorrow,
      });

      final authService = AuthService();
      final isValid = await authService.isTokenValid();
      
      expect(isValid, isTrue);
    });

    test('deve retornar false se o token já expirou', () async {
      // Configura um token que expirou ontem
      final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String();
      SharedPreferences.setMockInitialValues({
        'patientToken': 'meu_jwt_expirado',
        'patientTokenExpiresAt': yesterday,
      });

      final authService = AuthService();
      final isValid = await authService.isTokenValid();
      
      expect(isValid, isFalse);
    });

    test('deve retornar false se a data de expiração for inválida', () async {
      SharedPreferences.setMockInitialValues({
        'patientToken': 'token_com_data_ruim',
        'patientTokenExpiresAt': 'data-invalida',
      });

      final authService = AuthService();
      final isValid = await authService.isTokenValid();
      
      expect(isValid, isFalse);
    });
  });
}
