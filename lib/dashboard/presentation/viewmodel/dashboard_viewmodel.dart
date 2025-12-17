import 'package:flutter/material.dart';
import '../../data/dashboard_repository.dart';
import '../../data/patient_exam_service.dart';
import '../../data/patient_history_service.dart';
import '../../models/exam/patient_exam_response.dart';
import '../../models/exam/patient_exam.dart';
import '../../models/history/patient_history_models.dart';

class DashboardViewModel extends ChangeNotifier {
  final _repository = DashboardRepository();
  final _examService = PatientExamService();
  final _historyService = PatientHistoryService();

  // Estados
  String? patientName;
  PatientExamResponse? examResponse;
  PatientHistoryResponse? historyResponse;
  bool isLoading = false;
  String? errorMessage;

  // Inicialização global (carrega tudo de uma vez)
  Future<void> initDashboard() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    // Limpa dados anteriores antes de carregar os novos
    patientName = null;
    examResponse = null;
    historyResponse = null;
    notifyListeners();

    try {
      final id = await _repository.getPatientId();

      // Executa as chamadas em paralelo para ser mais rápido
      final results = await Future.wait([
        _repository.getPatientName(),
        _examService.getPatientExams(id),
        _historyService.getPatientRecordHistory(id),
      ]);

      patientName = results[0] as String;
      examResponse = results[1] as PatientExamResponse;
      historyResponse = results[2] as PatientHistoryResponse;
    } catch (e) {
      errorMessage = "Erro ao carregar dados do dashboard";
      debugPrint("DashboardViewModel Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    patientName = null;
    examResponse = null;
    historyResponse = null;
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }

  // Atalhos para facilitar o acesso nas telas
  List<PatientExam>? get exams => examResponse?.data;
  PatientHistoryResponse? get history => historyResponse;
}
