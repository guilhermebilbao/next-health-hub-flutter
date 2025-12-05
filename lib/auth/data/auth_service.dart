import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/patient_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Patient> loginPatient(String cpf) async {
    try {
      final cleanCPF = cpf.replaceAll(RegExp(r'\D'), '');

      final response = await _supabase.functions.invoke(
        'auth-patient',
        body: {'cpf': cleanCPF},
      );

      final data = response.data;

      if (data != null && data['statusCode'] == 200) {
        final patientData = data['data'];

        final patient = Patient(
          patientId: patientData['patientId'].toString(),
          patientName: patientData['patientName'],
          patientToken: patientData['token'],
          patientCpf: cleanCPF,
        );

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('patientId', patient.patientId);
        if (patient.patientName != null) {
          await prefs.setString('patientName', patient.patientName!);
        }
        await prefs.setString('patientToken', patient.patientToken);
        await prefs.setString('patientCpf', patient.patientCpf);
        await prefs.setString('userType', 'patient');

        return patient;
      } else {
        throw Exception(data['message'] ?? 'Erro desconhecido ao autenticar.');
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
