
import 'package:intl/intl.dart';

class DateConverter {

  static String formatToLongDate(String isoString) {
    final dt = DateTime.parse(isoString);
    return DateFormat('MMMM d, yyyy').format(dt);
  }

  static String formatToLongDateTwo(String isoString) {
    final dt = DateTime.parse(isoString);
    return DateFormat('d MMMM, yyyy').format(dt); // 5 May, 2024
  }

}

String calculateDuration(String? dateTimeStr) {
  if (dateTimeStr == null || dateTimeStr.isEmpty) {
    return "Invalid date";
  }

  DateTime? originalDate;
  try {
    originalDate = DateTime.parse(dateTimeStr);
  } catch (e) {
    return "Invalid date format";
  }

  // Trim seconds and milliseconds
  DateTime trimmedDate = DateTime(
    originalDate.year,
    originalDate.month,
    originalDate.day,
    originalDate.hour,
    originalDate.minute,
  );

  DateTime now = DateTime.now();

  int years = now.year - trimmedDate.year;
  int months = now.month - trimmedDate.month + (years * 12);
  int days = now.day - trimmedDate.day;

  if (days < 0) {
    months -= 1;
    DateTime previousMonthDate;
    if (now.month == 1) {
      previousMonthDate = DateTime(now.year - 1, 12, trimmedDate.day);
    } else {
      previousMonthDate = DateTime(now.year, now.month - 1, trimmedDate.day);
    }
    days = now.difference(previousMonthDate).inDays;
  }

  String formattedDate =
      "${trimmedDate.year.toString().padLeft(4, '0')}-"
      "${trimmedDate.month.toString().padLeft(2, '0')}-"
      "${trimmedDate.day.toString().padLeft(2, '0')} "
      "${trimmedDate.hour.toString().padLeft(2, '0')}:"
      "${trimmedDate.minute.toString().padLeft(2, '0')}";

  return "$formattedDate\n$months months $days days ago";
}


String formatDateToDTMY(String rawDate) {
  final date = DateTime.parse(rawDate).toLocal(); // Optional: .toLocal() if UTC
  final formatted = DateFormat("d MMMM yyyy @ hh:mm a").format(date);
  return "Posted on $formatted";
}
