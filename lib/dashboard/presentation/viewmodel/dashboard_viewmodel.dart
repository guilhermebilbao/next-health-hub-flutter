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
  double loadingProgress = 0.0;
  String? errorMessage;

  // Inicialização global (carrega tudo de uma vez)
  Future<void> initDashboard() async {
    if (isLoading) return;

    isLoading = true;
    loadingProgress = 0.0;
    errorMessage = null;
    patientName = null;
    examResponse = null;
    historyResponse = null;
    notifyListeners();

    final stopWatch = Stopwatch()..start();
    debugPrint("DashboardViewModel: Iniciando carregamento do dashboard...");

    try {
      debugPrint("DashboardViewModel: Buscando ID do paciente...");
      final id = await _repository.getPatientId();
      print(id);

      loadingProgress = 0.1;
      notifyListeners();
      debugPrint("DashboardViewModel: ID recuperado: $id em ${stopWatch.elapsedMilliseconds}ms");

      debugPrint("DashboardViewModel: Iniciando chamadas paralelas (Name, Exams, History)...");

      int completedTasks = 0;
      const int totalTasks = 3;

      Future<T> _logTask<T>(String name, Future<T> task) async {
        final start = stopWatch.elapsedMilliseconds;
        debugPrint("DashboardViewModel: [Tarefa: $name] Iniciada");
        try {
          final result = await task.timeout(const Duration(seconds: 60));
          completedTasks++;
          // Começa em 0.1 (ID) e vai até 1.0. As 3 tarefas dividem o restante 0.9.
          loadingProgress = 0.1 + (completedTasks / totalTasks) * 0.9;
          notifyListeners();
          
          final end = stopWatch.elapsedMilliseconds;
          debugPrint("DashboardViewModel: [Tarefa: $name] Finalizada com sucesso em ${end - start}ms");
          return result;
        } catch (e) {
          debugPrint("DashboardViewModel: [Tarefa: $name] FALHOU após ${stopWatch.elapsedMilliseconds - start}ms - Erro: $e");
          rethrow;
        }
      }

      final results = await Future.wait([
        _logTask("getPatientName", _repository.getPatientName()),
        _logTask("getPatientExams", _examService.getPatientExams(id)),
        _logTask("getPatientRecordHistory", _historyService.getPatientRecordHistory(id)),
      ]);

      patientName = results[0] as String;
      examResponse = results[1] as PatientExamResponse;
      historyResponse = results[2] as PatientHistoryResponse;

      debugPrint("DashboardViewModel: Todos os dados carregados com sucesso em ${stopWatch.elapsedMilliseconds}ms");

    } catch (e) {
      errorMessage = "Erro ao carregar dados do dashboard";
      debugPrint("DashboardViewModel ERROR após ${stopWatch.elapsedMilliseconds}ms: $e");

      // Tratamento específico para Timeout
      if (e.toString().contains("TimeoutException")) {
        errorMessage = "O servidor demorou muito para responder. Verifique sua conexão.";
      }
    } finally {
      stopWatch.stop();
      isLoading = false;
      loadingProgress = 1.0;
      notifyListeners();
    }
  }

  void clearData() {
    patientName = null;
    examResponse = null;
    historyResponse = null;
    errorMessage = null;
    isLoading = false;
    loadingProgress = 0.0;
    notifyListeners();
  }

  // Atalhos para facilitar o acesso nas telas
  List<PatientExam>? get exams => examResponse?.data;
  PatientHistoryResponse? get history => historyResponse;
}
