import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:h8_fli_geo_maps_starter/model/geo.dart';
import 'package:h8_fli_geo_maps_starter/service/geo_service.dart';

import 'package:meta/meta.dart';

part 'geo_event.dart';
part 'geo_state.dart';

class GeoBloc extends Bloc<GeoEvent, GeoState> {
  final GeoService service;

  StreamSubscription<Geo>? _subscription;

  GeoBloc({required this.service}) : super(GeoInitial()) {
    on<GeoInitEvent>((event, emit) async {
      try {
        emit(GeoLoading());
        final isGranted = await service.handlePermission();
        if (isGranted) {
          add(GeoGetLocationEvent());

          add(GeoStartRealtimeEvent());
        }
      } catch (e) {
        emit(GeoError(message: e.toString()));
      }
    });

    on<GeoGetLocationEvent>((event, emit) async {
      try {
        emit(GeoLoading());
        final geo = await service.getLocation();
        emit(GeoLoaded(geo: geo));
      } catch (e) {
        emit(GeoError(message: e.toString()));
      }
    });

    on<GeoStartRealtimeEvent>((event, emit) {
      _subscription = service.getLocationStream().listen((geo) {
        add(GeoUpdateLocationEvent(geo));
      });
    });

    on<GeoUpdateLocationEvent>((event, emit) {
      if (state is GeoLoaded) {
        final currState = state as GeoLoaded;
        emit(
          currState.copywith(
            geo: event.geo,
            points: [...currState.points, event.geo],
          ),
        );
      }
    });

    add(GeoInitEvent());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
