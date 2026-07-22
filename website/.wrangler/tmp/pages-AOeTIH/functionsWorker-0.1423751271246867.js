var __defProp = Object.defineProperty;
var __name = (target, value) => __defProp(target, "name", { value, configurable: true });

// api/ai.js
var STOCKS = {
  RELIANCE: { name: "Reliance Industries Ltd", sector: "Oil & Gas", price: 2845.3, change: 32.5, change_pct: 1.16, pe: 24.5, high_52w: 3200, low_52w: 2200, mcap: 1925e3, div_yield: 0.35, volume: 124e5 },
  TCS: { name: "Tata Consultancy Services", sector: "IT", price: 3920, change: -18.4, change_pct: -0.47, pe: 28.6, high_52w: 4200, low_52w: 3300, mcap: 145e4, div_yield: 1.2, volume: 38e5 },
  HDFCBANK: { name: "HDFC Bank Ltd", sector: "Banking", price: 1635.75, change: 8.9, change_pct: 0.55, pe: 18.5, high_52w: 1800, low_52w: 1360, mcap: 94e4, div_yield: 1.05, volume: 182e5 },
  INFY: { name: "Infosys Ltd", sector: "IT", price: 1482.55, change: -12.2, change_pct: -0.82, pe: 26.2, high_52w: 1750, low_52w: 1350, mcap: 62e4, div_yield: 1.8, volume: 86e5 },
  ICICIBANK: { name: "ICICI Bank Ltd", sector: "Banking", price: 1124.9, change: 6.75, change_pct: 0.6, pe: 17.8, high_52w: 1250, low_52w: 900, mcap: 82e4, div_yield: 0.8, volume: 141e5 },
  SBIN: { name: "State Bank of India", sector: "Banking", price: 782.3, change: 4.5, change_pct: 0.58, pe: 12.3, high_52w: 900, low_52w: 570, mcap: 71e4, div_yield: 3.2, volume: 225e5 },
  BHARTIARTL: { name: "Bharti Airtel Ltd", sector: "Telecom", price: 1345.6, change: 15.8, change_pct: 1.19, pe: 32.1, high_52w: 1500, low_52w: 1050, mcap: 78e4, div_yield: 0.45, volume: 73e5 },
  ITC: { name: "ITC Ltd", sector: "FMCG", price: 432.15, change: -2.3, change_pct: -0.53, pe: 22.4, high_52w: 520, low_52w: 380, mcap: 545e3, div_yield: 3.8, volume: 251e5 },
  WIPRO: { name: "Wipro Ltd", sector: "IT", price: 512.4, change: 3.2, change_pct: 0.63, pe: 18.5, high_52w: 600, low_52w: 380, mcap: 29e4, div_yield: 2.1, volume: 54e5 },
  HINDUNILVR: { name: "Hindustan Unilever Ltd", sector: "FMCG", price: 2345.6, change: -5.8, change_pct: -0.25, pe: 45.2, high_52w: 2700, low_52w: 2200, mcap: 55e4, div_yield: 1.65, volume: 21e5 },
  MARUTI: { name: "Maruti Suzuki India Ltd", sector: "Automobile", price: 11230, change: 45.2, change_pct: 0.4, pe: 28, high_52w: 13500, low_52w: 9500, mcap: 34e4, div_yield: 0.5, volume: 89e4 },
  BAJFINANCE: { name: "Bajaj Finance Ltd", sector: "NBFC", price: 7245.3, change: 56.8, change_pct: 0.79, pe: 31.5, high_52w: 8200, low_52w: 5800, mcap: 43e4, div_yield: 0.3, volume: 12e5 }
};
var INDICES = {
  NIFTY: { name: "Nifty 50", value: 23456.8, change: 128.45, change_pct: 0.55 },
  SENSEX: { name: "S&P BSE Sensex", value: 77123.45, change: 342.1, change_pct: 0.44 },
  BANKNIFTY: { name: "Bank Nifty", value: 49234.55, change: -87.3, change_pct: -0.18 }
};
function rnd(min, max) {
  return Math.random() * (max - min) + min;
}
__name(rnd, "rnd");
function rsiStr(price, pe = 20) {
  const rsi = Math.min(85, Math.max(15, 50 + (pe > 30 ? 15 : pe < 15 ? -15 : 0)));
  if (rsi > 70) return `RSI ${rsi.toFixed(1)} (overbought)`;
  if (rsi < 30) return `RSI ${rsi.toFixed(1)} (oversold)`;
  return `RSI ${rsi.toFixed(1)} (neutral)`;
}
__name(rsiStr, "rsiStr");
function smaTrend(prices) {
  if (prices.length < 25) return "Insufficient data";
  const sma = prices.slice(-20).reduce((a, b) => a + b, 0) / 20;
  const above = prices[prices.length - 1] > sma;
  return `Price ${above ? "above" : "below"} SMA(20) \u2014 ${above ? "uptrend" : "downtrend"}`;
}
__name(smaTrend, "smaTrend");
function analyzeStock(symbol, message) {
  const s = STOCKS[symbol.toUpperCase()];
  if (!s) {
    const guesses = Object.keys(STOCKS).filter((k) => symbol.toUpperCase().slice(0, 3) === k.slice(0, 3));
    return guesses.length ? `Did you mean ${guesses.join(", ")}?` : `No data for '${symbol}'. Available: ${Object.keys(STOCKS).join(", ")}.`;
  }
  const msg = (message || "").toLowerCase();
  const { price: p, change: ch, change_pct: cp, pe, mcap, div_yield: div } = s;
  const pos = (p - s.low_52w) / (s.high_52w - s.low_52w) * 100;
  const support = +(p * 0.95).toFixed(2), resistance = +(p * 1.08).toFixed(2);
  const fake = Array.from({ length: 30 }, () => p * (1 + rnd(-3e-3, 3e-3)));
  const lines = [
    `\u{1F4CA} ${s.name} (${symbol})`,
    `\u{1F4B0} Price: \u20B9${p.toLocaleString("en-IN")} (${ch >= 0 ? "+" : ""}${ch.toFixed(2)} | ${cp >= 0 ? "+" : ""}${cp.toFixed(2)}%)`,
    `\u{1F4C8} Range: \u20B9${s.low_52w.toLocaleString("en-IN")} \u2013 \u20B9${s.high_52w.toLocaleString("en-IN")} (52wk: ${pos.toFixed(0)}%)`,
    `\u{1F4D0} P/E: ${pe} | M-Cap: \u20B9${(mcap / 1e5).toFixed(1)}L Cr | Div Yield: ${div}%`,
    `\u{1F4C9} Support: \u20B9${support.toLocaleString("en-IN")} | Resistance: \u20B9${resistance.toLocaleString("en-IN")}`,
    `\u{1F4CA} ${smaTrend(fake)}`,
    `\u{1F4CA} ${rsiStr(p)}`
  ];
  if (/buy|recommend|should i/.test(msg)) {
    let score = 0;
    if (pe < 20) score++;
    if (pe < 15) score++;
    if (cp > 0) score++;
    if (div > 1.5) score++;
    if (div > 3) score++;
    if (s.volume > 1e7) score++;
    const verdicts = ["Avoid \u26A0\uFE0F \u2014 weak signals", "Hold \u23F8\uFE0F \u2014 wait for better entry", "Accumulate \u{1F4C8} \u2014 decent fundamentals", "Strong Buy \u2705"];
    lines.push(`
\u{1F4A1} ${verdicts[Math.min(score, 3)]}`);
  } else if (/compare/.test(msg)) {
    const peers = Object.entries(STOCKS).filter(([k, v]) => k !== symbol.toUpperCase() && v.sector === s.sector).slice(0, 3);
    if (peers.length) lines.push(`
\u{1F4CA} Sector peers: ${peers.map(([k]) => k).join(", ")}`);
  } else if (/target|goal/.test(msg)) {
    lines.push(`
\u{1F3AF} Upside: +${((resistance - p) / p * 100).toFixed(1)}% | Downside: -${((p - support) / p * 100).toFixed(1)}%`);
  }
  return lines.join("\n");
}
__name(analyzeStock, "analyzeStock");
function marketSummary() {
  const lines = ["\u{1F4CA} **Market Summary**", ""];
  for (const [sym, ix] of Object.entries(INDICES)) {
    lines.push(`${ix.change >= 0 ? "\u{1F7E2}" : "\u{1F534}"} ${ix.name}: ${ix.value.toLocaleString("en-IN")} (${ix.change_pct >= 0 ? "+" : ""}${ix.change_pct.toFixed(2)}%)`);
  }
  const sectors = {};
  for (const s of Object.values(STOCKS)) {
    const sec = s.sector;
    if (!sectors[sec]) sectors[sec] = { stocks: 0, up: 0, sum: 0 };
    sectors[sec].stocks++;
    sectors[sec].sum += s.change_pct;
    if (s.change_pct > 0) sectors[sec].up++;
  }
  lines.push("", "\u{1F3ED} Sector Performance:");
  const best = Object.entries(sectors).sort((a, b) => b[1].sum / b[1].stocks - a[1].sum / a[1].stocks)[0];
  const worst = Object.entries(sectors).sort((a, b) => a[1].sum / a[1].stocks - b[1].sum / b[1].stocks)[0];
  if (best) lines.push(`   \u2705 Best: ${best[0]} (${best[1].up}/${best[1].stocks} up)`);
  if (worst) lines.push(`   \u274C Worst: ${worst[0]} (${worst[1].up}/${worst[1].stocks} up)`);
  return lines.join("\n");
}
__name(marketSummary, "marketSummary");
function portfolioAnalysis() {
  const holdings = [
    ["RELIANCE", 50, 2450],
    ["HDFCBANK", 100, 1420],
    ["TCS", 20, 3850],
    ["ICICIBANK", 150, 980],
    ["INFY", 60, 1450],
    ["SBIN", 200, 650],
    ["ITC", 300, 380]
  ];
  let totalInv = 0, totalCur = 0;
  const lines = ["\u{1F4BC} **Portfolio Analysis**", ""];
  const secAlloc = {};
  for (const [sym, qty, avg] of holdings) {
    const s = STOCKS[sym];
    if (!s) continue;
    const inv = qty * avg, cur = qty * s.price;
    const pl = cur - inv, pct = pl / inv * 100;
    totalInv += inv;
    totalCur += cur;
    lines.push(`${pl >= 0 ? "\u{1F7E2}" : "\u{1F534}"} ${sym}: ${qty}sh @ avg \u20B9${avg.toLocaleString("en-IN")} \u2192 \u20B9${s.price.toFixed(2)} (${pl >= 0 ? "+" : ""}${pct.toFixed(1)}%)`);
    const sec = s.sector;
    secAlloc[sec] = (secAlloc[sec] || 0) + cur;
  }
  const totalPl = totalCur - totalInv, totalPct = totalPl / totalInv * 100;
  lines.push("", `\u{1F4CA} Total: \u20B9${totalInv.toLocaleString("en-IN")} \u2192 \u20B9${totalCur.toLocaleString("en-IN")} (${totalPl >= 0 ? "+" : ""}\u20B9${totalPl.toLocaleString("en-IN")} | ${totalPct >= 0 ? "+" : ""}${totalPct.toFixed(1)}%)`);
  lines.push("", "\u{1F4CA} Sector Allocation:");
  for (const [sec, val] of Object.entries(secAlloc).sort((a, b) => b[1] - a[1])) {
    lines.push(`   ${sec}: ${(val / totalCur * 100).toFixed(0)}%`);
  }
  return lines.join("\n");
}
__name(portfolioAnalysis, "portfolioAnalysis");
function compareStocks(symbols) {
  const data = symbols.map((s) => [s, STOCKS[s.toUpperCase()]]).filter(([_, d]) => d);
  if (data.length < 2) return "Need 2 known stocks to compare.";
  const lines = ["\u{1F4CA} **Stock Comparison**", ""];
  const metrics = [
    ["Price", (d) => `\u20B9${d.price.toFixed(2)}`],
    ["Change%", (d) => `${d.change_pct > 0 ? "+" : ""}${d.change_pct.toFixed(2)}%`],
    ["P/E", (d) => `${d.pe}`],
    ["M-Cap", (d) => `\u20B9${(d.mcap / 1e5).toFixed(1)}L`],
    ["Div Yield", (d) => `${d.div_yield}%`],
    ["Volume", (d) => `${(d.volume / 1e7).toFixed(1)}Cr`]
  ];
  for (const [name, fn] of metrics) {
    lines.push(`${name.padEnd(16)} ${data.map(([s, d]) => `${fn(d).padEnd(16)}`).join("")}`);
  }
  return lines.join("\n");
}
__name(compareStocks, "compareStocks");
function generateChart(symbol, days = 60) {
  const s = STOCKS[symbol.toUpperCase()];
  if (!s) return [];
  let price = s.price * 0.95;
  return Array.from({ length: days }, (_, i) => {
    price *= 1 + rnd(-1.2, 1.2) / 100;
    const d = new Date(Date.now() - (days - i) * 864e5);
    return {
      date: d.toISOString().slice(0, 10),
      close: +price.toFixed(2),
      high: +(price * (1 + rnd(0, 0.01))).toFixed(2),
      low: +(price * (1 - rnd(0, 0.01))).toFixed(2),
      volume: Math.round(s.volume * rnd(0.5, 1.5)),
      sma_20: +(price * (1 + rnd(-0.01, 0.01))).toFixed(2),
      rsi: +(30 + rnd(0, 40)).toFixed(1)
    };
  });
}
__name(generateChart, "generateChart");
function chat(message) {
  const msg = (message || "").toLowerCase().trim();
  const syms = Object.keys(STOCKS).sort((a, b) => b.length - a.length);
  let symFound = syms.find((s) => msg.includes(s.toLowerCase()));
  if (symFound && !/compare|vs /.test(msg)) return analyzeStock(symFound, message);
  if (/compare|vs /.test(msg)) {
    const found = msg.split(/[\s,]+/).map((w) => w.toUpperCase()).filter((w) => STOCKS[w]);
    if (found.length >= 2) return compareStocks(found.slice(0, 4));
  }
  if (/market|nifty|sensex|today|summary/.test(msg)) return marketSummary();
  if (/portfolio|holding|my stocks|my investment/.test(msg)) return portfolioAnalysis();
  if (/gain|top|leader/.test(msg)) {
    const g = Object.entries(STOCKS).sort((a, b) => b[1].change_pct - a[1].change_pct).slice(0, 5);
    return "\u{1F3C6} **Top Gainers**\n\n" + g.map(([s, d]) => `\u2705 ${s}: +${d.change_pct.toFixed(2)}% (\u20B9${d.price.toFixed(2)}) \u2014 ${d.sector}`).join("\n");
  }
  if (/los|decline|fall|drop/.test(msg)) {
    const l = Object.entries(STOCKS).sort((a, b) => a[1].change_pct - b[1].change_pct).slice(0, 5);
    return "\u{1F4C9} **Top Losers**\n\n" + l.map(([s, d]) => `\u{1F534} ${s}: ${d.change_pct.toFixed(2)}% (\u20B9${d.price.toFixed(2)}) \u2014 ${d.sector}`).join("\n");
  }
  if (/hello|hi|hey|help/.test(msg)) {
    return `Hello! I'm FinSwitch AI.

Try: "Analyze RELIANCE", "TCS buy or sell?", "How's the market?", "My portfolio", "Compare TCS and INFY", "Top gainers"`;
  }
  return `I can analyze ${Object.keys(STOCKS).length} Indian stocks: ${Object.keys(STOCKS).join(", ")}`;
}
__name(chat, "chat");
async function onRequest(context) {
  const { request } = context;
  const url = new URL(request.url);
  if (request.method === "GET") {
    const type = url.searchParams.get("type") || "indices";
    if (type === "indices") {
      return Response.json({ success: true, data: Object.entries(INDICES).map(([symbol, ix]) => ({ symbol, name: ix.name, price: ix.value, change: ix.change, change_percent: ix.change_pct })) });
    }
    if (type === "stocks") {
      return Response.json({ success: true, data: Object.entries(STOCKS).map(([symbol, s]) => ({ symbol, name: s.name, sector: s.sector, price: s.price, change: s.change, change_percent: s.change_pct, volume: s.volume, pe_ratio: s.pe, high_52w: s.high_52w, low_52w: s.low_52w, market_cap: s.mcap * 1e5, dividend_yield: s.div_yield, avg_volume: s.volume, industry: "", description: "" })) });
    }
    if (type === "stock") {
      const sym = url.searchParams.get("symbol") || "";
      const s = STOCKS[sym.toUpperCase()];
      if (!s) return Response.json({ success: false, error: "Not found" }, { status: 404 });
      return Response.json({ success: true, data: { symbol: sym.toUpperCase(), name: s.name, sector: s.sector, price: s.price, change: s.change, change_percent: s.change_pct, volume: s.volume, pe_ratio: s.pe, high_52w: s.high_52w, low_52w: s.low_52w, market_cap: s.mcap * 1e5, dividend_yield: s.div_yield, avg_volume: s.volume, industry: "", description: "" } });
    }
    return Response.json({ success: false, error: "Unknown type" }, { status: 400 });
  }
  if (request.method === "POST") {
    try {
      const body = await request.json();
      const { action, message, symbol, days } = body;
      if (action === "chat") return Response.json({ success: true, data: { response: chat(message || "") } });
      if (action === "analyze") return Response.json({ success: true, data: analyzeStock(symbol || "", message || "") });
      if (action === "chart") return Response.json({ success: true, data: generateChart(symbol || "", days || 60) });
      return Response.json({ success: false, error: "Unknown action" }, { status: 400 });
    } catch (e) {
      return Response.json({ success: false, error: e.message }, { status: 500 });
    }
  }
  return new Response("Method Not Allowed", { status: 405 });
}
__name(onRequest, "onRequest");

