const BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

async function get<T>(path: string): Promise<T> {
  const res = await fetch(`${BASE}${path}`);
  if (!res.ok) throw new Error(`API ${res.status}: ${path}`);
  return res.json();
}

async function post<T>(path: string, body: unknown): Promise<T> {
  const res = await fetch(`${BASE}${path}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  if (!res.ok) throw new Error(`API ${res.status}: ${path}`);
  return res.json();
}

export interface Index {
  symbol: string; name: string; price: number; change: number; change_percent: number;
}

export interface Stock {
  symbol: string; name: string; price: number; change: number; change_percent: number;
}

export interface StockDetail extends Stock {
  market_cap: number; pe_ratio: number; dividend_yield: number; high_52w: number; low_52w: number;
  volume: number; avg_volume: number; sector: string; industry: string; description: string;
}

export interface GainersLosers {
  symbol: string; name: string; price: number; change_percent: number;
}

export interface Holding {
  symbol: string; name: string; quantity: number; avg_price: number; current_price: number;
  total_value: number; total_returns: number; returns_percent: number;
}

export interface NewsItem {
  id: string; title: string; summary: string; source: string; url: string; published_at: string;
  symbol?: string;
}

export interface ChartPoint {
  date: string; close: number;
}

export function getIndices(): Promise<Index[]> { return get('/api/v1/indices'); }
export function getStocks(): Promise<Stock[]> { return get('/api/v1/stocks'); }
export function getStockDetail(symbol: string): Promise<StockDetail> { return get(`/api/v1/stocks/${symbol}`); }
export function getGainers(): Promise<GainersLosers[]> { return get('/api/v1/gainers'); }
export function getLosers(): Promise<GainersLosers[]> { return get('/api/v1/losers'); }
export function getPortfolio(): Promise<{ total_value: number; total_returns: number; returns_percent: number }> {
  return get('/api/v1/portfolio');
}
export function getHoldings(): Promise<Holding[]> { return get('/api/v1/holdings'); }
export function getNews(): Promise<NewsItem[]> { return get('/api/v1/news'); }
export function chatWithAI(message: string): Promise<{ response: string }> {
  return post('/api/v1/ai/chat', { message });
}
export function analyzeStock(symbol: string): Promise<{ response: string }> {
  return post('/api/v1/ai/analyze', { symbol });
}
export function getChartData(symbol: string): Promise<ChartPoint[]> {
  return post('/api/v1/ai/chart', { symbol });
}
