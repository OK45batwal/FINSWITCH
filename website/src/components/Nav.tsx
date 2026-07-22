'use client';

import Link from 'next/link';

export default function Nav() {
  return (
    <nav className="bg-surface/80 backdrop-blur-md border-b border-border fixed w-full top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 h-16 flex items-center justify-between">
        <Link href="/" className="flex items-center gap-2">
          <img src="/logo.svg" alt="FinSwitch" className="h-8 w-8" />
          <span className="text-xl font-bold">FinSwitch</span>
        </Link>
        <div className="flex items-center gap-6">
          <Link href="/#features" className="text-gray-400 hover:text-white text-sm">Features</Link>
          <Link href="/#download" className="text-gray-400 hover:text-white text-sm">Download</Link>
          <Link href="/dashboard" className="bg-brand hover:bg-brand-hover text-black px-4 py-2 rounded-lg text-sm font-semibold">Dashboard</Link>
        </div>
      </div>
    </nav>
  );
}
