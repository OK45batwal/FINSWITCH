'use client';

import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import { getStockDetail, analyzeStock, getChartData, type StockDetail, type ChartPoint } from '@/lib/api';
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

export default function StockDetailPage() {
  const { symbol } = useParams<{ symbol: string }>();
  const [stock, setStock] = useState<StockDetail | null>(null);
  const [analysis, setAnalysis] = useState('');
  const [chart, setChart] = useState<ChartPoint[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(true);
    Promise.all([
      getStockDetail(symbol).then(setStock),
      getChartData(symbol).then(setChart),
    ]).finally(() => setLoading(false));
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
            <div className="text-xs text-gray-500 mt-1">{stock.sector} · {stock.industry}</div>
          </div>
          <div className="text-right">
            <div className="text-3xl font-bold">{formatCurrency(stock.price)}</div>
            <div className={`text-sm ${stock.change >= 0 ? 'text-green-400' : 'text-red-400'}`}>
              {formatCurrency(stock.change)} ({formatPercent(stock.change_percent)})
            </div>
          </div>
        </div>
        {chart.length > 0 && <div className="mt-4">{sparkline(chart)}</div>}
      </div>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        {[
          { label: 'Market Cap', value: formatLargeNumber(stock.market_cap) },
          { label: 'P/E Ratio', value: stock.pe_ratio.toFixed(2) },
          { label: 'Dividend Yield', value: `${stock.dividend_yield.toFixed(2)}%` },
          { label: 'Volume', value: formatLargeNumber(stock.volume) },
          { label: 'Avg Volume', value: formatLargeNumber(stock.avg_volume) },
          { label: '52W High', value: formatCurrency(stock.high_52w) },
          { label: '52W Low', value: formatCurrency(stock.low_52w) },
        ].map((s) => (
          <div key={s.label} className="bg-card border border-border rounded-xl p-3">
            <div className="text-xs text-gray-500">{s.label}</div>
            <div className="text-sm font-semibold mt-1">{s.value}</div>
          </div>
        ))}
      </div>

      {stock.description && (
        <div className="bg-card border border-border rounded-xl p-4">
          <h3 className="font-semibold mb-2">About</h3>
          <p className="text-sm text-gray-400">{stock.description}</p>
        </div>
      )}

      <button
        onClick={async () => {
          setAnalysis('Analyzing...');
          try {
            const res = await analyzeStock(symbol);
            setAnalysis(res.response);
          } catch { setAnalysis('Analysis failed'); }
        }}
        className="bg-brand hover:bg-brand-hover text-black px-6 py-2.5 rounded-lg font-semibold transition-colors"
      >
        Run AI Analysis
      </button>

      {analysis && (
        <div className="bg-card border border-border rounded-xl p-4">
          <h3 className="font-semibold mb-2">AI Analysis</h3>
          <p className="text-sm text-gray-300 whitespace-pre-wrap">{analysis}</p>
        </div>
      )}
    </div>
  );
}
