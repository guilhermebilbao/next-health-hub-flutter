

class Patient {
  final String patientId;
  final String? patientName;
  final String patientToken;
  final String patientCpf;

  Patient({
    required this.patientId,
    this.patientName,
    required this.patientToken,
    required this.patientCpf,
  });

  factory Patient.fromPrefs(Map<String, dynamic> prefs) {
    return Patient(
      patientId: prefs['patientId'],
      patientName: prefs['patientName'],
      patientToken: prefs['patientToken'],
      patientCpf: prefs['patientCpf'],
    );
  }
}
