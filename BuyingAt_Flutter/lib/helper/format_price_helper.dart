import 'package:intl/intl.dart';


String formatPriceHelper(dynamic price) {
  if (price == null || price.isEmpty) return '0';
  final parsed = num.tryParse(price);
  if (parsed == null) return '0';
  final formatter = NumberFormat.decimalPattern();
  return formatter.format(parsed);
}