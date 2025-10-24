import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/biometrics_point.dart';
import '../models/ui_state.dart';
import '../repository/asset_repository.dart';
import '../util/decimation.dart';

final dashboardStateProvider = AsyncNotifierProvider<DashboardController, UiState>(() => DashboardController());

class DashboardController extends AsyncNotifier<UiState> {
  late AssetRepository _repository;

  @override
  FutureOr<UiState> build() async {
    _repository = ref.read(repositoryProvider);
    return await _loadData();
  }

  Future<void> reload() async {
    await _refreshData(state.value?.large ?? false);
  }

  void setRange(RangeChoice value) async {
    if(state.hasValue) {
      state = AsyncData(state.value!.copyWith(loading: true));
      // re-decimate for new range
      final decimated = await _decimateForRange(state.value!.raw, value);
      final series = _buildAllSeries(decimated);
      state = AsyncData(state.value!.copyWith(
          range: value,
          decimated: decimated,
          hrv: series.hrv,
          rhr: series.rhr,
          steps: series.steps,
          loading: false
      ));
    }
  }

  void toggleLarge(bool value) async {
    await _refreshData(value);
  }

  void setHover(FlSpot spot){
    state = AsyncData(state.value!.copyWith(hoverSpot: spot));
  }

  void clearHover() async{
    state = AsyncData(state.value!.copyWith(hoverSpot: null));
  }

  Future<void> _refreshData([bool large = false]) async{
    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(loading: true, error: null));
    }
    state = await AsyncValue.guard(() => _loadData(large));
  }

  Future<UiState> _loadData([bool large = false]) async {
    final raw = await _repository.loadBiometrics(large: large);
    final journals = state.value?.journals ?? await _repository.loadJournals();
    raw.sort((a, b) => a.date.compareTo(b.date));
    final range = state.value?.range ?? RangeChoice.d7;
    final decimated = await _decimateForRange(raw, range);
    final series = _buildAllSeries(decimated);

    return UiState(
      raw: raw,
      decimated: decimated,
      journals: journals,
      range: range,
      large: large,
      hrv: series.hrv,
      rhr: series.rhr,
      steps: series.steps,
    );
  }

  ({ChartSeries hrv, ChartSeries rhr, ChartSeries steps,}) _buildAllSeries(List<BiometricsPoint> points) {
    final h = <FlSpot>[];
    final r = <FlSpot>[];
    final s = <FlSpot>[];

    for (final p in points) {
      final t = p.date.millisecondsSinceEpoch.toDouble();
      if (p.hrv != null)   h.add(FlSpot(t, p.hrv!));
      if (p.rhr != null)   r.add(FlSpot(t, p.rhr!));
      if (p.steps != null) s.add(FlSpot(t, p.steps!.toDouble()));
    }

    return (hrv: _bounds(h), rhr: _bounds(r), steps: _bounds(s));
  }

  ChartSeries _bounds(List<FlSpot> spots) {
    if (spots.isEmpty) return ChartSeries.empty();

    double minX = spots.first.x;
    double maxX = spots.last.x;
    double minY = spots.first.y;
    double maxY = spots.first.y;

    for (final s in spots) {
      if (s.y < minY) minY = s.y;
      if (s.y > maxY) maxY = s.y;
    }

    final padding = (maxY - minY).abs();
    maxY += padding;

    return ChartSeries(spots: spots, minX: minX, maxX: maxX, minY: 0, maxY: maxY,);
  }

  Future<List<BiometricsPoint>> _decimateForRange(List<BiometricsPoint> data, RangeChoice range,) async {
    if (data.isEmpty) return [];

    final end = data.last.date;
    final cutoff = switch (range) {
      RangeChoice.d7  => end.subtract(const Duration(days: 6)),
      RangeChoice.d30 => end.subtract(const Duration(days: 29)),
      RangeChoice.d90 => end.subtract(const Duration(days: 89)),
    };

    // --- binary search for first >= cutoff ---
    int lo = 0, hi = data.length - 1, mid = 0;
    while (lo < hi) {
      mid = (lo + hi) >> 1;
      if (data[mid].date.isBefore(cutoff)) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    final slice = data.sublist(lo);

    final target = switch (range) {
      RangeChoice.d7 => slice.length,
      RangeChoice.d30 => 250,
      RangeChoice.d90 => 500,
    };

    if (slice.length <= target) return slice;

    final payload = {
      'points': slice.map((p) => p.toJson()).toList(),
      'target': target,
    };
    final result = await compute(decimateCompute, payload);
    final decJ = result['decimated'] as List<dynamic>;
    return decJ.map((e) =>
        BiometricsPoint.fromJson(Map<String, dynamic>.from(e as Map))
    ).toList();
  }
}