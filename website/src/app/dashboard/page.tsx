'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { supabase } from '@/lib/supabase';
import { getIndices, getGainers, getLosers, getNews, getPortfolio, Index, GainersLosers, type NewsItem } from '@/lib/api';
import { formatCurrency, formatPercent } from '@/lib/utils';

export const dynamic = 'force-dynamic';

export default function DashboardHome() {
  const [indices, setIndices] = useState<Index[]>([]);
  const [gainers, setGainers] = useState<GainersLosers[]>([]);
  const [losers, setLosers] = useState<GainersLosers[]>([]);
  const [news, setNews] = useState<NewsItem[]>([]);
  const [portfolio, setPortfolio] = useState<{ total_value: number; total_returns: number; returns_percent: number } | null>(null);

  useEffect(() => {
    getIndices().then(setIndices).catch(() => {});
    getGainers().then(setGainers).catch(() => {});
    getLosers().then(setLosers).catch(() => {});
    getNews().then(setNews).catch(() => {});

    (async () => {
      if (!supabase) return;
      const { data: { session } } = await supabase.auth.getSession();
      if (session?.user?.id) getPortfolio(session.user.id).then(setPortfolio);
    })();
  }, []);

  return (
    <div className="space-y-6">
      {portfolio && (
        <Link href="/dashboard/portfolio" className="block bg-gradient-to-r from-brand/20 to-blue-600/20 border border-brand/30 rounded-xl p-4 hover:brightness-110 transition-all">
          <div className="text-sm text-gray-400 mb-1">Portfolio Value</div>
          <div className="text-2xl font-bold">{formatCurrency(portfolio.total_value)}</div>
          <div className={`text-sm ${portfolio.total_returns >= 0 ? 'text-green-400' : 'text-red-400'}`}>
            {formatCurrency(portfolio.total_returns)} ({formatPercent(portfolio.returns_percent)})
          </div>
        </Link>
      )}

      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        {indices.map((ix) => (
          <div key={ix.symbol} className="bg-card border border-border rounded-xl p-3">
            <div className="text-xs text-gray-500 uppercase">{ix.symbol}</div>
            <div className="text-lg font-bold">{formatCurrency(ix.price)}</div>
            <div className={`text-xs ${ix.change >= 0 ? 'text-green-400' : 'text-red-400'}`}>
              {formatCurrency(ix.change)} ({formatPercent(ix.change_percent)})
            </div>
          </div>
        ))}
      </div>

      <div className="grid md:grid-cols-2 gap-6">
        <div className="bg-card border border-border rounded-xl p-4">
          <h2 className="font-semibold mb-3 text-green-400">Top Gainers</h2>
          <div className="space-y-2">
            {gainers.slice(0, 5).map((g) => (
              <Link key={g.symbol} href={`/dashboard/markets/${g.symbol}`}
                className="flex justify-between items-center py-1.5 border-b border-border/50 last:border-0 hover:bg-white/5 px-2 -mx-2 rounded transition-colors">
                <div>
                  <div className="text-sm font-medium">{g.symbol}</div>
                  <div className="text-xs text-gray-500">{g.name}</div>
                </div>
                <div className="text-green-400 text-sm font-medium">{formatPercent(g.change_percent)}</div>
              </Link>
            ))}
          </div>
        </div>
        <div className="bg-card border border-border rounded-xl p-4">
          <h2 className="font-semibold mb-3 text-red-400">Top Losers</h2>
          <div className="space-y-2">
            {losers.slice(0, 5).map((l) => (
              <Link key={l.symbol} href={`/dashboard/markets/${l.symbol}`}
                className="flex justify-between items-center py-1.5 border-b border-border/50 last:border-0 hover:bg-white/5 px-2 -mx-2 rounded transition-colors">
                <div>
                  <div className="text-sm font-medium">{l.symbol}</div>
                  <div className="text-xs text-gray-500">{l.name}</div>
                </div>
                <div className="text-red-400 text-sm font-medium">{formatPercent(l.change_percent)}</div>
              </Link>
            ))}
          </div>
        </div>
      </div>

      <div className="bg-card border border-border rounded-xl p-4">
        <div className="flex justify-between items-center mb-3">
          <h2 className="font-semibold">Latest News</h2>
          <Link href="/dashboard/news" className="text-xs text-brand hover:underline">View all</Link>
        </div>
        <div className="space-y-3">
          {news.slice(0, 3).map((article) => (
            <a key={article.id} href={article.url} target="_blank" rel="noopener noreferrer"
              className="block border-b border-border/50 last:border-0 pb-3 last:pb-0 hover:bg-white/5 px-2 -mx-2 rounded transition-colors">
              <div className="text-sm font-medium mb-1">{article.title}</div>
              <div className="text-xs text-gray-500">{article.source} · {new Date(article.published_at).toLocaleDateString()}</div>
            </a>
          ))}
        </div>
      </div>
    </div>
  );
}