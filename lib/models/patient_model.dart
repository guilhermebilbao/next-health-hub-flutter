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
}
