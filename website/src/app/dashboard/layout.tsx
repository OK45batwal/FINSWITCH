'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { ThemeToggle } from '@/components/ThemeProvider';

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
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [checkingAuth, setCheckingAuth] = useState(true);

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      if (!data?.session) {
        router.replace('/login');
        return;
      }
      setCheckingAuth(false);
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((event) => {
      if (event === 'SIGNED_OUT') {
        router.replace('/login');
      }
    });

    return () => subscription.unsubscribe();
  }, [router]);

  if (checkingAuth) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center bg-background text-gray-400">
        <div className="w-8 h-8 border-2 border-brand border-t-transparent rounded-full animate-spin mb-3"></div>
        <p className="text-xs font-medium">Verifying session...</p>
      </div>
    );
  }

  const handleSignOut = async () => {
    await supabase.auth.signOut();
    router.replace('/login');
  };

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
        <div className="p-4 border-t border-border flex items-center justify-between">
          <Link href="/" className="text-xs text-gray-500 hover:text-gray-300">← Back to site</Link>
          <button onClick={handleSignOut} className="text-xs text-red-400 hover:text-red-300 font-medium">Sign Out</button>
        </div>
      </aside>
      {open && <div className="fixed inset-0 bg-black/50 z-30 md:hidden" onClick={() => setOpen(false)} />}
      <div className="flex-1 flex flex-col min-h-screen">
        <header className="h-14 border-b border-border flex items-center justify-between px-4 bg-surface/50 backdrop-blur-sm sticky top-0 z-20">
          <div className="flex items-center gap-3">
            <button className="md:hidden text-gray-400" onClick={() => setOpen(!open)}>☰</button>
            <h1 className="text-sm font-medium text-muted">Dashboard</h1>
          </div>
          <div className="flex items-center gap-3">
            <ThemeToggle />
            <button onClick={handleSignOut} className="text-xs text-red-400 hover:text-red-300 font-medium">Sign Out</button>
          </div>
        </header>
        <main className="flex-1 p-4 md:p-6">{children}</main>
      </div>
    </div>
  );
}
