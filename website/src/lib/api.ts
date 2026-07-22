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

// Fallback: hit the local AI endpoint which has all data hardcoded
async function fallbackGet(path: string) {
  const res = await fetch(`/api/ai?type=${path}${path === 'stock' ? `&symbol=${new URLSearchParams(window.location.search).get('symbol') || ''}` : ''}`);
  return (await res.json()).data || [];
}

// ---- Supabase data queries (falls back to AI endpoint if Supabase not configured) ----

export async function getIndices(): Promise<Index[]> {
  const { data } = await supabase.from('indices').select('*');
  if (data?.length) return data.map((r: any) => ({ symbol: r.symbol, name: r.name, price: r.price, change: r.change, change_percent: r.change_percent }));
  return fallbackGet('indices');
}

export async function getStocks(): Promise<Stock[]> {
  const { data } = await supabase.from('stocks').select('*');
  if (data?.length) return data.map((r: any) => ({ symbol: r.symbol, name: r.name, sector: r.sector, price: r.price, change: r.change, change_percent: r.change_percent, volume: r.volume }));
  return fallbackGet('stocks');
}

export async function getStockDetail(symbol: string): Promise<StockDetail | null> {
  const { data } = await supabase.from('stocks').select('*').eq('symbol', symbol.toUpperCase()).single();
  if (data) return mapDetail(data);
  const fallback = await fetch(`/api/ai?type=stock&symbol=${symbol}`).then(r => r.json());
  return fallback.data ? mapDetail(fallback.data) : null;
}

function mapDetail(r: any): StockDetail {
  return { symbol: r.symbol, name: r.name, sector: r.sector, industry: r.industry || '', price: r.price, change: r.change, change_percent: r.change_percent, volume: r.volume || 0, avg_volume: r.avg_volume || 0, pe_ratio: r.pe_ratio, dividend_yield: r.dividend_yield, high_52w: r.high_52w, low_52w: r.low_52w, market_cap: r.market_cap, description: r.description || '' };
}

export async function getGainers(): Promise<Stock[]> {
  const { data } = await supabase.from('stocks').select('*').order('change_percent', { ascending: false }).limit(5);
  if (data?.length) return data.map((r: any) => ({ symbol: r.symbol, name: r.name, sector: r.sector, price: r.price, change: r.change, change_percent: r.change_percent, volume: r.volume }));
  const stocks = await getStocks();
  return [...stocks].sort((a, b) => b.change_percent - a.change_percent).slice(0, 5);
}

export async function getLosers(): Promise<Stock[]> {
  const { data } = await supabase.from('stocks').select('*').order('change_percent', { ascending: true }).limit(5);
  if (data?.length) return data.map((r: any) => ({ symbol: r.symbol, name: r.name, sector: r.sector, price: r.price, change: r.change, change_percent: r.change_percent, volume: r.volume }));
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
  const stockMap = new Map((stocks || []).map((s: any) => [s.symbol, s]));
  return (data || []).map((h: any) => {
    const s = stockMap.get(h.symbol) || { name: h.symbol, price: 0 };
    const value = h.quantity * s.price;
    const invested = h.quantity * h.avg_price;
    return { symbol: h.symbol, name: s.name, quantity: h.quantity, avg_price: h.avg_price, current_price: s.price, total_value: value, total_returns: value - invested, returns_percent: invested ? ((value - invested) / invested) * 100 : 0 };
  });
}

export async function getWatchlist(userId?: string): Promise<string[]> {
  if (!userId || !supabase) return [];
  const { data } = await supabase.from('watchlist_items').select('symbol').eq('user_id', userId);
  return (data || []).map((r: any) => r.symbol);
}

export async function addToWatchlist(userId: string, symbol: string): Promise<void> {
  await supabase.from('watchlist_items').insert({ user_id: userId, symbol: symbol.toUpperCase() });
}

export async function removeFromWatchlist(userId: string, symbol: string): Promise<void> {
  await supabase.from('watchlist_items').delete().eq('user_id', userId).eq('symbol', symbol.toUpperCase());
}

export async function getNews(): Promise<NewsItem[]> {
  const { data } = await supabase.from('news_articles').select('*').order('published_at', { ascending: false }).limit(20);
  if (data?.length) return data.map((r: any) => ({ id: String(r.id), title: r.title, summary: r.summary || '', source: r.source || '', url: r.url || '', published_at: r.published_at, symbols: r.symbols || [] }));
  return [];
}

// ---- AI endpoints (local Cloudflare Pages Functions) ----

const AI_URL = '/api/ai';

async function aiPost(body: any) {
  const res = await fetch(AI_URL, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
  return res.json();
}

export function chatWithAI(message: string): Promise<{ response: string }> {
  return aiPost({ action: 'chat', message }).then(r => ({ response: r.data?.response || '' }));
}

export function analyzeStockAI(symbol: string): Promise<{ response: string }> {
  return aiPost({ action: 'analyze', symbol }).then(r => ({ response: r.data || '' }));
}

export function getChartData(symbol: string): Promise<ChartPoint[]> {
  return aiPost({ action: 'chart', symbol }).then(r => r.data || []);
}
