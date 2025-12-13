import 'package:flutter/material.dart';
import '../../../components/app_bar.dart';
import '../../../components/app_drawer.dart';
import '../../../auth/data/auth_service.dart';
import '../../../app_routes.dart';
import '../../data/dashboard_repository.dart';
import '../../models/history/patient_history_models.dart';
import '../../../shared/app_utils.dart';

class PatientRecordDetailScreen extends StatefulWidget {
  final PatientRecord record;

  const PatientRecordDetailScreen({super.key, required this.record});

  @override
  State<PatientRecordDetailScreen> createState() => _PatientRecordDetailScreenState();
}

class _PatientRecordDetailScreenState extends State<PatientRecordDetailScreen> {
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
    String dateDisplay = widget.record.dataAtendimento;
    try {
      final date = DateTime.parse(widget.record.dataAtendimento);
      dateDisplay = "${date.day}/${date.month}/${date.year}, ${date.hour}:${date.minute}";
    } catch (_) {}

    final filteredProcedures = widget.record.procedimentos
        .where((p) => AppUtils.areCodesEqual(p.codigoAtendimento, widget.record.codigoAtendimento))
        .toList();
        
    final filteredExams = widget.record.solicitacoesExames
        .where((e) => AppUtils.areCodesEqual(e.codigoAtendimento, widget.record.codigoAtendimento))
        .toList();

    final filteredMedicine = widget.record.medicamentos
        .where((m) => AppUtils.areCodesEqual(m.codigoAtendimento, widget.record.codigoAtendimento))
        .toList();

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
        onItemSelected: (int value) {
          Navigator.pop(context);
          if (value == 0) Navigator.pop(context);
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(27, 106, 123, 1)),
                label: const Text(
                  'Voltar ao Histórico',
                  style: TextStyle(
                    color: Color.fromRGBO(27, 106, 123, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detalhes do Atendimento',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(27, 106, 123, 1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFF00695C), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        dateDisplay,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Código: #${widget.record.codigoAtendimento}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Prontuário: ${widget.record.medicalRecordNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.record.anamnese.isNotEmpty) ...[
                        _buildSectionTitle('Anamnese'),
                        Text(widget.record.anamnese, style: const TextStyle(fontSize: 15, height: 1.4)),
                        const Divider(height: 32),
                      ],
                      if (widget.record.exameFisico.isNotEmpty) ...[
                        _buildSectionTitle('Exame Físico'),
                        Text(widget.record.exameFisico, style: const TextStyle(fontSize: 15, height: 1.4)),
                        const Divider(height: 32),
                      ],
                      if (widget.record.conduta != null && widget.record.conduta!.trim().isNotEmpty) ...[
                        _buildSectionTitle('Conduta'),
                        Text(widget.record.conduta!, style: const TextStyle(fontSize: 15, height: 1.4)),
                        const Divider(height: 32),
                      ],
                      if (widget.record.procedimentos.isNotEmpty) ...[
                        _buildSectionTitle('Procedimentos'),
                        if (filteredProcedures.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'Sem procedimentos',
                              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black54),
                            ),
                          )
                        else
                          ...filteredProcedures.map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: Text(
                                    p.procedimento,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        const Divider(height: 32),
                      ],
                      if (widget.record.medicamentos.isNotEmpty) ...[
                        _buildSectionTitle('Medicamentos Prescritos'),
                        if (filteredMedicine.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'Não foram prescritos medicamentos.',
                              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black54),
                            ),
                          )
                        else
                          ...filteredMedicine.map((m) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      text: m.medicamento,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                      children: [
                                        TextSpan(
                                          text: ' (Qtd: ${m.quantidade})',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                        ),
                                        TextSpan(
                                          text: ' - ${m.posologia}',
                                          style: const TextStyle(fontWeight: FontWeight.normal),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        const Divider(height: 32),
                      ],
                      if (widget.record.solicitacoesExames.isNotEmpty) ...[
                        _buildSectionTitle('Solicitações de Exames'),
                        if (filteredExams.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'Não foram solicitados exames.',
                              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black54),
                            ),
                          )
                        else
                          ...filteredExams.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                                Expanded(child: Text(e.exame)),
                              ],
                            ),
                          )),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Color.fromRGBO(27, 106, 123, 1),
        ),
      ),
    );
  }
}
