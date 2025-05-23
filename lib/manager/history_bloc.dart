// manager/history_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:h8_fli_geo_maps_starter/manager/history_event.dart';
import 'package:h8_fli_geo_maps_starter/manager/history_state.dart';
import '../model/journey.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final List<Journey> _journeys = [];

  HistoryBloc() : super(HistoryInitial()) {
    on<AddJourneyEvent>((event, emit) {
      _journeys.add(event.journey);
      emit(HistoryUpdated(journeys: List.from(_journeys)));
    });

    on<HistoryLoadEvent>((event, emit) {
      emit(HistoryUpdated(journeys: List.from(_journeys)));
    });
  }
}
