'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/lib/supabase';

export default function LoginPage() {
  const [identifier, setIdentifier] = useState('+91 9876543210');
  const [name, setName] = useState('Omkar Batwal');
  const [step, setStep] = useState<1 | 2>(1); // 1: Send OTP, 2: Verify OTP
  const [otp, setOtp] = useState(['', '', '', '', '', '']);
  const [sentOtp, setSentOtp] = useState('123456');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const router = useRouter();

  const handleSendOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!identifier.trim()) return;
    setLoading(true);
    setError('');

    try {
      if (identifier.includes('@')) {
        await supabase.auth.signInWithOtp({ email: identifier.trim() });
      }
      setSentOtp('123456');
    } catch (_) {
      setSentOtp('123456');
    }

    setLoading(false);
    setStep(2);
  };

  const handleVerifyOtp = async (e?: React.FormEvent) => {
    if (e) e.preventDefault();
    const entered = otp.join('');
    if (entered.length < 6) {
      setError('Please enter complete 6-digit OTP');
      return;
    }

    setLoading(true);
    setError('');

    if (entered === sentOtp || entered === '123456') {
      try {
        if (identifier.includes('@')) {
          await supabase.auth.verifyOtp({
            email: identifier.trim(),
            token: entered,
            type: 'email',
          });
        }
      } catch (_) {
        // Fallback login
      }
      router.push('/dashboard');
    } else {
      setError('Invalid OTP code. Try 123456');
      setLoading(false);
    }
  };

  const handleOtpChange = (index: number, value: string) => {
    if (value.length > 1) value = value.slice(-1);
    const newOtp = [...otp];
    newOtp[index] = value;
    setOtp(newOtp);

    // Auto-focus next field
    if (value && index < 5) {
      const nextInput = document.getElementById(`otp-input-${index + 1}`);
      nextInput?.focus();
    }
  };

  const handleKeyDown = (index: number, e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Backspace' && !otp[index] && index > 0) {
      const prevInput = document.getElementById(`otp-input-${index - 1}`);
      prevInput?.focus();
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-background px-4">
      <div className="w-full max-w-md bg-card border border-border rounded-2xl p-8 shadow-2xl">
        <div className="text-center mb-8">
          <div className="h-12 w-12 rounded-xl bg-brand/10 text-brand flex items-center justify-center mx-auto mb-3 font-bold text-xl">
            FS
          </div>
          <h1 className="text-2xl font-bold">{step === 1 ? 'Sign In / Register' : 'Verify OTP'}</h1>
          <p className="text-gray-400 text-sm mt-1">
            {step === 1 ? 'Enter your details to receive a 6-digit verification code' : `Enter the 6-digit OTP sent to ${identifier}`}
          </p>
        </div>

        {step === 1 ? (
          <form onSubmit={handleSendOtp} className="space-y-4">
            <div>
              <label className="text-xs font-semibold text-gray-400 mb-1 block">Full Name</label>
              <input
                type="text"
                required
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="Omkar Batwal"
                className="w-full bg-background border border-border rounded-xl px-4 py-3 text-sm focus:outline-none focus:border-brand"
              />
            </div>
            <div>
              <label className="text-xs font-semibold text-gray-400 mb-1 block">Mobile Number or Email</label>
              <input
                type="text"
                required
                value={identifier}
                onChange={(e) => setIdentifier(e.target.value)}
                placeholder="+91 9876543210 or user@example.com"
                className="w-full bg-background border border-border rounded-xl px-4 py-3 text-sm focus:outline-none focus:border-brand"
              />
            </div>

            {error && <div className="text-xs text-red-400 mt-1">{error}</div>}

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-brand hover:bg-brand-hover text-black font-bold py-3 rounded-xl transition-all disabled:opacity-50 mt-2"
            >
              {loading ? 'Sending OTP...' : 'Send Verification Code'}
            </button>
          </form>
        ) : (
          <form onSubmit={handleVerifyOtp} className="space-y-6">
            <div className="bg-brand/10 border border-brand/20 rounded-xl p-3 text-xs text-brand flex items-center justify-between">
              <span>Demo Verification Code:</span>
              <span className="font-mono font-bold text-sm">{sentOtp}</span>
            </div>

            <div className="flex justify-between gap-2">
              {otp.map((digit, idx) => (
                <input
                  key={idx}
                  id={`otp-input-${idx}`}
                  type="text"
                  inputMode="numeric"
                  maxLength={1}
                  value={digit}
                  onChange={(e) => handleOtpChange(idx, e.target.value)}
                  onKeyDown={(e) => handleKeyDown(idx, e)}
                  className="w-12 h-14 bg-background border border-border rounded-xl text-center text-xl font-bold text-white focus:outline-none focus:border-brand"
                />
              ))}
            </div>

            {error && <div className="text-xs text-red-400 text-center">{error}</div>}

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-brand hover:bg-brand-hover text-black font-bold py-3 rounded-xl transition-all disabled:opacity-50"
            >
              {loading ? 'Verifying...' : 'Verify & Continue'}
            </button>

            <div className="flex items-center justify-between text-xs text-gray-400">
              <button type="button" onClick={() => setStep(1)} className="hover:text-white">
                Change Number / Email
              </button>
              <button type="button" onClick={handleSendOtp} className="text-brand hover:underline">
                Resend OTP
              </button>
            </div>
          </form>
        )}
      </div>
    </div>
  );
}