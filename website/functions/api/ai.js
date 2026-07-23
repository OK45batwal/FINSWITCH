const SUPABASE_URL = 'https://lydliyjidlzzwggywwpd.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_wBSqQQfKwNl9ikf4YXJ0Vg_RiNvTzGs';
const SUPABASE_HEADERS = {
  apikey: SUPABASE_ANON_KEY,
  Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
  Accept: 'application/json',
};

// --- In-Memory Rate Limiter (Sliding Window per IP) ---
const RATE_LIMIT_WINDOW_MS = 60 * 1000;
const MAX_REQUESTS_PER_WINDOW = 30;
const ipRequestMap = new Map();

function isRateLimited(ip) {
  const now = Date.now();
  if (ipRequestMap.size > 10000) {
    ipRequestMap.clear();
  }
  const record = ipRequestMap.get(ip);
  if (!record || now > record.resetTime) {
    ipRequestMap.set(ip, { count: 1, resetTime: now + RATE_LIMIT_WINDOW_MS });
    return false;
  }
  record.count += 1;
  return record.count > MAX_REQUESTS_PER_WINDOW;
}

// --- Supabase REST Client Helper ---
async function fetchSupabaseTable(table, queryParams = '') {
  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/${table}${queryParams}`, {
      headers: SUPABASE_HEADERS,
    });
    if (!response.ok) {
      console.error(`[AI Function Error]: Supabase query failed for table '${table}' (status: ${response.status})`);
      throw new Error(`Supabase query failed for ${table}`);
    }
    return await response.json();
  } catch (error) {
    console.error(`[AI Function Error]: Failed to fetch Supabase table '${table}':`, error);
    throw error;
  }
}

function getRandomRange(min, max) {
  return Math.random() * (max - min) + min;
}

function formatRsiStatus(price, peRatio = 20) {
  const rsi = Math.min(85, Math.max(15, 50 + (peRatio > 30 ? 15 : peRatio < 15 ? -15 : 0)));
  if (rsi > 70) return `RSI ${rsi.toFixed(1)} (overbought)`;
  if (rsi < 30) return `RSI ${rsi.toFixed(1)} (oversold)`;
  return `RSI ${rsi.toFixed(1)} (neutral)`;
}

function formatSmaTrend(prices) {
  if (prices.length < 25) return 'Insufficient data';
  const sma20 = prices.slice(-20).reduce((sum, p) => sum + p, 0) / 20;
  const currentPrice = prices[prices.length - 1];
  const isAboveSma = currentPrice > sma20;
  return `Price ${isAboveSma ? 'above' : 'below'} SMA(20) — ${isAboveSma ? 'uptrend' : 'downtrend'}`;
}

async function getAllStocks() {
  const rows = await fetchSupabaseTable('stocks');
  const stockMap = {};
  for (const row of rows) {
    stockMap[row.symbol] = {
      name: row.name,
      sector: row.sector,
      price: row.price,
      change: row.change,
      change_pct: row.change_percent,
      pe: row.pe_ratio,
      high_52w: row.high_52w,
      low_52w: row.low_52w,
      mcap: row.market_cap / 100000,
      div_yield: row.dividend_yield,
      volume: row.volume,
    };
  }
  return stockMap;
}

async function getAllIndices() {
  const rows = await fetchSupabaseTable('indices');
  const indexMap = {};
  for (const row of rows) {
    indexMap[row.symbol] = {
      name: row.name,
      value: row.price,
      change: row.change,
      change_pct: row.change_percent,
    };
  }
  return indexMap;
}

async function analyzeStock(symbol, message) {
  const sanitizedSymbol = symbol.toUpperCase();
  let stockData = null;

  try {
    const rows = await fetchSupabaseTable('stocks', `?symbol=eq.${encodeURIComponent(sanitizedSymbol)}`);
    if (rows && rows[0]) {
      const row = rows[0];
      stockData = {
        name: row.name,
        sector: row.sector,
        price: row.price,
        change: row.change,
        change_pct: row.change_percent,
        pe: row.pe_ratio,
        high_52w: row.high_52w,
        low_52w: row.low_52w,
        mcap: row.market_cap / 100000,
        div_yield: row.dividend_yield,
        volume: row.volume,
      };
    }
  } catch (error) {
    console.error(`[AI Function Error]: Error querying stock details for symbol '${sanitizedSymbol}':`, error);
  }

  if (!stockData) {
    let allStocks = {};
    try {
      allStocks = await getAllStocks();
    } catch (error) {
      console.error('[AI Function Error]: Failed to get all stocks for fallback search:', error);
    }
    const guesses = Object.keys(allStocks).filter(k => sanitizedSymbol.slice(0, 3) === k.slice(0, 3));
    return guesses.length
      ? `Did you mean ${guesses.join(', ')}?`
      : `No data found for stock '${symbol}'.`;
  }

  const userMsg = (message || '').toLowerCase();
  const { price, change, change_pct: changePct, pe, mcap, div_yield: divYield } = stockData;
  const fiftyTwoWeekRangePos = ((price - stockData.low_52w) / (stockData.high_52w - stockData.low_52w)) * 100;
  const supportPrice = +(price * 0.95).toFixed(2);
  const resistancePrice = +(price * 1.08).toFixed(2);
  const simulatedPrices = Array.from({ length: 30 }, () => price * (1 + getRandomRange(-0.003, 0.003)));

  const lines = [
    `📊 ${stockData.name} (${sanitizedSymbol})`,
    `💰 Price: ₹${price.toLocaleString('en-IN')} (${change >= 0 ? '+' : ''}${change.toFixed(2)} | ${changePct >= 0 ? '+' : ''}${changePct.toFixed(2)}%)`,
    `📈 Range: ₹${stockData.low_52w.toLocaleString('en-IN')} – ₹${stockData.high_52w.toLocaleString('en-IN')} (52wk: ${fiftyTwoWeekRangePos.toFixed(0)}%)`,
    `📐 P/E: ${pe} | M-Cap: ₹${(mcap / 100000).toFixed(1)}L Cr | Div Yield: ${divYield}%`,
    `📉 Support: ₹${supportPrice.toLocaleString('en-IN')} | Resistance: ₹${resistancePrice.toLocaleString('en-IN')}`,
    `📊 ${formatSmaTrend(simulatedPrices)}`,
    `📊 ${formatRsiStatus(price, pe)}`,
  ];

  if (/buy|recommend|should i/.test(userMsg)) {
    let buyScore = 0;
    if (pe < 20) buyScore++;
    if (pe < 15) buyScore++;
    if (changePct > 0) buyScore++;
    if (divYield > 1.5) buyScore++;
    if (divYield > 3) buyScore++;
    if (stockData.volume > 10000000) buyScore++;
    const verdicts = [
      'Avoid ⚠️ — weak signals',
      'Hold ⏸️ — wait for better entry',
      'Accumulate 📈 — decent fundamentals',
      'Strong Buy ✅',
    ];
    lines.push(`\n💡 ${verdicts[Math.min(buyScore, 3)]}`);
  } else if (/compare/.test(userMsg)) {
    let allStocks = {};
    try {
      allStocks = await getAllStocks();
    } catch (error) {
      console.error('[AI Function Error]: Failed to fetch stocks for peer comparison:', error);
    }
    const sectorPeers = Object.entries(allStocks)
      .filter(([ticker, s]) => ticker !== sanitizedSymbol && s.sector === stockData.sector)
      .slice(0, 3);
    if (sectorPeers.length) {
      lines.push(`\n📊 Sector peers: ${sectorPeers.map(([ticker]) => ticker).join(', ')}`);
    }
  } else if (/target|goal/.test(userMsg)) {
    const upsidePct = (((resistancePrice - price) / price) * 100).toFixed(1);
    const downsidePct = (((price - supportPrice) / price) * 100).toFixed(1);
    lines.push(`\n🎯 Upside: +${upsidePct}% | Downside: -${downsidePct}%`);
  }

  return lines.join('\n');
}

async function marketSummary() {
  let indexMap = {};
  let stockMap = {};
  try {
    indexMap = await getAllIndices();
  } catch (error) {
    console.error('[AI Function Error]: Failed to fetch indices for market summary:', error);
  }
  try {
    stockMap = await getAllStocks();
  } catch (error) {
    console.error('[AI Function Error]: Failed to fetch stocks for market summary:', error);
  }

  const lines = ['📊 **Market Summary**', ''];

  for (const [, indexInfo] of Object.entries(indexMap)) {
    const icon = indexInfo.change >= 0 ? '🟢' : '🔴';
    const sign = indexInfo.change_pct >= 0 ? '+' : '';
    lines.push(`${icon} ${indexInfo.name}: ${indexInfo.value.toLocaleString('en-IN')} (${sign}${indexInfo.change_pct.toFixed(2)}%)`);
  }

  const sectorPerformance = {};
  for (const stockInfo of Object.values(stockMap)) {
    const sec = stockInfo.sector;
    if (!sectorPerformance[sec]) {
      sectorPerformance[sec] = { totalCount: 0, upCount: 0, sumChangePct: 0 };
    }
    sectorPerformance[sec].totalCount++;
    sectorPerformance[sec].sumChangePct += stockInfo.change_pct;
    if (stockInfo.change_pct > 0) sectorPerformance[sec].upCount++;
  }

  lines.push('', '🏭 Sector Performance:');
  const sectorEntries = Object.entries(sectorPerformance);
  const bestSector = sectorEntries.length
    ? [...sectorEntries].sort((a, b) => (b[1].sumChangePct / b[1].totalCount) - (a[1].sumChangePct / a[1].totalCount))[0]
    : null;
  const worstSector = sectorEntries.length
    ? [...sectorEntries].sort((a, b) => (a[1].sumChangePct / a[1].totalCount) - (b[1].sumChangePct / b[1].totalCount))[0]
    : null;

  if (bestSector) {
    lines.push(`   ✅ Best: ${bestSector[0]} (${bestSector[1].upCount}/${bestSector[1].totalCount} up)`);
  }
  if (worstSector) {
    lines.push(`   ❌ Worst: ${worstSector[0]} (${worstSector[1].upCount}/${worstSector[1].totalCount} up)`);
  }

  return lines.join('\n');
}

async function portfolioAnalysis(userId) {
  if (!userId) {
    return '💼 **Portfolio Analysis**\n\nPlease sign in to view your personalized portfolio analysis.';
  }

  let userPortfolios = [];
  try {
    userPortfolios = await fetchSupabaseTable('portfolios', `?user_id=eq.${encodeURIComponent(userId)}`);
  } catch (error) {
    console.error(`[AI Function Error]: Failed to fetch portfolio for user '${userId}':`, error);
  }

  if (!userPortfolios || userPortfolios.length === 0) {
    return '💼 **Portfolio Analysis**\n\nYou do not have an active portfolio created yet.';
  }

  const portfolioId = userPortfolios[0].id;
  let userHoldings = [];
  try {
    userHoldings = await fetchSupabaseTable('holdings', `?portfolio_id=eq.${encodeURIComponent(portfolioId)}`);
  } catch (error) {
    console.error(`[AI Function Error]: Failed to fetch holdings for portfolio '${portfolioId}':`, error);
  }

  if (!userHoldings || userHoldings.length === 0) {
    return '💼 **Portfolio Analysis**\n\nYou don\'t have any holdings in your portfolio yet. Add holdings in the Portfolio tab to track them here!';
  }

  let stockMap = {};
  try {
    stockMap = await getAllStocks();
  } catch (error) {
    console.error('[AI Function Error]: Failed to fetch current stock prices for portfolio analysis:', error);
  }

  let totalInvested = 0;
  let totalCurrentValue = 0;
  const sectorAllocation = {};
  const lines = ['💼 **Your Portfolio Analysis**', ''];

  for (const holding of userHoldings) {
    const symbol = (holding.symbol || '').toUpperCase();
    const qty = holding.quantity || 0;
    const avgPrice = holding.avg_price || 0;
    const stockInfo = stockMap[symbol];

    const currentPrice = stockInfo ? stockInfo.price : avgPrice;
    const investedAmount = qty * avgPrice;
    const currentValue = qty * currentPrice;
    const pnl = currentValue - investedAmount;
    const pnlPct = investedAmount > 0 ? (pnl / investedAmount) * 100 : 0;

    totalInvested += investedAmount;
    totalCurrentValue += currentValue;

    const icon = pnl >= 0 ? '🟢' : '🔴';
    const sign = pnl >= 0 ? '+' : '';
    lines.push(`${icon} ${symbol}: ${qty} sh @ avg ₹${avgPrice.toLocaleString('en-IN')} → ₹${currentPrice.toFixed(2)} (${sign}${pnlPct.toFixed(1)}%)`);

    const sector = stockInfo ? stockInfo.sector : 'Other';
    sectorAllocation[sector] = (sectorAllocation[sector] || 0) + currentValue;
  }

  const totalPnl = totalCurrentValue - totalInvested;
  const totalPnlPct = totalInvested > 0 ? (totalPnl / totalInvested) * 100 : 0;
  const totalSign = totalPnl >= 0 ? '+' : '';

  lines.push('', `📊 Total Value: ₹${totalInvested.toLocaleString('en-IN')} → ₹${totalCurrentValue.toLocaleString('en-IN')} (${totalSign}₹${totalPnl.toLocaleString('en-IN')} | ${totalSign}${totalPnlPct.toFixed(1)}%)`);

  if (totalCurrentValue > 0) {
    lines.push('', '📊 Sector Allocation:');
    for (const [sector, value] of Object.entries(sectorAllocation).sort((a, b) => b[1] - a[1])) {
      const pct = ((value / totalCurrentValue) * 100).toFixed(0);
      lines.push(`   ${sector}: ${pct}%`);
    }
  }

  return lines.join('\n');
}

async function compareStocks(symbols) {
  let stockMap = {};
  try {
    stockMap = await getAllStocks();
  } catch (error) {
    console.error('[AI Function Error]: Failed to fetch stock map for comparison:', error);
  }

  const validStocks = symbols.map(s => [s, stockMap[s.toUpperCase()]]).filter(([, data]) => data);
  if (validStocks.length < 2) {
    return 'Need at least 2 known stock symbols to compare.';
  }

  const lines = ['📊 **Stock Comparison**', ''];
  const metrics = [
    ['Price', d => `₹${d.price.toFixed(2)}`],
    ['Change%', d => `${d.change_pct > 0 ? '+' : ''}${d.change_pct.toFixed(2)}%`],
    ['P/E', d => `${d.pe}`],
    ['M-Cap', d => `₹${(d.mcap / 100000).toFixed(1)}L`],
    ['Div Yield', d => `${d.div_yield}%`],
    ['Volume', d => `${(d.volume / 10000000).toFixed(1)}Cr`],
  ];

  for (const [metricName, formatter] of metrics) {
    lines.push(`${metricName.padEnd(16)} ${validStocks.map(([, data]) => `${formatter(data).padEnd(16)}`).join('')}`);
  }

  return lines.join('\n');
}

async function generateChart(symbol, days = 60) {
  let baseData = null;
  const sanitizedSymbol = symbol.toUpperCase();

  try {
    const rows = await fetchSupabaseTable('stocks', `?symbol=eq.${encodeURIComponent(sanitizedSymbol)}`);
    if (rows && rows[0]) {
      baseData = { price: rows[0].price, volume: rows[0].volume };
    }
  } catch (error) {
    console.error(`[AI Function Error]: Error querying stock price for chart '${sanitizedSymbol}':`, error);
  }

  if (!baseData) return [];

  let currentPrice = baseData.price * 0.95;
  const validDays = Math.min(Math.max(parseInt(days, 10) || 60, 1), 365);

  return Array.from({ length: validDays }, (_, i) => {
    currentPrice *= 1 + getRandomRange(-1.2, 1.2) / 100;
    const dateObj = new Date(Date.now() - (validDays - i) * 86400000);
    return {
      date: dateObj.toISOString().slice(0, 10),
      close: +currentPrice.toFixed(2),
      high: +(currentPrice * (1 + getRandomRange(0, 0.01))).toFixed(2),
      low: +(currentPrice * (1 - getRandomRange(0, 0.01))).toFixed(2),
      volume: Math.round(baseData.volume * getRandomRange(0.5, 1.5)),
      sma_20: +(currentPrice * (1 + getRandomRange(-0.01, 0.01))).toFixed(2),
      rsi: +(30 + getRandomRange(0, 40)).toFixed(1),
    };
  });
}

async function chat(message, userId) {
  const userMsg = (message || '').toLowerCase().trim();
  let stockMap = {};
  try {
    stockMap = await getAllStocks();
  } catch (error) {
    console.error('[AI Function Error]: Error fetching stock map in chat handler:', error);
  }

  const sortedSymbols = Object.keys(stockMap).sort((a, b) => b.length - a.length);
  const matchedSymbol = sortedSymbols.find(s => userMsg.includes(s.toLowerCase()));

  if (matchedSymbol && !/compare|vs /.test(userMsg)) {
    return analyzeStock(matchedSymbol, message);
  }
  if (/compare|vs /.test(userMsg)) {
    const symbolsFound = userMsg.split(/[\s,]+/).map(w => w.toUpperCase()).filter(w => stockMap[w]);
    if (symbolsFound.length >= 2) {
      return compareStocks(symbolsFound.slice(0, 4));
    }
  }
  if (/market|nifty|sensex|today|summary/.test(userMsg)) {
    return marketSummary();
  }
  if (/portfolio|holding|my stocks|my investment/.test(userMsg)) {
    return portfolioAnalysis(userId);
  }
  if (/gain|top|leader/.test(userMsg)) {
    const topGainers = Object.entries(stockMap)
      .sort((a, b) => b[1].change_pct - a[1].change_pct)
      .slice(0, 5);
    return '🏆 **Top Gainers**\n\n' + topGainers.map(([sym, d]) => `✅ ${sym}: +${d.change_pct.toFixed(2)}% (₹${d.price.toFixed(2)}) — ${d.sector}`).join('\n');
  }
  if (/los|decline|fall|drop/.test(userMsg)) {
    const topLosers = Object.entries(stockMap)
      .sort((a, b) => a[1].change_pct - b[1].change_pct)
      .slice(0, 5);
    return '📉 **Top Losers**\n\n' + topLosers.map(([sym, d]) => `🔴 ${sym}: ${d.change_pct.toFixed(2)}% (₹${d.price.toFixed(2)}) — ${d.sector}`).join('\n');
  }
  if (/hello|hi|hey|help/.test(userMsg)) {
    return 'Hello! I\'m FinSwitch AI.\n\nTry: "Analyze RELIANCE", "TCS buy or sell?", "How\'s the market?", "My portfolio", "Compare TCS and INFY", "Top gainers"';
  }

  return `I can analyze ${Object.keys(stockMap).length} Indian stocks: ${Object.keys(stockMap).join(', ')}`;
}

// --- Entry Point ---
export async function onRequest(context) {
  const { request } = context;
  const url = new URL(request.url);

  // Rate Limiting Check
  const clientIp = request.headers.get('cf-connecting-ip') || request.headers.get('x-forwarded-for') || '127.0.0.1';
  if (isRateLimited(clientIp)) {
    return Response.json({ success: false, error: 'Rate limit exceeded. Maximum 30 requests per minute.' }, { status: 429 });
  }

  if (request.method === 'GET') {
    try {
      const type = url.searchParams.get('type') || 'indices';
      const validTypes = ['indices', 'stocks', 'stock'];
      if (!validTypes.includes(type)) {
        return Response.json({ success: false, error: 'Invalid type parameter. Must be indices, stocks, or stock.' }, { status: 400 });
      }

      if (type === 'indices') {
        const rows = await fetchSupabaseTable('indices');
        return Response.json({
          success: true,
          data: rows.map(r => ({
            symbol: r.symbol,
            name: r.name,
            price: r.price,
            change: r.change,
            change_percent: r.change_percent,
          })),
        });
      }

      if (type === 'stocks') {
        const rows = await fetchSupabaseTable('stocks');
        return Response.json({
          success: true,
          data: rows.map(r => ({
            symbol: r.symbol,
            name: r.name,
            sector: r.sector,
            price: r.price,
            change: r.change,
            change_percent: r.change_percent,
            volume: r.volume,
            pe_ratio: r.pe_ratio,
            high_52w: r.high_52w,
            low_52w: r.low_52w,
            market_cap: r.market_cap,
            dividend_yield: r.dividend_yield,
            avg_volume: r.volume,
            industry: r.industry || '',
            description: r.description || '',
          })),
        });
      }

      if (type === 'stock') {
        const rawSymbol = url.searchParams.get('symbol') || '';
        const symbol = typeof rawSymbol === 'string'
          ? rawSymbol.trim().toUpperCase().slice(0, 20).replace(/[^A-Z0-9_-]/g, '')
          : '';

        if (!symbol) {
          return Response.json({ success: false, error: 'Symbol query parameter is required for type=stock' }, { status: 400 });
        }

        const rows = await fetchSupabaseTable('stocks', `?symbol=eq.${encodeURIComponent(symbol)}`);
        const r = rows[0];
        if (!r) return Response.json({ success: false, error: 'Stock not found' }, { status: 404 });
        return Response.json({
          success: true,
          data: {
            symbol: r.symbol,
            name: r.name,
            sector: r.sector,
            price: r.price,
            change: r.change,
            change_percent: r.change_percent,
            volume: r.volume,
            pe_ratio: r.pe_ratio,
            high_52w: r.high_52w,
            low_52w: r.low_52w,
            market_cap: r.market_cap,
            dividend_yield: r.dividend_yield,
            avg_volume: r.volume,
            industry: r.industry || '',
            description: r.description || '',
          },
        });
      }
    } catch (e) {
      console.error('[AI Function Error]: GET Handler Error:', e);
      return Response.json({ success: false, error: e.message || 'Internal Server Error' }, { status: 500 });
    }
  }

  if (request.method === 'POST') {
    try {
      let body;
      try {
        body = await request.json();
      } catch (jsonErr) {
        return Response.json({ success: false, error: 'Invalid JSON request body' }, { status: 400 });
      }

      const { action, message, symbol, days, user_id, userId } = body || {};
      const validActions = ['chat', 'analyze', 'chart'];

      if (!action || typeof action !== 'string' || !validActions.includes(action)) {
        return Response.json({ success: false, error: 'Invalid action parameter. Must be one of: chat, analyze, chart' }, { status: 400 });
      }

      const sanitizedMessage = typeof message === 'string' ? message.trim().slice(0, 1000) : '';
      const sanitizedSymbol = typeof symbol === 'string'
        ? symbol.trim().toUpperCase().slice(0, 20).replace(/[^A-Z0-9_-]/g, '')
        : '';
      const sanitizedDays = Math.min(Math.max(parseInt(days, 10) || 60, 1), 365);
      const rawUserId = user_id || userId;
      const sanitizedUserId = typeof rawUserId === 'string'
        ? rawUserId.trim().slice(0, 100).replace(/[^a-zA-Z0-9_-]/g, '')
        : '';

      if (action === 'chat') {
        return Response.json({
          success: true,
          data: { response: await chat(sanitizedMessage, sanitizedUserId) },
        });
      }

      if (action === 'analyze') {
        if (!sanitizedSymbol) {
          return Response.json({ success: false, error: 'Symbol parameter is required for analyze action' }, { status: 400 });
        }
        return Response.json({
          success: true,
          data: await analyzeStock(sanitizedSymbol, sanitizedMessage),
        });
      }

      if (action === 'chart') {
        if (!sanitizedSymbol) {
          return Response.json({ success: false, error: 'Symbol parameter is required for chart action' }, { status: 400 });
        }
        return Response.json({
          success: true,
          data: await generateChart(sanitizedSymbol, sanitizedDays),
        });
      }
    } catch (e) {
      console.error('[AI Function Error]: POST Handler Error:', e);
      return Response.json({ success: false, error: e.message || 'Internal Server Error' }, { status: 500 });
    }
  }

  return new Response('Method Not Allowed', { status: 405 });
}
