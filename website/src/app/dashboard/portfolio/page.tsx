'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { getPortfolio, getHoldings, type Holding } from '@/lib/api';
import { formatCurrency, formatPercent } from '@/lib/utils';

export default function PortfolioPage() {
  const [pf, setPf] = useState<{ total_value: number; total_returns: number; returns_percent: number } | null>(null);
  const [holdings, setHoldings] = useState<Holding[]>([]);

  useEffect(() => {
    getPortfolio().then(setPf).catch(() => {});
    getHoldings().then(setHoldings).catch(() => {});
  }, []);

  return (
    <div className="space-y-6">
      {pf && (
        <div className="bg-gradient-to-r from-brand/20 to-blue-600/20 border border-brand/30 rounded-xl p-6">
          <div className="text-sm text-gray-400 mb-1">Total Portfolio Value</div>
          <div className="text-3xl font-bold">{formatCurrency(pf.total_value)}</div>
          <div className={`text-sm mt-1 ${pf.total_returns >= 0 ? 'text-green-400' : 'text-red-400'}`}>
            {formatCurrency(pf.total_returns)} ({formatPercent(pf.returns_percent)})
          </div>
        </div>
      )}

      <div className="bg-card border border-border rounded-xl overflow-hidden">
        <div className="hidden md:grid grid-cols-6 gap-4 px-4 py-3 text-xs text-gray-500 uppercase border-b border-border">
          <div>Symbol</div>
          <div>Qty</div>
          <div>Avg Price</div>
          <div>Current</div>
          <div>Value</div>
          <div>P&L</div>
        </div>
        {holdings.map((h) => (
          <Link key={h.symbol} href={`/dashboard/markets/${h.symbol}`}
            className="grid grid-cols-3 md:grid-cols-6 gap-4 px-4 py-3 border-b border-border/50 last:border-0 hover:bg-white/5 transition-colors">
            <div className="text-sm font-medium">{h.symbol}</div>
            <div className="text-sm">{h.quantity}</div>
            <div className="text-sm">{formatCurrency(h.avg_price)}</div>
            <div className="text-sm">{formatCurrency(h.current_price)}</div>
            <div className="text-sm">{formatCurrency(h.total_value)}</div>
            <div className={`text-sm ${h.total_returns >= 0 ? 'text-green-400' : 'text-red-400'}`}>
              {formatCurrency(h.total_returns)}
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}
