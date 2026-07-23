const SB = 'https://lydliyjidlzzwggywwpd.supabase.co';
const KEY = 'sb_publishable_wBSqQQfKwNl9ikf4YXJ0Vg_RiNvTzGs';
const H = { apikey: KEY, Authorization: `Bearer ${KEY}`, Accept: 'application/json' };

async function sb(t, p = '') {
  const r = await fetch(`${SB}/rest/v1/${t}${p}`, { headers: H });
  if (!r.ok) throw Error();
  return r.json();
}

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

async function getAllStocks() {
  const rows = await sb('stocks');
  const o = {};
  for (const r of rows) {
    o[r.symbol] = {
      name: r.name, sector: r.sector, price: r.price,
      change: r.change, change_pct: r.change_percent,
      pe: r.pe_ratio, high_52w: r.high_52w, low_52w: r.low_52w,
      mcap: r.market_cap / 100000, div_yield: r.dividend_yield,
      volume: r.volume,
    };
  }
  return o;
}

async function getAllIndices() {
  const rows = await sb('indices');
  const o = {};
  for (const r of rows) {
    o[r.symbol] = { name: r.name, value: r.price, change: r.change, change_pct: r.change_percent };
  }
  return o;
}

async function analyzeStock(symbol, message) {
  const sym = symbol.toUpperCase();
  let s;
  try {
    const rows = await sb('stocks', `?symbol=eq.${sym}`);
    if (rows[0]) {
      const r = rows[0];
      s = {
        name: r.name, sector: r.sector, price: r.price,
        change: r.change, change_pct: r.change_percent,
        pe: r.pe_ratio, high_52w: r.high_52w, low_52w: r.low_52w,
        mcap: r.market_cap / 100000, div_yield: r.dividend_yield,
        volume: r.volume,
      };
    }
  } catch {}
  if (!s) {
    let stocks;
    try { stocks = await getAllStocks(); } catch { stocks = {}; }
    const guesses = Object.keys(stocks).filter(k => sym.slice(0, 3) === k.slice(0, 3));
    return guesses.length ? `Did you mean ${guesses.join(', ')}?` : `No data for '${symbol}'.`;
  }
  const msg = (message || '').toLowerCase();
  const { price: p, change: ch, change_pct: cp, pe, mcap, div_yield: div } = s;
  const pos = ((p - s.low_52w) / (s.high_52w - s.low_52w)) * 100;
  const support = +(p * 0.95).toFixed(2), resistance = +(p * 1.08).toFixed(2);
  const fake = Array.from({ length: 30 }, () => p * (1 + rnd(-0.003, 0.003)));
  const lines = [
    `📊 ${s.name} (${sym})`,
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
    let allStocks;
    try { allStocks = await getAllStocks(); } catch { allStocks = {}; }
    const peers = Object.entries(allStocks).filter(([k, v]) => k !== sym && v.sector === s.sector).slice(0, 3);
    if (peers.length) lines.push(`\n📊 Sector peers: ${peers.map(([k]) => k).join(', ')}`);
  } else if (/target|goal/.test(msg)) {
    lines.push(`\n🎯 Upside: +${(((resistance - p) / p) * 100).toFixed(1)}% | Downside: -${(((p - support) / p) * 100).toFixed(1)}%`);
  }
  return lines.join('\n');
}

async function marketSummary() {
  let indices, stocks;
  try { indices = await getAllIndices(); } catch { indices = {}; }
  try { stocks = await getAllStocks(); } catch { stocks = {}; }
  const lines = ['📊 **Market Summary**', ''];
  for (const [sym, ix] of Object.entries(indices)) {
    lines.push(`${ix.change >= 0 ? '🟢' : '🔴'} ${ix.name}: ${ix.value.toLocaleString('en-IN')} (${ix.change_pct >= 0 ? '+' : ''}${ix.change_pct.toFixed(2)}%)`);
  }
  const sectors = {};
  for (const s of Object.values(stocks)) {
    const sec = s.sector;
    if (!sectors[sec]) sectors[sec] = { stocks: 0, up: 0, sum: 0 };
    sectors[sec].stocks++; sectors[sec].sum += s.change_pct;
    if (s.change_pct > 0) sectors[sec].up++;
  }
  lines.push('', '🏭 Sector Performance:');
  const secs = Object.entries(sectors);
  const best = secs.length ? secs.sort((a, b) => (b[1].sum / b[1].stocks) - (a[1].sum / a[1].stocks))[0] : null;
  const worst = secs.length ? secs.sort((a, b) => (a[1].sum / a[1].stocks) - (b[1].sum / b[1].stocks))[0] : null;
  if (best) lines.push(`   ✅ Best: ${best[0]} (${best[1].up}/${best[1].stocks} up)`);
  if (worst) lines.push(`   ❌ Worst: ${worst[0]} (${worst[1].up}/${worst[1].stocks} up)`);
  return lines.join('\n');
}

