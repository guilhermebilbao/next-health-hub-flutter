import 'package:flutter/material.dart';
import '../../models/patient_history_models.dart';
import 'patient_history_list_screen.dart';

class PatientHistoryCard extends StatelessWidget {
  final Future<PatientHistoryResponse> historyFuture;

  const PatientHistoryCard({
    super.key,
    required this.historyFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PatientHistoryResponse>(
      future: historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Erro ao carregar dados: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          );
        }
        if (snapshot.hasData) {
          final response = snapshot.data!;

          // CARD INTERATIVO PARA ABRIR A NOVA TELA
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientHistoryScreen(historyResponse: response),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.history_edu, size: 32, color: Colors.blue),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Histórico de Prontuário',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${response.data.length} registros disponíveis',
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
