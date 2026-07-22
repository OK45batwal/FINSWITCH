// Cloudflare Pages Function: /api/ai
const STOCKS = {
  RELIANCE: { name: 'Reliance Industries Ltd', sector: 'Oil & Gas', price: 2845.30, change: 32.50, change_pct: 1.16, pe: 24.5, high_52w: 3200, low_52w: 2200, mcap: 1925000, div_yield: 0.35, volume: 12400000 },
  TCS: { name: 'Tata Consultancy Services', sector: 'IT', price: 3920.00, change: -18.40, change_pct: -0.47, pe: 28.6, high_52w: 4200, low_52w: 3300, mcap: 1450000, div_yield: 1.20, volume: 3800000 },
  HDFCBANK: { name: 'HDFC Bank Ltd', sector: 'Banking', price: 1635.75, change: 8.90, change_pct: 0.55, pe: 18.5, high_52w: 1800, low_52w: 1360, mcap: 940000, div_yield: 1.05, volume: 18200000 },
  INFY: { name: 'Infosys Ltd', sector: 'IT', price: 1482.55, change: -12.20, change_pct: -0.82, pe: 26.2, high_52w: 1750, low_52w: 1350, mcap: 620000, div_yield: 1.80, volume: 8600000 },
  ICICIBANK: { name: 'ICICI Bank Ltd', sector: 'Banking', price: 1124.90, change: 6.75, change_pct: 0.60, pe: 17.8, high_52w: 1250, low_52w: 900, mcap: 820000, div_yield: 0.80, volume: 14100000 },
  SBIN: { name: 'State Bank of India', sector: 'Banking', price: 782.30, change: 4.50, change_pct: 0.58, pe: 12.3, high_52w: 900, low_52w: 570, mcap: 710000, div_yield: 3.20, volume: 22500000 },
  BHARTIARTL: { name: 'Bharti Airtel Ltd', sector: 'Telecom', price: 1345.60, change: 15.80, change_pct: 1.19, pe: 32.1, high_52w: 1500, low_52w: 1050, mcap: 780000, div_yield: 0.45, volume: 7300000 },
  ITC: { name: 'ITC Ltd', sector: 'FMCG', price: 432.15, change: -2.30, change_pct: -0.53, pe: 22.4, high_52w: 520, low_52w: 380, mcap: 545000, div_yield: 3.80, volume: 25100000 },
  WIPRO: { name: 'Wipro Ltd', sector: 'IT', price: 512.40, change: 3.20, change_pct: 0.63, pe: 18.5, high_52w: 600, low_52w: 380, mcap: 290000, div_yield: 2.10, volume: 5400000 },
  HINDUNILVR: { name: 'Hindustan Unilever Ltd', sector: 'FMCG', price: 2345.60, change: -5.80, change_pct: -0.25, pe: 45.2, high_52w: 2700, low_52w: 2200, mcap: 550000, div_yield: 1.65, volume: 2100000 },
  MARUTI: { name: 'Maruti Suzuki India Ltd', sector: 'Automobile', price: 11230.00, change: 45.20, change_pct: 0.40, pe: 28.0, high_52w: 13500, low_52w: 9500, mcap: 340000, div_yield: 0.50, volume: 890000 },
  BAJFINANCE: { name: 'Bajaj Finance Ltd', sector: 'NBFC', price: 7245.30, change: 56.80, change_pct: 0.79, pe: 31.5, high_52w: 8200, low_52w: 5800, mcap: 430000, div_yield: 0.30, volume: 1200000 },
};

const INDICES = {
  NIFTY: { name: 'Nifty 50', value: 23456.80, change: 128.45, change_pct: 0.55 },
  SENSEX: { name: 'S&P BSE Sensex', value: 77123.45, change: 342.10, change_pct: 0.44 },
  BANKNIFTY: { name: 'Bank Nifty', value: 49234.55, change: -87.30, change_pct: -0.18 },
};

function rnd(min, max) { return Math.random() * (max - min) + min; }

function rsiStr(price, pe = 20) {
  const rsi = Math.min(85, Math.max(15, 50 + (pe > 30 ? 15 : pe < 15 ? -15 : 0)));
  if (rsi > 70) return `RSI ${rsi.toFixed(1)} (overbought)`;
  if (rsi < 30) return `RSI ${rsi.toFixed(1)} (oversold)`;
  return `RSI ${rsi.toFixed(1)} (neutral)`;
}

