![FinSwitch logo](https://raw.githubusercontent.com/OK45batwal/FINSWITCH/master/website/public/logo.svg#gh-dark-mode-only)
![FinSwitch logo](https://raw.githubusercontent.com/OK45batwal/FINSWITCH/master/website/public/logo.svg#gh-light-mode-only)

# FinSwitch

**AI-Powered Financial Intelligence for Indian Markets**

[![Website](https://img.shields.io/badge/Live_Website-finswitch.pages.dev-0A192F?style=for-the-badge&logo=cloudflare&logoColor=white)](https://finswitch.pages.dev)
[![APK](https://img.shields.io/badge/Download_APK-v1.0.0-10B981?style=for-the-badge&logo=android&logoColor=white)](https://finswitch.pages.dev/downloads/finswitch.apk)
[![Version](https://img.shields.io/badge/version-1.0.0-blue?style=for-the-badge&color=2563EB)](https://github.com/OK45batwal/FINSWITCH/releases)
[![License](https://img.shields.io/badge/license-MIT-10B981?style=for-the-badge)](LICENSE)

![Hero](https://raw.githubusercontent.com/OK45batwal/FINSWITCH/master/assets/website-hero.png)

## Features

- **AI Financial Copilot** — Natural language stock analysis, buy/sell scores, market insights
- **Live Markets** — Nifty 50, Sensex, Bank Nifty — real-time indices & stock data
- **Portfolio Tracker** — Holdings, P&L, sector allocation, returns tracking
- **Watchlist** — Follow your favorite stocks with instant updates
- **60-Day Charts** — OHLCV with RSI, SMA, support & resistance
- **Smart News** — Curated financial news with stock-specific relevance
- **Dark & Light Themes** — Seamless switching on web & mobile
- **Offline Ready** — Full local fallback when network is unavailable
- **Auto Update** — Automatic APK download & install prompt on new version

## Web App

| | |
|---|---|
| ![Hero](https://raw.githubusercontent.com/OK45batwal/FINSWITCH/master/assets/website-hero.png) | ![Dashboard](https://raw.githubusercontent.com/OK45batwal/FINSWITCH/master/assets/website-desktop.png) |
| ![Mobile](https://raw.githubusercontent.com/OK45batwal/FINSWITCH/master/assets/website-mobile.png) | ![Full page](https://raw.githubusercontent.com/OK45batwal/FINSWITCH/master/assets/website-fullpage.png) |

## Mobile App

| | | | |
|---|---|---|---|
| ![Home](https://raw.githubusercontent.com/OK45batwal/FINSWITCH/master/assets/App-Home.png) | ![Markets](https://raw.githubusercontent.com/OK45batwal/FINSWITCH/master/assets/App-Markets.png) | ![AI](https://raw.githubusercontent.com/OK45batwal/FINSWITCH/master/assets/App-AI.png) | ![Portfolio](https://raw.githubusercontent.com/OK45batwal/FINSWITCH/master/assets/App-Portfolio.png) | ![News](https://raw.githubusercontent.com/OK45batwal/FINSWITCH/master/assets/App-News.png) |

## Quick Start

**Web:**
```bash
cd website && npm install && npm run dev
```

**Mobile:**
```bash
cd flutter_app && flutter pub get && flutter run
```

**Full stack:**
```bash
./run.sh
```

## Architecture

```
User ──Browser──▶ Next.js 16 · Cloudflare Pages
User ──App──────▶ Flutter 3.x
Both ──────────▶ Supabase (auth + data)
Both ──────────▶ Cloudflare Function /api/ai
```

## Auto Update Flow

```
Developer ──scripts/release.sh──▶ GitHub ──tag v*──▶ GitHub Actions
Actions ──Build APK──▶ GitHub Release
User App ──checkForUpdate──▶ GitHub raw pubspec.yaml
New version? ──▶ Auto-download APK ──▶ Tap Install ──▶ System Installer
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend (Web) | Next.js 16, React 19, Turbopack, Tailwind CSS v4 |
| Mobile | Flutter 3.x, go_router, supabase_flutter |
| AI Engine | Cloudflare Pages Function (JS, zero deps) |
| Database | Supabase (PostgreSQL) |
| Hosting | Cloudflare Pages (free tier) |
| CI/CD | GitHub Actions, Cloudflare Pages auto-deploy |

## License

MIT — see [LICENSE](LICENSE).

---

[🌐 finswitch.pages.dev](https://finswitch.pages.dev) · [📱 Download APK](https://finswitch.pages.dev/downloads/finswitch.apk) · [📦 GitHub](https://github.com/OK45batwal/FINSWITCH)

*Built for smarter investing in India*
