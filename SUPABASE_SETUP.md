# FinSwitch — Supabase Setup & Migration Guide

---

## ⚡ Overview

FinSwitch relies on **Supabase** as its primary cloud backend for Database (PostgreSQL), Authentication, Row-Level Security (RLS), and Real-time data.

---

## 🚀 1. Create Supabase Project

1. Go to [https://supabase.com](https://supabase.com) and sign in.
2. Click **New Project**, enter project name `finswitch`, and select region (e.g. `ap-south-1` Mumbai).
3. Save your database password securely.
4. Once provisioned, note down your **Project URL** and **anon / public key** from **Project Settings → API**.

---

## 🗄️ 2. Apply Database Schema & Seed Data

Navigate to **SQL Editor** in the Supabase Dashboard, or connect via CLI/psql, and execute:

```sql
-- 1. Apply Schema
-- Run supabase/schema.sql:
```

### Schema & RLS SQL

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- PROFILES (Linked to Supabase Auth)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  avatar_url TEXT,
  phone TEXT,
  preferences JSONB DEFAULT '{"theme":"dark","language":"en","currency":"INR"}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- STOCKS TABLE
CREATE TABLE IF NOT EXISTS public.stocks (
  symbol TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  sector TEXT NOT NULL,
  price NUMERIC(12,2) NOT NULL,
  change NUMERIC(12,2) NOT NULL,
  change_percent NUMERIC(6,2) NOT NULL,
  volume BIGINT NOT NULL DEFAULT 0,
  pe_ratio NUMERIC(6,2),
  high_52w NUMERIC(12,2),
  low_52w NUMERIC(12,2),
  market_cap NUMERIC(18,2),
  dividend_yield NUMERIC(6,2) DEFAULT 0,
  avg_volume BIGINT DEFAULT 0,
  industry TEXT DEFAULT '',
  description TEXT DEFAULT ''
);

-- INDICES TABLE
CREATE TABLE IF NOT EXISTS public.indices (
  symbol TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  price NUMERIC(12,2) NOT NULL,
  change NUMERIC(12,2) NOT NULL,
  change_percent NUMERIC(6,2) NOT NULL
);

-- PORTFOLIOS TABLE
CREATE TABLE IF NOT EXISTS public.portfolios (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  current_value NUMERIC(14,2) DEFAULT 0,
  total_invested NUMERIC(14,2) DEFAULT 0,
  total_returns NUMERIC(14,2) DEFAULT 0,
  returns_percent NUMERIC(6,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- HOLDINGS TABLE
CREATE TABLE IF NOT EXISTS public.holdings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  portfolio_id UUID NOT NULL REFERENCES public.portfolios(id) ON DELETE CASCADE,
  symbol TEXT NOT NULL REFERENCES public.stocks(symbol),
  quantity INT NOT NULL CHECK (quantity > 0),
  avg_price NUMERIC(12,2) NOT NULL
);

-- WATCHLIST ITEMS
CREATE TABLE IF NOT EXISTS public.watchlist_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  symbol TEXT NOT NULL REFERENCES public.stocks(symbol),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, symbol)
);

-- NEWS ARTICLES
CREATE TABLE IF NOT EXISTS public.news_articles (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  summary TEXT,
  source TEXT,
  url TEXT,
  published_at TIMESTAMPTZ DEFAULT NOW(),
  symbols TEXT[] DEFAULT '{}'
);

-- ROW LEVEL SECURITY (RLS) POLICIES
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.holdings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.watchlist_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read on stocks" ON public.stocks FOR SELECT USING (true);
CREATE POLICY "Allow public read on indices" ON public.indices FOR SELECT USING (true);
CREATE POLICY "Allow public read on news" ON public.news_articles FOR SELECT USING (true);

CREATE POLICY "Users access own profile" ON public.profiles FOR ALL USING (auth.uid() = id);
CREATE POLICY "Users access own portfolio" ON public.portfolios FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users access own holdings" ON public.holdings FOR ALL USING (
  portfolio_id IN (SELECT id FROM public.portfolios WHERE user_id = auth.uid())
);
CREATE POLICY "Users access own watchlist" ON public.watchlist_items FOR ALL USING (auth.uid() = user_id);
```

---

## 🔑 3. Environment Variables

### Website (Next.js / Cloudflare Pages)

Add to `.env.local` and Cloudflare Pages Dashboard environment variables:

```bash
NEXT_PUBLIC_SUPABASE_URL=https://<your-project-ref>.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
```

### Mobile App (Flutter)

Pass via `--dart-define` at build time or configure default in `lib/core/supabase_service.dart`:

```bash
flutter run --dart-define=SUPABASE_URL=https://<your-project-ref>.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJ...
```

---

## 🔑 4. Authentication Configuration

1. In Supabase Dashboard, go to **Authentication → Providers**.
2. Enable **Email** authentication.
3. Enable **Google OAuth** if desired by adding Client ID and Secret from Google Cloud Console.
4. Set Redirect URL to `https://finswitch.pages.dev/auth/callback`.

---

## ✅ 5. Verification

1. Test user sign-up in Next.js web app at `/login`.
2. Verify portfolio & watchlist items created in Supabase Dashboard.
3. Verify RLS restricts users from seeing other users' portfolios.
