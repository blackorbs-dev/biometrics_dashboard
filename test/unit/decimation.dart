import 'dart:math' as math;

import 'package:biometrics_dashboard/models/biometrics_point.dart';
import 'package:biometrics_dashboard/util/decimation.dart';
import 'package:flutter_test/flutter_test.dart';

void main(){
  test('LTTB preserves target size and keeps spike', (){
    final pts = List.generate(1000, (i)=>BiometricsPoint(date: DateTime(2025,1,1).add(Duration(minutes:i)), hrv: (i==500)?300.0:50+10*math.sin(i/50), rhr:60.0, steps:1000));
    final payload={'points': pts.map((p)=>p.toJson()).toList(), 'target':200};
    final res = decimateCompute(payload);
    final out = (res['decimated'] as List).map((m)=>BiometricsPoint.fromJson(Map<String,dynamic>.from(m))).toList();
    expect(out.length, 200);
    expect(out.any((p)=> (p.hrv ?? 0) > 250), true);
  });
}