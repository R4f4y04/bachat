import 'package:intl/intl.dart';

String formatTime(String timestamp) {
  final DateTime dateTime = DateTime.parse(timestamp);
  final DateFormat formatter = DateFormat('h:mm a');
  print("formatted");
  return formatter.format(dateTime);
}

String formatDate(String timestamp) {
  final DateTime dateTime = DateTime.parse(timestamp);
  final DateFormat formatter = DateFormat('d MMMM h:mm a');
  return formatter.format(dateTime);
}
