'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [pw, setPw] = useState('');
  const router = useRouter();

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    localStorage.setItem('finswitch_user', JSON.stringify({ email }));
    router.push('/dashboard');
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-background px-4">
      <div className="w-full max-w-sm bg-card border border-border rounded-2xl p-8">
        <div className="text-center mb-8">
          <img src="/logo.svg" alt="" className="h-10 w-10 mx-auto mb-3" />
          <h1 className="text-2xl font-bold">Sign In</h1>
          <p className="text-gray-500 text-sm mt-1">Access your dashboard</p>
        </div>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="text-sm text-gray-400 mb-1 block">Email</label>
            <input type="email" required value={email} onChange={(e) => setEmail(e.target.value)}
              className="w-full bg-background border border-border rounded-lg px-3 py-2 text-sm focus:outline-none focus:border-brand" />
          </div>
          <div>
            <label className="text-sm text-gray-400 mb-1 block">Password</label>
            <input type="password" required value={pw} onChange={(e) => setPw(e.target.value)}
              className="w-full bg-background border border-border rounded-lg px-3 py-2 text-sm focus:outline-none focus:border-brand" />
          </div>
          <button type="submit" className="w-full bg-brand hover:bg-brand-hover text-black font-semibold py-2.5 rounded-lg transition-colors">
            Sign In
          </button>
        </form>
        <p className="text-center text-sm text-gray-500 mt-6">
          No account?{' '}
          <a href="/login" className="text-brand hover:underline">Create one</a>
        </p>
      </div>
    </div>
  );
}
