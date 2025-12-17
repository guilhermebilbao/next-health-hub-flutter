import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../../components/app_bar.dart';
import '../../../components/app_drawer.dart';
import '../../../auth/data/auth_service.dart';
import '../../../app_routes.dart';
import '../../data/dashboard_repository.dart';
import '../../models/exam/patient_exam.dart';
import '../../models/exam/patient_exam_response.dart';
import '../../models/exam/exam_attachment_file_response.dart';
import '../../data/patient_exam_attachment_service.dart';
import '../../data/patient_history_service.dart';
import '../history/patient_history_list_screen.dart';
import '../sus/patient_sus_card_screen.dart';

class PatientExamListScreen extends StatefulWidget {
  final List<PatientExam> exams;
  final PatientExamResponse examResponse;

  const PatientExamListScreen({super.key, required this.exams, required this.examResponse});

  @override
  State<PatientExamListScreen> createState() => _PatientExamListScreenState();
}

class _PatientExamListScreenState extends State<PatientExamListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PatientExamAttachmentService _attachmentService = PatientExamAttachmentService();
  late Future<String> _patientNameFuture;
  bool _isLoading = false;

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
    // Navigation logic based on index
    if (index == 0) { // Dashboard
      Navigator.pop(context); // Just pop to go back to Dashboard
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
    } else if (index == 3) { // Carteirinha
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PatientSusCardScreen(),
        ),
      );
    }
  }

  Future<void> _downloadAttachment(String attachmentId, String displayFileName) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      
      // Tenta encontrar um arquivo que comece com o attachmentId (independente da extensão)
      final files = directory.listSync();
      File? existingFile;
      for (var file in files) {
        if (file is File && file.path.split('/').last.startsWith(attachmentId)) {
           existingFile = file;
           break;
        }
      }

      if (existingFile != null) {
        // Se já existe, abre o arquivo
        // Ex caminho /data/user/0/com.example.next_healt_hub/app_flutter/ee7aaf38-2e38-4445-5c5e-08de377965a6.pdf

         final result = await OpenFile.open(existingFile.path);
         if (result.type != ResultType.done) {
            throw Exception(result.message);
         }
      } else {
        // Se não existe, faz o download
        final responseMap = await _attachmentService.getExamAttachment(attachmentId);
        final response = ExamAttachmentFileResponse.fromJson(responseMap);

        if (response.statusCode == 200 && response.data != null) {
          final base64String = response.data!.fileBase64;
          final format = response.data!.fileFormat.toLowerCase();
          final bytes = base64Decode(base64String);
          
          final extension = format.startsWith('.') ? format : '.$format';
          // Usando attachmentId como nome do arquivo para garantir unicidade e facilitar a busca
          final fileName = '$attachmentId$extension';
          final filePath = '${directory.path}/$fileName';
          
          final file = File(filePath);
          await file.writeAsBytes(bytes);
          
          if (context.mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Arquivo "$displayFileName" baixado com sucesso!')),
              );
          }

          final result = await OpenFile.open(filePath);
           if (result.type != ResultType.done) {
            throw Exception(result.message);
         }
        } else {
          throw Exception(response.message);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao abrir o arquivo: $e')),
        );
      }
    } finally {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
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
        selectedIndex: 1, // Meus Exames
        onItemSelected: _onItemSelected,
      ),
      body: Stack(
        children: [
          Column(
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
                  'Resultados de Exames',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(27, 106, 123, 1),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: widget.exams.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final exam = widget.exams[index];
                    final hasAttachment = exam.examAttachments != null && exam.examAttachments!.isNotEmpty;
                    String dateDisplay = 'Data indisponível';
                    try {
                      if(exam.examDate.startsWith('0001')) throw Exception();
                      final date = DateTime.parse(exam.examDate);
                      dateDisplay = "${date.day}/${date.month}/${date.year}";
                    } catch (_) {}

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.biotech, color: Color(0xFF6A1B9A), size: 40),
                        title: Text(exam.examName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dateDisplay),
                            if (hasAttachment)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.attachment, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(exam.examAttachments!.first.fileName, style: const TextStyle(fontStyle: FontStyle.italic)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        onTap: hasAttachment
                            ? () => _downloadAttachment(exam.examAttachments!.first.id, exam.examAttachments!.first.fileName)
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
