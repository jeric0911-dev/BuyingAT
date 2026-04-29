import 'package:intl/intl.dart';

String formatDateTime(String? timestamp) {
  try {
    if (timestamp == null || timestamp.isEmpty) return 'Invalid Date';

    DateTime dateTime = DateTime.parse(timestamp).toLocal();
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  } catch (e) {
    return 'Invalid Date';
  }
}
