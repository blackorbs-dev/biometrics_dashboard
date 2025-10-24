# Biometrics Dashboard

Interactive Flutter Web dashboard visualizing HRV, RHR, and Steps data with performance-focused charting and clean architecture.

---

## ✅ Overview

This project demonstrates:
- Time-series biometrics visualizations using `fl_chart`
- State management with `Riverpod`
- Efficient dataset handling (LTTB decimation, binary search)
- Mock latency, failure handling, and UI states
- Unit and widget tests validating logic and interactions

---

## 📊 Core Features

| Feature              | Details                                     |
|----------------------|---------------------------------------------|
| Synchronized Charts  | HRV, RHR, Steps aligned on shared timeline  |
| Tooltip Sync         | Hover/tap shows same date across all charts |
| Range Selection      | 7d / 30d / 90d switching                    |
| HRV Insights         | Rolling 7-day mean ±1σ                      |
| Journal Markers      | Vertical lines; tap shows mood and notes    |
| Large Dataset Mode   | Simulates 12k+ data points                  |
| Error/Loading States | Latency + 10% failure simulation            |
| Light/Dark Mode      | Follows system theme                        |

---

## ⚡ Performance

| Optimization       | Purpose                                                      |
|--------------------|--------------------------------------------------------------|
| LTTB decimation    | Reduces 10k+ points to ~250–500 for smooth rendering         |
| Binary search      | Quickly find visible data range without scanning all points. |
| Cached results     | Decimated results stored per range                           |
| Loop optimizations | Reduced allocations & micro overhead                         |

**Measured frame times:**
- 7d: ~8 ms  
- 90d (decimated): ~13 ms  

---

## 📦 Setup

```bash
git clone https://github.com/blackorbs-dev/biometrics_dashboard.git
flutter pub get
flutter run -d chrome
flutter test
```

---

## 🧪 Testing Summary

| Type   | What is validated                                        |
|--------|----------------------------------------------------------|
| Unit   | LTTB decimator correctness (min/max, output size)        |
| Widget | Range switching logic, tooltip sync, journal interaction |

UI canvas rendering is not pixel-tested due to `fl_chart` limitations.

---

## 🚧 Known Limitations

- Pan/zoom not implemented  
- Journal entries are read-only  
- No backend—data from local assets only

---

