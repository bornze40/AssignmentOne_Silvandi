import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:h8_fli_geo_maps_starter/model/geo.dart';
import 'package:h8_fli_geo_maps_starter/manager/history_state.dart';
import 'package:h8_fli_geo_maps_starter/utils/time_utils.dart';
import '../manager/history_bloc.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  double _hitungJarak(List<Geo> points) {
    final distance = Distance();
    double total = 0.0;

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = LatLng(points[i].latitude, points[i].longitude);
      final p2 = LatLng(points[i + 1].latitude, points[i + 1].longitude);
      total += distance(p1, p2);
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History Perjalanan"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryUpdated) {
            if (state.journeys.isEmpty) {
              return const Center(child: Text('Belum ada perjalanan.'));
            }
            return ListView.builder(
              itemCount: state.journeys.length,
              itemBuilder: (context, index) {
                final journey = state.journeys[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      'Perjalanan ${index + 1} (${journey.points.length} titik)',
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start: ${formatTime(journey.startTime)} (${journey.points.first.latitude}, ${journey.points.first.longitude})',
                        ),
                        Text(
                          'End: ${formatTime(journey.endTime)} (${journey.points.last.latitude}, ${journey.points.last.longitude})',
                        ),
                        Text(
                          'Jarak: ${_hitungJarak(journey.points).toStringAsFixed(2)} meter',
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          if (state is HistoryInitial) {
            return const Center(child: Text('Belum ada perjalanan.'));
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
