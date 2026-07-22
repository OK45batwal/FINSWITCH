import Nav from '@/components/Nav';
import Footer from '@/components/Footer';
import Link from 'next/link';

export default function Home() {
  return (
    <>
      <Nav />
      <main className="flex-1">
        <section className="pt-32 pb-20 px-4 text-center bg-gradient-to-b from-surface/50 to-transparent">
          <div className="max-w-4xl mx-auto">
            <h1 className="text-5xl md:text-7xl font-bold mb-6 leading-tight">
              Stock Market Intelligence,<br />
              <span className="text-brand">Powered by AI</span>
            </h1>
            <p className="text-xl text-gray-400 mb-10 max-w-2xl mx-auto">
              Real-time market data, AI-driven analysis, and portfolio tracking — all in one platform.
              Works offline on mobile. No API keys needed.
            </p>
            <div className="flex flex-wrap gap-4 justify-center mb-12">
              <Link href="/dashboard" className="bg-brand hover:bg-brand-hover text-black px-8 py-3 rounded-lg text-lg font-semibold">
                Launch Dashboard
              </Link>
              <a href="/downloads/finswitch.apk" className="border border-border hover:border-brand text-white px-8 py-3 rounded-lg text-lg">
                Download Android App
              </a>
            </div>
            <div className="grid grid-cols-3 gap-8 max-w-2xl mx-auto text-center">
              <div>
                <div className="text-3xl font-bold text-brand mb-1">10,000+</div>
                <div className="text-gray-500 text-sm">Market Coverage</div>
              </div>
              <div>
                <div className="text-3xl font-bold text-brand mb-1">60d</div>
                <div className="text-gray-500 text-sm">Historical Data</div>
              </div>
              <div>
                <div className="text-3xl font-bold text-brand mb-1">99%</div>
                <div className="text-gray-500 text-sm">Offline Ready</div>
              </div>
            </div>
          </div>
        </section>

        <section id="features" className="py-20 px-4">
          <div className="max-w-6xl mx-auto">
            <h2 className="text-3xl font-bold text-center mb-12">Everything you need</h2>
            <div className="grid md:grid-cols-3 gap-6">
              {[
                { title: 'Live Markets', desc: 'Real-time indices, gainers, losers, and sector performance. NSE & BSE coverage.' },
                { title: 'AI Analysis', desc: 'Buy/sell scores, fundamentals, and natural language chat about any stock.' },
                { title: 'Portfolio', desc: 'Track holdings, P&L, and returns across your investments.' },
                { title: 'Watchlist', desc: 'Follow your favorite stocks with instant price alerts.' },
                { title: 'News Feed', desc: 'Curated financial news with stock-specific relevance.' },
                { title: '60-Day Charts', desc: 'OHLCV data with RSI, SMA, and support/resistance levels.' },
              ].map((f) => (
                <div key={f.title} className="bg-card border border-border rounded-xl p-6 hover:border-brand/50 transition-colors">
                  <h3 className="text-lg font-semibold mb-2">{f.title}</h3>
                  <p className="text-gray-400 text-sm">{f.desc}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        <section id="download" className="py-20 px-4 bg-surface/30">
          <div className="max-w-4xl mx-auto text-center">
            <h2 className="text-3xl font-bold mb-4">Get Started</h2>
            <p className="text-gray-400 mb-8">Available as a web app or native Android application.</p>
            <div className="flex flex-wrap gap-4 justify-center">
              <Link href="/dashboard" className="bg-brand hover:bg-brand-hover text-black px-8 py-3 rounded-lg font-semibold">
                Web Dashboard
              </Link>
              <a href="/downloads/finswitch.apk" className="border border-border hover:border-brand text-white px-8 py-3 rounded-lg">
                Download APK
              </a>
            </div>
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}