function smaTrend(prices) {
  if (prices.length < 25) return 'Insufficient data';
  const sma = prices.slice(-20).reduce((a, b) => a + b, 0) / 20;
  const above = prices[prices.length - 1] > sma;
  return `Price ${above ? 'above' : 'below'} SMA(20) — ${above ? 'uptrend' : 'downtrend'}`;
}

function analyzeStock(symbol, message) {
  const s = STOCKS[symbol.toUpperCase()];
  if (!s) {
    const guesses = Object.keys(STOCKS).filter(k => symbol.toUpperCase().slice(0, 3) === k.slice(0, 3));
    return guesses.length ? `Did you mean ${guesses.join(', ')}?` : `No data for '${symbol}'. Available: ${Object.keys(STOCKS).join(', ')}.`;
  }
  const msg = (message || '').toLowerCase();
  const { price: p, change: ch, change_pct: cp, pe, mcap, div_yield: div } = s;
  const pos = ((p - s.low_52w) / (s.high_52w - s.low_52w)) * 100;
  const support = +(p * 0.95).toFixed(2), resistance = +(p * 1.08).toFixed(2);
  const fake = Array.from({ length: 30 }, () => p * (1 + rnd(-0.003, 0.003)));
  const lines = [
    `📊 ${s.name} (${symbol})`,
    `💰 Price: ₹${p.toLocaleString('en-IN')} (${ch >= 0 ? '+' : ''}${ch.toFixed(2)} | ${cp >= 0 ? '+' : ''}${cp.toFixed(2)}%)`,
    `📈 Range: ₹${s.low_52w.toLocaleString('en-IN')} – ₹${s.high_52w.toLocaleString('en-IN')} (52wk: ${pos.toFixed(0)}%)`,
    `📐 P/E: ${pe} | M-Cap: ₹${(mcap / 100000).toFixed(1)}L Cr | Div Yield: ${div}%`,
    `📉 Support: ₹${support.toLocaleString('en-IN')} | Resistance: ₹${resistance.toLocaleString('en-IN')}`,
    `📊 ${smaTrend(fake)}`,
    `📊 ${rsiStr(p)}`,
  ];
  if (/buy|recommend|should i/.test(msg)) {
    let score = 0;
    if (pe < 20) score++; if (pe < 15) score++;
    if (cp > 0) score++; if (div > 1.5) score++; if (div > 3) score++;
    if (s.volume > 10000000) score++;
    const verdicts = ['Avoid ⚠️ — weak signals', 'Hold ⏸️ — wait for better entry', 'Accumulate 📈 — decent fundamentals', 'Strong Buy ✅'];
    lines.push(`\n💡 ${verdicts[Math.min(score, 3)]}`);
  } else if (/compare/.test(msg)) {
    const peers = Object.entries(STOCKS).filter(([k, v]) => k !== symbol.toUpperCase() && v.sector === s.sector).slice(0, 3);
    if (peers.length) lines.push(`\n📊 Sector peers: ${peers.map(([k]) => k).join(', ')}`);
  } else if (/target|goal/.test(msg)) {
    lines.push(`\n🎯 Upside: +${(((resistance - p) / p) * 100).toFixed(1)}% | Downside: -${(((p - support) / p) * 100).toFixed(1)}%`);
  }
  return lines.join('\n');
}

function marketSummary() {
  const lines = ['📊 **Market Summary**', ''];
  for (const [sym, ix] of Object.entries(INDICES)) {
    lines.push(`${ix.change >= 0 ? '🟢' : '🔴'} ${ix.name}: ${ix.value.toLocaleString('en-IN')} (${ix.change_pct >= 0 ? '+' : ''}${ix.change_pct.toFixed(2)}%)`);
  }
  const sectors = {};
  for (const s of Object.values(STOCKS)) {
    const sec = s.sector;
    if (!sectors[sec]) sectors[sec] = { stocks: 0, up: 0, sum: 0 };
    sectors[sec].stocks++; sectors[sec].sum += s.change_pct;
    if (s.change_pct > 0) sectors[sec].up++;
  }
  lines.push('', '🏭 Sector Performance:');
  const best = Object.entries(sectors).sort((a, b) => (b[1].sum / b[1].stocks) - (a[1].sum / a[1].stocks))[0];
  const worst = Object.entries(sectors).sort((a, b) => (a[1].sum / a[1].stocks) - (b[1].sum / b[1].stocks))[0];
  if (best) lines.push(`   ✅ Best: ${best[0]} (${best[1].up}/${best[1].stocks} up)`);
  if (worst) lines.push(`   ❌ Worst: ${worst[0]} (${worst[1].up}/${worst[1].stocks} up)`);
  return lines.join('\n');
}

