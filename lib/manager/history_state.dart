import 'package:h8_fli_geo_maps_starter/model/journey.dart';

abstract class HistoryState {}

class HistoryInitial extends HistoryState {}

class HistoryUpdated extends HistoryState {
  final List<Journey> journeys;
  HistoryUpdated({required this.journeys});
}
