'use client';

import { useState, useRef, useEffect } from 'react';
import { chatWithAI } from '@/lib/api';

interface Message {
  role: 'user' | 'ai';
  text: string;
}

export default function AIChatPage() {
  const [messages, setMessages] = useState<Message[]>([
    { role: 'ai', text: 'Hi! I\'m your AI financial analyst. Ask me about any stock, market trends, or investment questions.' },
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const bottomRef = useRef<HTMLDivElement>(null);

  useEffect(() => { bottomRef.current?.scrollIntoView({ behavior: 'smooth' }); }, [messages]);

  const send = async () => {
    if (!input.trim() || loading) return;
    const userMsg = input.trim();
    setInput('');
    setMessages((m) => [...m, { role: 'user', text: userMsg }]);
    setLoading(true);
    try {
      const res = await chatWithAI(userMsg);
      setMessages((m) => [...m, { role: 'ai', text: res.response }]);
    } catch {
      setMessages((m) => [...m, { role: 'ai', text: 'Sorry, analysis failed. Is the backend running?' }]);
    }
    setLoading(false);
  };

  return (
    <div className="flex flex-col h-[calc(100vh-10rem)]">
      <h1 className="text-xl font-bold mb-4">AI Financial Analyst</h1>
      <div className="flex-1 overflow-y-auto space-y-4 mb-4 pr-2">
        {messages.map((m, i) => (
          <div key={i} className={`flex ${m.role === 'user' ? 'justify-end' : 'justify-start'}`}>
            <div className={`max-w-[80%] rounded-xl px-4 py-2.5 text-sm ${
              m.role === 'user'
                ? 'bg-brand/20 text-white border border-brand/30'
                : 'bg-card border border-border text-gray-300'
            }`}>
              {m.text}
            </div>
          </div>
        ))}
        {loading && <div className="text-gray-500 text-sm">Thinking...</div>}
        <div ref={bottomRef} />
      </div>
      <div className="flex gap-2">
        <input
          value={input} onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && send()}
          placeholder="Ask about a stock..."
          className="flex-1 bg-background border border-border rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:border-brand"
        />
        <button onClick={send} disabled={loading}
          className="bg-brand hover:bg-brand-hover text-black px-4 py-2.5 rounded-lg font-semibold text-sm transition-colors disabled:opacity-50">
          Send
        </button>
      </div>
    </div>
  );
}
