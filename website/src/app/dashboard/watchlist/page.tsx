'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { getStocks, type Stock } from '@/lib/api';
import { formatCurrency, formatPercent } from '@/lib/utils';

const STORAGE_KEY = 'finswitch_watchlist';

function loadWatchlist(): string[] {
  if (typeof window === 'undefined') return [];
  try { return JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]'); } catch { return []; }
}

export default function WatchlistPage() {
  const [stocks, setStocks] = useState<Stock[]>([]);
  const [watchlist, setWatchlist] = useState<string[]>(loadWatchlist);

  useEffect(() => { getStocks().then(setStocks).catch(() => {}); }, []);

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(watchlist));
  }, [watchlist]);

  const toggle = (symbol: string) => {
    setWatchlist((prev) =>
      prev.includes(symbol) ? prev.filter((s) => s !== symbol) : [...prev, symbol]
    );
  };

  const watched = stocks.filter((s) => watchlist.includes(s.symbol));

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap gap-2">
        {stocks.filter((s) => !watchlist.includes(s.symbol)).slice(0, 20).map((s) => (
          <button key={s.symbol} onClick={() => toggle(s.symbol)}
            className="bg-card border border-border hover:border-brand/50 text-xs px-3 py-1.5 rounded-full transition-colors">
            + {s.symbol}
          </button>
        ))}
      </div>

      <div className="bg-card border border-border rounded-xl overflow-hidden">
        <div className="hidden md:grid grid-cols-4 gap-4 px-4 py-3 text-xs text-gray-500 uppercase border-b border-border">
          <div>Symbol</div>
          <div>Name</div>
          <div className="text-right">Price</div>
          <div />
        </div>
        {watched.length === 0 && (
          <div className="px-4 py-8 text-center text-gray-500">Click a symbol above to add it to your watchlist</div>
        )}
        {watched.map((s) => (
          <div key={s.symbol}
            className="grid grid-cols-4 gap-4 px-4 py-3 border-b border-border/50 last:border-0 items-center">
            <Link href={`/dashboard/markets/${s.symbol}`} className="text-sm font-medium hover:text-brand">
              {s.symbol}
            </Link>
            <div className="text-sm text-gray-400 truncate">{s.name}</div>
            <div className={`text-sm text-right ${s.change >= 0 ? 'text-green-400' : 'text-red-400'}`}>
              {formatCurrency(s.price)}
              <span className="text-xs ml-1">{formatPercent(s.change_percent)}</span>
            </div>
            <button onClick={() => toggle(s.symbol)}
              className="text-xs text-gray-500 hover:text-red-400 text-right">
              Remove
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}
