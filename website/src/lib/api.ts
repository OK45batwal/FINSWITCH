import { supabase } from './supabase';

export interface Index {
  symbol: string; name: string; price: number; change: number; change_percent: number;
}

export interface Stock {
  symbol: string; name: string; sector: string; price: number; change: number; change_percent: number; volume: number;
}

export interface StockDetail extends Stock {
  pe_ratio: number; dividend_yield: number; high_52w: number; low_52w: number;
  market_cap: number; avg_volume: number; industry: string; description: string;
}

export interface Holding {
  symbol: string; name: string; quantity: number; avg_price: number; current_price: number;
  total_value: number; total_returns: number; returns_percent: number;
}

export interface NewsItem {
  id: string; title: string; summary: string; source: string; url: string; published_at: string;
  symbols?: string[];
}

export interface GainersLosers {
  symbol: string; name: string; price: number; change_percent: number;
}

export interface ChartPoint {
  date: string; close: number; high: number; low: number; volume: number; sma_20: number; rsi: number;
}

interface DbRecord {
  id?: string | number;
  symbol?: string;
  name?: string;
  sector?: string;
  industry?: string;
  price?: number;
  change?: number;
  change_percent?: number;
  volume?: number;
  avg_volume?: number;
  pe_ratio?: number;
  dividend_yield?: number;
  high_52w?: number;
  low_52w?: number;
  market_cap?: number;
  description?: string;
  quantity?: number;
  avg_price?: number;
  current_price?: number;
  title?: string;
  summary?: string;
  source?: string;
  url?: string;
  published_at?: string;
  symbols?: string[];
}

// Fallback: hit the local AI endpoint which has all data hardcoded
async function fallbackGet(path: string) {
  const res = await fetch(`/api/ai?type=${path}${path === 'stock' ? `&symbol=${new URLSearchParams(window.location.search).get('symbol') || ''}` : ''}`);
  return (await res.json()).data || [];
}

// ---- Supabase data queries (falls back to AI endpoint if Supabase not configured) ----

export async function getIndices(): Promise<Index[]> {
  const { data } = await supabase.from('indices').select('*');
  if (data?.length) return data.map((r: DbRecord) => ({ symbol: r.symbol || '', name: r.name || '', price: r.price || 0, change: r.change || 0, change_percent: r.change_percent || 0 }));
  return fallbackGet('indices');
}

export async function getStocks(): Promise<Stock[]> {
  const { data } = await supabase.from('stocks').select('*');
  if (data?.length) return data.map((r: DbRecord) => ({ symbol: r.symbol || '', name: r.name || '', sector: r.sector || '', price: r.price || 0, change: r.change || 0, change_percent: r.change_percent || 0, volume: r.volume || 0 }));
  return fallbackGet('stocks');
}

export async function getStockDetail(symbol: string): Promise<StockDetail | null> {
  const { data } = await supabase.from('stocks').select('*').eq('symbol', symbol.toUpperCase()).single();
  if (data) return mapDetail(data);
  const fallback = await fetch(`/api/ai?type=stock&symbol=${symbol}`).then(r => r.json());
  return fallback.data ? mapDetail(fallback.data) : null;
}

function mapDetail(r: DbRecord): StockDetail {
  return { symbol: r.symbol || '', name: r.name || '', sector: r.sector || '', industry: r.industry || '', price: r.price || 0, change: r.change || 0, change_percent: r.change_percent || 0, volume: r.volume || 0, avg_volume: r.avg_volume || 0, pe_ratio: r.pe_ratio || 0, dividend_yield: r.dividend_yield || 0, high_52w: r.high_52w || 0, low_52w: r.low_52w || 0, market_cap: r.market_cap || 0, description: r.description || '' };
}

export async function getGainers(): Promise<Stock[]> {
  const { data } = await supabase.from('stocks').select('*').order('change_percent', { ascending: false }).limit(5);
  if (data?.length) return data.map((r: DbRecord) => ({ symbol: r.symbol || '', name: r.name || '', sector: r.sector || '', price: r.price || 0, change: r.change || 0, change_percent: r.change_percent || 0, volume: r.volume || 0 }));
  const stocks = await getStocks();
  return [...stocks].sort((a, b) => b.change_percent - a.change_percent).slice(0, 5);
}

export async function getLosers(): Promise<Stock[]> {
  const { data } = await supabase.from('stocks').select('*').order('change_percent', { ascending: true }).limit(5);
  if (data?.length) return data.map((r: DbRecord) => ({ symbol: r.symbol || '', name: r.name || '', sector: r.sector || '', price: r.price || 0, change: r.change || 0, change_percent: r.change_percent || 0, volume: r.volume || 0 }));
  const stocks = await getStocks();
  return [...stocks].sort((a, b) => a.change_percent - b.change_percent).slice(0, 5);
}

export async function getPortfolio(userId?: string): Promise<{ total_value: number; total_returns: number; returns_percent: number } | null> {
  if (!userId || !supabase) return null;
  const { data } = await supabase.from('portfolios').select('*').eq('user_id', userId).maybeSingle();
  if (!data) return null;
  return { total_value: data.current_value, total_returns: data.total_returns, returns_percent: data.returns_percent };
}

