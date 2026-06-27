import 'package:intl/intl.dart';

class DateUtilsX {
  DateUtilsX._();

  static final DateFormat _full = DateFormat('d MMM yyyy', 'id_ID');
  static final DateFormat _iso = DateFormat('yyyy-MM-dd');
  static final DateFormat _shortTime = DateFormat('HH:mm', 'id_ID');

  static String formatFull(DateTime d) => _full.format(d);
  static String formatIso(DateTime d) => _iso.format(d);

  static DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  static DateTime endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  static DateTime startOfWeek(DateTime d) {
    final base = startOfDay(d);
    return base.subtract(Duration(days: base.weekday - 1));
  }

  static DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

  static DateTime endOfMonth(DateTime d) =>
      DateTime(d.year, d.month + 1, 0, 23, 59, 59, 999);

  static String relative(DateTime d) {
    final now = DateTime.now();
    final today = startOfDay(now);
    final target = startOfDay(d);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Hari ini, ${_shortTime.format(d)}';
    if (diff == 1) return 'Kemarin, ${_shortTime.format(d)}';
    if (diff < 7) return '${diff}h lalu';
    return _full.format(d);
  }

  static DateTime? tryParseIso(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
}
