import 'package:shared_preferences/shared_preferences.dart';

class Patient {
  final String patientId;
  final String? patientName;
  final String patientToken;
  final String patientCpf;
  final String? birthDate;
  final String? socialName;
  final String? cns;
  final bool? habilitarHistoricoApp;
  final String? email;

  Patient({
    required this.patientId,
    this.patientName,
    required this.patientToken,
    required this.patientCpf,
    this.birthDate,
    this.socialName,
    this.cns,
    this.habilitarHistoricoApp,
    this.email,
  });

  factory Patient.fromPrefs(Map<String, dynamic> prefs) {
    return Patient(
      patientId: prefs['patientId'] ?? '',
      patientName: prefs['patientName'],
      patientToken: prefs['patientToken'] ?? '',
      patientCpf: prefs['patientCpf'] ?? '',
      birthDate: prefs['birthDate'],
      socialName: prefs['socialName'],
      cns: prefs['cns'],
      habilitarHistoricoApp: prefs['habilitarHistoricoApp'] == true || prefs['habilitarHistoricoApp'] == 'true',
      email: prefs['email'],
    );
  }

  factory Patient.fromJson(Map<String, dynamic> json, String cpf) {
    return Patient(
      patientId: json['patientId']?.toString() ?? '',
      patientName: json['patientName'],
      patientToken: json['token'] ?? '',
      patientCpf: json['cpfNumber']?.toString() ?? cpf,
      birthDate: json['birthDate'],
      socialName: json['socialName'],
      cns: json['cns'],
      habilitarHistoricoApp: json['habilitarHistoricoApp'],
      email: json['email'],
    );
  }

  Future<void> saveToPreferences(SharedPreferences prefs) async {

    await prefs.setString('patientId', patientId);
    await prefs.setString('patientToken', patientToken);
    await prefs.setString('patientCpf', patientCpf);

    final Map<String, String?> optionalStringFields = {
      'patientName': patientName,
      'birthDate': birthDate,
      'socialName': socialName,
      'cns': cns,
      'email': email,
    };

    for (var entry in optionalStringFields.entries) {
      if (entry.value != null) {
        await prefs.setString(entry.key, entry.value!);
      }
    }

    if (habilitarHistoricoApp != null) {
      await prefs.setBool('habilitarHistoricoApp', habilitarHistoricoApp!);
    }
  }
}