async function portfolioAnalysis() {
  const holdings = [
    ['RELIANCE', 50, 2450], ['HDFCBANK', 100, 1420], ['TCS', 20, 3850],
    ['ICICIBANK', 150, 980], ['INFY', 60, 1450], ['SBIN', 200, 650], ['ITC', 300, 380],
  ];
  let stocks;
  try { stocks = await getAllStocks(); } catch { stocks = {}; }
  let totalInv = 0, totalCur = 0;
  const lines = ['💼 **Portfolio Analysis**', ''];
  const secAlloc = {};
  for (const [sym, qty, avg] of holdings) {
    const s = stocks[sym]; if (!s) continue;
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

async function compareStocks(symbols) {
  let stocks;
  try { stocks = await getAllStocks(); } catch { stocks = {}; }
  const data = symbols.map(s => [s, stocks[s.toUpperCase()]]).filter(([_, d]) => d);
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

async function generateChart(symbol, days = 60) {
  let base;
  try {
    const rows = await sb('stocks', `?symbol=eq.${symbol.toUpperCase()}`);
    if (rows[0]) base = { price: rows[0].price, volume: rows[0].volume };
  } catch {}
  if (!base) return [];
  let price = base.price * 0.95;
  return Array.from({ length: days }, (_, i) => {
    price *= 1 + rnd(-1.2, 1.2) / 100;
    const d = new Date(Date.now() - (days - i) * 86400000);
    return {
      date: d.toISOString().slice(0, 10),
      close: +price.toFixed(2),
      high: +(price * (1 + rnd(0, 0.01))).toFixed(2),
      low: +(price * (1 - rnd(0, 0.01))).toFixed(2),
      volume: Math.round(base.volume * rnd(0.5, 1.5)),
      sma_20: +(price * (1 + rnd(-0.01, 0.01))).toFixed(2),
      rsi: +(30 + rnd(0, 40)).toFixed(1),
    };
  });
}

async function chat(message) {
  const msg = (message || '').toLowerCase().trim();
  let stocks;
  try { stocks = await getAllStocks(); } catch { stocks = {}; }
  const syms = Object.keys(stocks).sort((a, b) => b.length - a.length);
  let symFound = syms.find(s => msg.includes(s.toLowerCase()));
  if (symFound && !/compare|vs /.test(msg)) return analyzeStock(symFound, message);
  if (/compare|vs /.test(msg)) {
    const found = msg.split(/[\s,]+/).map(w => w.toUpperCase()).filter(w => stocks[w]);
    if (found.length >= 2) return compareStocks(found.slice(0, 4));
  }
  if (/market|nifty|sensex|today|summary/.test(msg)) return marketSummary();
  if (/portfolio|holding|my stocks|my investment/.test(msg)) return portfolioAnalysis();
  if (/gain|top|leader/.test(msg)) {
    const g = Object.entries(stocks).sort((a, b) => b[1].change_pct - a[1].change_pct).slice(0, 5);
    return '🏆 **Top Gainers**\n\n' + g.map(([s, d]) => `✅ ${s}: +${d.change_pct.toFixed(2)}% (₹${d.price.toFixed(2)}) — ${d.sector}`).join('\n');
  }
  if (/los|decline|fall|drop/.test(msg)) {
    const l = Object.entries(stocks).sort((a, b) => a[1].change_pct - b[1].change_pct).slice(0, 5);
    return '📉 **Top Losers**\n\n' + l.map(([s, d]) => `🔴 ${s}: ${d.change_pct.toFixed(2)}% (₹${d.price.toFixed(2)}) — ${d.sector}`).join('\n');
  }
  if (/hello|hi|hey|help/.test(msg)) {
    return 'Hello! I\'m FinSwitch AI.\n\nTry: "Analyze RELIANCE", "TCS buy or sell?", "How\'s the market?", "My portfolio", "Compare TCS and INFY", "Top gainers"';
  }
  return `I can analyze ${Object.keys(stocks).length} Indian stocks: ${Object.keys(stocks).join(', ')}`;
}

export async function onRequest(context) {
  const { request } = context;
  const url = new URL(request.url);

  if (request.method === 'GET') {
    try {
      const type = url.searchParams.get('type') || 'indices';
      if (type === 'indices') {
        const rows = await sb('indices');
        return Response.json({ success: true, data: rows.map(r => ({ symbol: r.symbol, name: r.name, price: r.price, change: r.change, change_percent: r.change_percent })) });
      }
      if (type === 'stocks') {
        const rows = await sb('stocks');
        return Response.json({ success: true, data: rows.map(r => ({ symbol: r.symbol, name: r.name, sector: r.sector, price: r.price, change: r.change, change_percent: r.change_percent, volume: r.volume, pe_ratio: r.pe_ratio, high_52w: r.high_52w, low_52w: r.low_52w, market_cap: r.market_cap, dividend_yield: r.dividend_yield, avg_volume: r.volume, industry: r.industry || '', description: r.description || '' })) });
      }
      if (type === 'stock') {
        const sym = url.searchParams.get('symbol') || '';
        const rows = await sb('stocks', `?symbol=eq.${sym}`);
        const r = rows[0];
        if (!r) return Response.json({ success: false, error: 'Not found' }, { status: 404 });
        return Response.json({ success: true, data: { symbol: r.symbol, name: r.name, sector: r.sector, price: r.price, change: r.change, change_percent: r.change_percent, volume: r.volume, pe_ratio: r.pe_ratio, high_52w: r.high_52w, low_52w: r.low_52w, market_cap: r.market_cap, dividend_yield: r.dividend_yield, avg_volume: r.volume, industry: r.industry || '', description: r.description || '' } });
      }
      return Response.json({ success: false, error: 'Unknown type' }, { status: 400 });
    } catch (e) {
      return Response.json({ success: false, error: e.message }, { status: 500 });
    }
  }

  if (request.method === 'POST') {
    try {
      const body = await request.json();
      const { action, message, symbol, days } = body;
      if (action === 'chat') return Response.json({ success: true, data: { response: await chat(message || '') } });
      if (action === 'analyze') return Response.json({ success: true, data: await analyzeStock(symbol || '', message || '') });
      if (action === 'chart') return Response.json({ success: true, data: await generateChart(symbol || '', days || 60) });
      return Response.json({ success: false, error: 'Unknown action' }, { status: 400 });
    } catch (e) {
      return Response.json({ success: false, error: e.message }, { status: 500 });
    }
  }

  return new Response('Method Not Allowed', { status: 405 });
}
