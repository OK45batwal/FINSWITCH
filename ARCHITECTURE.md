# FinSwitch Architecture

## System

```text
Flutter app ─┬─ Supabase (auth and data)
             └─ Cloudflare Pages Function (AI)

Next.js site ┬─ Supabase (auth and data)
             └─ Cloudflare Pages Function (AI)
```

The website is deployed to Cloudflare Pages. Supabase provides PostgreSQL, authentication, and row-level security. The Pages Function at `/api/ai` serves AI requests for both clients.

## Repository

```text
flutter_app/  Flutter client
website/      Next.js site and Pages Functions
supabase/     Database schema and seed data
```
