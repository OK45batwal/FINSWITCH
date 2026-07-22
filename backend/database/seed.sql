-- ====================================================================
-- FinSwitch — Seed Data for Supabase PostgreSQL
-- ====================================================================

-- 1. SEED INDICES
INSERT INTO public.indices (symbol, name, price, change, change_percent) VALUES
  ('NIFTY', 'Nifty 50', 23456.80, 128.45, 0.55),
  ('SENSEX', 'S&P BSE Sensex', 77123.45, 342.10, 0.44),
  ('BANKNIFTY', 'Bank Nifty', 49234.55, -87.30, -0.18)
ON CONFLICT (symbol) DO UPDATE SET
  price = EXCLUDED.price,
  change = EXCLUDED.change,
  change_percent = EXCLUDED.change_percent;

-- 2. SEED STOCKS
INSERT INTO public.stocks (symbol, name, sector, price, change, change_percent, volume, pe_ratio, high_52w, low_52w, market_cap, dividend_yield, avg_volume, industry, description) VALUES
  ('RELIANCE', 'Reliance Industries Ltd', 'Oil & Gas', 2845.30, 32.50, 1.16, 12400000, 24.50, 3200.00, 2200.00, 192500000000.00, 0.35, 12400000, 'Energy & Retail', 'Reliance Industries Limited is an Indian multinational conglomerate with businesses in energy, petrochemicals, retail, and telecommunications.'),
  ('TCS', 'Tata Consultancy Services', 'IT', 3920.00, -18.40, -0.47, 3800000, 28.60, 4200.00, 3300.00, 145000000000.00, 1.20, 3800000, 'IT Services', 'Tata Consultancy Services is an Indian multinational information technology services and consulting company.'),
  ('HDFCBANK', 'HDFC Bank Ltd', 'Banking', 1635.75, 8.90, 0.55, 18200000, 18.50, 1800.00, 1360.00, 94000000000.00, 1.05, 18200000, 'Private Banking', 'HDFC Bank is India’s largest private sector bank by assets and market capitalization.'),
  ('INFY', 'Infosys Ltd', 'IT', 1482.55, -12.20, -0.82, 8600000, 26.20, 1750.00, 1350.00, 62000000000.00, 1.80, 8600000, 'IT Consulting', 'Infosys is a global leader in next-generation digital services and consulting.'),
  ('ICICIBANK', 'ICICI Bank Ltd', 'Banking', 1124.90, 6.75, 0.60, 14100000, 17.80, 1250.00, 900.00, 82000000000.00, 0.80, 14100000, 'Private Banking', 'ICICI Bank is a leading private sector bank in India offering diversified financial services.'),
  ('SBIN', 'State Bank of India', 'Banking', 782.30, 4.50, 0.58, 22500000, 12.30, 900.00, 570.00, 71000000000.00, 3.20, 22500000, 'Public Banking', 'State Bank of India is a Fortune 500 public sector banking and financial services body.'),
  ('BHARTIARTL', 'Bharti Airtel Ltd', 'Telecom', 1345.60, 15.80, 1.19, 7300000, 32.10, 1500.00, 1050.00, 78000000000.00, 0.45, 7300000, 'Telecommunications', 'Bharti Airtel is a global telecommunications company operating across 18 countries.'),
  ('ITC', 'ITC Ltd', 'FMCG', 432.15, -2.30, -0.53, 25100000, 22.40, 520.00, 380.00, 54500000000.00, 3.80, 25100000, 'Consumer Goods', 'ITC Limited is a diversified conglomerate with presence in FMCG, Hotels, Paperboards, and Agri Business.'),
  ('WIPRO', 'Wipro Ltd', 'IT', 512.40, 3.20, 0.63, 5400000, 18.50, 600.00, 380.00, 29000000000.00, 2.10, 5400000, 'IT Services', 'Wipro Limited is a leading technology services and consulting company focused on building innovative solutions.'),
  ('HINDUNILVR', 'Hindustan Unilever Ltd', 'FMCG', 2345.60, -5.80, -0.25, 2100000, 45.20, 2700.00, 2200.00, 55000000000.00, 1.65, 2100000, 'Consumer Goods', 'Hindustan Unilever Limited is India’s largest Fast-Moving Consumer Goods company.'),
  ('MARUTI', 'Maruti Suzuki India Ltd', 'Automobile', 11230.00, 45.20, 0.40, 890000, 28.00, 13500.00, 9500.00, 34000000000.00, 0.50, 890000, 'Auto Manufacturers', 'Maruti Suzuki India Limited is India’s leading passenger vehicle manufacturer.'),
  ('BAJFINANCE', 'Bajaj Finance Ltd', 'NBFC', 7245.30, 56.80, 0.79, 1200000, 31.50, 8200.00, 5800.00, 43000000000.00, 0.30, 1200000, 'Financial Services', 'Bajaj Finance Limited is a non-banking financial company engaged in lending and deposit taking.')
ON CONFLICT (symbol) DO UPDATE SET
  price = EXCLUDED.price,
  change = EXCLUDED.change,
  change_percent = EXCLUDED.change_percent,
  volume = EXCLUDED.volume;

-- 3. SEED NEWS ARTICLES
INSERT INTO public.news_articles (title, summary, source, url, published_at, symbols) VALUES
  ('RBI keeps repo rate unchanged at 6.50%', 'The MPC voted 5-1 to maintain status quo, maintaining its withdrawal of accommodation stance.', 'Economic Times', 'https://economictimes.indiatimes.com', NOW() - INTERVAL '2 hours', ARRAY['SBIN', 'HDFCBANK']),
  ('Reliance Industries Q1 net profit rises 12%', 'Revenue from operations increased 8% YoY driven by strong performance in retail and telecom segments.', 'Moneycontrol', 'https://moneycontrol.com', NOW() - INTERVAL '4 hours', ARRAY['RELIANCE']),
  ('HDFC Bank reports 15% growth in net profit', 'Net interest margin improved to 4.1% with strong growth in advances and deposits.', 'Bloomberg', 'https://bloomberg.com', NOW() - INTERVAL '6 hours', ARRAY['HDFCBANK']),
  ('TCS wins $2.5B digital transformation deal', '5-year deal involves modernizing core banking infrastructure for major European bank.', 'Financial Express', 'https://financialexpress.com', NOW() - INTERVAL '8 hours', ARRAY['TCS']);