export async function getHoldings(userId?: string): Promise<Holding[]> {
  if (!userId || !supabase) return [];
  const { data: pf } = await supabase.from('portfolios').select('id').eq('user_id', userId).maybeSingle();
  if (!pf) return [];
  const { data } = await supabase.from('holdings').select('symbol, quantity, avg_price').eq('portfolio_id', pf.id);
  const { data: stocks } = await supabase.from('stocks').select('symbol, name, price');
  const stockMap = new Map((stocks || []).map((s: DbRecord) => [s.symbol || '', s]));
  return (data || []).map((h: DbRecord) => {
    const s = stockMap.get(h.symbol || '') || { name: h.symbol || '', price: 0 };
    const qty = h.quantity || 0;
    const avgP = h.avg_price || 0;
    const sPrice = s.price || 0;
    const value = qty * sPrice;
    const invested = qty * avgP;
    return { symbol: h.symbol || '', name: s.name || '', quantity: qty, avg_price: avgP, current_price: sPrice, total_value: value, total_returns: value - invested, returns_percent: invested ? ((value - invested) / invested) * 100 : 0 };
  });
}

export async function getWatchlist(userId?: string): Promise<string[]> {
  if (!userId || !supabase) return [];
  const { data } = await supabase.from('watchlist_items').select('symbol').eq('user_id', userId);
  return (data || []).map((r: DbRecord) => r.symbol || '');
}

export async function addToWatchlist(userId: string, symbol: string): Promise<void> {
  await supabase.from('watchlist_items').insert({ user_id: userId, symbol: symbol.toUpperCase() });
}

export async function removeFromWatchlist(userId: string, symbol: string): Promise<void> {
  await supabase.from('watchlist_items').delete().eq('user_id', userId).eq('symbol', symbol.toUpperCase());
}

const FALLBACK_NEWS: NewsItem[] = [
  { id: '1', title: 'Nifty hits fresh all-time high above 23,500; Sensex surges 500 points', summary: 'Indian equity benchmarks scaled new peaks on Wednesday, driven by strong buying in banking and IT stocks amid positive global cues.', source: 'Economic Times', url: '#', published_at: new Date().toISOString(), symbols: ['NIFTY'] },
  { id: '2', title: 'RBI keeps repo rate unchanged at 6.5%, maintains status quo', summary: 'The Monetary Policy Committee voted 5-1 to hold rates steady, signaling caution on inflation while supporting growth.', source: 'Business Standard', url: '#', published_at: new Date().toISOString(), symbols: ['BANKNIFTY'] },
  { id: '3', title: 'Reliance Industries to invest ₹75,000 Cr in green energy', summary: 'The conglomerate announced its biggest clean energy push, setting up 100 GW of solar capacity by 2030.', source: 'Financial Express', url: '#', published_at: new Date().toISOString(), symbols: ['RELIANCE'] },
  { id: '4', title: 'TCS wins $2.5B deal from US-based financial services firm', summary: 'India\'s largest IT firm secures its largest-ever deal, boosting investor confidence in the IT sector\'s growth trajectory.', source: 'Mint', url: '#', published_at: new Date().toISOString(), symbols: ['TCS'] },
  { id: '5', title: 'Gold prices soar to ₹76,500 amid geopolitical tensions', summary: 'Safe-haven demand pushes gold to record highs as Middle East tensions escalate and global uncertainties persist.', source: 'Bloomberg', url: '#', published_at: new Date().toISOString(), symbols: [] },
];

export async function getNews(): Promise<NewsItem[]> {
  const { data } = await supabase.from('news_articles').select('*').order('published_at', { ascending: false }).limit(20);
  if (data?.length) return data.map((r: DbRecord) => ({ id: String(r.id), title: r.title || '', summary: r.summary || '', source: r.source || '', url: r.url || '', published_at: r.published_at || '', symbols: r.symbols || [] }));
  return FALLBACK_NEWS;
}

// ---- AI endpoints (local Cloudflare Pages Functions) ----

const AI_URL = '/api/ai';

async function aiPost(body: { action: string; message?: string; symbol?: string; user_id?: string }): Promise<{ data?: { response?: string } | ChartPoint[] | StockDetail }> {
  const res = await fetch(AI_URL, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
  return res.json();
}

export function chatWithAI(message: string, userId?: string): Promise<{ response: string }> {
  return aiPost({ action: 'chat', message, user_id: userId }).then(r => ({ response: (r.data as { response?: string })?.response || '' }));
}

export function analyzeStockAI(symbol: string): Promise<{ response: string }> {
  return aiPost({ action: 'analyze', symbol }).then(r => ({ response: (r.data as unknown as string) || '' }));
}

export function getChartData(symbol: string): Promise<ChartPoint[]> {
  return aiPost({ action: 'chart', symbol }).then(r => (r.data as ChartPoint[]) || []);
}