function portfolioAnalysis() {
  const holdings = [
    ['RELIANCE', 50, 2450], ['HDFCBANK', 100, 1420], ['TCS', 20, 3850],
    ['ICICIBANK', 150, 980], ['INFY', 60, 1450], ['SBIN', 200, 650], ['ITC', 300, 380],
  ];
  let totalInv = 0, totalCur = 0;
  const lines = ['💼 **Portfolio Analysis**', ''];
  const secAlloc = {};
  for (const [sym, qty, avg] of holdings) {
    const s = STOCKS[sym]; if (!s) continue;
    const inv = qty * avg, cur = qty * s.price;
    const pl = cur - inv, pct = (pl / inv) * 100;
    totalInv += inv; totalCur += cur;
    lines.push(`${pl >= 0 ? '🟢' : '🔴'} ${sym}: ${qty}sh @ avg ₹${avg.toLocaleString('en-IN')} → ₹${s.price.toFixed(2)} (${pl >= 0 ? '+' : ''}${pct.toFixed(1)}%)`);
    const sec = s.sector;
    secAlloc[sec] = (secAlloc[sec] || 0) + cur;
  }
  const totalPl = totalCur - totalInv, totalPct = (totalPl / totalInv) * 100;
  lines.push('', `📊 Total: ₹${totalInv.toLocaleString('en-IN')} → ₹${totalCur.toLocaleString('en-IN')} (${totalPl >= 0 ? '+' : ''}₹${totalPl.toLocaleString('en-IN')} | ${totalPct >= 0 ? '+' : ''}${totalPct.toFixed(1)}%)`);
  lines.push('', '📊 Sector Allocation:');
  for (const [sec, val] of Object.entries(secAlloc).sort((a, b) => b[1] - a[1])) {
    lines.push(`   ${sec}: ${((val / totalCur) * 100).toFixed(0)}%`);
  }
  return lines.join('\n');
}

function compareStocks(symbols) {
  const data = symbols.map(s => [s, STOCKS[s.toUpperCase()]]).filter(([_, d]) => d);
  if (data.length < 2) return 'Need 2 known stocks to compare.';
  const lines = ['📊 **Stock Comparison**', ''];
  const metrics = [
    ['Price', d => `₹${d.price.toFixed(2)}`],
    ['Change%', d => `${d.change_pct > 0 ? '+' : ''}${d.change_pct.toFixed(2)}%`],
    ['P/E', d => `${d.pe}`],
    ['M-Cap', d => `₹${(d.mcap / 100000).toFixed(1)}L`],
    ['Div Yield', d => `${d.div_yield}%`],
    ['Volume', d => `${(d.volume / 10000000).toFixed(1)}Cr`],
  ];
  for (const [name, fn] of metrics) {
    lines.push(`${name.padEnd(16)} ${data.map(([s, d]) => `${fn(d).padEnd(16)}`).join('')}`);
  }
  return lines.join('\n');
}

function generateChart(symbol, days = 60) {
  const s = STOCKS[symbol.toUpperCase()];
  if (!s) return [];
  let price = s.price * 0.95;
  return Array.from({ length: days }, (_, i) => {
    price *= 1 + rnd(-1.2, 1.2) / 100;
    const d = new Date(Date.now() - (days - i) * 86400000);
    return {
      date: d.toISOString().slice(0, 10),
      close: +price.toFixed(2),
      high: +(price * (1 + rnd(0, 0.01))).toFixed(2),
      low: +(price * (1 - rnd(0, 0.01))).toFixed(2),
      volume: Math.round(s.volume * rnd(0.5, 1.5)),
      sma_20: +(price * (1 + rnd(-0.01, 0.01))).toFixed(2),
      rsi: +(30 + rnd(0, 40)).toFixed(1),
    };
  });
}

