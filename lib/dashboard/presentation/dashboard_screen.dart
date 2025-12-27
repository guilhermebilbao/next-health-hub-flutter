import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:next_health_hub/dashboard/presentation/sac/sac_card.dart';
import 'package:next_health_hub/dashboard/presentation/sus/sus_card.dart';
import '../../components/app_bar.dart';
import '../../components/app_drawer.dart';
import '../../auth/data/auth_service.dart';
import '../../app_routes.dart';
import '../data/dashboard_repository.dart';
import 'exam/patient_exam_card.dart';
import 'exam/patient_exam_list_screen.dart';
import 'history/patient_history_list_screen.dart';
import 'patient_info_card.dart';
import 'history/patient_history_card.dart';
import 'sus/patient_sus_card_screen.dart';
import 'viewmodel/dashboard_viewmodel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    // Carrega os dados do dashboard ao entrar na tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().initDashboard();
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
      // Limpa os dados do ViewModel ao deslogar
      context.read<DashboardViewModel>().clearData();

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.onboarding, (route) => false);
    }
  }

  void _onItemSelected(int index) {
    final viewModel = context.read<DashboardViewModel>();

    if (index == 1) {
      // Meus Exames
      if (viewModel.exams != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PatientExamListScreen(exams: viewModel.exams!),
          ),
        );
      }
    } else if (index == 2) {
      // Histórico de Prontuário
      if (viewModel.history != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PatientHistoryScreen(historyResponse: viewModel.history!),
          ),
        );
      }
    } else if (index == 3) {
      // Carteirinha
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PatientSusCardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = DashboardRepository();
    final viewModel = context.watch<DashboardViewModel>();

    if (viewModel.isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/next_health_logo.png',
                  height: 100,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.medical_services,
                    size: 80,
                    color: Color.fromRGBO(27, 106, 123, 1),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  "Carregando suas informações...",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(27, 106, 123, 1),
                  ),
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: viewModel.loadingProgress,
                    minHeight: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color.fromRGBO(27, 106, 123, 1),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "${(viewModel.loadingProgress * 100).toInt()}%",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(27, 106, 123, 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (viewModel.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  viewModel.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => viewModel.initDashboard(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(27, 106, 123, 1),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Tentar novamente"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: NextAppBar(
        onMenuPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        automaticallyImplyLeading: false,
      ),
      endDrawer: NextAppDrawer(
        onLogout: () => _logout(context),
        patientNameFuture: Future.value(viewModel.patientName ?? ""),
        selectedIndex: 0,
        onItemSelected: _onItemSelected,
      ),
      body: Column(
        children: [
          PatientInfoCard(
            pulseController: _pulseController,
            repository: repository,
            patientName: viewModel.patientName,
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
                          const Text(
                            'Bem-vindo ao ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'NEXT - Saúde One',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(27, 106, 123, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 24.0, right: 24.0),
                      child: Center(
                        child: Text(
                          'Acesse seus exames e histórico médico de forma rápida e segura',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    PatientExamCard(exams: viewModel.exams),

                    PatientHistoryCard(history: viewModel.history),

                    const SusCard(),

                    const SacCard(),
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
