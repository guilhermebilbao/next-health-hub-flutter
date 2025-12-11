class AppUtils {
  static bool areCodesEqual(String? code1, String? code2) {
    if (code1 == null || code2 == null) return false;
    final c1 = code1.trim();
    final c2 = code2.trim();
    if (c1 == c2) return true;
    final i1 = int.tryParse(c1);
    final i2 = int.tryParse(c2);
    return i1 != null && i2 != null && i1 == i2;
  }
}
