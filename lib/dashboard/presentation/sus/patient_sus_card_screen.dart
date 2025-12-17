import 'package:flutter/material.dart';

import '../../../components/app_bar.dart';
import '../../../components/app_drawer.dart';
import '../../../auth/data/auth_service.dart';
import '../../../app_routes.dart';
import '../../data/dashboard_repository.dart';
import '../../data/patient_exam_service.dart';
import '../../data/patient_history_service.dart';
import '../exam/patient_exam_list_screen.dart';
import '../history/patient_history_list_screen.dart';

class PatientSusCardScreen extends StatefulWidget {
  const PatientSusCardScreen({super.key});

  @override
  State<PatientSusCardScreen> createState() => _PatientSusCardScreenState();
}

class _PatientSusCardScreenState extends State<PatientSusCardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<String> _patientNameFuture;

  @override
  void initState() {
    super.initState();
    _patientNameFuture = DashboardRepository().getPatientName();
  }

  Future<void> _logout(BuildContext context) async {
    final authService = AuthService();
    await authService.logout();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.onboarding,
        (route) => false,
      );
    }
  }

  void _onItemSelected(int index) async {
    if (index == 0) { // Dashboard
      Navigator.pop(context);
    } else if (index == 1) { // Meus Exames
      try {
        final id = await DashboardRepository().getPatientId();
        final exams = await PatientExamService().getPatientExams(id);
        if (mounted) {
          Navigator.pushReplacement(
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
    } else if (index == 2) { // Histórico
      try {
        final id = await DashboardRepository().getPatientId();
        final history = await PatientHistoryService().getPatientRecordHistory(id);
        if (mounted) {
          Navigator.pushReplacement(
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: NextAppBar(
        automaticallyImplyLeading: false,
        onMenuPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
      ),
      endDrawer: NextAppDrawer(
        onLogout: () => _logout(context),
        patientNameFuture: _patientNameFuture,
        selectedIndex: 3, // Carteirinha
        onItemSelected: _onItemSelected,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(27, 106, 123, 1)),
              label: const Text(
                'Voltar ao Dashboard',
                style: TextStyle(
                  color: Color.fromRGBO(27, 106, 123, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Carteirinha Saude One',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(27, 106, 123, 1),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/next_healt_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
