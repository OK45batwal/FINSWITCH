-- ====================================================================
-- FinSwitch — Complete Supabase PostgreSQL Schema & RLS Policies
-- ====================================================================

-- 1. Enable Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. PROFILES TABLE (Tied to auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  avatar_url TEXT,
  phone TEXT,
  preferences JSONB DEFAULT '{"theme":"dark","language":"en","currency":"INR"}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. STOCKS TABLE
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
  description TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. INDICES TABLE
CREATE TABLE IF NOT EXISTS public.indices (
  symbol TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  price NUMERIC(12,2) NOT NULL,
  change NUMERIC(12,2) NOT NULL,
  change_percent NUMERIC(6,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. PORTFOLIOS TABLE
CREATE TABLE IF NOT EXISTS public.portfolios (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  current_value NUMERIC(14,2) DEFAULT 0,
  total_invested NUMERIC(14,2) DEFAULT 0,
  total_returns NUMERIC(14,2) DEFAULT 0,
  returns_percent NUMERIC(6,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. HOLDINGS TABLE
CREATE TABLE IF NOT EXISTS public.holdings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  portfolio_id UUID NOT NULL REFERENCES public.portfolios(id) ON DELETE CASCADE,
  symbol TEXT NOT NULL REFERENCES public.stocks(symbol),
  quantity INT NOT NULL CHECK (quantity > 0),
  avg_price NUMERIC(12,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. WATCHLIST ITEMS
CREATE TABLE IF NOT EXISTS public.watchlist_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  symbol TEXT NOT NULL REFERENCES public.stocks(symbol),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, symbol)
);

-- 8. NEWS ARTICLES
CREATE TABLE IF NOT EXISTS public.news_articles (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  summary TEXT,
  source TEXT,
  url TEXT,
  published_at TIMESTAMPTZ DEFAULT NOW(),
  symbols TEXT[] DEFAULT '{}'
);

-- 9. ROW LEVEL SECURITY (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.indices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.holdings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.watchlist_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.news_articles ENABLE ROW LEVEL SECURITY;

-- Public Read Access Policies
CREATE POLICY "Public read access for stocks" ON public.stocks FOR SELECT USING (true);
CREATE POLICY "Public read access for indices" ON public.indices FOR SELECT USING (true);
CREATE POLICY "Public read access for news" ON public.news_articles FOR SELECT USING (true);

-- User-level Private Policies
CREATE POLICY "Users can view and update own profile" ON public.profiles FOR ALL USING (auth.uid() = id);
CREATE POLICY "Users can manage own portfolio" ON public.portfolios FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own holdings" ON public.holdings FOR ALL USING (
  portfolio_id IN (SELECT id FROM public.portfolios WHERE user_id = auth.uid())
);
CREATE POLICY "Users can manage own watchlist" ON public.watchlist_items FOR ALL USING (auth.uid() = user_id);

-- Auto-create profile trigger on new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name)
  VALUES (new.id, new.raw_user_meta_data->>'display_name');
  
  INSERT INTO public.portfolios (user_id, current_value, total_invested, total_returns, returns_percent)
  VALUES (new.id, 0, 0, 0, 0);

  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
