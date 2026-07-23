-- FinSwitch 2.0 Wave 1 Schema Expansion Migration

-- 1. user_preferences
CREATE TABLE IF NOT EXISTS public.user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
    theme TEXT DEFAULT 'dark' CHECK (theme IN ('light', 'dark', 'system')),
    currency TEXT DEFAULT 'INR',
    notifications_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. ai_conversations
CREATE TABLE IF NOT EXISTS public.ai_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT,
    messages JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3. ai_bookmarks
CREATE TABLE IF NOT EXISTS public.ai_bookmarks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    symbol TEXT NOT NULL,
    note TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    CONSTRAINT unique_user_symbol_bookmark UNIQUE (user_id, symbol)
);

-- 4. portfolio_snapshots
CREATE TABLE IF NOT EXISTS public.portfolio_snapshots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    portfolio_id UUID REFERENCES public.portfolios(id) ON DELETE CASCADE,
    total_value NUMERIC NOT NULL DEFAULT 0,
    total_invested NUMERIC NOT NULL DEFAULT 0,
    total_returns NUMERIC NOT NULL DEFAULT 0,
    returns_percent NUMERIC NOT NULL DEFAULT 0,
    snapshot_date DATE DEFAULT current_date,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. market_events
CREATE TABLE IF NOT EXISTS public.market_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    category TEXT,
    event_date TIMESTAMPTZ NOT NULL,
    symbol TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- --- INDEXES ---
CREATE INDEX IF NOT EXISTS idx_user_preferences_user_id ON public.user_preferences(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_conversations_user_id ON public.ai_conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_bookmarks_user_id_symbol ON public.ai_bookmarks(user_id, symbol);
CREATE INDEX IF NOT EXISTS idx_portfolio_snapshots_user_id ON public.portfolio_snapshots(user_id);
CREATE INDEX IF NOT EXISTS idx_market_events_symbol ON public.market_events(symbol);
CREATE INDEX IF NOT EXISTS idx_news_articles_published_at ON public.news_articles(published_at DESC);
CREATE INDEX IF NOT EXISTS idx_stocks_symbol ON public.stocks(symbol);
CREATE INDEX IF NOT EXISTS idx_holdings_portfolio_id ON public.holdings(portfolio_id);

-- --- ROW LEVEL SECURITY (RLS) ---
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolio_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.market_events ENABLE ROW LEVEL SECURITY;

-- User Preferences RLS Policies
CREATE POLICY "Users can view own preferences" ON public.user_preferences FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own preferences" ON public.user_preferences FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own preferences" ON public.user_preferences FOR UPDATE USING (auth.uid() = user_id);

-- AI Conversations RLS Policies
CREATE POLICY "Users can view own AI conversations" ON public.ai_conversations FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own AI conversations" ON public.ai_conversations FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own AI conversations" ON public.ai_conversations FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own AI conversations" ON public.ai_conversations FOR DELETE USING (auth.uid() = user_id);

-- AI Bookmarks RLS Policies
CREATE POLICY "Users can view own AI bookmarks" ON public.ai_bookmarks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own AI bookmarks" ON public.ai_bookmarks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own AI bookmarks" ON public.ai_bookmarks FOR DELETE USING (auth.uid() = user_id);

-- Portfolio Snapshots RLS Policies
CREATE POLICY "Users can view own portfolio snapshots" ON public.portfolio_snapshots FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own portfolio snapshots" ON public.portfolio_snapshots FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Market Events RLS Policies (Public Read)
CREATE POLICY "Anyone can view market events" ON public.market_events FOR SELECT USING (true);

-- --- REFERENCE SEED DATA ---
INSERT INTO public.market_events (title, description, category, event_date, symbol) VALUES
('RBI Monetary Policy Meeting', 'Reserve Bank of India Monetary Policy Committee rate decision meeting.', 'Central Bank', NOW() + INTERVAL '5 days', 'BANKNIFTY'),
('Reliance Industries Q3 Earnings Release', 'Quarterly financial earnings report publication.', 'Earnings', NOW() + INTERVAL '2 days', 'RELIANCE'),
('TCS Annual Shareholder Meeting', 'Annual general meeting and strategic growth update.', 'Corporate Action', NOW() + INTERVAL '10 days', 'TCS')
ON CONFLICT DO NOTHING;
