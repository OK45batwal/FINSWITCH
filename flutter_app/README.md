# FinSwitch — Flutter Mobile App

Cross-platform Android app for FinSwitch, the AI-powered financial intelligence platform.

## Build

```bash
flutter pub get
flutter build apk --release --split-per-abi
```

APK output: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

## Run

```bash
flutter run
```

## Key Dependencies

- `go_router` — navigation & auth redirect
- `supabase_flutter` — auth & data
- `http` — API client
- `fl_chart` — stock charts
- `open_filex` — APK install
- `url_launcher` — deep links

## Update System

App checks for updates on launch via `AppUpdateService.checkForUpdate()`.
See [scripts/README.md](../scripts/README.md) for release instructions.
