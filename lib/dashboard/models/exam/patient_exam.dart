import 'exam_attachment.dart';

class PatientExam {
  final String patientExamineId;
  final String examId;
  final String examName;
  final String examDate;
  final String? externalViewerUrl;
  final String? dicomViewerUrl;
  final List<ExamAttachment>? examAttachments;

  PatientExam({
    required this.patientExamineId,
    required this.examId,
    required this.examName,
    required this.examDate,
    this.externalViewerUrl,
    this.dicomViewerUrl,
    this.examAttachments,
  });

  factory PatientExam.fromJson(Map<String, dynamic> json) {
    return PatientExam(
      patientExamineId: json['patientExamineId'] ?? '',
      examId: json['examId'] ?? '',
      examName: json['examName'] ?? '',
      examDate: json['examDate'] ?? '',
      externalViewerUrl: json['externalViewerUrl'],
      dicomViewerUrl: json['dicomViewerUrl'],
      examAttachments: (json['examAttachments'] as List?)
          ?.map((e) => ExamAttachment.fromJson(e))
          .toList(),
    );
  }
}
