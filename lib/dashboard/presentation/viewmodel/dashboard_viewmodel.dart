import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../services/notification_service.dart';
import '../../data/dashboard_repository.dart';
import '../../data/patient_exam_service.dart';
import '../../data/patient_history_service.dart';
import '../../models/exam/patient_exam_response.dart';
import '../../models/exam/patient_exam.dart';
import '../../models/history/patient_history_response.dart';

class DashboardViewModel extends ChangeNotifier {
  final _repository = DashboardRepository();
  final _examService = PatientExamService();
  final _historyService = PatientHistoryService();
  final _notificationService = NotificationService();

  static const _keyExamData = 'cached_exams';
  static const _keyHistoryData = 'cached_history';
  static const _keyPatientName = 'cached_patient_name';
  static const _keyPatientCns = 'cached_patient_cns';
  static const _keyPatientBirthDate = 'cached_birth_date';

  // Estados
  String? patientName;
  String? patientCns;
  String? patientBirthDate;
  PatientExamResponse? examResponse;
  PatientHistoryResponse? historyResponse;
  bool isLoading = false;
  double loadingProgress = 0.0;
  String? errorMessage;
  bool isOffline = false;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  DashboardViewModel() {
    _initConnectivity();
  }

  void _initConnectivity() {
    debugPrint("DashboardViewModel: Inicializando monitoramento de conectividade...");
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      final bool hasConnection = results.any(
        (result) => result != ConnectivityResult.none,
      );

      debugPrint("DashboardViewModel: Conectividade alterada - Online: $hasConnection");

      if (isOffline && hasConnection) {
        isOffline = false;
        notifyListeners();
        initDashboard(); // Tenta atualizar quando a internet volta
      } else if (!hasConnection) {
        isOffline = true;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  // Inicialização global (carrega tudo de uma vez)
  Future<void> initDashboard() async {
    if (isLoading) return;

    debugPrint("DashboardViewModel: Inciando processo de inicialização de dados...");

    // CARREGAMENTO LOCAL (OFFLINE-FIRST)
    await _loadLocalData();

    isLoading = true;
    loadingProgress = 0.0;
    errorMessage = null;
    notifyListeners();

    final stopWatch = Stopwatch()..start();

    try {
      // Verifica conectividade antes de tentar
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        debugPrint("DashboardViewModel: Sem conexão de rede disponível. Mantendo cache.");
        isOffline = true;
        isLoading = false;
        notifyListeners();
        return;
      }

      debugPrint("DashboardViewModel: Buscando ID do paciente para sincronização remota...");
      final id = await _repository.getPatientId();

      loadingProgress = 0.1;
      notifyListeners();

      int completedTasks = 0;
      const int totalTasks = 5;

      Future<T> logTask<T>(String name, Future<T> task) async {
        debugPrint("DashboardViewModel: Iniciando tarefa: $name");
        try {
          final result = await task.timeout(const Duration(seconds: 30));
          completedTasks++;
          loadingProgress = 0.1 + (completedTasks / totalTasks) * 0.9;
          debugPrint("DashboardViewModel: Tarefa finalizada com sucesso: $name");
          notifyListeners();
          return result;
        } catch (e) {
          debugPrint("DashboardViewModel: Erro na tarefa $name: $e");
          rethrow;
        }
      }

      final results = await Future.wait([
        logTask("getPatientName", _repository.getPatientName()),
        logTask("getPatientCns", _repository.getPatientCns()),
        logTask("getPatientBirthDate", _repository.getPatientBirthDate()),
        logTask("getPatientExams", _examService.getPatientExams(id)),
        logTask(
          "getPatientRecordHistory",
          _historyService.getPatientRecordHistory(id),
        ),
      ]);

      patientName = results[0] as String;
      patientCns = results[1] as String?;
      patientBirthDate = results[2] as String?;
      examResponse = results[3] as PatientExamResponse;
      historyResponse = results[4] as PatientHistoryResponse;

      isOffline = false;

      debugPrint("DashboardViewModel: Sincronização remota concluída. Salvando dados localmente.");
      await _saveDataLocally();

      _scheduleBirthdayIfNeeded();
    } catch (e) {
      debugPrint("DashboardViewModel: Falha na inicialização remota: $e");

      if (e is SocketException ||
          e.toString().contains("SocketException") ||
          e.toString().contains("Network is unreachable") ||
          e is TimeoutException) {
        isOffline = true;
        debugPrint("DashboardViewModel: Dispositivo parece estar offline ou servidor inacessível.");
      }

      if (patientName == null) {
        errorMessage = "Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente.";
      }
    } finally {
      stopWatch.stop();
      isLoading = false;
      loadingProgress = 1.0;
      notifyListeners();
      debugPrint("DashboardViewModel: Processo de inicialização finalizado em ${stopWatch.elapsedMilliseconds}ms");
    }
  }

  // MÉTODO PARA CARREGAR DO CACHE
  Future<void> _loadLocalData() async {
    debugPrint("DashboardViewModel: Carregando dados do armazenamento local...");
    try {
      final prefs = await SharedPreferences.getInstance();

      final cachedName = prefs.getString(_keyPatientName);
      final cachedCns = prefs.getString(_keyPatientCns);
      final cachedBirthDate = prefs.getString(_keyPatientBirthDate);
      final cachedExamsJson = prefs.getString(_keyExamData);
      final cachedHistoryJson = prefs.getString(_keyHistoryData);

      if (cachedName != null) patientName = cachedName;
      if (cachedCns != null) patientCns = cachedCns;
      if (cachedBirthDate != null) patientBirthDate = cachedBirthDate;

      if (cachedExamsJson != null) {
        examResponse = PatientExamResponse.fromJson(
          jsonDecode(cachedExamsJson),
        );
      }

      if (cachedHistoryJson != null) {
        historyResponse = PatientHistoryResponse.fromJson(
          jsonDecode(cachedHistoryJson),
        );
      }

      if (patientName != null) {
        debugPrint("DashboardViewModel: Cache local restaurado com sucesso para o paciente: $patientName");
        notifyListeners();
      } else {
        debugPrint("DashboardViewModel: Nenhum dado em cache encontrado.");
      }
    } catch (e) {
      debugPrint("DashboardViewModel: Erro ao carregar cache local: $e");
    }
  }

  // MÉTODO PARA SALVAR NO CACHE
  Future<void> _saveDataLocally() async {
    debugPrint("DashboardViewModel: Persistindo dados no armazenamento local...");
    try {
      final prefs = await SharedPreferences.getInstance();

      if (patientName != null) {
        await prefs.setString(_keyPatientName, patientName!);
      }
      if (patientCns != null) {
        await prefs.setString(_keyPatientCns, patientCns!);
      }
      if (patientBirthDate != null) {
        await prefs.setString(_keyPatientBirthDate, patientBirthDate!);
      }

      if (examResponse != null) {
        await prefs.setString(_keyExamData, jsonEncode(examResponse!.toJson()));
      }

      if (historyResponse != null) {
        await prefs.setString(
          _keyHistoryData,
          jsonEncode(historyResponse!.toJson()),
        );
      }
      debugPrint("DashboardViewModel: Dados persistidos com sucesso.");
    } catch (e) {
      debugPrint("DashboardViewModel: Erro ao salvar cache local: $e");
    }
  }

  // Limpar cache no logout
  Future<void> clearAllCache() async {
    debugPrint("DashboardViewModel: Limpando todos os dados em cache...");
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyExamData);
    await prefs.remove(_keyHistoryData);
    await prefs.remove(_keyPatientName);
    await prefs.remove(_keyPatientCns);
    await prefs.remove(_keyPatientBirthDate);
    clearData();
    debugPrint("DashboardViewModel: Cache limpo.");
  }

  Future<void> _scheduleBirthdayIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final birthDateStr = prefs.getString('patientBirthDate');
      final name = patientName ?? prefs.getString('patientName') ?? "Paciente";

      if (birthDateStr != null && birthDateStr.isNotEmpty) {
        final birthDate = DateTime.parse(birthDateStr);
        debugPrint("DashboardViewModel: Agendando notificação de aniversário para $name em $birthDateStr");
        await _notificationService.scheduleBirthdayNotification(
          birthDate,
          name,
        );
      }
    } catch (e) {
      debugPrint(
        "DashboardViewModel: Erro ao agendar notificação de aniversário: $e",
      );
    }
  }

  void clearData() {
    patientName = null;
    patientCns = null;
    patientBirthDate = null;
    examResponse = null;
    historyResponse = null;
    errorMessage = null;
    isLoading = false;
    loadingProgress = 0.0;
    isOffline = false;
    notifyListeners();
  }

  List<PatientExam>? get exams => examResponse?.data;
  PatientHistoryResponse? get history => historyResponse;
}