// downloads/finswitch.apk.js
async function onRequest2(context) {
  return Response.redirect("https://github.com/OK45batwal/FINSWITCH/releases/download/v1.0.0/app-release.apk", 302);
}
__name(onRequest2, "onRequest");

// downloads/[[path]].js
async function onRequest3(context) {
  return Response.redirect("https://github.com/OK45batwal/FINSWITCH/releases/download/v1.0.0/app-release.apk", 302);
}
__name(onRequest3, "onRequest");

// _middleware.js
async function onRequest4(context) {
  const url = new URL(context.request.url);
  if (url.pathname === "/downloads/finswitch.apk" || url.pathname.endsWith("/finswitch.apk")) {
    return Response.redirect("https://github.com/OK45batwal/FINSWITCH/releases/download/v1.0.0/app-release.apk", 302);
  }
  return context.next();
}
__name(onRequest4, "onRequest");

// ../.wrangler/tmp/pages-AOeTIH/functionsRoutes-0.35144277780956323.mjs
var routes = [
  {
    routePath: "/api/ai",
    mountPath: "/api",
    method: "",
    middlewares: [],
    modules: [onRequest]
  },
  {
    routePath: "/downloads/finswitch.apk",
    mountPath: "/downloads",
    method: "",
    middlewares: [],
    modules: [onRequest2]
  },
  {
    routePath: "/downloads/:path*",
    mountPath: "/downloads",
    method: "",
    middlewares: [],
    modules: [onRequest3]
  },
  {
    routePath: "/",
    mountPath: "/",
    method: "",
    middlewares: [onRequest4],
    modules: []
  }
];

