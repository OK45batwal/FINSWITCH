# FinSwitch Infrastructure

## Services

| Service | Responsibility |
| --- | --- |
| Cloudflare Pages | Hosts the Next.js static export and Pages Functions. |
| Supabase | PostgreSQL, authentication, row-level security, and real-time data. |
| Flutter | Native mobile client. |

## Data Flow

The web and Flutter clients read market, portfolio, watchlist, and news data from Supabase. Both call the Cloudflare Pages Function at `/api/ai` for AI responses.

## Deployment

Deploy the website to Cloudflare Pages and apply `supabase/schema.sql` and `supabase/seed.sql` through Supabase. The Flutter app is built with `scripts/build-apk.sh`.
