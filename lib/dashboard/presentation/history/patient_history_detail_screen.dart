import 'package:flutter/material.dart';
import '../../../components/app_bar.dart';
import '../../../components/app_drawer.dart';
import '../../../shared/app_formatters.dart';
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

  @override
  Widget build(BuildContext context) {
    String dateDisplay = widget.record.dataAtendimento;
    try {
      final date = DateTime.parse(widget.record.dataAtendimento);
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      dateDisplay = "$day/$month/${date.year}, $hour:$minute";
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
        onLogout: () => AppUtils.logout(context),
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
                      if (widget.record.anamnese.trim().isNotEmpty) ...[
                        _buildSectionTitle('Anamnese / Evoluções'),
                        ...AppFormatters.parseAnamnese(widget.record.anamnese).map((evolution) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (evolution.date.isNotEmpty) ...[
                                  Row(
                                    children: [
                                      const Icon(Icons.history_edu, size: 16, color: Color.fromRGBO(27, 106, 123, 1)),
                                      const SizedBox(width: 8),
                                      Text(
                                        evolution.date,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                ],
                                Text(
                                  evolution.content,
                                  style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const Divider(height: 32),
                      ],
                      if (widget.record.exameFisico.trim().isNotEmpty) ...[
                        _buildSectionTitle('Exame Físico'),
                        Text(widget.record.exameFisico, style: const TextStyle(fontSize: 15, height: 1.4)),
                        const Divider(height: 32),
                      ],
                      if (widget.record.conduta != null && widget.record.conduta!.trim().isNotEmpty) ...[
                        _buildSectionTitle('Conduta'),
                        Text(widget.record.conduta!, style: const TextStyle(fontSize: 15, height: 1.4)),
                        const Divider(height: 32),
                      ],
                      if (filteredProcedures.isNotEmpty) ...[
                        _buildSectionTitle('Procedimentos'),
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
                      if (filteredMedicine.isNotEmpty) ...[
                        _buildSectionTitle('Medicamentos Prescritos'),
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
                      if (filteredExams.isNotEmpty) ...[
                        _buildSectionTitle('Solicitações de Exames'),
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