function chat(message) {
  const msg = (message || '').toLowerCase().trim();
  const syms = Object.keys(STOCKS).sort((a, b) => b.length - a.length);
  let symFound = syms.find(s => msg.includes(s.toLowerCase()));
  if (symFound && !/compare|vs /.test(msg)) return analyzeStock(symFound, message);
  if (/compare|vs /.test(msg)) {
    const found = msg.split(/[\s,]+/).map(w => w.toUpperCase()).filter(w => STOCKS[w]);
    if (found.length >= 2) return compareStocks(found.slice(0, 4));
  }
  if (/market|nifty|sensex|today|summary/.test(msg)) return marketSummary();
  if (/portfolio|holding|my stocks|my investment/.test(msg)) return portfolioAnalysis();
  if (/gain|top|leader/.test(msg)) {
    const g = Object.entries(STOCKS).sort((a, b) => b[1].change_pct - a[1].change_pct).slice(0, 5);
    return '🏆 **Top Gainers**\n\n' + g.map(([s, d]) => `✅ ${s}: +${d.change_pct.toFixed(2)}% (₹${d.price.toFixed(2)}) — ${d.sector}`).join('\n');
  }
  if (/los|decline|fall|drop/.test(msg)) {
    const l = Object.entries(STOCKS).sort((a, b) => a[1].change_pct - b[1].change_pct).slice(0, 5);
    return '📉 **Top Losers**\n\n' + l.map(([s, d]) => `🔴 ${s}: ${d.change_pct.toFixed(2)}% (₹${d.price.toFixed(2)}) — ${d.sector}`).join('\n');
  }
  if (/hello|hi|hey|help/.test(msg)) {
    return 'Hello! I\'m FinSwitch AI.\n\nTry: "Analyze RELIANCE", "TCS buy or sell?", "How\'s the market?", "My portfolio", "Compare TCS and INFY", "Top gainers"';
  }
  return `I can analyze ${Object.keys(STOCKS).length} Indian stocks: ${Object.keys(STOCKS).join(', ')}`;
}

export async function onRequest(context) {
  const { request } = context;
  const url = new URL(request.url);

  if (request.method === 'GET') {
    const type = url.searchParams.get('type') || 'indices';
    if (type === 'indices') {
      return Response.json({ success: true, data: Object.entries(INDICES).map(([symbol, ix]) => ({ symbol, name: ix.name, price: ix.value, change: ix.change, change_percent: ix.change_pct })) });
    }
    if (type === 'stocks') {
      return Response.json({ success: true, data: Object.entries(STOCKS).map(([symbol, s]) => ({ symbol, name: s.name, sector: s.sector, price: s.price, change: s.change, change_percent: s.change_pct, volume: s.volume, pe_ratio: s.pe, high_52w: s.high_52w, low_52w: s.low_52w, market_cap: s.mcap * 100000, dividend_yield: s.div_yield, avg_volume: s.volume, industry: '', description: '' })) });
    }
    if (type === 'stock') {
      const sym = url.searchParams.get('symbol') || '';
      const s = STOCKS[sym.toUpperCase()];
      if (!s) return Response.json({ success: false, error: 'Not found' }, { status: 404 });
      return Response.json({ success: true, data: { symbol: sym.toUpperCase(), name: s.name, sector: s.sector, price: s.price, change: s.change, change_percent: s.change_pct, volume: s.volume, pe_ratio: s.pe, high_52w: s.high_52w, low_52w: s.low_52w, market_cap: s.mcap * 100000, dividend_yield: s.div_yield, avg_volume: s.volume, industry: '', description: '' } });
    }
    return Response.json({ success: false, error: 'Unknown type' }, { status: 400 });
  }

  if (request.method === 'POST') {
    try {
      const body = await request.json();
      const { action, message, symbol, days } = body;
      if (action === 'chat') return Response.json({ success: true, data: { response: chat(message || '') } });
      if (action === 'analyze') return Response.json({ success: true, data: analyzeStock(symbol || '', message || '') });
      if (action === 'chart') return Response.json({ success: true, data: generateChart(symbol || '', days || 60) });
      return Response.json({ success: false, error: 'Unknown action' }, { status: 400 });
    } catch (e) {
      return Response.json({ success: false, error: e.message }, { status: 500 });
    }
  }

  return new Response('Method Not Allowed', { status: 405 });
}
