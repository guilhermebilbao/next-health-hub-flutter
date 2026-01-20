import 'package:flutter/material.dart';
import 'package:next_health_hub/dashboard/presentation/sus/patient_sus_card.dart';
import 'package:provider/provider.dart';

import '../../../components/app_bar.dart';
import '../../../components/app_drawer.dart';
import '../../../auth/data/auth_service.dart';
import '../../../app_routes.dart';
import '../exam/patient_exam_list_screen.dart';
import '../history/patient_history_list_screen.dart';
import '../viewmodel/dashboard_viewmodel.dart';

class PatientSusCardScreen extends StatefulWidget {
  const PatientSusCardScreen({super.key});

  @override
  State<PatientSusCardScreen> createState() => _PatientSusCardScreenState();
}

class _PatientSusCardScreenState extends State<PatientSusCardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _logout(BuildContext context) async {
    final authService = AuthService();
    await authService.logout();
    if (context.mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.onboarding, (route) => false);
    }
  }

  void _onItemSelected(int index) {
    final viewModel = context.read<DashboardViewModel>();

    if (index == 0) {
      Navigator.pop(context);
    } else if (index == 1) {
      if (viewModel.exams != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PatientExamListScreen(exams: viewModel.exams!),
          ),
        );
      }
    } else if (index == 2) {
      if (viewModel.history != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PatientHistoryScreen(historyResponse: viewModel.history!),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: NextAppBar(
        automaticallyImplyLeading: false,
        onMenuPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
      ),
      endDrawer: NextAppDrawer(
        onLogout: () => _logout(context),
        patientNameFuture: Future.value(viewModel.patientName ?? ""),
        selectedIndex: 3,
        onItemSelected: _onItemSelected,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: Color.fromRGBO(27, 106, 123, 1),
              ),
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
              'Carteirinha Saúde One',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(27, 106, 123, 1),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: PatientSusCard(
                nomeCompleto: viewModel.patientName?.toUpperCase() ?? "PACIENTE",
                numeroCartao: viewModel.patientCns ?? "--- --- --- ---",
                dataNascimento: viewModel.patientBirthDate ?? "--/--/----",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
