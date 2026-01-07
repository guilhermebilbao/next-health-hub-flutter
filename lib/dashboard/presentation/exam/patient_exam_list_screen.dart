import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:next_health_hub/shared/app_formatters.dart';
import 'package:next_health_hub/shared/app_utils.dart';
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../../components/app_bar.dart';
import '../../../components/app_drawer.dart';
import '../../../auth/data/auth_service.dart';
import '../../../app_routes.dart';
import '../../models/exam/patient_exam.dart';
import '../../models/exam/exam_attachment_file_response.dart';
import '../../data/patient_exam_attachment_service.dart';
import '../history/patient_history_list_screen.dart';
import '../sus/patient_sus_card_screen.dart';
import '../viewmodel/dashboard_viewmodel.dart';

class PatientExamListScreen extends StatefulWidget {
  final List<PatientExam> exams;

  const PatientExamListScreen({super.key, required this.exams});

  @override
  State<PatientExamListScreen> createState() => _PatientExamListScreenState();
}

class _PatientExamListScreenState extends State<PatientExamListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PatientExamAttachmentService _attachmentService = PatientExamAttachmentService();
  bool _isLoading = false;

  static const Color primaryColor = Color.fromRGBO(27, 106, 123, 1);

  void _onItemSelected(int index) {
    final viewModel = context.read<DashboardViewModel>();

    if (index == 0) {
      Navigator.pop(context);
    } else if (index == 2) {
      if (viewModel.historyResponse != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PatientHistoryScreen(historyResponse: viewModel.historyResponse!),
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

  Future<void> _downloadAttachment(String attachmentId, String displayFileName) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      File? existingFile;
      await for (var file in directory.list()) {
        if (file is File && file.path.split('/').last.startsWith(attachmentId)) {
          existingFile = file;
          break;
        }
      }

      if (existingFile != null) {
        final result = await OpenFile.open(existingFile.path);
        if (result.type != ResultType.done) {
          throw Exception(result.message);
        }
      } else {
        final responseMap = await _attachmentService.getExamAttachment(attachmentId);
        final response = ExamAttachmentFileResponse.fromJson(responseMap);

        if (response.statusCode == 200 && response.data != null) {
          final base64String = response.data!.fileBase64;
          final format = response.data!.fileFormat.toLowerCase();
          final bytes = base64Decode(base64String);

          final extension = format.startsWith('.') ? format : '.$format';
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
    final viewModel = context.watch<DashboardViewModel>();
    // Prioriza os dados atualizados do ViewModel
    final examList = viewModel.exams ?? widget.exams;

    return Scaffold(
      key: _scaffoldKey,
      appBar: NextAppBar(
        automaticallyImplyLeading: false,
        onMenuPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
      ),
      endDrawer: NextAppDrawer(
        onLogout: () => AppUtils.logout(context),
        patientNameFuture: Future.value(viewModel.patientName ?? ""),
        selectedIndex: 1,
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
                  icon: const Icon(Icons.arrow_back, color: primaryColor),
                  label: const Text(
                    'Voltar ao Dashboard',
                    style: TextStyle(
                      color: primaryColor,
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
                    color: primaryColor,
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => viewModel.initDashboard(),
                  color: primaryColor,
                  child: examList.isEmpty
                      ? ListView( // Usamos ListView para que o RefreshIndicator continue funcionando
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 100),
                      Center(
                        child: Text(
                          "Você ainda não tem exames para visualizar.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ) : ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: examList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final exam = examList[index];
                      final hasAttachment = exam.examAttachments != null && exam.examAttachments!.isNotEmpty;
                      final dateDisplay = AppFormatters.formateDate(exam.examDate);

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
                              if (hasAttachment) ...[
                                const SizedBox(height: 8),
                                ...exam.examAttachments!.map((attachment) {
                                  return InkWell(
                                    onTap: () => _downloadAttachment(attachment.id, attachment.fileName),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.attachment, size: 16, color: primaryColor),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              attachment.fileName,
                                              style: const TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: primaryColor,
                                                decoration: TextDecoration.underline,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
