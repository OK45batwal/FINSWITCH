# 🚀 FINSWITCH — Improvement List

28 actionable improvements across 7 categories, ranked by impact within each section.

---

## 🔴 Security (Fix First)

| # | Issue | Details | Effort |
|---|-------|---------|--------|
| 1 | **Supabase anon key hardcoded in 3 places** | The same JWT is baked into [supabase_service.dart](file:///Users/omkar/FINSWITCH/flutter_app/lib/core/supabase_service.dart#L5), [supabase.ts](file:///Users/omkar/FINSWITCH/website/src/lib/supabase.ts#L4), and [deploy-website.yml](file:///Users/omkar/FINSWITCH/.github/workflows/deploy-website.yml#L33). Anon keys are *meant* to be public, but having them copy-pasted everywhere makes rotation painful. Centralize into env vars / GitHub Secrets only. | 🟢 Small |
| 2 | **`.env` file committed to git** | [backend/.env](file:///Users/omkar/FINSWITCH/backend/.env) contains `SECRET_KEY` and is tracked in git. `.gitignore` has `.env` at root but `backend/.env` still slips through because it matches differently. Add `**/.env` to gitignore and remove from tracking. | 🟢 Small |
| 3 | **`SECRET_KEY` is a weak dev string in prod config** | [config.py](file:///Users/omkar/FINSWITCH/backend/app/core/config.py#L6) defaults to `"dev-secret-key-change-in-prod"` — if the env var isn't set in production, this default is used. Crash on startup if `SECRET_KEY` is the default and `DEBUG=False`. | 🟢 Small |
| 4 | **CORS allows `*` by default** | [config.py](file:///Users/omkar/FINSWITCH/backend/app/core/config.py#L8) — fine for dev, but production should restrict origins. | 🟢 Small |
| 5 | **OTP hardcoded to `123456`** | Both [create_account_screen.dart](file:///Users/omkar/FINSWITCH/flutter_app/lib/features/auth/presentation/create_account_screen.dart#L77) and [login/page.tsx](file:///Users/omkar/FINSWITCH/website/src/app/login/page.tsx#L47) accept `123456` as a bypass. Add a `DEV_MODE` flag to disable this in production builds. | 🟡 Medium |

---

## 🏗️ Architecture

| # | Issue | Details | Effort |
|---|-------|---------|--------|
| 6 | **Stock data duplicated 4× across the codebase** | Identical stock/index data lives in Flutter [api.dart](file:///Users/omkar/FINSWITCH/flutter_app/lib/core/api.dart#L211) (mock), Python [local_ai.py](file:///Users/omkar/FINSWITCH/backend/app/services/local_ai.py#L5), JS [ai.js](file:///Users/omkar/FINSWITCH/website/functions/api/ai.js#L2), and SQL [seed.sql](file:///Users/omkar/FINSWITCH/supabase/seed.sql). Make Supabase the single source; generate a `stocks.json` asset for offline fallback. | 🟡 Medium |
| 7 | **`_useLocal` flag is sticky — one timeout permanently disables the backend** | [api.dart L37](file:///Users/omkar/FINSWITCH/flutter_app/lib/core/api.dart#L37) sets `_useLocal = true` on any error and never resets it. Add a retry timer (e.g., retry backend after 30 seconds) so a transient network blip doesn't kill the API layer for the session. | 🟢 Small |
| 8 | **No state management** | The Flutter app uses raw `ValueNotifier` and `setState`. This works now, but adding features like real-time price updates or multi-screen portfolio sync will get messy. Consider adopting Riverpod or Provider. | 🔴 Large |
| 9 | **Backend and Flutter have no shared contract** | API responses are untyped `dynamic` maps throughout. A mismatched key silently returns `null`. Consider generating Dart models from the Supabase schema or a shared OpenAPI spec. | 🟡 Medium |

---

## 💻 Code Quality

| # | Issue | Details | Effort |
|---|-------|---------|--------|
| 10 | **Every `catch` block swallows errors silently** | All of [api.dart](file:///Users/omkar/FINSWITCH/flutter_app/lib/core/api.dart), [supabase_service.dart](file:///Users/omkar/FINSWITCH/flutter_app/lib/core/supabase_service.dart), [home_screen.dart](file:///Users/omkar/FINSWITCH/flutter_app/lib/features/home/presentation/home_screen.dart#L46) use `catch (_) {}`. Add at minimum `debugPrint` logging or a crash-reporting service so failures aren't invisible. | 🟢 Small |
| 11 | **No tests at all** | Zero unit tests, zero widget tests, zero backend tests. At minimum add: API response parsing tests, auth flow tests, backend endpoint smoke tests. | 🟡 Medium |
| 12 | **`website/src/lib/utils.ts` formats in USD but app is INR-only** | [formatCurrency](file:///Users/omkar/FINSWITCH/website/src/lib/utils.ts#L1) uses `$` prefix. Should use `₹` or `Intl.NumberFormat('en-IN', {currency: 'INR'})`. | 🟢 Small |
| 13 | **Quick action buttons are no-ops** | [home_screen.dart L173](file:///Users/omkar/FINSWITCH/flutter_app/lib/features/home/presentation/home_screen.dart#L173) — "Invest", "SIP", "Sell", "History" buttons have `onPressed: () {}`. Either wire them up or remove them to avoid confusing users. | 🟢 Small |

---

## 🐍 Backend

| # | Issue | Details | Effort |
|---|-------|---------|--------|
| 14 | **Backend doesn't connect to Supabase at all** | The Python backend serves only hardcoded mock data from [local_ai.py](file:///Users/omkar/FINSWITCH/backend/app/services/local_ai.py). It could be replaced entirely by Supabase Edge Functions + the existing Cloudflare Pages Function. Evaluate if the Python backend is needed. | 🟡 Medium |
| 15 | **AI is keyword matching, not actual AI** | [local_ai.py](file:///Users/omkar/FINSWITCH/backend/app/services/local_ai.py#L252) and [ai.js](file:///Users/omkar/FINSWITCH/website/functions/api/ai.js#L160) use simple `if msg.contains("reliance")` pattern matching. Consider integrating a real LLM (Gemini API, OpenAI) with your stock data as context for genuinely useful analysis. | 🔴 Large |
| 16 | **RSI calculation uses random numbers** | [local_ai.py L37](file:///Users/omkar/FINSWITCH/backend/app/services/local_ai.py#L37) — `random.uniform()` for RSI/SMA means every request gives different "technical analysis." Use real historical price data or remove the indicator entirely. | 🟡 Medium |
| 17 | **`math` module imported but never used** | [local_ai.py L1](file:///Users/omkar/FINSWITCH/backend/app/services/local_ai.py#L1) — `import math` is unused. | 🟢 Small |

---

## 📱 Flutter App

| # | Issue | Details | Effort |
|---|-------|---------|--------|
| 18 | **No pull-to-refresh on Markets, News, Portfolio screens** | Only [HomeScreen](file:///Users/omkar/FINSWITCH/flutter_app/lib/features/home/presentation/home_screen.dart#L76) has `RefreshIndicator`. All data screens should support pull-to-refresh. | 🟢 Small |
| 19 | **No loading/error states on detail screens** | Screens jump straight from loading spinner to content with no empty-state or error UI. Add skeleton loaders and "retry" error states. | 🟡 Medium |
| 20 | **App always shows positive P&L (hardcoded `+` prefix)** | [home_screen.dart L152](file:///Users/omkar/FINSWITCH/flutter_app/lib/features/home/presentation/home_screen.dart#L152) hardcodes `+` — will look wrong if portfolio is down. Use conditional formatting. | 🟢 Small |
| 21 | **No deep linking / share support** | Stock detail pages (`/stock/:symbol`) are app-internal only. Add Android intent filters so users can share stock URLs. | 🟡 Medium |
| 22 | **`app_update_service.dart` has hardcoded changelog** | [Lines 90-91](file:///Users/omkar/FINSWITCH/flutter_app/lib/core/app_update_service.dart#L90) — "Performance improvements", "Supabase real-time sync", "AI Copilot enhancements" are static strings. Fetch changelog from GitHub Releases API instead. | 🟢 Small |

---

## 🌐 Website

| # | Issue | Details | Effort |
|---|-------|---------|--------|
| 23 | **No `<meta>` description or OG tags on any page** | [layout.tsx](file:///Users/omkar/FINSWITCH/website/src/app/layout.tsx) and [page.tsx](file:///Users/omkar/FINSWITCH/website/src/app/page.tsx) have no SEO metadata. Add `metadata` exports with title, description, and Open Graph tags. | 🟢 Small |
| 24 | **Dashboard has no auth guard** | Anyone can visit `/dashboard` without logging in. The login page is skippable and there's no session check on dashboard routes. | 🟡 Medium |
| 25 | **Landing page claims "100+ Stocks Tracked"** | [page.tsx L30](file:///Users/omkar/FINSWITCH/website/src/app/page.tsx#L30) — actual stock count is 12. Either add more stocks to the database or change the copy. | 🟢 Small |

---

## ⚙️ DevOps & Infrastructure

| # | Issue | Details | Effort |
|---|-------|---------|--------|
| 26 | **No `.env.local` in `.gitignore` for website** | [website/.env.local](file:///Users/omkar/FINSWITCH/website/.env.local) with Supabase keys is tracked. Add to gitignore. | 🟢 Small |
| 27 | **GitHub Actions don't run linting or tests** | All 3 workflows ([build-flutter.yml](file:///Users/omkar/FINSWITCH/.github/workflows/build-flutter.yml), [deploy-backend.yml](file:///Users/omkar/FINSWITCH/.github/workflows/deploy-backend.yml), [deploy-website.yml](file:///Users/omkar/FINSWITCH/.github/workflows/deploy-website.yml)) skip `flutter analyze`, `pytest`, and `eslint`. Add lint/test steps before deploy. | 🟡 Medium |
| 28 | **No staging/preview environment** | Pushes to `master` deploy directly to production. Add a branch-based preview (Cloudflare branch deploys, Render preview environments). | 🟡 Medium |

---

## Summary by priority

| Priority | Count | Items |
|----------|-------|-------|
| 🔴 **Fix now** (security) | 5 | #1–5 |
| 🟠 **High impact** | 8 | #6, 7, 10, 12, 13, 17, 25, 26 |
| 🟡 **Medium effort, big payoff** | 10 | #8, 9, 11, 14, 15, 16, 19, 21, 24, 27, 28 |
| 🟢 **Nice to have** | 5 | #18, 20, 22, 23 |
