import 'package:flutter/material.dart';
import '../../models/exam/patient_exam.dart';
import '../../models/exam/patient_exam_response.dart';
import 'patient_exam_list_screen.dart';

class PatientExamCard extends StatelessWidget {
  final List<PatientExam>? exams;

  const PatientExamCard({super.key, this.exams});

  @override
  Widget build(BuildContext context) {
    if (exams == null) {
      return const SizedBox.shrink();
    }

    final count = exams!.length;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientExamListScreen(
                exams: exams!,
              ),
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
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
