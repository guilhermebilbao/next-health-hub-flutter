class ExamAttachmentFile {
  final String id;
  final String fileBase64;
  final String fileName;
  final String fileFormat;

  ExamAttachmentFile({
    required this.id,
    required this.fileBase64,
    required this.fileName,
    required this.fileFormat,
  });

  factory ExamAttachmentFile.fromJson(Map<String, dynamic> json) {
    return ExamAttachmentFile(
      id: json['id'] ?? '',
      fileBase64: json['fileBase64'] ?? '',
      fileName: json['fileName'] ?? '',
      fileFormat: json['fileFormat'] ?? '',
    );
  }
}

class ExamAttachmentFileResponse {
  final int statusCode;
  final String message;
  final ExamAttachmentFile? data;

  ExamAttachmentFileResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory ExamAttachmentFileResponse.fromJson(Map<String, dynamic> json) {
    return ExamAttachmentFileResponse(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? ExamAttachmentFile.fromJson(json['data']) : null,
    );
  }
}
