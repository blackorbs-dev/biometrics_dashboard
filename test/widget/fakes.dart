import 'dart:async';

import 'package:biometrics_dashboard/dashboard/controller.dart';
import 'package:biometrics_dashboard/models/biometrics_point.dart';
import 'package:biometrics_dashboard/models/journal_entry.dart';
import 'package:biometrics_dashboard/models/ui_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

UiState fakeStateWithRange(RangeChoice range) {
  final now = DateTime.now().toUtc();
  final days = range == RangeChoice.d90 ? 90 : 7;

  // Generate biometrics data
  final data = List.generate(days, (i) {
    final d = now.subtract(Duration(days: days - i));
    return BiometricsPoint(date: d, hrv: 40 + i.toDouble(), rhr: 60, steps: 3000);
  });

  // ✅ Generate matching journal entries (one per day)
  final journals = List.generate(days, (i) {
    final d = now.subtract(Duration(days: days - i));
    return JournalEntry(
      date: d,
      mood: (i % 5) + 1, // just 1–5 mood scale
      note: "Journal entry for day $i",
    );
  });

  // Convert to chart spots
  List<FlSpot> toSpots(List<BiometricsPoint> pts) => pts
      .map((e) => FlSpot(e.date.millisecondsSinceEpoch.toDouble(), e.hrv ?? 0))
      .toList();

  final spots = toSpots(data);
  final minX = spots.first.x;
  final maxX = spots.last.x;

  return UiState(
    loading: false,
    raw: data,
    decimated: data,
    journals: journals, // ✅ <-- now non-empty
    range: range,
    large: false,
    error: null,
    selectedJournal: null,
    hoverSpot: null,
    hrv: ChartSeries(
      spots: spots, minX: minX, maxX: maxX, minY: 35, maxY: 120,
    ),
    rhr: ChartSeries(
      spots: spots, minX: minX, maxX: maxX, minY: 50, maxY: 100,
    ),
    steps: ChartSeries(
      spots: spots, minX: minX, maxX: maxX, minY: 0, maxY: 15000,
    ),
  );
}


class FakeDashboardController extends DashboardController {
  final RangeChoice initialRange;

  FakeDashboardController({required this.initialRange});

  @override
  FutureOr<UiState> build() async {
    // Instead of loading JSON, we insert test data directly
    return fakeStateWithRange(initialRange);
  }

  @override
  Future<void> setRange(RangeChoice newRange) async {
    state = AsyncData(fakeStateWithRange(newRange));
  }
}
