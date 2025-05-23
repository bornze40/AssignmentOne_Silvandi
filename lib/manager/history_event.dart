import 'package:h8_fli_geo_maps_starter/model/journey.dart';

abstract class HistoryEvent {}

class AddJourneyEvent extends HistoryEvent {
  final Journey journey;
  AddJourneyEvent(this.journey);
}

class HistoryLoadEvent extends HistoryEvent {}
