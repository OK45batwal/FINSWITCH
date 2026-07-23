# FinSwitch — Web App

Next.js 16 frontend for FinSwitch, deployed on Cloudflare Pages.

## Development

```bash
npm install
npm run dev     # → http://localhost:3000
```

## Deployment

Pushes to `master` auto-deploy via Cloudflare Pages.

## Pages

| Route | Description |
|-------|-------------|
| `/` | Marketing landing page |
| `/login` | Sign in / register |
| `/dashboard` | Portfolio overview, indices, gainers/losers |
| `/dashboard/markets` | Stock screener & search |
| `/dashboard/markets/[symbol]` | Stock detail, chart, AI analysis |
| `/dashboard/watchlist` | Watchlist management |
| `/dashboard/news` | Financial news feed |
| `/dashboard/ai` | AI chat assistant |
| `/dashboard/portfolio` | Holdings & P&L |

## AI Endpoint

`functions/api/ai.js` — Cloudflare Pages Function.
Serves stock data, chat, analysis, and charts.
Zero external dependencies, fully offline-capable.
