# FinSwitch 2.0 — Upgrade Plan

## Guiding Principles
- Performance > features. Every addition must meet a real investor need.
- Backward compatible. No breaking changes to existing screens or data.
- Ship iteratively. Each wave is independently deployable.

---

## Wave 1 — Foundation Cleanup

### 1.1 Delete dead code (ponytail audit items)
- Remove 218-line `ai.js` mock data — Supabase is the source of truth
- Remove `BrandLogoHeader` custom painter — use existing `logo.svg` asset
- Replace `cardOf`/`mutedOf`/`textOf`/`bgOf`/`borderOf` theme helpers with built-in `Theme.of(context).colorScheme`
- Fix Profile screen hardcoded `v1.0.0` → use `package_info_plus`
- Remove dead router route (`/dashboard` in `_skip()`)
- Fix MarketsScreen query params that Api.get() silently ignores

### 1.2 Backend consolidation
- Create a single shared API layer (`website/src/lib/api.ts` becomes the canonical client)
- Flutter removes its `api.dart` duplicate, calls the same Cloudflare Function endpoints
- Supabase credentials already embedded — no env var dance

### 1.3 Schema expansions
- Add tables: `user_preferences`, `ai_conversations`, `ai_bookmarks`, `portfolio_snapshots`, `market_events`
- Add indexes on `user_id`, `symbol`, `published_at`
- Seed reference data (sectors, indices)

---

## Wave 2 — UI/UX 2.0

### 2.1 Design system
- Define design tokens (spacing, radius, colors, typography scale) in one place
- Unify Flutter theme + website Tailwind tokens from same source
- Add motion system: standard easing curves, transition durations
- WCAG AA contrast audit on all color pairs

### 2.2 Dashboard overhaul
- Personalized greeting + AI Daily Brief (pull from last AI conversation)
- Portfolio snapshot card (reuse existing `_PortfolioOverview`)
- Market movers bar (top 3 gainers/losers by sector)
- Modular layout — each section is a self-contained widget
- Skeleton loaders for each section during fetch

### 2.3 Better states
- Empty states with illustration + CTA for: no portfolio, no watchlist, no news
- Error states with retry button
- Pull-to-refresh on all list screens (already done on some)
- Smooth page transitions (already have _slidePage — keep and polish)

---

## Wave 3 — AI Copilot 2.0

### 3.1 Conversation history
- New `ai_conversations` table: user_id, messages (JSON array), created_at, updated_at
- Load last N messages on screen open
- Save on each exchange (debounced, not every keystroke)

### 3.2 AI features
- Stock explainer (already works via `analyzeStock`)
- Company comparison (already works via `compareStocks`)
- Portfolio health review (already works via `portfolioAnalysis`)
- Bookmark AI responses (new `ai_bookmarks` table)
- Never give guaranteed investment advice — already in prompts

### 3.3 Daily market recap
- Cron-style trigger (Cloudflare Cron + Function): fetch market data, generate AI summary, store in `market_events` table
- Shown on dashboard as "AI Daily Brief"

---

## Wave 4 — Learning Hub

### 4.1 Content model
- New tables: `courses`, `lessons`, `quiz_questions`, `user_progress`
- Course: title, description, difficulty, estimated_minutes, thumbnail
- Lesson: course_id, title, content (markdown), order, video_url (nullable)
- Quiz: lesson_id, question, options (JSON), correct_index

### 4.2 Learning screens
- Course listing page (grid of cards with progress ring)
- Lesson reader (markdown renderer + optional video embed)
- Quiz screen (single-select, instant feedback)
- Progress tracking (lessons completed, score per course)

### 4.3 AI Tutor
- Chat context includes user's current course/lesson
- "Explain this like I'm 5" mode for any investing concept
- Uses existing `/api/ai` endpoint with additional context

---

## Wave 5 — Market Intelligence

### 5.1 Stock screener
- Filters: sector, price range, P/E range, market cap, dividend yield
- Sortable results table (website: real HTML table, Flutter: DataTable)
- Saved screener queries (optional, depends on adoption)

### 5.2 Company comparison tool
- Select 2–4 stocks, side-by-side metrics
- Reuses existing `compareStocks` logic from ai.js
- Visual: radar chart for multi-metric comparison

### 5.3 Financial data
- Sector heatmap (Flutter: grid of colored boxes showing sector perf %)
- Earnings calendar from `market_events` table
- Analyst consensus (manual entry via admin panel)

---

## Wave 6 — Portfolio 2.0

### 6.1 Analytics
- Diversification score (HHI-based: sum of squared allocation %s)
- Sector allocation pie chart (already partially in portfolioAnalysis)
- Performance timeline (line chart of portfolio value over time)
- Benchmark comparison (vs Nifty 50)

### 6.2 Goals
- New `financial_goals` table: user_id, name, target_amount, current_amount, target_date
- Goal progress card on dashboard
- SIP recommendation: monthly amount needed to hit target

---

## Wave 7 — Calculators Suite

- SIP: monthly investment → future value
- EMI: loan amount → monthly payment
- FD: principal → maturity amount
- SWP: withdrawal → portfolio longevity
- All visualized with `fl_chart` line charts
- One shared calculator component pattern: input fields → compute → chart

---

## Wave 8 — Admin Panel

- Analytics dashboard (user count, AI usage, portfolio creation rate)
- News CMS (CRUD news_articles)
- Learning CMS (CRUD courses, lessons)
- Feature flags table + toggle UI
- Audit logs table (read-only)

---

## Wave 9 — Security & Performance

### 9.1 Security
- API rate limiting (Cloudflare Functions throttle per IP)
- Device management (store device_id on login, list in profile)
- Audit logging on write operations
- Input validation on all API endpoints

### 9.2 Performance
- Lazy load screens below the fold
- Paginate stock list (already partially done)
- Cache Supabase responses (SWR pattern on web, cached_with_notification on Flutter)
- Optimize images (next/image already handles web)
- Flutter: `ImageCache` + precache key assets

---

## Wave 10 — Testing & Launch

- Unit tests: `flutter test` for services, `jest` for website lib
- Widget tests for critical screens (auth, home, portfolio)
- E2E: manual checklist for: sign up → onboarding → AI chat → portfolio → watchlist → update
- Dark mode regression on all screens
- Test on: Android 12+, Chrome, Safari, Firefox

---

## Non-Goals (explicitly deferred)
- Push notifications (requires Firebase Cloud Messaging setup)
- Premium subscriptions (architect for future only)
- International markets (India-only remains scope)
- Real broker integration (FinSwitch is not a brokerage)
- Multi-language (English-only)
- MFA (prepare but don't ship)

---

## Success Criteria

| Metric | Current | Target |
|--------|---------|--------|
| Flutter app startup time | ~3s | <1.5s |
| Screens with skeleton loaders | 0 | 5+ |
| Screens with empty states | 0 | 5+ |
| AI features | 5 | 10+ |
| Learning content | 0 | 5 courses |
| Calculator types | 0 | 5+ |
| Admin panel | none | functional |
