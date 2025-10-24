# Trade-offs & Decisions

Focused delivery required simplifying certain parts. Below are key technical trade-offs.

---

## ❌ Deferred

| Feature           | Reason                                                  |
|-------------------|---------------------------------------------------------|
| Pan/Zoom          | Time constraints + fl_chart gesture complexity          |
| Full Golden Tests | Canvas rendering makes deterministic testing unreliable |
| Editable Journals | UX flow beyond visualization scope                      |

---

## ⚖️ Key Decisions

- **Decimation vs. Raw Data**  
  LTTB used to balance accuracy and performance. Small spikes may be lost, but rendering remains smooth.

- **Mock Data Expansion**  
  Asset files were populated with 12k+ synthetic entries to stress-test performance.

- **Testing Focus**  
  Prioritized logical state and interactions, not pixel rendering.

---

## ✅ Assumptions

- All timestamps are ISO-formatted and day-aligned  
- Sleep score loaded but intentionally not visualized  
- No persistent storage or backend API

---

## 💡 Future Enhancements

- Pan/pinch zoom across stacked charts  
- Chart golden testing via rasterized image comparison  
- Pre-cached decimated ranges or WebAssembly-based processing  
- Editable journal entries and data upload

---

