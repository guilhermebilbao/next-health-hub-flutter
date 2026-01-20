import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

import '../../../shared/app_formatters.dart';

class PatientSusCard extends StatelessWidget {
  final String nomeCompleto;
  final String numeroCartao;
  final String dataNascimento;


  // Cores usadas na contrucao
  final Color emerald700 = const Color(0xFF047857);
  final Color emerald600 = const Color(0xFF059669);
  final Color emerald500 = const Color(0xFF10B981);
  final Color yellow400 = const Color(0xFFFACC15);
  final Color yellow500 = const Color(0xFFEAB308);
  final Color blue600 = const Color(0xFF2563EB);
  final Color blue700 = const Color(0xFF1D4ED8);

  const PatientSusCard({
    super.key,
    required this.nomeCompleto,
    required this.numeroCartao,
    required this.dataNascimento,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 320,
      height: 500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Parte superior verde
            Expanded(flex: 4, child: _buildTopSection()),
            // Parte inferior amarelo
            Expanded(flex: 7, child: _buildBottomSection()),
          ],
        ),
      ),
    );
  }

  // Parte Superior identidade SUS
  Widget _buildTopSection() {
    return Stack(
      children: [
        // 1. Fundo Gradiente Verde
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [emerald700, emerald600, emerald500],
            ),
          ),
        ),

        // 2. Triângulo Azul - Canto Superior Direito
        Positioned(
          top: 0,
          right: 0,
          child: ClipPath(
            clipper: TriangleClipper(),
            child: Container(
              width: 120,
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [blue600, blue700]),
              ),
              child: const Stack(
                children: [
                  Positioned(
                    top: 30,
                    right: 30,
                    child: Text(
                      '★',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  Positioned(
                    top: 55,
                    right: 45,
                    child: Text(
                      '★',
                      style: TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    right: 30,
                    child: Text(
                      '★',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  Positioned(
                    top: 55,
                    right: 15,
                    child: Text(
                      '★',
                      style: TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 3. Logo SUS e Título
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      color: emerald600,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: const Text(
                        'SUS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sistema\nde Saúde',
                      style: TextStyle(
                        color: emerald700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                'Cartão Nacional\nde Saúde',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                ),
              ),
            ],
          ),
        ),

        // 4. Faixa Amarela de Transição
        Positioned(
          bottom: -10,
          left: -10,
          right: -10,
          child: Transform(
            transform: Matrix4.skewY(-0.04),
            child: Container(
              height: 25,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [yellow400, yellow500]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Parte inferior -  Dados e Barcode
  Widget _buildBottomSection() {

    String dataNascimentoFormatada = AppFormatters.formateBirthDate(dataNascimento);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [yellow400, yellow500],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              'Sistema Único de Saúde',
              style: TextStyle(
                color: emerald700,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          // Cartão Branco Interno
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Nome do beneficiário'),
                  Text(
                    nomeCompleto.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Data Nasc.:'),
                            Text(
                              dataNascimentoFormatada,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Sexo:'),
                            const Text(
                              '--',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLabel('Número do Cartão'),
                        const SizedBox(height: 4),
                        BarcodeWidget(
                          barcode: Barcode.code128(),
                          data: numeroCartao.replaceAll(RegExp(r'[.\-\s]'), ''),
                          height: 40,
                          drawText: false,
                          width: double.infinity,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          numeroCartao,
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Rodapé Verde
          Container(
            color: emerald700,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'DISQUE SAÚDE 136',
                          style: TextStyle(
                            color: emerald700,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'VÁLIDO EM TODO O TERRITÓRIO NACIONAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Bandeira do Brasil simplificada
                Container(
                  width: 35,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    border: Border.all(color: Colors.white, width: 0.5),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(
                        angle: 0.8,
                        child: Container(
                          width: 18,
                          height: 18,
                          color: Colors.yellow,
                        ),
                      ),
                      const Icon(Icons.circle, color: Colors.blue, size: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey[600],
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
