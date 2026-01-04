class PatientVerifyTokenModel {
  final bool success;
  final String? jwt;
  final String? expiresAt;
  final VerifyTokenUser? user;

  PatientVerifyTokenModel({
    required this.success,
    this.jwt,
    this.expiresAt,
    this.user,
  });

  factory PatientVerifyTokenModel.fromJson(Map<String, dynamic> json) {
    return PatientVerifyTokenModel(
      success: json['success'] ?? false,
      jwt: json['jwt'],
      expiresAt: json['expires_at'],
      user: json['user'] != null ? VerifyTokenUser.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'jwt': jwt,
      'expires_at': expiresAt,
      'user': user?.toJson(),
    };
  }
}

class VerifyTokenUser {
  final String cpf;
  final String name;
  final String email;
  final String? patientName;
  final String? patientId;
  final String? birthDate;
  final String? socialName;
  final String? cns;

  VerifyTokenUser({
    required this.cpf,
    required this.name,
    required this.email,
    this.patientName,
    this.patientId,
    this.birthDate,
    this.socialName,
    this.cns,
  });

  factory VerifyTokenUser.fromJson(Map<String, dynamic> json) {
    return VerifyTokenUser(
      cpf: json['cpf'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      patientName: json['patientName'],
      patientId: json['patientId'],
      birthDate: json['birthDate'],
      socialName: json['socialName'],
      cns: json['cns'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cpf': cpf,
      'name': name,
      'email': email,
      'patientName': patientName,
      'patientId': patientId,
      'birthDate': birthDate,
      'socialName': socialName,
      'cns': cns,
    };
  }
}
