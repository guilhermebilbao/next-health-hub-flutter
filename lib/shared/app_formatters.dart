import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../dashboard/models/history/patient_record.dart';

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
       // Se tiver apenas um nome, pega as duas primeiras letras ou a única letra
       return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    // Pega a primeira letra do primeiro e do ultimo nome
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
}
