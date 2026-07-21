#!/usr/bin/env bash
set -euo pipefail

echo "==> Building FinSwitch APK (release)"
if ! command -v flutter &>/dev/null; then
  echo "ERROR: Flutter SDK not found."
  echo "       Install: https://docs.flutter.dev/get-started/install"
  echo "       Or use: brew install --cask flutter"
  exit 1
fi

cd "$(dirname "$0")/../flutter_app"

flutter clean >/dev/null 2>&1 || true
flutter pub get
flutter build apk --release --split-per-abi

mkdir -p ../assets
cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk ../assets/finswitch.apk

SIZE=$(du -h ../assets/finswitch.apk | cut -f1)
echo "==> Done: assets/finswitch.apk ($SIZE)"
