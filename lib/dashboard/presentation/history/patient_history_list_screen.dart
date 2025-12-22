import 'package:flutter/material.dart';
import 'package:next_health_hub/shared/app_formatters.dart';
import 'package:next_health_hub/shared/app_utils.dart';
import 'package:provider/provider.dart';
import '../../../components/app_bar.dart';
import '../../../components/app_drawer.dart';
import '../../../auth/data/auth_service.dart';
import '../../../app_routes.dart';
import '../../models/history/patient_history_models.dart';
import 'patient_history_detail_screen.dart';
import '../exam/patient_exam_list_screen.dart';
import '../sus/patient_sus_card_screen.dart';
import '../viewmodel/dashboard_viewmodel.dart';

class PatientHistoryScreen extends StatefulWidget {
  final PatientHistoryResponse historyResponse;

  const PatientHistoryScreen({super.key, required this.historyResponse});

  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color primaryColor = Color.fromRGBO(27, 106, 123, 1);

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

  void _onItemSelected(int index) {
    final viewModel = context.read<DashboardViewModel>();

    if (index == 0) {
      Navigator.pop(context);
    } else if (index == 1) {
      if (viewModel.exams != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PatientExamListScreen(
              exams: viewModel.exams!,
            ),
          ),
        );
      }
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PatientSusCardScreen(),
        ),
      );
    }
  }

  Widget _buildSummaryItem(IconData icon, String label, int count) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF00695C)),
          const SizedBox(width: 4),
          Text(
            count > 1 ? '$label ($count)' : label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00695C),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();
    final historyData = viewModel.historyResponse?.data ?? widget.historyResponse.data;

    return Scaffold(
      key: _scaffoldKey,
      appBar: NextAppBar(
        automaticallyImplyLeading: false,
        onMenuPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
      ),
      endDrawer: NextAppDrawer(
        onLogout: () => _logout(context),
        patientNameFuture: Future.value(viewModel.patientName ?? ""),
        selectedIndex: 2,
        onItemSelected: _onItemSelected,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: primaryColor),
              label: const Text(
                'Voltar ao Dashboard',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Histórico de Prontuário',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => viewModel.initDashboard(),
              color: primaryColor,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: historyData.length,
                itemBuilder: (context, index) {
                  final record = historyData[index];
                  final dateDisplay = AppFormatters.formateDate(record.dataAtendimento);

                  final procedureCount = record.procedimentos
                      .where((p) => AppUtils.areCodesEqual(p.codigoAtendimento, record.codigoAtendimento))
                      .length;
                  final medicationCount = record.medicamentos
                      .where((m) => AppUtils.areCodesEqual(m.codigoAtendimento, record.codigoAtendimento))
                      .length;
                  final examCount = record.solicitacoesExames
                      .where((e) => AppUtils.areCodesEqual(e.codigoAtendimento, record.codigoAtendimento))
                      .length;

                  final hasDetails = record.anamnese.trim().isNotEmpty ||
                      record.exameFisico.trim().isNotEmpty ||
                      (record.conduta?.trim().isNotEmpty ?? false) ||
                      procedureCount > 0 ||
                      medicationCount > 0 ||
                      examCount > 0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: () {
                        if (hasDetails) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PatientRecordDetailScreen(record: record),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sem mais detalhes sobre este atendimento'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Color(0xFF00695C)),
                                const SizedBox(width: 16),
                                Text(
                                  dateDisplay,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const Spacer(),
                                if (hasDetails) const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text('#${record.codigoAtendimento}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text('MRN: ${record.medicalRecordNumber}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              hasDetails
                                  ? 'Clique para ver os detalhes completos deste atendimento'
                                  : 'Sem mais detalhes sobre este atendimento',
                              style: const TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: Colors.black54,
                              ),),
                            if (hasDetails) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                children: [
                                  _buildSummaryItem(Icons.description, 'Anamnese', record.anamnese.trim().isNotEmpty ? 1 : 0),
                                  _buildSummaryItem(Icons.person_search, 'Exame Físico', record.exameFisico.trim().isNotEmpty ? 1 : 0),
                                  _buildSummaryItem(Icons.assignment, 'Conduta', (record.conduta?.trim().isNotEmpty ?? false) ? 1 : 0),
                                  _buildSummaryItem(Icons.medical_services, 'Procedimentos', procedureCount),
                                  _buildSummaryItem(Icons.medication_outlined, 'Medicamentos', medicationCount),
                                  _buildSummaryItem(Icons.science, 'Exames', examCount),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}