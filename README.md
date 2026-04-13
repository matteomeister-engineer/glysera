# Glysera

**AI-powered glucose monitoring for iOS** — real-time CGM tracking, predictive insights, and smart alerts in a clean, modern interface.

🌐 **[View portfolio page →](https://matteomeister.framer.website/)**

> ⚠️ **Disclaimer:** Glysera is a research and demonstration project. It uses simulated CGM data and is **not a certified medical device**. Do not use it for clinical decisions.

---

<!-- Replace the paths below with your actual screenshot paths once uploaded to the repo -->
<p align="center">
  <img src="Branding/Screenshots/Simulator Screenshot - iPhone 16e - 2026-03-24 at 19.42.15.png" width="28%" alt="Dashboard" />
  &nbsp;&nbsp;
  <img src="Branding/Screenshots/Simulator Screenshot - iPhone 16e - 2026-03-25 at 12.12.39.png" width="28%" alt="Logbook" />
</p>

---

## Getting started

### Prerequisites

- **macOS** with Xcode 15+ installed
- **Flutter SDK** 3.19 or later → [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
- An iPhone or iOS Simulator (iOS 17+)

### 1. Clone the repo

```bash
git clone https://github.com/matteomeister-engineer/glysera.git
cd glysera
```

### 2. Install dependencies

```bash
flutter pub get
cd ios && pod install && cd ..
```

### 3. Run on simulator

```bash
flutter run
```

Or pick a specific device:

```bash
flutter run -d "iPhone 15"
```

### 4. Run on your own iPhone

Plug in your iPhone, trust the developer certificate when prompted, then:

```bash
flutter run --release
```

First time only: go to **Settings → General → VPN & Device Management** on your iPhone and tap **Trust** next to your developer certificate.

---

## What it does

Glysera connects to a simulated continuous glucose monitor (CGM) and gives you a live view of your glucose trends, predictions, and patterns — all in one place.

| Feature | Description |
|---|---|
| **Live dashboard** | Real-time glucose reading, 3-hour trend chart, time-in-range |
| **AI prediction** | 30-minute glucose forecast based on rate of change |
| **Logbook** | Manual entries for meals, insulin, activity, and notes |
| **Trends** | 3h / 6h / 24h chart with distribution stats |
| **AI Insights** | Weekly patterns, health score, personalised recommendations |
| **Settings** | Target range, therapy mode, alert configuration |

---

## Tech stack

```
Flutter 3.19+   Cross-platform UI framework (iOS target)
Dart            Application language
Riverpod        State management
go_router       Navigation
Lottie          Splash screen animation
flutter_svg     SVG asset rendering
Google Fonts    Typography (Montserrat)
```

---

## Project structure

```
lib/
├── core/
│   ├── constants/       App-wide constants & glucose converter
│   ├── router/          go_router navigation setup
│   └── theme/           Colors, typography, dimensions
├── data/
│   ├── models/          GlucoseReading, UserProfile
│   ├── repositories/    In-memory glucose store
│   └── simulator/       CGM data simulator
├── features/
│   ├── dashboard/       Home screen with live chart
│   ├── trends/          Historical trend view
│   ├── logbook/         Manual entry log
│   ├── insights/        AI analysis & health score
│   ├── settings/        User preferences & alerts
│   └── onboarding/      First-run setup flow
└── shared/
    └── widgets/         Reusable components (AvatarWidget, AnimatedRevealCard…)

assets/
├── animations/          Lottie JSON files
├── avatars/             SVG profile shapes (1.svg – 9.svg)
└── images/              Logo and splash assets
```

---

## Key design decisions

- **No real CGM hardware required** — a built-in simulator generates realistic glucose curves so anyone can try the app immediately
- **ISO-aware alerts** — urgent low and urgent high alerts are locked per ISO 14971 and cannot be disabled
- **Offline first** — all data lives in memory; no backend or account needed to run
- **Scroll-free onboarding** — every setup step fits the screen without scrolling, for a polished first impression

---

## Contributing

Pull requests are welcome. For major changes, open an issue first to discuss what you'd like to change.

---

## License

MIT — see `LICENSE` for details.