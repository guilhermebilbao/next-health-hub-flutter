import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class MedicalEvolution {
  final String content;
  final String date;

  MedicalEvolution({required this.content, required this.date});
}

class AppFormatters {
  static MaskTextInputFormatter get cpf {
    return MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
  }

  static String getInitials(String name) {
    if (name.isEmpty) return '';
    List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
       return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static String formateDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return "$day/$month/${date.year} às $hour:$minute";
    } catch (_) {
      return dateString;
    }
  }

  static List<MedicalEvolution> parseAnamnese(String text) {
    if (text.isEmpty) return [];
    
    final dateRegex = RegExp(r'\(Data: (\d{2}/\d{2}/\d{4} \d{2}:\d{2})\)');
    final matches = dateRegex.allMatches(text).toList();

    if (matches.isEmpty) {
      String cleanContent = text
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll('&nbsp;', ' ')
          .replaceAll(RegExp(r'\r\n'), '\n')
          .trim();
          
      return cleanContent.isNotEmpty 
          ? [MedicalEvolution(content: cleanContent, date: "")] 
          : [];
    }

    List<MedicalEvolution> evolutions = [];
    int lastIndex = 0;
    for (var match in matches) {
      String content = text.substring(lastIndex, match.start).trim();
      String date = match.group(1) ?? "";

      content = content
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll('&nbsp;', ' ')
          .replaceAll(RegExp(r'-\s+'), '')
          .replaceAll(RegExp(r'\r\n'), '\n')
          .trim();

      if (content.isNotEmpty) {
        evolutions.add(MedicalEvolution(content: content, date: date));
      }
      lastIndex = match.end;
    }

    return evolutions.reversed.toList();
  }
}
