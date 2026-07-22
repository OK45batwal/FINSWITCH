'use client';

import { useEffect, useState } from 'react';
import { getStockDetail, analyzeStockAI, getChartData, type StockDetail, type ChartPoint } from '@/lib/api';
import { formatCurrency, formatPercent, formatLargeNumber } from '@/lib/utils';

const sparkline = (data: ChartPoint[]) => {
  if (!data.length) return null;
  const w = 280, h = 80;
  const max = Math.max(...data.map(d => d.close));
  const min = Math.min(...data.map(d => d.close));
  const range = max - min || 1;
  const pts = data.map((d, i) => `${(i / (data.length - 1)) * w},${h - ((d.close - min) / range) * h}`).join(' ');
  const color = data[0].close <= data[data.length - 1].close ? '#00c853' : '#ff4444';
  return (
    <svg viewBox={`0 0 ${w} ${h}`} className="w-full max-w-xs h-20">
      <polyline fill="none" stroke={color} strokeWidth="2" points={pts} />
    </svg>
  );
};

export default function StockDetailClient({ symbol }: { symbol: string }) {
  const [stock, setStock] = useState<StockDetail | null>(null);
  const [analysis, setAnalysis] = useState('');
  const [chart, setChart] = useState<ChartPoint[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let active = true;
    Promise.all([
      getStockDetail(symbol),
      getChartData(symbol),
    ]).then(([stkData, chrtData]) => {
      if (active) {
        setStock(stkData);
        setChart(chrtData);
        setLoading(false);
      }
    }).catch(() => {
      if (active) setLoading(false);
    });

    return () => {
      active = false;
    };
  }, [symbol]);

  if (loading) return <div className="text-gray-500">Loading...</div>;
  if (!stock) return <div className="text-red-400">Stock not found</div>;

  return (
    <div className="space-y-6">
      <div className="bg-card border border-border rounded-xl p-6">
        <div className="flex flex-wrap items-start justify-between gap-4">
          <div>
            <h1 className="text-2xl font-bold">{stock.symbol}</h1>
            <div className="text-gray-400 text-sm">{stock.name}</div>
            <div className="text-xs text-brand font-medium mt-1">{stock.sector} &middot; {stock.industry}</div>
          </div>
          <div className="text-right">
            <div className="text-3xl font-bold font-mono">{formatCurrency(stock.price)}</div>
            <div className={`text-sm font-semibold ${stock.change >= 0 ? 'text-emerald-400' : 'text-red-400'}`}>
              {formatPercent(stock.change_percent)} ({stock.change >= 0 ? '+' : ''}{stock.change.toFixed(2)})
            </div>
          </div>
        </div>
      </div>

      <div className="grid md:grid-cols-2 gap-6">
        <div className="bg-card border border-border rounded-xl p-6">
          <h2 className="text-lg font-semibold mb-4">Price Action (60 Days)</h2>
          {sparkline(chart)}
          <div className="grid grid-cols-2 gap-4 mt-4 text-xs border-t border-border pt-4">
            <div><span className="text-gray-400">52W High:</span> <span className="font-mono font-medium">{formatCurrency(stock.high_52w)}</span></div>
            <div><span className="text-gray-400">52W Low:</span> <span className="font-mono font-medium">{formatCurrency(stock.low_52w)}</span></div>
            <div><span className="text-gray-400">Volume:</span> <span className="font-mono font-medium">{formatLargeNumber(stock.volume)}</span></div>
            <div><span className="text-gray-400">Avg Volume:</span> <span className="font-mono font-medium">{formatLargeNumber(stock.avg_volume)}</span></div>
          </div>
        </div>

        <div className="bg-card border border-border rounded-xl p-6">
          <h2 className="text-lg font-semibold mb-4">Fundamentals</h2>
          <div className="space-y-3 text-sm">
            <div className="flex justify-between border-b border-border/50 pb-2">
              <span className="text-gray-400">P/E Ratio</span>
              <span className="font-mono font-medium">{stock.pe_ratio}</span>
            </div>
            <div className="flex justify-between border-b border-border/50 pb-2">
              <span className="text-gray-400">Dividend Yield</span>
              <span className="font-mono font-medium">{stock.dividend_yield}%</span>
            </div>
            <div className="flex justify-between border-b border-border/50 pb-2">
              <span className="text-gray-400">Market Cap</span>
              <span className="font-mono font-medium">₹{formatLargeNumber(stock.market_cap)} Cr</span>
            </div>
          </div>
        </div>
      </div>

      <div className="bg-card border border-border rounded-xl p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold flex items-center gap-2">🤖 AI Copilot Analysis</h2>
          <button
            onClick={() => analyzeStockAI(stock.symbol).then(r => setAnalysis(r.response))}
            className="text-xs bg-brand/20 text-brand px-3 py-1.5 rounded-lg hover:bg-brand/30 transition-colors font-medium"
          >
            {analysis ? 'Refresh AI Analysis' : 'Run AI Analysis'}
          </button>
        </div>
        {analysis ? (
          <div className="text-sm text-gray-300 whitespace-pre-line leading-relaxed bg-background/50 p-4 rounded-lg border border-border">
            {analysis}
          </div>
        ) : (
          <p className="text-sm text-gray-500 italic">Click &quot;Run AI Analysis&quot; to generate LLM insights for {stock.symbol}.</p>
        )}
      </div>
    </div>
  );
}
