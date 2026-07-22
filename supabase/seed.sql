-- Seed data — run after schema.sql
-- Stocks (12)
INSERT INTO public.stocks (symbol, name, sector, industry, price, change, change_percent, pe_ratio, high_52w, low_52w, market_cap, dividend_yield, volume, avg_volume, description) VALUES
('RELIANCE', 'Reliance Industries Ltd', 'Oil & Gas', 'Conglomerate', 2845.30, 32.50, 1.16, 24.5, 3200, 2200, 1925000000000, 0.35, 12400000, 11000000, 'Reliance Industries Limited is an Indian multinational conglomerate with businesses in energy, petrochemicals, textiles, retail, and telecommunications.'),
('TCS', 'Tata Consultancy Services', 'IT', 'IT Services', 3920.00, -18.40, -0.47, 28.6, 4200, 3300, 1450000000000, 1.20, 3800000, 4200000, 'Tata Consultancy Services is an Indian multinational information technology services and consulting company.'),
('HDFCBANK', 'HDFC Bank Ltd', 'Banking', 'Banking', 1635.75, 8.90, 0.55, 18.5, 1800, 1360, 940000000000, 1.05, 18200000, 16500000, 'HDFC Bank is an Indian banking and financial services company.'),
('INFY', 'Infosys Ltd', 'IT', 'IT Services', 1482.55, -12.20, -0.82, 26.2, 1750, 1350, 620000000000, 1.80, 8600000, 9200000, 'Infosys is an Indian multinational information technology company.'),
('ICICIBANK', 'ICICI Bank Ltd', 'Banking', 'Banking', 1124.90, 6.75, 0.60, 17.8, 1250, 900, 820000000000, 0.80, 14100000, 13000000, 'ICICI Bank is an Indian multinational banking and financial services company.'),
('SBIN', 'State Bank of India', 'Banking', 'PSU Bank', 782.30, 4.50, 0.58, 12.3, 900, 570, 710000000000, 3.20, 22500000, 20000000, 'State Bank of India is an Indian multinational public sector bank.'),
('BHARTIARTL', 'Bharti Airtel Ltd', 'Telecom', 'Telecom', 1345.60, 15.80, 1.19, 32.1, 1500, 1050, 780000000000, 0.45, 7300000, 8000000, 'Bharti Airtel is an Indian multinational telecommunications services company.'),
('ITC', 'ITC Ltd', 'FMCG', 'Conglomerate', 432.15, -2.30, -0.53, 22.4, 520, 380, 545000000000, 3.80, 25100000, 23000000, 'ITC Limited is an Indian multinational conglomerate.'),
('WIPRO', 'Wipro Ltd', 'IT', 'IT Services', 512.40, 3.20, 0.63, 18.5, 600, 380, 290000000000, 2.10, 5400000, 6000000, 'Wipro is an Indian multinational corporation that provides information technology services.'),
('HINDUNILVR', 'Hindustan Unilever Ltd', 'FMCG', 'FMCG', 2345.60, -5.80, -0.25, 45.2, 2700, 2200, 550000000000, 1.65, 2100000, 2500000, 'Hindustan Unilever Limited is an Indian multinational consumer goods company.'),
('MARUTI', 'Maruti Suzuki India Ltd', 'Automobile', 'Automobile', 11230.00, 45.20, 0.40, 28.0, 13500, 9500, 340000000000, 0.50, 890000, 950000, 'Maruti Suzuki India Limited is a leading automobile manufacturer in India.'),
('BAJFINANCE', 'Bajaj Finance Ltd', 'NBFC', 'NBFC', 7245.30, 56.80, 0.79, 31.5, 8200, 5800, 430000000000, 0.30, 1200000, 1100000, 'Bajaj Finance Limited is an Indian non-banking financial company.')
ON CONFLICT (symbol) DO NOTHING;

-- Indices (3)
INSERT INTO public.indices (symbol, name, price, change, change_percent) VALUES
('NIFTY', 'Nifty 50', 23456.80, 128.45, 0.55),
('SENSEX', 'S&P BSE Sensex', 77123.45, 342.10, 0.44),
('BANKNIFTY', 'Bank Nifty', 49234.55, -87.30, -0.18)
ON CONFLICT (symbol) DO NOTHING;

-- News (8)
INSERT INTO public.news_articles (title, summary, source, category, sentiment, symbols, published_at) VALUES
('RBI keeps repo rate unchanged at 6.50% for 8th consecutive time', 'The MPC voted 5-1 to maintain status quo, maintaining its withdrawal of accommodation stance.', 'Economic Times', 'economy', 'neutral', ARRAY[]::TEXT[], '2026-07-21T09:30:00Z'),
('Reliance Industries Q1 net profit rises 12% to ₹22,500 crore', 'Revenue from operations increased 8% YoY driven by strong performance in retail and telecom segments.', 'Moneycontrol', 'markets', 'positive', ARRAY['RELIANCE'], '2026-07-21T08:45:00Z'),
('HDFC Bank reports 15% growth in net profit for Q1 FY27', 'Net interest margin improved to 4.1% with strong growth in advances and deposits.', 'Bloomberg', 'stocks', 'positive', ARRAY['HDFCBANK'], '2026-07-21T07:30:00Z'),
('SEBI introduces new framework for SME IPOs to protect investors', 'The regulator mandates higher disclosure norms and track record requirements for SME listings.', 'Business Standard', 'ipo', 'positive', ARRAY[]::TEXT[], '2026-07-20T18:00:00Z'),
('Rupee weakens to 83.75 against US dollar amid FII outflows', 'Foreign institutional investors have pulled out ₹15,000 crore from Indian equities this month.', 'Reuters', 'economy', 'negative', ARRAY[]::TEXT[], '2026-07-20T15:45:00Z'),
('TCS wins $2.5 billion deal from UK-based banking giant', 'The 5-year deal involves digital transformation of the bank''s legacy systems.', 'Financial Express', 'stocks', 'positive', ARRAY['TCS'], '2026-07-20T14:20:00Z'),
('Gold prices hit all-time high of ₹76,500 per 10 grams', 'Geopolitical tensions and US interest rate cut expectations drive safe-haven demand.', 'CNBC TV18', 'commodities', 'neutral', ARRAY[]::TEXT[], '2026-07-20T11:00:00Z'),
('Zomato turns profitable for second consecutive quarter', 'Food delivery giant reports net profit of ₹450 crore driven by quick commerce growth.', 'Livemint', 'stocks', 'positive', ARRAY[]::TEXT[], '2026-07-19T16:30:00Z')
ON CONFLICT DO NOTHING;
