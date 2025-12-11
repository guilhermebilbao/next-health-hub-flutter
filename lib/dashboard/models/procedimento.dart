class Procedimento {
  final String procedimento;

  Procedimento({required this.procedimento});

  factory Procedimento.fromJson(Map<String, dynamic> json) {
    return Procedimento(
      procedimento: json['procedimento'] ?? '',
    );
  }
}