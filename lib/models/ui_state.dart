import 'package:fl_chart/fl_chart.dart';

import 'biometrics_point.dart';
import 'journal_entry.dart';

enum RangeChoice { d7, d30, d90 }
enum ChartType { hrv, rhr, steps }

class UiState {
  final bool loading;
  final String? error;
  final List<BiometricsPoint> raw; // full sorted raw
  final List<BiometricsPoint> decimated; // latest decimated for current range
  final List<JournalEntry> journals;
  final JournalEntry? selectedJournal;
  final RangeChoice range;
  final bool large;
  final FlSpot? hoverSpot;
  final ChartSeries hrv;
  final ChartSeries rhr;
  final ChartSeries steps;

  UiState({
    this.loading = false,
    this.error,
    required this.raw,
    required this.decimated,
    required this.journals,
    this.selectedJournal,
    required this.range,
    required this.large,
    this.hoverSpot,
    required this.hrv,
    required this.rhr,
    required this.steps,
  });

  UiState copyWith({
    bool? loading,
    String? error,
    List<BiometricsPoint>? raw,
    List<BiometricsPoint>? decimated,
    List<JournalEntry>? journals,
    JournalEntry? selectedJournal,
    RangeChoice? range,
    bool? large,
    FlSpot? hoverSpot,
    ChartSeries? hrv,
    ChartSeries? rhr,
    ChartSeries? steps,
  }) {
    return UiState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      raw: raw ?? this.raw,
      decimated: decimated ?? this.decimated,
      journals: journals ?? this.journals,
      selectedJournal: selectedJournal,
      range: range ?? this.range,
      large: large ?? this.large,
      hoverSpot: hoverSpot,
      hrv: hrv ?? this.hrv,
      rhr: rhr ?? this.rhr,
      steps: steps ?? this.steps,
    );
  }
}

class ChartSeries {
  final List<FlSpot> spots;
  final double minX, maxX, minY, maxY;

  const ChartSeries({
    required this.spots,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  const ChartSeries.empty()
      : spots = const [],
        minX = 0,
        maxX = 0,
        minY = 0,
        maxY = 0;
}