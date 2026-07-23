'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/lib/supabase';
import Link from 'next/link';

const SUPABASE_CONFIGURED = !!(process.env.NEXT_PUBLIC_SUPABASE_URL && process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY);

export default function LoginPage() {
  const [mode, setMode] = useState<'login' | 'register'>('login');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [name, setName] = useState('');
  const [rememberMe, setRememberMe] = useState(true);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const router = useRouter();

  useEffect(() => {
    const sub = supabase.auth.onAuthStateChange((event) => {
      if (event === 'SIGNED_IN') router.push('/dashboard');
    }).data.subscription;
    return () => sub.unsubscribe();
  }, [router]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email.trim() || !email.includes('@')) { setError('Please enter a valid email address'); return; }
    if (!password || password.length < 6) { setError('Password must be at least 6 characters'); return; }
    if (mode === 'register' && password !== confirmPassword) { setError('Passwords do not match'); return; }

    setLoading(true);
    setError('');

    try {
      if (mode === 'register') {
        const { error: signUpError } = await supabase.auth.signUp({
          email: email.trim(),
          password,
          options: { data: { full_name: name.trim() } },
        });
        if (signUpError) {
          if (signUpError.message.includes('already registered')) {
            setError('This email is already registered. Please sign in instead.');
          } else {
            setError(signUpError.message);
          }
          setLoading(false); return;
        }
      } else {
        const { error: signInError } = await supabase.auth.signInWithPassword({
          email: email.trim(),
          password,
        });
        if (signInError) {
          if (signInError.message.includes('Invalid login credentials')) {
            setError('Invalid email or password. Please try again.');
          } else {
            setError(signInError.message);
          }
          setLoading(false); return;
        }
      }

      router.push('/dashboard');
    } catch {
      if (!SUPABASE_CONFIGURED) {
        localStorage.setItem('finswitch_session',
          JSON.stringify({ user: email.trim(), name: name.trim() || 'User', loggedInAt: Date.now(), remember: rememberMe }));
        router.push('/dashboard');
      } else {
        setError('Connection error. Please try again.');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-background px-4 py-12">
      <div className="w-full max-w-md bg-card border border-border rounded-2xl p-8 shadow-2xl">
        <div className="text-center mb-6">
          <Link href="/" className="inline-flex items-center gap-2 mb-3">
            <img src="/logo.svg" alt="FinSwitch" className="h-10 w-10" />
            <div className="text-left">
              <div className="text-xl font-bold tracking-tight text-foreground">FinSwitch</div>
              <div className="text-[8px] font-bold text-brand tracking-widest uppercase">SWITCH. SAVE. SMARTER.</div>
            </div>
          </Link>
          <h1 className="text-2xl font-bold text-foreground">
            {mode === 'login' ? 'Sign In to FinSwitch' : 'Create an Account'}
          </h1>
          <p className="text-muted text-xs mt-1">
            {mode === 'login'
              ? 'Enter your credentials to access your market intelligence dashboard'
              : 'Sign up to start tracking your portfolio with AI insights'}
          </p>
        </div>

        <div className="flex bg-background border border-border rounded-xl p-1 mb-6">
          <button type="button" onClick={() => { setMode('login'); setError(''); }}
            className={`flex-1 py-2 text-xs font-semibold rounded-lg transition-all ${mode === 'login' ? 'bg-surface text-foreground shadow-sm' : 'text-muted hover:text-foreground'}`}>
            Sign In
          </button>
          <button type="button" onClick={() => { setMode('register'); setError(''); }}
            className={`flex-1 py-2 text-xs font-semibold rounded-lg transition-all ${mode === 'register' ? 'bg-surface text-foreground shadow-sm' : 'text-muted hover:text-foreground'}`}>
            Register
          </button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          {mode === 'register' && (
            <div>
              <label className="text-xs font-semibold text-muted mb-1 block">Full Name</label>
              <input type="text" value={name} onChange={(e) => setName(e.target.value)}
                placeholder="John Doe"
                className="w-full bg-background border border-border rounded-xl px-4 py-3 text-sm focus:outline-none focus:border-brand text-foreground" />
            </div>
          )}

          <div>
            <label className="text-xs font-semibold text-muted mb-1 block">Email Address</label>
            <input type="email" required value={email} onChange={(e) => setEmail(e.target.value)}
              placeholder="you@example.com"
              className="w-full bg-background border border-border rounded-xl px-4 py-3 text-sm focus:outline-none focus:border-brand text-foreground" />
          </div>

          <div>
            <label className="text-xs font-semibold text-muted mb-1 block">Password</label>
            <div className="relative">
              <input type={showPassword ? 'text' : 'password'} required value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••••••"
                className="w-full bg-background border border-border rounded-xl pl-4 pr-12 py-3 text-sm focus:outline-none focus:border-brand text-foreground" />
              <button type="button" onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-muted hover:text-foreground text-sm font-medium px-1">
                {showPassword ? 'Hide' : 'Show'}
              </button>
            </div>
          </div>

          {mode === 'register' && (
            <div>
              <label className="text-xs font-semibold text-muted mb-1 block">Confirm Password</label>
              <input type={showPassword ? 'text' : 'password'} required value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                placeholder="••••••••••••"
                className="w-full bg-background border border-border rounded-xl px-4 py-3 text-sm focus:outline-none focus:border-brand text-foreground" />
            </div>
          )}

          {mode === 'login' && (
            <div className="flex items-center justify-between text-xs text-muted pt-1">
              <label className="flex items-center gap-2 cursor-pointer">
                <input type="checkbox" checked={rememberMe}
                  onChange={(e) => setRememberMe(e.target.checked)}
                  className="rounded border-border bg-background text-brand focus:ring-brand" />
                <span>Remember me</span>
              </label>
              <a href="#" onClick={(e) => { e.preventDefault(); setError('Password reset not yet available through this interface.'); }}
                className="text-brand hover:underline">Forgot password?</a>
            </div>
          )}

          {error && <div className="text-xs text-red-400 mt-1">{error}</div>}

          <button type="submit" disabled={loading}
            className="w-full bg-brand hover:bg-brand-hover text-black font-bold py-3 rounded-xl transition-all disabled:opacity-50 mt-2 text-sm">
            {loading ? (mode === 'login' ? 'Signing In...' : 'Creating Account...')
              : (mode === 'login' ? 'Sign In' : 'Create Account')}
          </button>
        </form>

        <div className="mt-6 text-center text-xs text-muted">
          {mode === 'login' ? (
            <span>Don&apos;t have an account?{' '}
              <button type="button" onClick={() => { setMode('register'); setError(''); }}
                className="text-brand font-semibold hover:underline">Register</button>
            </span>
          ) : (
            <span>Already have an account?{' '}
              <button type="button" onClick={() => { setMode('login'); setError(''); }}
                className="text-brand font-semibold hover:underline">Sign In</button>
            </span>
          )}
        </div>

        <div className="mt-6 pt-4 border-t border-border text-center text-xs text-muted flex items-center justify-center gap-1.5">
          <span>📧 Official Support Email:</span>
          <a href="mailto:finswitch74@gmail.com" className="text-brand font-mono font-medium hover:underline">
            finswitch74@gmail.com
          </a>
        </div>
      </div>
    </div>
  );
}
