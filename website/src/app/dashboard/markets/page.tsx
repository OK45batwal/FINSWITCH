'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { getStocks, type Stock } from '@/lib/api';
import { formatCurrency, formatPercent } from '@/lib/utils';

export default function MarketsPage() {
  const [stocks, setStocks] = useState<Stock[]>([]);
  const [q, setQ] = useState('');

  useEffect(() => { getStocks().then(setStocks).catch(() => {}); }, []);

  const filtered = q
    ? stocks.filter(s => s.symbol.toLowerCase().includes(q.toLowerCase()) || s.name.toLowerCase().includes(q.toLowerCase()))
    : stocks;

  return (
    <div className="space-y-4">
      <input
        placeholder="Search by symbol or name..."
        value={q} onChange={(e) => setQ(e.target.value)}
        className="w-full max-w-md bg-background border border-border rounded-lg px-3 py-2 text-sm focus:outline-none focus:border-brand"
      />
      <div className="bg-card border border-border rounded-xl overflow-hidden">
        <div className="hidden md:grid grid-cols-4 gap-4 px-4 py-3 text-xs text-gray-500 uppercase border-b border-border">
          <div>Symbol</div>
          <div>Name</div>
          <div className="text-right">Price</div>
          <div className="text-right">Change</div>
        </div>
        {filtered.map((s) => (
          <Link key={s.symbol} href={`/dashboard/markets/${s.symbol}`}
            className="grid grid-cols-2 md:grid-cols-4 gap-4 px-4 py-3 border-b border-border/50 last:border-0 hover:bg-white/5 transition-colors">
            <div className="text-sm font-medium">{s.symbol}</div>
            <div className="text-sm text-gray-400 truncate">{s.name}</div>
            <div className="text-sm text-right">{formatCurrency(s.price)}</div>
            <div className={`text-sm text-right ${s.change >= 0 ? 'text-green-400' : 'text-red-400'}`}>
              {formatPercent(s.change_percent)}
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}
