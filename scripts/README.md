## Release a new version

```bash
# 1. Bump version, build APK, commit, tag, push
./scripts/release.sh
```

This updates `flutter_app/pubspec.yaml`, builds the APK, copies it to
`website/public/downloads/finswitch.apk` (served by Cloudflare Pages),
commits and tags. On `git push`, two things happen:

1. **Cloudflare Pages** redeploys the website with the new APK download
2. **GitHub Actions** builds a release APK and creates a GitHub Release

App users will see "Update Available" on next launch — the new APK
downloads automatically and they tap "Install".

## Build (without release)

```bash
./scripts/build-apk.sh
```
