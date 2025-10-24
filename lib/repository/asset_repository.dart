import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/biometrics_point.dart';
import '../models/journal_entry.dart';

final repositoryProvider = Provider((ref) => AssetRepository());

class AssetRepository {
  final Random _rng = Random();

  Future<List<BiometricsPoint>> loadBiometrics({bool large = false}) async {
    final latency = 700 + _rng.nextInt(500);
    await Future.delayed(Duration(milliseconds: latency));
    if (_rng.nextDouble() < 0.10) throw 'Error occurred while loading biometrics';
    if (!large) {
      final raw = await rootBundle.loadString('assets/biometrics_90d.json');
      final List<dynamic> arr = json.decode(raw);
      final base = arr.map((e) => BiometricsPoint.fromJson(Map<String, dynamic>.from(e))).toList();
      base.sort((a, b) => a.date.compareTo(b.date));
      return base;
    }

    // L1: generate realistic synthetic dataset (replace base entirely)
    final int points = 12000;
    final List<BiometricsPoint> largeList = [];
    final now = DateTime.now().toUtc();
    final start = now.subtract(Duration(minutes: points * 30 ~/ 2)); // centered around now
    for (int i = 0; i < points; i++) {
      final d = start.add(Duration(minutes: i * 30));
      final t = i.toDouble();
      // circadian-like: daily (~48 samples/day at 30-min), plus weekly modulation
      final circ = 10 * sin(t / 48 * 2 * pi) + 3 * sin(t / (48*7) * 2 * pi);
      final seed = (_rng.nextDouble() - 0.5) * 4.0; // small noise
      final hrv = 55 + circ + seed; // typical HRV ranges
      final rhr = 60 + 4 * sin(t / 24) + (_rng.nextDouble() - 0.5) * 2;
      final steps = (50 + 30 * max(0, sin(t / 6)) + (_rng.nextDouble() * 20)).round();
      largeList.add(BiometricsPoint(date: d, hrv: hrv, rhr: rhr, steps: steps));
    }
    return largeList;
  }

  Future<List<JournalEntry>> loadJournals() async {
    final latency = 700 + _rng.nextInt(500);
    await Future.delayed(Duration(milliseconds: latency));
    if (_rng.nextDouble() < 0.10) throw 'Error occurred while loading journals';
    final raw = await rootBundle.loadString('assets/journals.json');
    final List<dynamic> arr = json.decode(raw);
    return arr.map((e) => JournalEntry.fromJson(Map<String, dynamic>.from(e))).toList();
  }
}