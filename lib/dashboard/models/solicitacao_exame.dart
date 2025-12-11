class SolicitacaoExame {
  final String exame;

  SolicitacaoExame({required this.exame});

  factory SolicitacaoExame.fromJson(Map<String, dynamic> json) {
    return SolicitacaoExame(
      exame: json['exame'] ?? '',
    );
  }
}