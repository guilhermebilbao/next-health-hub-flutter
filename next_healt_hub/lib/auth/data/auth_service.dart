import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> loginPatient(String cpf) async {
    try {
      // Limpeza do CPF
      final cleanCPF = cpf.replaceAll(RegExp(r'\D'), '');

      // Chamada da Edge Function

      final response = await _supabase.functions.invoke(
        'auth-patient',
        body: {'cpf': cleanCPF},
      );

      final data = response.data;

      // Validação da resposta
      if (data != null && data['statusCode'] == 200) {
        final patientData = data['data'];

        // Persistência local
        final prefs = await SharedPreferences.getInstance();

        // Salvando os campos
        await prefs.setString('patientId', patientData['patientId'].toString());
        if (patientData['patientName'] != null) {
          await prefs.setString('patientName', patientData['patientName']);
        }
        await prefs.setString('patientToken', patientData['token']);
        await prefs.setString('patientCpf', cleanCPF);
        await prefs.setString('userType', 'patient');
      } else {
        // Tratamento de erro vindo da API (ex: CPF não encontrado)
        throw Exception(data['message'] ?? 'Erro desconhecido ao autenticar.');
      }
    } catch (e) {
      // Erros de rede ou exceções lançadas acima
      throw Exception('Falha na autenticação: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Se estiver usando Auth do Supabase também
    // await _supabase.auth.signOut();
  }
}
