import 'package:intl/intl.dart';

String formatTime(DateTime time) {
  return DateFormat('HH:mm:ss').format(time);
}
