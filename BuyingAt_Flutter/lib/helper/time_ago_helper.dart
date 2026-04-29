import 'package:timeago/timeago.dart' as timeago;

String formatTimeAgo(String dateTimeString) {
  final dateTime = DateTime.parse(dateTimeString);
  return timeago.format(dateTime);
}