// ../../../.npm/_npx/32026684e21afda6/node_modules/path-to-regexp/dist.es2015/index.js
function lexer(str) {
  var tokens = [];
  var i = 0;
  while (i < str.length) {
    var char = str[i];
    if (char === "*" || char === "+" || char === "?") {
      tokens.push({ type: "MODIFIER", index: i, value: str[i++] });
      continue;
    }
    if (char === "\\") {
      tokens.push({ type: "ESCAPED_CHAR", index: i++, value: str[i++] });
      continue;
    }
    if (char === "{") {
      tokens.push({ type: "OPEN", index: i, value: str[i++] });
      continue;
    }
    if (char === "}") {
      tokens.push({ type: "CLOSE", index: i, value: str[i++] });
      continue;
    }
    if (char === ":") {
      var name = "";
      var j = i + 1;
      while (j < str.length) {
        var code = str.charCodeAt(j);
        if (
          // `0-9`
          code >= 48 && code <= 57 || // `A-Z`
          code >= 65 && code <= 90 || // `a-z`
          code >= 97 && code <= 122 || // `_`
          code === 95
        ) {
          name += str[j++];
          continue;
        }
        break;
      }
      if (!name)
        throw new TypeError("Missing parameter name at ".concat(i));
      tokens.push({ type: "NAME", index: i, value: name });
      i = j;
      continue;
    }
    if (char === "(") {
      var count = 1;
      var pattern = "";
      var j = i + 1;
      if (str[j] === "?") {
        throw new TypeError('Pattern cannot start with "?" at '.concat(j));
      }
      while (j < str.length) {
        if (str[j] === "\\") {
          pattern += str[j++] + str[j++];
          continue;
        }
        if (str[j] === ")") {
          count--;
          if (count === 0) {
            j++;
            break;
          }
        } else if (str[j] === "(") {
          count++;
          if (str[j + 1] !== "?") {
            throw new TypeError("Capturing groups are not allowed at ".concat(j));
          }
        }
        pattern += str[j++];
      }
      if (count)
        throw new TypeError("Unbalanced pattern at ".concat(i));
      if (!pattern)
        throw new TypeError("Missing pattern at ".concat(i));
      tokens.push({ type: "PATTERN", index: i, value: pattern });
      i = j;
      continue;
    }
    tokens.push({ type: "CHAR", index: i, value: str[i++] });
  }
  tokens.push({ type: "END", index: i, value: "" });
  return tokens;
}
__name(lexer, "lexer");
function parse(str, options) {
  if (options === void 0) {
    options = {};
  }
  var tokens = lexer(str);
  var _a = options.prefixes, prefixes = _a === void 0 ? "./" : _a, _b = options.delimiter, delimiter = _b === void 0 ? "/#?" : _b;
  var result = [];
  var key = 0;
  var i = 0;
  var path = "";
  var tryConsume = /* @__PURE__ */ __name(function(type) {
    if (i < tokens.length && tokens[i].type === type)
      return tokens[i++].value;
  }, "tryConsume");
  var mustConsume = /* @__PURE__ */ __name(function(type) {
    var value2 = tryConsume(type);
    if (value2 !== void 0)
      return value2;
    var _a2 = tokens[i], nextType = _a2.type, index = _a2.index;
    throw new TypeError("Unexpected ".concat(nextType, " at ").concat(index, ", expected ").concat(type));
  }, "mustConsume");
  var consumeText = /* @__PURE__ */ __name(function() {
    var result2 = "";
    var value2;
    while (value2 = tryConsume("CHAR") || tryConsume("ESCAPED_CHAR")) {
      result2 += value2;
    }
    return result2;
  }, "consumeText");
  var isSafe = /* @__PURE__ */ __name(function(value2) {
    for (var _i = 0, delimiter_1 = delimiter; _i < delimiter_1.length; _i++) {
      var char2 = delimiter_1[_i];
      if (value2.indexOf(char2) > -1)
        return true;
    }
    return false;
  }, "isSafe");
  var safePattern = /* @__PURE__ */ __name(function(prefix2) {
    var prev = result[result.length - 1];
    var prevText = prefix2 || (prev && typeof prev === "string" ? prev : "");
    if (prev && !prevText) {
      throw new TypeError('Must have text between two parameters, missing text after "'.concat(prev.name, '"'));
    }
    if (!prevText || isSafe(prevText))
      return "[^".concat(escapeString(delimiter), "]+?");
    return "(?:(?!".concat(escapeString(prevText), ")[^").concat(escapeString(delimiter), "])+?");
  }, "safePattern");
  while (i < tokens.length) {
    var char = tryConsume("CHAR");
    var name = tryConsume("NAME");
    var pattern = tryConsume("PATTERN");
    if (name || pattern) {
      var prefix = char || "";
      if (prefixes.indexOf(prefix) === -1) {
        path += prefix;
        prefix = "";
      }
      if (path) {
        result.push(path);
        path = "";
      }
      result.push({
        name: name || key++,
        prefix,
        suffix: "",
        pattern: pattern || safePattern(prefix),
        modifier: tryConsume("MODIFIER") || ""
      });
      continue;
    }
    var value = char || tryConsume("ESCAPED_CHAR");
    if (value) {
      path += value;
      continue;
    }
    if (path) {
      result.push(path);
      path = "";
    }
    var open = tryConsume("OPEN");
    if (open) {
      var prefix = consumeText();
      var name_1 = tryConsume("NAME") || "";
      var pattern_1 = tryConsume("PATTERN") || "";
      var suffix = consumeText();
      mustConsume("CLOSE");
      result.push({
        name: name_1 || (pattern_1 ? key++ : ""),
        pattern: name_1 && !pattern_1 ? safePattern(prefix) : pattern_1,
        prefix,
        suffix,
        modifier: tryConsume("MODIFIER") || ""
      });
      continue;
    }
    mustConsume("END");
  }
  return result;
}
__name(parse, "parse");
function match(str, options) {
  var keys = [];
  var re = pathToRegexp(str, keys, options);
  return regexpToFunction(re, keys, options);
}
__name(match, "match");
function regexpToFunction(re, keys, options) {
  if (options === void 0) {
    options = {};
  }
  var _a = options.decode, decode = _a === void 0 ? function(x) {
    return x;
  } : _a;
  return function(pathname) {
    var m = re.exec(pathname);
    if (!m)
      return false;
    var path = m[0], index = m.index;
    var params = /* @__PURE__ */ Object.create(null);
    var _loop_1 = /* @__PURE__ */ __name(function(i2) {
      if (m[i2] === void 0)
        return "continue";
      var key = keys[i2 - 1];
      if (key.modifier === "*" || key.modifier === "+") {
        params[key.name] = m[i2].split(key.prefix + key.suffix).map(function(value) {
          return decode(value, key);
        });
      } else {
        params[key.name] = decode(m[i2], key);
      }
    }, "_loop_1");
    for (var i = 1; i < m.length; i++) {
      _loop_1(i);
    }
    return { path, index, params };
  };
}
__name(regexpToFunction, "regexpToFunction");
function escapeString(str) {
  return str.replace(/([.+*?=^!:${}()[\]|/\\])/g, "\\$1");
}
__name(escapeString, "escapeString");
function flags(options) {
  return options && options.sensitive ? "" : "i";
}
__name(flags, "flags");
function regexpToRegexp(path, keys) {
  if (!keys)
    return path;
  var groupsRegex = /\((?:\?<(.*?)>)?(?!\?)/g;
  var index = 0;
  var execResult = groupsRegex.exec(path.source);
  while (execResult) {
    keys.push({
      // Use parenthesized substring match if available, index otherwise
      name: execResult[1] || index++,
      prefix: "",
      suffix: "",
      modifier: "",
      pattern: ""
    });
    execResult = groupsRegex.exec(path.source);
  }
  return path;
}
__name(regexpToRegexp, "regexpToRegexp");
function arrayToRegexp(paths, keys, options) {
  var parts = paths.map(function(path) {
    return pathToRegexp(path, keys, options).source;
  });
  return new RegExp("(?:".concat(parts.join("|"), ")"), flags(options));
}
__name(arrayToRegexp, "arrayToRegexp");
function stringToRegexp(path, keys, options) {
  return tokensToRegexp(parse(path, options), keys, options);
}
__name(stringToRegexp, "stringToRegexp");
function tokensToRegexp(tokens, keys, options) {
  if (options === void 0) {
    options = {};
  }
  var _a = options.strict, strict = _a === void 0 ? false : _a, _b = options.start, start = _b === void 0 ? true : _b, _c = options.end, end = _c === void 0 ? true : _c, _d = options.encode, encode = _d === void 0 ? function(x) {
    return x;
  } : _d, _e = options.delimiter, delimiter = _e === void 0 ? "/#?" : _e, _f = options.endsWith, endsWith = _f === void 0 ? "" : _f;
  var endsWithRe = "[".concat(escapeString(endsWith), "]|$");
  var delimiterRe = "[".concat(escapeString(delimiter), "]");
  var route = start ? "^" : "";
  for (var _i = 0, tokens_1 = tokens; _i < tokens_1.length; _i++) {
    var token = tokens_1[_i];
    if (typeof token === "string") {
      route += escapeString(encode(token));
    } else {
      var prefix = escapeString(encode(token.prefix));
      var suffix = escapeString(encode(token.suffix));
      if (token.pattern) {
        if (keys)
          keys.push(token);
        if (prefix || suffix) {
          if (token.modifier === "+" || token.modifier === "*") {
            var mod = token.modifier === "*" ? "?" : "";
            route += "(?:".concat(prefix, "((?:").concat(token.pattern, ")(?:").concat(suffix).concat(prefix, "(?:").concat(token.pattern, "))*)").concat(suffix, ")").concat(mod);
          } else {
            route += "(?:".concat(prefix, "(").concat(token.pattern, ")").concat(suffix, ")").concat(token.modifier);
          }
        } else {
          if (token.modifier === "+" || token.modifier === "*") {
            throw new TypeError('Can not repeat "'.concat(token.name, '" without a prefix and suffix'));
          }
          route += "(".concat(token.pattern, ")").concat(token.modifier);
        }
      } else {
        route += "(?:".concat(prefix).concat(suffix, ")").concat(token.modifier);
      }
    }
  }
  if (end) {
    if (!strict)
      route += "".concat(delimiterRe, "?");
    route += !options.endsWith ? "$" : "(?=".concat(endsWithRe, ")");
  } else {
    var endToken = tokens[tokens.length - 1];
    var isEndDelimited = typeof endToken === "string" ? delimiterRe.indexOf(endToken[endToken.length - 1]) > -1 : endToken === void 0;
    if (!strict) {
      route += "(?:".concat(delimiterRe, "(?=").concat(endsWithRe, "))?");
    }
    if (!isEndDelimited) {
      route += "(?=".concat(delimiterRe, "|").concat(endsWithRe, ")");
    }
  }
  return new RegExp(route, flags(options));
}
__name(tokensToRegexp, "tokensToRegexp");
function pathToRegexp(path, keys, options) {
  if (path instanceof RegExp)
    return regexpToRegexp(path, keys);
  if (Array.isArray(path))
    return arrayToRegexp(path, keys, options);
  return stringToRegexp(path, keys, options);
}
__name(pathToRegexp, "pathToRegexp");

// ../../../.npm/_npx/32026684e21afda6/node_modules/wrangler/templates/pages-template-worker.ts
var escapeRegex = /[.+?^${}()|[\]\\]/g;
function* executeRequest(request) {
  const requestPath = new URL(request.url).pathname;
  for (const route of [...routes].reverse()) {
    if (route.method && route.method !== request.method) {
      continue;
    }
    const routeMatcher = match(route.routePath.replace(escapeRegex, "\\$&"), {
      end: false
    });
    const mountMatcher = match(route.mountPath.replace(escapeRegex, "\\$&"), {
      end: false
    });
    const matchResult = routeMatcher(requestPath);
    const mountMatchResult = mountMatcher(requestPath);
    if (matchResult && mountMatchResult) {
      for (const handler of route.middlewares.flat()) {
        yield {
          handler,
          params: matchResult.params,
          path: mountMatchResult.path
        };
      }
    }
  }
  for (const route of routes) {
    if (route.method && route.method !== request.method) {
      continue;
    }
    const routeMatcher = match(route.routePath.replace(escapeRegex, "\\$&"), {
      end: true
    });
    const mountMatcher = match(route.mountPath.replace(escapeRegex, "\\$&"), {
      end: false
    });
    const matchResult = routeMatcher(requestPath);
    const mountMatchResult = mountMatcher(requestPath);
    if (matchResult && mountMatchResult && route.modules.length) {
      for (const handler of route.modules.flat()) {
        yield {
          handler,
          params: matchResult.params,
          path: matchResult.path
        };
      }
      break;
    }
  }
}
__name(executeRequest, "executeRequest");
var pages_template_worker_default = {
  async fetch(originalRequest, env, workerContext) {
    let request = originalRequest;
    const handlerIterator = executeRequest(request);
    let data = {};
    let isFailOpen = false;
    const next = /* @__PURE__ */ __name(async (input, init) => {
      if (input !== void 0) {
        let url = input;
        if (typeof input === "string") {
          url = new URL(input, request.url).toString();
        }
        request = new Request(url, init);
      }
      const result = handlerIterator.next();
      if (result.done === false) {
        const { handler, params, path } = result.value;
        const context = {
          request: new Request(request.clone()),
          functionPath: path,
          next,
          params,
          get data() {
            return data;
          },
          set data(value) {
            if (typeof value !== "object" || value === null) {
              throw new Error("context.data must be an object");
            }
            data = value;
          },
          env,
          waitUntil: workerContext.waitUntil.bind(workerContext),
          passThroughOnException: /* @__PURE__ */ __name(() => {
            isFailOpen = true;
          }, "passThroughOnException")
        };
        const response = await handler(context);
        if (!(response instanceof Response)) {
          throw new Error("Your Pages function should return a Response");
        }
        return cloneResponse(response);
      } else if ("ASSETS") {
        const response = await env["ASSETS"].fetch(request);
        return cloneResponse(response);
      } else {
        const response = await fetch(request);
        return cloneResponse(response);
      }
    }, "next");
    try {
      return await next();
    } catch (error) {
      if (isFailOpen) {
        const response = await env["ASSETS"].fetch(request);
        return cloneResponse(response);
      }
      throw error;
    }
  }
};
var cloneResponse = /* @__PURE__ */ __name((response) => (
  // https://fetch.spec.whatwg.org/#null-body-status
  new Response(
    [101, 204, 205, 304].includes(response.status) ? null : response.body,
    response
  )
), "cloneResponse");
export {
  pages_template_worker_default as default
};
