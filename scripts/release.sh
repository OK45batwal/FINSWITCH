#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

CURRENT=$(grep '^version: ' flutter_app/pubspec.yaml | sed 's/version: //' | sed 's/\+.*//')
echo "Current version: $CURRENT"

read -rp "New version (e.g. 1.1.0): " VERSION
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "Invalid semver"; exit 1; }

sed -i '' "s/^version: .*/version: $VERSION+1/" flutter_app/pubspec.yaml

echo "==> Building APK"
cd flutter_app
flutter clean >/dev/null 2>&1 || true
flutter pub get
flutter build apk --release --split-per-abi
cd ..

echo "==> Copying APK to website assets"
mkdir -p website/public/downloads
cp flutter_app/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk website/public/downloads/finswitch.apk

echo "==> Committing release v$VERSION"
git add flutter_app/pubspec.yaml website/public/downloads/finswitch.apk
git commit -m "release: v$VERSION"
git tag "v$VERSION"

echo "==> Push to GitHub? (y/n)"
read -r PUSH
if [ "$PUSH" = "y" ]; then
  git push origin master --tags
  echo "==> Pushed. Cloudflare Pages will deploy automatically."
  echo "==> Users will see the update within minutes."
fi

SIZE=$(du -h website/public/downloads/finswitch.apk | cut -f1)
echo "==> Done: v$VERSION ($SIZE)"
