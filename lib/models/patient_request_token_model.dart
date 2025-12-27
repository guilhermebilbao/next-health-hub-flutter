class PatientRequestTokenModel {
  final bool success;
  final String message;
  final String? emailMasked;

  PatientRequestTokenModel({
    required this.success,
    required this.message,
    this.emailMasked,
  });

  factory PatientRequestTokenModel.fromJson(Map<String, dynamic> json) {
    return PatientRequestTokenModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      emailMasked: json['emailMasked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'emailMasked': emailMasked,
    };
  }
}
