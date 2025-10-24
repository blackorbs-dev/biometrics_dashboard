class BiometricsPoint {
  final DateTime date;
  final double? hrv;
  final double? rhr;
  final int? steps;
  final int? sleepScore;

  BiometricsPoint({required this.date, this.hrv, this.rhr, this.steps, this.sleepScore});

  static BiometricsPoint fromJson(Map<String, dynamic> j) => BiometricsPoint(
    date: DateTime.parse(j['date'] as String),
    hrv: j['hrv'] != null ? (j['hrv'] as num).toDouble() : null,
    rhr: j['rhr'] != null ? (j['rhr'] as num).toDouble() : null,
    steps: j['steps'] as int?,
    sleepScore: j['sleepScore'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'hrv': hrv,
    'rhr': rhr,
    'steps': steps,
    'sleepScore': sleepScore,
  };
}