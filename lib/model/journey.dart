import 'geo.dart';

class Journey {
  final DateTime startTime;
  final DateTime endTime;
  final List<Geo> points;

  Journey({
    required this.startTime,
    required this.endTime,
    required this.points,
  });
}
