import 'dart:async';
import 'package:flutter/material.dart';
import 'package:next_healt_hub/dashboard/models/exam/patient_exam_response.dart';
import 'package:next_healt_hub/dashboard/presentation/sac/sac_card.dart';
import 'package:next_healt_hub/dashboard/presentation/sus/sus_card.dart';
import '../../components/app_bar.dart';
import '../../components/app_drawer.dart';
import '../../auth/data/auth_service.dart';
import '../../app_routes.dart';
import '../data/dashboard_repository.dart';
import '../data/patient_exam_service.dart';
import '../data/patient_history_service.dart';
import '../models/history/patient_history_models.dart';
import 'exam/patient_exam_card.dart';
import 'exam/patient_exam_list_screen.dart';
import 'history/patient_history_list_screen.dart';
import 'patient_info_card.dart';
import 'history/patient_history_card.dart';
import 'sus/patient_sus_card_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  Timer? _timer;
  late Future<String> _patientNameFuture;
  late Future<PatientHistoryResponse> _historyFuture;
  late Future<PatientExamResponse> _examFuture;
  late AnimationController _pulseController;
  late PatientHistoryService _patientHistoryService;
  late PatientExamService _patientExamService;
  String _patienteId = '';

  @override
  void initState() {
    super.initState();
    _patientHistoryService = PatientHistoryService();
    _patientExamService = PatientExamService();

    // Carrega o nome apenas uma vez
    _patientNameFuture = DashboardRepository().getPatientName();

    // CACHE DO FUTURE: Encadeia a busca do ID com a busca do histórico.
    _historyFuture = DashboardRepository().getPatientId().then((id) {
      _patienteId = id;
      return _patientHistoryService.getPatientRecordHistory(id);
    });

    _examFuture = DashboardRepository().getPatientId().then((id) {
      _patienteId = id;
      return _patientExamService.getPatientExams(id);
    });

    // Controlador da animação de pulso
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // Atualiza o relógio a cada 1 seg.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    final authService = AuthService();
    await authService.logout();
    if (context.mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.onboarding, (route) => false);
    }
  }

  void _onItemSelected(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    
    // Navigation logic based on index
    if (index == 1) { // Meus Exames
      try {
        final exams = await _examFuture;
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientExamListScreen(
                exams: exams.data, 
                examResponse: exams,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Não foi possível carregar os exames.")),
          );
        }
      }
    } else if (index == 2) { // Histórico de Prontuário
      try {
        final history = await _historyFuture;
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientHistoryScreen(historyResponse: history),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Não foi possível carregar o histórico.")),
          );
        }
      }
    } else if (index == 3) { // Carteirinha
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PatientSusCardScreen(),
        ),
      );
    } else if (index == 4) { // SAC - Em breve, no action for now or maybe a toast
       // SAC is disabled/coming soon
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = DashboardRepository();

    return Scaffold(
      key: _scaffoldKey,
      appBar: NextAppBar(
        onMenuPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        automaticallyImplyLeading: false,
      ),
      endDrawer: NextAppDrawer(
        onLogout: () => _logout(context),
        patientNameFuture: _patientNameFuture,
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
      ),
      body: Column(
        children: [
          FutureBuilder<String>(
            future: _patientNameFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return PatientInfoCard(
                pulseController: _pulseController,
                repository: repository,
                patientName: snapshot.data,
              );
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Bem-vindo ao ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'NEXT - Saúde One',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromRGBO(27, 106, 123, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                      child: Center(
                        child: Text(
                          'Acesse seus exames e histórico médico de forma rápida e segura',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    PatientExamCard(examsFuture: _examFuture),

                    PatientHistoryCard(historyFuture: _historyFuture),

                    SusCard(),

                    SacCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
