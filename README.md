<div align="center">
  <svg width="80" height="80" viewBox="0 0 512 512" fill="none" xmlns="http://www.w3.org/2000/svg" style="border-radius:16px;"><rect width="512" height="512" rx="104" fill="#0B1220"/><path d="M200 380V132h80c32 0 56 8 72 24s24 36 24 60c0 28-10 50-30 66s-48 24-84 24h-38l92 74" stroke="#F8FAFC" stroke-width="36" stroke-linecap="round" stroke-linejoin="round" fill="none"/><path d="M280 200l-80 0" stroke="#2563EB" stroke-width="20" stroke-linecap="round" fill="none"/></svg>
  <h1 align="center" style="font-size: 3em; margin: 10px 0; background: linear-gradient(135deg, #2563EB, #38BDF8); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;">FinSwitch</h1>
  <p align="center"><strong>AI-Powered Financial Intelligence Platform</strong></p>
  <p align="center">Switch from confusion to confident financial decisions.</p>

  <p align="center">
    <a href="https://github.com/OK45batwal/FINSWITCH">
      <img src="https://img.shields.io/badge/version-2.0.0-blue?style=for-the-badge&labelColor=0B1220&color=2563EB" alt="Version">
    </a>
    <a href="https://github.com/OK45batwal/FINSWITCH/stargazers">
      <img src="https://img.shields.io/github/stars/OK45batwal/FINSWITCH?style=for-the-badge&labelColor=0B1220&color=10B981" alt="Stars">
    </a>
    <a href="LICENSE">
      <img src="https://img.shields.io/badge/license-MIT-green?style=for-the-badge&labelColor=0B1220&color=10B981" alt="License">
    </a>
    <br>
    <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
    <img src="https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi&logoColor=white" alt="FastAPI">
    <img src="https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL">
    <img src="https://img.shields.io/badge/Material_3-757575?style=for-the-badge&logo=materialdesign&logoColor=white" alt="Material 3">
  </p>
</div>

<br>

---

## ✦ Overview

**FinSwitch** is a modern, AI-powered financial intelligence platform designed for the Indian market. It helps users understand markets, analyze stocks, track portfolios, and make smarter financial decisions — all powered by advanced AI.

> **FinSwitch is NOT a broker.** Users cannot buy or sell stocks directly. Instead, it's a complete financial decision intelligence platform.

---

## ✦ Features

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 16px;">

### 📊 Market Intelligence
Real-time Nifty, Sensex, and stock data with interactive charts, sector heatmaps, and market movers. Live tracking of 10,000+ stocks.

### 🤖 AI Copilot
Natural language chat that explains stocks, compares companies, analyzes markets, and answers financial questions. Like ChatGPT for finance.

### 💼 Portfolio Tracker
Track holdings, view allocation, analyze returns, and get AI-powered insights to optimize your investments.

### 📰 Smart News Feed
Curated financial news with AI summaries, sentiment analysis, and related stock impact assessments. Never miss a market-moving event.

### 📈 Stock Screener
Advanced filters, financial ratios, peer comparison, and fundamental analysis tools for deep research.

### 🎓 Learning Platform
Courses, tutorials, quizzes, and certificates covering finance basics to advanced investing strategies.

### 💰 SIP Planner
Goal-based planning with AI recommendations, future value projections, and inflation-adjusted targets.

### 🔔 Smart Alerts
Price, news, dividend, IPO, and volatility alerts with push notifications.

</div>

---

## ✦ Tech Stack

```
Frontend     →  Flutter (iOS, Android, Web)
Backend      →  Python FastAPI
Database     →  PostgreSQL 15 + Redis Cache
AI           →  LLM-powered Financial Intelligence
Auth         →  JWT + Firebase Authentication
Infra        →  Docker · Celery Workers
```

---

## ✦ Screenshots

### Website

<table>
  <tr>
    <td width="50%"><img src="assets/website-hero.png" alt="Hero Section" style="border-radius: 12px;"></td>
    <td width="50%"><img src="assets/website-desktop.png" alt="Desktop View" style="border-radius: 12px;"></td>
  </tr>
  <tr>
    <td align="center"><em>Hero Section — Bento Grid Layout</em></td>
    <td align="center"><em>Full Desktop Viewport</em></td>
  </tr>
  <tr>
    <td width="50%"><img src="assets/website-fullpage.png" alt="Full Page" style="border-radius: 12px;"></td>
    <td width="50%"><img src="assets/website-mobile.png" alt="Mobile View" style="border-radius: 12px;"></td>
  </tr>
  <tr>
    <td align="center"><em>Full Page — All Sections</em></td>
    <td align="center"><em>Mobile Viewport</em></td>
  </tr>
</table>

### Mobile App

<table>
  <tr>
    <td width="20%"><img src="assets/App-Home.png" alt="App Home" style="border-radius: 12px; width: 100%;"></td>
    <td width="20%"><img src="assets/App-Markets.png" alt="App Markets" style="border-radius: 12px; width: 100%;"></td>
    <td width="20%"><img src="assets/App-AI.png" alt="App AI" style="border-radius: 12px; width: 100%;"></td>
    <td width="20%"><img src="assets/App-Portfolio.png" alt="App Portfolio" style="border-radius: 12px; width: 100%;"></td>
    <td width="20%"><img src="assets/App-News.png" alt="App News" style="border-radius: 12px; width: 100%;"></td>
  </tr>
  <tr>
    <td align="center"><em>Home</em></td>
    <td align="center"><em>Markets</em></td>
    <td align="center"><em>AI Chat</em></td>
    <td align="center"><em>Portfolio</em></td>
    <td align="center"><em>News</em></td>
  </tr>
