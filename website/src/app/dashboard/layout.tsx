'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useState } from 'react';

const links = [
  { href: '/dashboard', label: 'Home', icon: '📊' },
  { href: '/dashboard/markets', label: 'Markets', icon: '📈' },
  { href: '/dashboard/watchlist', label: 'Watchlist', icon: '⭐' },
  { href: '/dashboard/news', label: 'News', icon: '📰' },
  { href: '/dashboard/ai', label: 'AI Chat', icon: '🤖' },
  { href: '/dashboard/portfolio', label: 'Portfolio', icon: '💰' },
];

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const [open, setOpen] = useState(false);

  return (
    <div className="min-h-screen flex">
      <aside className={`${open ? 'block' : 'hidden'} md:flex flex-col w-64 bg-surface border-r border-border fixed md:static inset-y-0 z-40`}>
        <div className="p-4 border-b border-border">
          <Link href="/" className="flex items-center gap-2">
            <img src="/logo.svg" alt="" className="h-7 w-7" />
            <span className="font-bold text-lg">FinSwitch</span>
          </Link>
        </div>
        <nav className="flex-1 p-3 space-y-1">
          {links.map((l) => {
            const active = pathname === l.href || (l.href !== '/dashboard' && pathname.startsWith(l.href));
            return (
              <Link key={l.href} href={l.href}
                className={`flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-colors ${
                  active ? 'bg-brand/20 text-brand font-medium' : 'text-gray-400 hover:text-white hover:bg-white/5'
                }`}
                onClick={() => setOpen(false)}>
                <span>{l.icon}</span> {l.label}
              </Link>
            );
          })}
        </nav>
        <div className="p-4 border-t border-border">
          <a href="/" className="text-xs text-gray-500 hover:text-gray-300">← Back to site</a>
        </div>
      </aside>
      {open && <div className="fixed inset-0 bg-black/50 z-30 md:hidden" onClick={() => setOpen(false)} />}
      <div className="flex-1 flex flex-col min-h-screen">
        <header className="h-14 border-b border-border flex items-center px-4 bg-surface/50 backdrop-blur-sm sticky top-0 z-20">
          <button className="md:hidden mr-3 text-gray-400" onClick={() => setOpen(!open)}>☰</button>
          <h1 className="text-sm font-medium text-gray-300">Dashboard</h1>
        </header>
        <main className="flex-1 p-4 md:p-6">{children}</main>
      </div>
    </div>
  );
}
