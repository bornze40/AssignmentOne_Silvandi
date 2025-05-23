import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:h8_fli_geo_maps_starter/manager/geo_bloc.dart';
import 'package:h8_fli_geo_maps_starter/manager/history_bloc.dart';
import 'package:h8_fli_geo_maps_starter/manager/history_event.dart';
import 'package:h8_fli_geo_maps_starter/model/geo.dart';
import 'package:h8_fli_geo_maps_starter/model/journey.dart';
import 'package:h8_fli_geo_maps_starter/view/history_view.dart';
import 'package:latlong2/latlong.dart' as l2;

class GeoView extends StatefulWidget {
  const GeoView({super.key});
  @override
  State<GeoView> createState() => _GeoViewState();
}

class _GeoViewState extends State<GeoView> {
  final _mapAltController = fmap.MapController();
  bool _isMapAltAvailable = false;

  DateTime? _startTime;
  final List<Geo> _currentPoints = [];

  @override
  void initState() {
    super.initState();
  }

  bool _isRecording = false;
  bool _isLoadingLocation = false;

  void _updateCameraPosition(Geo geo) {
    if (_isMapAltAvailable) {
      _mapAltController.move(l2.LatLng(geo.latitude, geo.longitude), 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GeoBloc, GeoState>(
      listener: (context, state) {
        if (state is GeoLoaded) {
          _updateCameraPosition(state.geo);
        }
        if (_isRecording && state is GeoLoaded) {
          _currentPoints.add(state.geo);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Geo Hands-On'),
            foregroundColor: Colors.white,
            backgroundColor: Colors.blueAccent,
            actions: [
              IconButton(
                icon: Icon(Icons.history),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryView()),
                  );
                },
              ),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: switch (state) {
                GeoInitial() => SizedBox(),
                GeoLoading() => CircularProgressIndicator(),
                GeoLoaded() => fmap.FlutterMap(
                  mapController: _mapAltController,
                  options: fmap.MapOptions(
                    initialZoom: 16,
                    onMapReady: () {
                      setState(() {
                        _isMapAltAvailable = true;
                      });
                    },
                    initialCenter: l2.LatLng(
                      state.geo.latitude,
                      state.geo.longitude,
                    ),
                  ),
                  children: [
                    fmap.TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.hacktive8.app',
                    ),
                    if (_isRecording && state.points.isNotEmpty)
                      fmap.PolylineLayer(
                        polylines: [
                          fmap.Polyline(
                            points:
                                state.points
                                    .map(
                                      (e) => l2.LatLng(e.latitude, e.longitude),
                                    )
                                    .toList(),
                            strokeWidth: 4.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    fmap.MarkerLayer(
                      markers: [
                        fmap.Marker(
                          width: 40,
                          height: 40,
                          point: l2.LatLng(
                            state.geo.latitude,
                            state.geo.longitude,
                          ),
                          alignment: Alignment(0, -0.8), // tengah bawah
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                        if (_isRecording && state.points.isNotEmpty)
                          fmap.Marker(
                            width: 60,
                            height: 60,
                            point: l2.LatLng(
                              state.points.first.latitude,
                              state.points.first.longitude,
                            ),
                            alignment: Alignment(0.2, 0), // ini penting!
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.flag, color: Colors.green, size: 36),
                                Text(
                                  'Start',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                GeoError() => Text('${state.message}'),
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'record',
            backgroundColor: _isRecording ? Colors.red : Colors.white70,
            foregroundColor: _isRecording ? Colors.black : Colors.black,
            onPressed: () async {
              if (_isLoadingLocation) return; // prevent double tap

              setState(() => _isLoadingLocation = true);

              final geoBloc = context.read<GeoBloc>();
              final historyBloc = context.read<HistoryBloc>();

              try {
                await geoBloc.service.getLocation();

                if (!mounted) return;

                setState(() {
                  _isLoadingLocation = false;

                  _isRecording = !_isRecording;

                  if (_isRecording) {
                    _startTime = DateTime.now();
                    _currentPoints.clear();
                  } else {
                    if (_currentPoints.isNotEmpty && _startTime != null) {
                      final journey = Journey(
                        startTime: _startTime!,
                        endTime: DateTime.now(),
                        points: List.from(_currentPoints),
                      );
                      historyBloc.add(AddJourneyEvent(journey));
                    }
                  }
                });

                geoBloc.add(GeoGetLocationEvent());
              } catch (e) {
                if (!mounted) return;

                setState(() {
                  _isLoadingLocation = false;
                });

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Gagal mendapatkan lokasi: ${e.toString()}",
                      ),
                    ),
                  );
                });
              }
            },
            child:
                _isLoadingLocation
                    ? CircularProgressIndicator(color: Colors.black)
                    : Icon(Icons.fiber_manual_record),
          ),
        );
      },
    );
  }
}
