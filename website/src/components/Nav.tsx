'use client';

import Link from 'next/link';
import { ThemeToggle } from './ThemeProvider';

export default function Nav() {
  return (
    <nav className="bg-surface/80 backdrop-blur-md border-b border-border fixed w-full top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 h-16 flex items-center justify-between">
        <Link href="/" className="flex items-center gap-2.5">
          <img src="/logo.svg" alt="FinSwitch" className="h-8 w-8" />
          <div className="flex flex-col">
            <span className="text-xl font-bold tracking-tight text-foreground">FinSwitch</span>
            <span className="text-[9px] font-bold text-brand tracking-widest -mt-1 uppercase">SWITCH. SAVE. SMARTER.</span>
          </div>
        </Link>
        <div className="flex items-center gap-4">
          <Link href="/#features" className="text-muted hover:text-foreground text-sm font-medium hidden sm:inline-block">Features</Link>
          <Link href="/#download" className="text-muted hover:text-foreground text-sm font-medium hidden sm:inline-block">Download</Link>
          <ThemeToggle />
          <Link href="/dashboard" className="bg-brand hover:bg-brand-hover text-black px-4 py-2 rounded-xl text-sm font-bold shadow-sm transition-all">Dashboard</Link>
        </div>
      </div>
    </nav>
  );
}
