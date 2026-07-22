-- Run this in Supabase SQL Editor
-- 1. Create tables, 2. Enable RLS, 3. Create policies

CREATE TABLE IF NOT EXISTS public.stocks (
  symbol TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  sector TEXT NOT NULL,
  industry TEXT,
  price NUMERIC(12,2) NOT NULL,
  change NUMERIC(12,2) NOT NULL DEFAULT 0,
  change_percent NUMERIC(6,2) NOT NULL DEFAULT 0,
  pe_ratio NUMERIC(6,2),
  high_52w NUMERIC(12,2),
  low_52w NUMERIC(12,2),
  market_cap NUMERIC(20,2),
  dividend_yield NUMERIC(6,2),
  volume BIGINT,
  avg_volume BIGINT,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.indices (
  symbol TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  price NUMERIC(14,2) NOT NULL,
  change NUMERIC(14,2) NOT NULL DEFAULT 0,
  change_percent NUMERIC(6,2) NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.news_articles (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  summary TEXT,
  source TEXT,
  url TEXT,
  category TEXT,
  sentiment TEXT,
  symbols TEXT[],
  published_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.portfolios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL DEFAULT 'My Portfolio',
  total_invested NUMERIC(15,2) DEFAULT 0,
  current_value NUMERIC(15,2) DEFAULT 0,
  total_returns NUMERIC(15,2) DEFAULT 0,
  returns_percent NUMERIC(6,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.holdings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  portfolio_id UUID NOT NULL REFERENCES public.portfolios(id) ON DELETE CASCADE,
  symbol TEXT NOT NULL REFERENCES public.stocks(symbol),
  quantity INTEGER NOT NULL,
  avg_price NUMERIC(12,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.watchlist_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  symbol TEXT NOT NULL REFERENCES public.stocks(symbol),
  added_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, symbol)
);

-- Enable Row Level Security
ALTER TABLE public.portfolios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.holdings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.watchlist_items ENABLE ROW LEVEL SECURITY;

-- Portfolios: users can only see their own
CREATE POLICY "portfolios_own" ON public.portfolios
  FOR ALL USING (auth.uid() = user_id);

-- Holdings: via portfolio ownership
CREATE POLICY "holdings_own" ON public.holdings
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.portfolios WHERE id = portfolio_id AND user_id = auth.uid())
  );

-- Watchlist: users own their items
CREATE POLICY "watchlist_own" ON public.watchlist_items
  FOR ALL USING (auth.uid() = user_id);

-- Indices: public read
CREATE POLICY "indices_public" ON public.indices
  FOR SELECT USING (true);

-- Stocks: public read
CREATE POLICY "stocks_public" ON public.stocks
  FOR SELECT USING (true);

-- News: public read
CREATE POLICY "news_public" ON public.news_articles
  FOR SELECT USING (true);
