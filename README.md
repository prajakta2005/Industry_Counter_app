# Solar Hardware Counter

> Camera-based Flutter app to count solar plant hardware items (nuts, bolts, washers, etc.) using on-device TFLite — with offline logs, Firebase sync, and Excel export.

---

## Status

🚧 **In active development** — TY final year project. Started March 2026.

---

## Problem

Solar plant installations require hardware items in quantities reaching the lakhs. Manual counting at site is impractical and error-prone. This app automates counting using the phone camera.

---

## Planned features

- [ ] Camera-based item counting via TFLite model
- [ ] Photo capture + live camera feed
- [ ] Offline-first log storage (SQLite)
- [ ] Cloud sync when online (Firebase)
- [ ] Excel report export (.xlsx)

---

## Tech stack

- Flutter (Dart)
- TFLite — on-device ML model (provided by ML team)
- SQLite — local storage
- Firebase Firestore — cloud sync
- Excel export package (TBD)

---

## Project structure

> Will be updated as the project grows. See `concept_log.md` for concepts learned along the way.

---

## Team

| Role | Responsibility |
|---|---|
| Flutter development | This repo — UI, services, integration |
| ML team | TFLite model training and delivery |

---

