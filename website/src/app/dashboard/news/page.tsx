'use client';

import { useEffect, useState } from 'react';
import { getNews, type NewsItem } from '@/lib/api';

export default function NewsPage() {
  const [news, setNews] = useState<NewsItem[]>([]);

  useEffect(() => { getNews().then(setNews).catch(() => {}); }, []);

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-bold">Financial News</h1>
      <div className="space-y-3">
        {news.map((a) => (
          <a key={a.id} href={a.url} target="_blank" rel="noopener noreferrer"
            className="block bg-card border border-border rounded-xl p-4 hover:border-brand/50 transition-colors">
            <div className="text-sm text-gray-500 mb-1">
              {a.source} · {a.symbol && `${a.symbol} · `}{new Date(a.published_at).toLocaleDateString()}
            </div>
            <div className="font-medium mb-1">{a.title}</div>
            <div className="text-sm text-gray-400">{a.summary}</div>
          </a>
        ))}
      </div>
    </div>
  );
}
