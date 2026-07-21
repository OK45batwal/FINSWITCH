-- FinSwitch Database Schema
-- PostgreSQL 15+

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "citext";

-- ENUMS
CREATE TYPE user_role AS ENUM ('user', 'premium', 'admin', 'super_admin');
CREATE TYPE plan_type AS ENUM ('free', 'basic', 'pro', 'enterprise');
CREATE TYPE transaction_type AS ENUM ('buy', 'sell', 'dividend', 'bonus', 'split');
CREATE TYPE alert_type AS ENUM ('price', 'news', 'dividend', 'ipo', 'earnings', 'volatility');
CREATE TYPE alert_channel AS ENUM ('push', 'email', 'sms');
CREATE TYPE news_category AS ENUM ('markets', 'stocks', 'economy', 'ipo', 'technology', 'mutual_funds', 'government', 'global', 'commodities', 'currency');
CREATE TYPE news_sentiment AS ENUM ('positive', 'negative', 'neutral');
CREATE TYPE sip_frequency AS ENUM ('daily', 'weekly', 'monthly', 'quarterly');
CREATE TYPE ai_chat_role AS ENUM ('user', 'assistant', 'system');
CREATE TYPE notification_type AS ENUM ('alert', 'insight', 'system', 'promotion', 'update');
CREATE TYPE watchlist_item_type AS ENUM ('stock', 'mutual_fund', 'etf', 'index', 'currency', 'commodity');

-- USERS
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email CITEXT UNIQUE NOT NULL,
  phone VARCHAR(15) UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  display_name VARCHAR(100),
  avatar_url VARCHAR(500),
  role user_role DEFAULT 'user',
  plan plan_type DEFAULT 'free',
  firebase_uid VARCHAR(128) UNIQUE,
  is_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  kyc_status VARCHAR(20) DEFAULT 'pending',
  preferences JSONB DEFAULT '{"theme":"dark","language":"en","currency":"INR","notifications":true}',
  metadata JSONB DEFAULT '{}',
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- COMPANIES
CREATE TABLE companies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  symbol VARCHAR(20) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  sector VARCHAR(100),
  industry VARCHAR(100),
  description TEXT,
  logo_url VARCHAR(500),
  website VARCHAR(500),
  isin VARCHAR(20) UNIQUE,
  bse_code VARCHAR(20),
  nse_symbol VARCHAR(20),
  market_cap NUMERIC(20,2),
  face_value NUMERIC(10,2),
  listed_shares BIGINT,
  is_active BOOLEAN DEFAULT TRUE,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- STOCK PRICES (time-series)
CREATE TABLE stock_prices (
  id BIGSERIAL PRIMARY KEY,
  company_id UUID REFERENCES companies(id),
  date DATE NOT NULL,
  open NUMERIC(12,2) NOT NULL,
  high NUMERIC(12,2) NOT NULL,
  low NUMERIC(12,2) NOT NULL,
  close NUMERIC(12,2) NOT NULL,
  volume BIGINT NOT NULL,
  adjusted_close NUMERIC(12,2),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(company_id, date)
);