</table>

### Logo

<p align="center">
  <img src="assets/logo-horizontal.png" alt="FinSwitch Logo" height="60">
  <br>
  <img src="assets/logo-icon.png" alt="FinSwitch Icon" height="80" style="margin: 10px;">
  <img src="assets/app-icon.png" alt="FinSwitch App Icon" height="80" style="margin: 10px; border-radius: 16px;">
</p>

---

## ✦ Project Structure

```
finswitch/
├── branding/              # Logo, brand guidelines, favicon
├── website/               # Premium landing page (HTML/CSS/JS)
│   ├── index.html         # Main landing page
│   ├── css/               # Design system + page styles
│   ├── js/                # Animations, interactions
│   └── assets/            # Logo, favicon
├── backend/               # FastAPI backend
│   ├── app/
│   │   ├── api/v1/        # REST API routes (auth, markets, portfolio, AI...)
│   │   ├── core/           # Config, security, database
│   │   ├── models/         # SQLAlchemy ORM models
│   │   ├── schemas/        # Pydantic request/response schemas
│   │   ├── services/       # Business logic
│   │   └── workers/        # Celery background tasks
│   ├── database/           # PostgreSQL schema
│   ├── Dockerfile
│   └── docker-compose.yml
├── flutter_app/            # Mobile app (iOS + Android)
│   └── lib/
│       ├── app/            # App shell, theme, navigation
│       ├── core/           # Networking, storage, constants
│       └── features/       # Feature modules
├── admin/                  # Admin dashboard
├── API.md                  # API documentation
├── ARCHITECTURE.md         # Architecture overview
├── DEPLOYMENT.md           # Deployment strategy
├── PERSONAS.md             # User personas
└── ROADMAP.md              # Development roadmap
```

---

## ✦ Quick Start

### Backend
```bash
cd backend
cp .env.example .env
docker-compose up
# API available at http://localhost:8000
# Docs at http://localhost:8000/api/docs
```

### Flutter App
```bash
cd flutter_app
flutter pub get
flutter run
```

### Website
```bash
cd website
python3 -m http.server 3000
# Open http://localhost:3000
```

---

## ✦ API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/register` | Create account |
| POST | `/api/v1/auth/login` | Sign in |
| GET | `/api/v1/markets/indices` | Nifty, Sensex, Bank Nifty |
| GET | `/api/v1/markets/stocks` | Stock screener with filters |
| GET | `/api/v1/markets/gainers` | Top gainers |
| GET | `/api/v1/markets/losers` | Top losers |
| GET | `/api/v1/portfolio/summary` | Portfolio overview |
| GET | `/api/v1/portfolio/holdings` | Portfolio holdings |
| POST | `/api/v1/ai/chat` | AI Copilot chat |
| GET | `/api/v1/news` | Financial news feed |
| POST | `/api/v1/sip/calculate` | SIP calculator |

Full documentation: [API.md](API.md)

---

## ✦ Roadmap

- **Phase 1** ✅ Core Platform — Market data, portfolio, AI chat, news
- **Phase 2** 🔄 Advanced Analytics — Stock screener, technical indicators, comparisons
- **Phase 3** 📅 Learning Platform — Courses, quizzes, certificates
- **Phase 4** 📅 Advanced AI — Predictive analytics, sentiment analysis
- **Phase 5** 📅 Ecosystem — International markets, premium tiers

See [ROADMAP.md](ROADMAP.md) for details.

---

## ✦ Design System

| Token | Value |
|-------|-------|
| Primary | `#2563EB` — Royal Blue |
| Success | `#10B981` — Emerald |
| Danger | `#EF4444` — Red |
| Background | `#0B1220` — Deep Navy |
| Card | `#131D2E` — Elevated Surface |
| Accent | `#38BDF8` — Sky Blue |
| Text | `#F8FAFC` — Off White |
| Font Headings | SF Pro Display (system) |
| Font Body | `Inter` |
| Font Numbers | `JetBrains Mono` |
| Card Radius | `20px` |
| Button Radius | `14px` |

Modern minimal FinTech design: 40% Apple, 25% CRED, 20% TradingView, 10% Linear, 5% Glassmorphism. Bento Grid layout on web. Card-based on mobile. Dark first.

---

## ✦ Security

- 🔒 JWT authentication with refresh tokens
- 🛡️ Password hashing with bcrypt
- 🔐 HTTPS enforced everywhere
- 📋 Audit logging for sensitive actions
- 🚦 Rate limiting on API endpoints
- ✅ OWASP best practices

---

## ✦ License

MIT License — see [LICENSE](LICENSE) for details.

---

<div align="center">
  <p>Built with ❤️ for smarter investing in India</p>
  <p>
    <a href="https://github.com/OK45batwal/FINSWITCH">GitHub</a> ·
    <a href="website/index.html">Live Demo</a> ·
    <a href="API.md">API Docs</a>
  </p>
</div>
