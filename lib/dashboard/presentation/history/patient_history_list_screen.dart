import 'package:flutter/material.dart';
import '../../../components/app_bar.dart';
import '../../../components/app_drawer.dart';
import '../../../auth/data/auth_service.dart';
import '../../../app_routes.dart';
import '../../data/dashboard_repository.dart';
import '../../models/patient_history_models.dart';
import 'patient_history_detail_screen.dart';

class PatientHistoryScreen extends StatefulWidget {
  final PatientHistoryResponse historyResponse;

  const PatientHistoryScreen({super.key, required this.historyResponse});

  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
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
        selectedIndex: 1,
        onItemSelected: (index) {
           Navigator.pop(context); // Fecha drawer
           if (index == 0) {
             Navigator.pop(context); // Volta para dashboard
           }
        },
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
              'Histórico de Prontuário',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(27, 106, 123, 1),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.historyResponse.data.length,
              itemBuilder: (context, index) {
                final record = widget.historyResponse.data[index];
                String dateDisplay = record.dataAtendimento;
                try {
                  final date = DateTime.parse(record.dataAtendimento);
                  dateDisplay = "${date.day}/${date.month}/${date.year} às ${date.hour}:${date.minute}";
                } catch (_) {}

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientRecordDetailScreen(record: record),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                           const CircleAvatar(
                            backgroundColor: Color(0xFFE0F2F1),
                            child: Icon(Icons.medical_services, color: Color(0xFF00695C)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                   dateDisplay,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text('MRN: ${record.medicalRecordNumber}',
                                  style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
