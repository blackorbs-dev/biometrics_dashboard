Map<String, dynamic> decimateCompute(Map<String, dynamic> payload) {
  final ptsJ = payload['points'] as List<dynamic>;
  final target = (payload['target'] as num).toInt();

  final n = ptsJ.length;
  if (n <= target || target < 3) {
    return {'decimated': ptsJ}; // just return as-is
  }

  // sort json list by date without creating objects
  ptsJ.sort((a, b) =>
      (a['date'] as String).compareTo(b['date'] as String));

  // count non-null HRV and RHR directly
  int nonNullHrv = 0, nonNullRhr = 0;
  for (final p in ptsJ) {
    if (p['hrv']  != null) nonNullHrv++;
    if (p['rhr']  != null) nonNullRhr++;
  }
  final useHrv = nonNullHrv >= (n * 0.25) || nonNullHrv >= nonNullRhr;

  final xs = List<double>.generate( n,
        (i) => DateTime.parse(ptsJ[i]['date'] as String)
        .millisecondsSinceEpoch
        .toDouble(),
  );

  final ys = List<double>.generate(n, (i) {
    final p = ptsJ[i];
    return useHrv
        ? (p['hrv'] ?? p['rhr'] ?? (p['steps']?.toDouble() ?? 0.0))
        : (p['rhr'] ?? p['hrv'] ?? (p['steps']?.toDouble() ?? 0.0));
  });

  // LTTB
  final outIndices = <int>[0];
  final bucketSize = (n - 2) / (target - 2);
  int a = 0;

  for (int i = 0; i < target - 2; i++) {
    int start = (1 + (i * bucketSize)).floor();
    int end   = (1 + ((i + 1) * bucketSize)).floor();
    if (end   >= n) end   = n - 1;
    if (start >= n) start = n - 1;

    final nextStart = (1 + ((i + 1) * bucketSize)).floor();
    int nextEnd     = (1 + ((i + 2) * bucketSize)).floor();
    if (nextStart >= n) {
      nextEnd = n;
    } else if (nextEnd >= n) {
      nextEnd = n;
    }

    double cx = 0, cy = 0;
    final len = nextEnd - nextStart;
    if (len > 0) {
      for (int ci = nextStart; ci < nextEnd; ci++) {
        cx += xs[ci];
        cy += ys[ci];
      }
      cx /= len;
      cy /= len;
    } else {
      cx = xs[n - 1];
      cy = ys[n - 1];
    }

    double maxArea = -1;
    int maxIdx = start;
    final ax = xs[a], ay = ys[a];
    final bEnd = end > start ? end : start + 1;
    for (int j = start; j < bEnd; j++) {
      final area = ((ax - cx) * (ys[j] - ay) -
          (ax - xs[j]) * (cy - ay)).abs();
      if (area > maxArea) { maxArea = area; maxIdx = j; }
    }
    outIndices.add(maxIdx);
    a = maxIdx;
  }
  outIndices.add(n - 1);

  return {'decimated': outIndices.map((i) => ptsJ[i]).toList()};
}