# Glysera — First Run Setup Guide
# Path: /Users/matteomeister/Documents/Medical Devices/Projects/

## Step 1 — Create the Flutter project scaffold

Open Terminal and run:

```bash
cd "/Users/matteomeister/Documents/Medical Devices/Projects"
flutter create --org com.glysera --platforms ios glysera
cd glysera
```

This gives you the native iOS scaffolding (Xcode project, Runner, etc.)
that Flutter needs but we don't generate manually.

---

## Step 2 — Replace lib/ and config files with our code

```bash
# Remove Flutter's default lib/ content
rm -rf lib/

# Copy our entire lib/ folder in
cp -r ~/Downloads/glysera/lib .

# Copy config files
cp ~/Downloads/glysera/pubspec.yaml .
cp ~/Downloads/glysera/analysis_options.yaml .
cp ~/Downloads/glysera/ios/Runner/Info.plist ios/Runner/Info.plist
```

---

## Step 3 — Create asset folders

```bash
mkdir -p assets/images assets/icons
```

Then add this to pubspec.yaml under flutter: (already included):
```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
```

---

## Step 4 — Install dependencies

```bash
flutter pub get
```

Expected output: "Got dependencies!"
If you see version conflicts, run: flutter pub upgrade

---

## Step 5 — Run code generation (Riverpod + Isar)

```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates the .g.dart files for Isar models and Riverpod annotations.
You only need to re-run this when you add new @riverpod or @collection annotations.

---

## Step 6 — Open iOS Simulator

```bash
open -a Simulator
```

Choose iPhone 15 Pro (iOS 17+) for best results.
Or connect a physical iPhone with Developer Mode enabled.

---

## Step 7 — Run Glysera

```bash
flutter run
```

You should see:
✓  Built build/ios/iphonesimulator/Runner.app (XX.Xs)
Syncing files to device iPhone 15 Pro...

The app opens on the Glysera onboarding Welcome screen.

---

## Troubleshooting

### "Unable to load contents of file list"
```bash
cd ios && pod install && cd ..
flutter run
```

### "CocoaPods not installed"
```bash
sudo gem install cocoapods
pod setup
```

### "No devices found"
```bash
# List available devices
flutter devices

# Use specific simulator
flutter run -d "iPhone 15 Pro"
```

### Isar build_runner errors
```bash
flutter pub upgrade isar isar_flutter_libs isar_generator
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Riverpod lint errors in VSCode
Install the "Riverpod Snippets" VSCode extension.
Add to VSCode settings.json:
```json
"dart.analyzerAdditionalArgs": ["--enable-experiment=macros"]
```

---

## VSCode recommended extensions

- Flutter (Dart-Code.flutter)
- Dart (Dart-Code.dart-code)  
- Riverpod Snippets (robert-brunhage.flutter-riverpod-snippets)
- Pubspec Assist (jeroen-meijer.pubspec-assist)
- Error Lens (usernamehw.errorlens)

---

## Project path reference

```
/Users/matteomeister/Documents/Medical Devices/Projects/glysera/
├── lib/
│   ├── main.dart                          ← Entry point
│   ├── providers.dart                     ← Global Riverpod providers
│   ├── core/
│   │   ├── constants/app_constants.dart   ← Glucose thresholds, ISO metadata
│   │   ├── constants/glucose_converter.dart
│   │   ├── theme/app_colors.dart          ← Your exact palette
│   │   ├── theme/app_text_styles.dart
│   │   ├── theme/app_dimens.dart
│   │   ├── theme/app_theme.dart
│   │   └── router/app_router.dart
│   ├── data/
│   │   ├── models/glucose_reading.dart
│   │   ├── simulator/glucose_simulator.dart  ← CGM simulator
│   │   └── repositories/glucose_repository.dart
│   ├── features/
│   │   ├── onboarding/   ← Step 2 ✅ DONE
│   │   ├── dashboard/    ← Step 3 next
│   │   ├── trends/
│   │   ├── logbook/
│   │   ├── insights/
│   │   └── settings/
│   └── shared/widgets/main_shell.dart
├── pubspec.yaml
├── analysis_options.yaml
└── ios/Runner/Info.plist
```

---

## Build steps status

| Step | Feature                        | Status      |
|------|-------------------------------|-------------|
| 1    | Scaffold + design system       | ✅ Complete |
| 2    | CGM simulator + onboarding     | ✅ Complete |
| 3    | Dashboard screen               | 🔜 Next     |
| 4    | Alert engine + notifications   | 🔜          |
| 5    | Trends + charts                | 🔜          |
| 6    | AI Insights                    | 🔜          |
| 7    | Settings screen                | 🔜          |