-- LIVE MARKET DATA
CREATE TABLE market_snapshot (
  id BIGSERIAL PRIMARY KEY,
  company_id UUID REFERENCES companies(id),
  last_price NUMERIC(12,2) NOT NULL,
  change NUMERIC(12,2) NOT NULL,
  change_percent NUMERIC(6,2) NOT NULL,
  day_high NUMERIC(12,2),
  day_low NUMERIC(12,2),
  volume BIGINT,
  bid NUMERIC(12,2),
  ask NUMERIC(12,2),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- INDICES
CREATE TABLE indices (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  symbol VARCHAR(20) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  category VARCHAR(50),
  last_value NUMERIC(14,2),
  change NUMERIC(14,2),
  change_percent NUMERIC(6,2),
  is_active BOOLEAN DEFAULT TRUE,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- FINANCIALS
CREATE TABLE financial_statements (
  id BIGSERIAL PRIMARY KEY,
  company_id UUID REFERENCES companies(id),
  period VARCHAR(10) NOT NULL,
  year INTEGER NOT NULL,
  quarter INTEGER,
  statement_type VARCHAR(20) NOT NULL CHECK (statement_type IN ('balance_sheet', 'income', 'cash_flow')),
  data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(company_id, period, year, quarter, statement_type)
);

-- FINANCIAL RATIOS
CREATE TABLE financial_ratios (
  id BIGSERIAL PRIMARY KEY,
  company_id UUID REFERENCES companies(id),
  period VARCHAR(10),
  year INTEGER,
  pe_ratio NUMERIC(10,2),
  pb_ratio NUMERIC(10,2),
  eps NUMERIC(10,2),
  roe NUMERIC(6,2),
  roa NUMERIC(6,2),
  debt_to_equity NUMERIC(8,2),
  current_ratio NUMERIC(6,2),
  dividend_yield NUMERIC(6,2),
  market_cap NUMERIC(20,2),
  enterprise_value NUMERIC(20,2),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- SHAREHOLDING
CREATE TABLE shareholding_patterns (
  id BIGSERIAL PRIMARY KEY,
  company_id UUID REFERENCES companies(id),
  quarter VARCHAR(10) NOT NULL,
  year INTEGER NOT NULL,
  promoters NUMERIC(6,2),
  fii NUMERIC(6,2),
  dii NUMERIC(6,2),
  retail NUMERIC(6,2),
  others NUMERIC(6,2),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(company_id, quarter, year)
);

-- NEWS
CREATE TABLE news_articles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title VARCHAR(500) NOT NULL,
  slug VARCHAR(500) UNIQUE NOT NULL,
  summary TEXT,
  content TEXT,
  image_url VARCHAR(500),
  source VARCHAR(200),
  source_url VARCHAR(500),
  category news_category,
  sentiment news_sentiment,
  sentiment_score NUMERIC(4,3),
  ai_summary TEXT,
  is_featured BOOLEAN DEFAULT FALSE,
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- NEWS-STOCK RELATION
CREATE TABLE news_stocks (
  news_id UUID REFERENCES news_articles(id) ON DELETE CASCADE,
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
  relevance_score NUMERIC(3,2),
  PRIMARY KEY (news_id, company_id)
);

-- PORTFOLIO
CREATE TABLE portfolios (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  is_primary BOOLEAN DEFAULT FALSE,
  total_invested NUMERIC(15,2) DEFAULT 0,
  current_value NUMERIC(15,2) DEFAULT 0,
  total_returns NUMERIC(15,2) DEFAULT 0,
  returns_percent NUMERIC(6,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- PORTFOLIO HOLDINGS
CREATE TABLE portfolio_holdings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  portfolio_id UUID REFERENCES portfolios(id) ON DELETE CASCADE,
  company_id UUID REFERENCES companies(id),
  quantity INTEGER NOT NULL,
  average_price NUMERIC(12,2) NOT NULL,
  invested_amount NUMERIC(15,2) NOT NULL,
  current_value NUMERIC(15,2),
  unrealized_pl NUMERIC(12,2),
  unrealized_pl_percent NUMERIC(6,2),
  allocation_percent NUMERIC(6,2),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TRANSACTIONS
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  portfolio_id UUID REFERENCES portfolios(id) ON DELETE CASCADE,
  company_id UUID REFERENCES companies(id),
  transaction_type transaction_type NOT NULL,
  quantity INTEGER NOT NULL,
  price NUMERIC(12,2) NOT NULL,
  total_amount NUMERIC(15,2) NOT NULL,
  brokerage NUMERIC(12,2) DEFAULT 0,
  transaction_date TIMESTAMPTZ NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- WATCHLISTS
CREATE TABLE watchlists (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(100) DEFAULT 'Default',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- WATCHLIST ITEMS
CREATE TABLE watchlist_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  watchlist_id UUID REFERENCES watchlists(id) ON DELETE CASCADE,
  item_type watchlist_item_type NOT NULL,
  company_id UUID REFERENCES companies(id),
  symbol VARCHAR(20) NOT NULL,
  notes TEXT,
  added_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(watchlist_id, symbol)
);

-- ALERTS
CREATE TABLE alerts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  company_id UUID REFERENCES companies(id),
  alert_type alert_type NOT NULL,
  channel alert_channel DEFAULT 'push',
  condition VARCHAR(50),
  threshold NUMERIC(12,2),
  is_active BOOLEAN DEFAULT TRUE,
  is_triggered BOOLEAN DEFAULT FALSE,
  triggered_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- SIP PLANS
CREATE TABLE sip_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(200) NOT NULL,
  goal_type VARCHAR(50) NOT NULL,
  target_amount NUMERIC(15,2),
  monthly_amount NUMERIC(12,2) NOT NULL,
  expected_return NUMERIC(5,2) DEFAULT 12.0,
  inflation_rate NUMERIC(5,2) DEFAULT 6.0,
  frequency sip_frequency DEFAULT 'monthly',
  start_date DATE NOT NULL,
  end_date DATE,
  current_value NUMERIC(15,2) DEFAULT 0,
  total_invested NUMERIC(15,2) DEFAULT 0,
  projected_value NUMERIC(15,2),
  status VARCHAR(20) DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- SIP ALLOCATIONS
CREATE TABLE sip_allocations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sip_id UUID REFERENCES sip_plans(id) ON DELETE CASCADE,
  company_id UUID REFERENCES companies(id),
  allocation_percent NUMERIC(5,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- AI CHATS
CREATE TABLE ai_chats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(200),
  context JSONB DEFAULT '{}',
  is_archived BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- AI MESSAGES
CREATE TABLE ai_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  chat_id UUID REFERENCES ai_chats(id) ON DELETE CASCADE,
  role ai_chat_role NOT NULL,
  content TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  tokens_used INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- CALCULATOR HISTORY
CREATE TABLE calculator_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  calc_type VARCHAR(50) NOT NULL,
  input_data JSONB NOT NULL,
  result_data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- LEARNING
CREATE TABLE courses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title VARCHAR(200) NOT NULL,
  slug VARCHAR(200) UNIQUE NOT NULL,
  description TEXT,
  category VARCHAR(50),
  difficulty VARCHAR(20),
  image_url VARCHAR(500),
  duration_minutes INTEGER,
  is_published BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- MODULES
CREATE TABLE course_modules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  title VARCHAR(200) NOT NULL,
  order_index INTEGER NOT NULL,
  content_type VARCHAR(50) DEFAULT 'article',
  content TEXT,
  video_url VARCHAR(500),
  duration_minutes INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- USER PROGRESS
CREATE TABLE user_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  module_id UUID REFERENCES course_modules(id) ON DELETE CASCADE,
  is_completed BOOLEAN DEFAULT FALSE,
  score INTEGER,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, module_id)
);

-- QUIZZES
CREATE TABLE quizzes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  module_id UUID REFERENCES course_modules(id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  options JSONB NOT NULL,
  correct_answer INTEGER NOT NULL,
  explanation TEXT,
  order_index INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- CERTIFICATES
CREATE TABLE certificates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  course_id UUID REFERENCES courses(id),
  certificate_url VARCHAR(500),
  issued_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, course_id)
);

-- NOTIFICATIONS
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  type notification_type NOT NULL,
  title VARCHAR(200) NOT NULL,
  body TEXT,
  data JSONB DEFAULT '{}',
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- USER SESSIONS
CREATE TABLE user_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  device_info JSONB,
  ip_address INET,
  user_agent TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  last_activity TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- AUDIT LOGS
CREATE TABLE audit_logs (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  action VARCHAR(100) NOT NULL,
  entity_type VARCHAR(50),
  entity_id UUID,
  old_values JSONB,
  new_values JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- API KEYS (for admin/premium)
CREATE TABLE api_keys (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(100),
  key_hash VARCHAR(255) NOT NULL,
  permissions JSONB DEFAULT '{}',
  is_active BOOLEAN DEFAULT TRUE,
  last_used_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- INDEXES
CREATE INDEX idx_stock_prices_company_date ON stock_prices(company_id, date DESC);
CREATE INDEX idx_market_snapshot_updated ON market_snapshot(updated_at);
CREATE INDEX idx_news_published ON news_articles(published_at DESC);
CREATE INDEX idx_news_category_sentiment ON news_articles(category, sentiment);
CREATE INDEX idx_portfolio_user ON portfolios(user_id);
CREATE INDEX idx_holdings_portfolio ON portfolio_holdings(portfolio_id);
CREATE INDEX idx_transactions_portfolio ON transactions(portfolio_id, transaction_date DESC);
CREATE INDEX idx_watchlist_user ON watchlists(user_id);
CREATE INDEX idx_alerts_user ON alerts(user_id, is_active);
CREATE INDEX idx_sip_user ON sip_plans(user_id, status);
CREATE INDEX idx_ai_chats_user ON ai_chats(user_id, updated_at DESC);
CREATE INDEX idx_ai_messages_chat ON ai_messages(chat_id, created_at);
CREATE INDEX idx_notifications_user ON notifications(user_id, is_read, created_at DESC);
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id, created_at DESC);
CREATE INDEX idx_audit_logs_action ON audit_logs(action, created_at DESC);
CREATE INDEX idx_user_sessions_user ON user_sessions(user_id, is_active);
CREATE INDEX idx_financials_company ON financial_statements(company_id, year DESC, quarter DESC);
CREATE INDEX idx_ratios_company ON financial_ratios(company_id, year DESC);
CREATE INDEX idx_shareholding_company ON shareholding_patterns(company_id, year DESC, quarter DESC);

-- TRIGGERS
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER companies_updated_at BEFORE UPDATE ON companies
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER portfolios_updated_at BEFORE UPDATE ON portfolios
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER portfolios_holdings_updated_at BEFORE UPDATE ON portfolio_holdings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER watchlists_updated_at BEFORE UPDATE ON watchlists
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER sip_plans_updated_at BEFORE UPDATE ON sip_plans
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER ai_chats_updated_at BEFORE UPDATE ON ai_chats
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER news_updated_at BEFORE UPDATE ON news_articles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER courses_updated_at BEFORE UPDATE ON courses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
