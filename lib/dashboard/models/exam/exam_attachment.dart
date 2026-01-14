class ExamAttachment {
  final String id;
  final String fileName;
  final String date;

  ExamAttachment({
    required this.id,
    required this.fileName,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'date': date,
    };
  }

  factory ExamAttachment.fromJson(Map<String, dynamic> json) {
    return ExamAttachment(
      id: json['id'] ?? '',
      fileName: json['fileName'] ?? '',
      date: json['date'] ?? '',
    );
  }
}
