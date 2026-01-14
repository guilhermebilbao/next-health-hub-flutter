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

  // Estados
  String? patientName;
  String? patientCns;
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
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      final bool hasConnection = results.any(
        (result) => result != ConnectivityResult.none,
      );

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

    // CARREGAMENTO LOCAL (OFFLINE-FIRST)
    await _loadLocalData();

    isLoading = true;
    loadingProgress = 0.0;
    errorMessage = null;
    notifyListeners();

    final stopWatch = Stopwatch()..start();
    debugPrint("DashboardViewModel: Iniciando carregamento do dashboard...");

    try {
      // Verifica conectividade antes de tentar
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        isOffline = true;
        isLoading = false;
        notifyListeners();
        return;
      }

      debugPrint("DashboardViewModel: Buscando ID do paciente...");
      final id = await _repository.getPatientId();
      print(id);

      loadingProgress = 0.1;
      notifyListeners();

      int completedTasks = 0;
      const int totalTasks = 4;

      Future<T> _logTask<T>(String name, Future<T> task) async {
        final start = stopWatch.elapsedMilliseconds;
        try {
          final result = await task.timeout(const Duration(seconds: 60));
          completedTasks++;
          loadingProgress = 0.1 + (completedTasks / totalTasks) * 0.9;
          notifyListeners();
          return result;
        } catch (e) {
          rethrow;
        }
      }

      final results = await Future.wait([
        _logTask("getPatientName", _repository.getPatientName()),
        _logTask("getPatientCns", _repository.getPatientCns()),
        _logTask("getPatientExams", _examService.getPatientExams(id)),
        _logTask(
          "getPatientRecordHistory",
          _historyService.getPatientRecordHistory(id),
        ),
      ]);

      patientName = results[0] as String;
      patientCns = results[1] as String?;
      examResponse = results[2] as PatientExamResponse;
      historyResponse = results[3] as PatientHistoryResponse;

      isOffline = false;

      // PERSISTÊNCIA LOCAL (SALVAR PARA PRÓXIMA VEZ)
      await _saveDataLocally();

      // Agendamento notificação aniversário se houver birthDate
      _scheduleBirthdayIfNeeded();
    } catch (e) {
      debugPrint("DashboardViewModel ERROR: $e");

      if (e is SocketException ||
          e.toString().contains("SocketException") ||
          e.toString().contains("Network is unreachable")) {
        isOffline = true;
      }

      if (patientName == null) {
        errorMessage = "Sem conexão e sem dados salvos.";
      }
    } finally {
      stopWatch.stop();
      isLoading = false;
      loadingProgress = 1.0;
      notifyListeners();
    }
  }

  // MÉTODO PARA CARREGAR DO CACHE
  Future<void> _loadLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final cachedName = prefs.getString(_keyPatientName);
      final cachedCns = prefs.getString(_keyPatientCns);
      final cachedExamsJson = prefs.getString(_keyExamData);
      final cachedHistoryJson = prefs.getString(_keyHistoryData);

      if (cachedName != null) patientName = cachedName;
      if (cachedCns != null) patientCns = cachedCns;

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
        debugPrint("DashboardViewModel: Dados locais carregados com sucesso.");
        notifyListeners();
      }
    } catch (e) {
      debugPrint("DashboardViewModel: Erro ao carregar cache local: $e");
    }
  }

  // MÉTODO PARA SALVAR NO CACHE
  Future<void> _saveDataLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (patientName != null)
        await prefs.setString(_keyPatientName, patientName!);
      if (patientCns != null)
        await prefs.setString(_keyPatientCns, patientCns!);

      if (examResponse != null) {
        await prefs.setString(_keyExamData, jsonEncode(examResponse!.toJson()));
      }

      if (historyResponse != null) {
        await prefs.setString(
          _keyHistoryData,
          jsonEncode(historyResponse!.toJson()),
        );
      }
    } catch (e) {
      debugPrint("DashboardViewModel: Erro ao salvar cache local: $e");
    }
  }

  // Limpar cache no logout
  Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyExamData);
    await prefs.remove(_keyHistoryData);
    await prefs.remove(_keyPatientName);
    await prefs.remove(_keyPatientCns);
    clearData();
  }

  Future<void> _scheduleBirthdayIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final birthDateStr = prefs.getString('patientBirthDate');
      final name = patientName ?? prefs.getString('patientName') ?? "Paciente";

      if (birthDateStr != null && birthDateStr.isNotEmpty) {
        final birthDate = DateTime.parse(birthDateStr);
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
