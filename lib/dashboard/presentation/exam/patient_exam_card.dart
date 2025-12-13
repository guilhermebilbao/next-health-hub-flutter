import 'package:flutter/material.dart';
import '../../models/exam/patient_exam_response.dart';
import 'patient_exam_list_screen.dart';

class PatientExamCard extends StatelessWidget {
  final Future<PatientExamResponse> examsFuture;

  const PatientExamCard({super.key, required this.examsFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PatientExamResponse>(
      future: examsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Erro ao carregar exames: ${snapshot.error}'),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final count = snapshot.data!.data.length;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientExamListScreen(examResponse: snapshot.data!, exams: snapshot.data!.data,),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.biotech, color: Colors.purple, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resultados de Exames',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(27, 106, 123, 1),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$count exames disponíveis',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
