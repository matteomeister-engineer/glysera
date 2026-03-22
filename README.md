# GlucoTrack — iOS Glucose Monitoring App

A modern, ISO-compliant CGM glucose monitoring app built with Flutter.

## Standards
- **IEC 62304** — Software lifecycle (Safety Class B)
- **ISO 14971** — Risk management
- **IEC 62366** — Usability engineering
- **ISO 15197** — CGM accuracy guidelines

## Tech Stack
- Flutter 3.19+ / Dart 3.3+
- Riverpod 2.x — state management
- go_router — navigation
- fl_chart — glucose charts
- Isar — encrypted local database
- flutter_local_notifications — alerts

## Project Structure
```
lib/
├── main.dart                  # App entry point
├── providers.dart             # Global Riverpod providers
├── core/
│   ├── constants/             # App constants, glucose converter
│   ├── theme/                 # Colors, typography, spacing, ThemeData
│   └── router/                # go_router configuration
├── data/
│   ├── models/                # GlucoseReading, UserProfile
│   ├── simulator/             # Physiological CGM simulator
│   └── repositories/          # Data access layer
├── features/
│   ├── onboarding/            # Welcome → Profile → Mode → Range
│   ├── dashboard/             # Live glucose + sparkline + TIR
│   ├── trends/                # Charts (3h/6h/24h)
│   ├── logbook/               # Meals, insulin, notes
│   ├── insights/              # AI predictions + meal impact
│   └── settings/              # Alerts, units, profile
└── shared/
    └── widgets/               # MainShell, shared components
```

## Setup

### Prerequisites
- Flutter SDK ≥ 3.19.0
- Xcode 15+ (for iOS)
- VS Code with Flutter extension

### Install
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Run on iOS Simulator
```bash
open -a Simulator
flutter run
```

### Run on physical iPhone
```bash
flutter run --release
```

## Build Steps
| Step | Feature | Status |
|------|---------|--------|
| 1 | Project scaffold + design system | ✅ Done |
| 2 | CGM simulator + Riverpod stream | ✅ Done |
| 3 | Onboarding screens | 🔜 Next |
| 4 | Dashboard screen | 🔜 |
| 5 | Alert engine + notifications | 🔜 |
| 6 | Trends + charts | 🔜 |
| 7 | AI Insights | 🔜 |
| 8 | Settings screen | 🔜 |

## Glucose Simulation
The `GlucoseSimulator` uses a physiological model:
- Mean-reversion toward 110 mg/dL set point
- Random-walk noise matching real CGM variance (~±5 mg/dL)
- Meal spike events (post-prandial rise)
- Dawn phenomenon (4–8 AM glucose rise)
- Rate-of-change based trend arrows

Readings fire every 10 seconds in dev mode (= 5 min real CGM interval compressed).

## Color System
| Color | Hex | Usage |
|-------|-----|-------|
| Background | `#FFFFFF` | Screen backgrounds |
| Surface | `#F3F2E9` | Cards, inputs |
| Accent | `#E7FE54` | CTAs, in-range status |
| Text | `#1F1F1F` | All primary text |
| Black | `#000000` | Dark cards |
| Urgent | `#FF4545` | Hypo/hyperglycemia alerts |
| Warning | `#FF8C42` | Low/high alerts |
