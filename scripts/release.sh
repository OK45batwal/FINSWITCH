#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

CURRENT=$(grep '^version: ' flutter_app/pubspec.yaml | sed 's/version: //' | sed 's/\+.*//')
echo "Current version: $CURRENT"

read -rp "New version (e.g. 1.1.0): " VERSION
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "Invalid semver"; exit 1; }

sed -i '' "s/^version: .*/version: $VERSION+1/" flutter_app/pubspec.yaml

if command -v java &>/dev/null; then
  echo "==> Building APK"
  cd flutter_app
  flutter clean >/dev/null 2>&1 || true
  flutter pub get
  flutter build apk --release
  cd ..
else
  echo "==> No Java found. GitHub Actions will build the APK on tag push."
fi

echo "==> Committing release v$VERSION"
git add flutter_app/pubspec.yaml
git commit -m "release: v$VERSION"
git tag "v$VERSION"

echo "==> Push to GitHub? (y/n)"
read -r PUSH
if [ "$PUSH" = "y" ]; then
  git push origin master --tags
  echo "==> Pushed. GitHub Actions will build the APK and create the release."
fi

echo "==> Done: v$VERSION"
