import 'package:shared_preferences/shared_preferences.dart';

class DashboardRepository {
  Future<String> getPatientName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('patientName') ?? 'Usuário';
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Bom dia";
    if (hour < 18) return "Boa tarde";
    return "Boa noite";
  }

  String getFormattedDate() {
    final now = DateTime.now();
    final days = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo'
    ];
    final months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];

    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];

    return '$dayName, ${now.day} de $monthName de ${now.year}';
  }

  String getFormattedTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
