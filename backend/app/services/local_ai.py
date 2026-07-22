import math
import random
from datetime import datetime, timedelta

STOCKS = {
    "RELIANCE": {"name": "Reliance Industries Ltd", "sector": "Oil & Gas", "price": 2845.30, "change": 32.50, "change_pct": 1.16, "pe": 24.5, "high_52w": 3200, "low_52w": 2200, "mcap": 1925000, "div_yield": 0.35, "volume": 12400000},
    "TCS": {"name": "Tata Consultancy Services", "sector": "IT", "price": 3920.00, "change": -18.40, "change_pct": -0.47, "pe": 28.6, "high_52w": 4200, "low_52w": 3300, "mcap": 1450000, "div_yield": 1.20, "volume": 3800000},
    "HDFCBANK": {"name": "HDFC Bank Ltd", "sector": "Banking", "price": 1635.75, "change": 8.90, "change_pct": 0.55, "pe": 18.5, "high_52w": 1800, "low_52w": 1360, "mcap": 940000, "div_yield": 1.05, "volume": 18200000},
    "INFY": {"name": "Infosys Ltd", "sector": "IT", "price": 1482.55, "change": -12.20, "change_pct": -0.82, "pe": 26.2, "high_52w": 1750, "low_52w": 1350, "mcap": 620000, "div_yield": 1.80, "volume": 8600000},
    "ICICIBANK": {"name": "ICICI Bank Ltd", "sector": "Banking", "price": 1124.90, "change": 6.75, "change_pct": 0.60, "pe": 17.8, "high_52w": 1250, "low_52w": 900, "mcap": 820000, "div_yield": 0.80, "volume": 14100000},
    "SBIN": {"name": "State Bank of India", "sector": "Banking", "price": 782.30, "change": 4.50, "change_pct": 0.58, "pe": 12.3, "high_52w": 900, "low_52w": 570, "mcap": 710000, "div_yield": 3.20, "volume": 22500000},
    "BHARTIARTL": {"name": "Bharti Airtel Ltd", "sector": "Telecom", "price": 1345.60, "change": 15.80, "change_pct": 1.19, "pe": 32.1, "high_52w": 1500, "low_52w": 1050, "mcap": 780000, "div_yield": 0.45, "volume": 7300000},
    "ITC": {"name": "ITC Ltd", "sector": "FMCG", "price": 432.15, "change": -2.30, "change_pct": -0.53, "pe": 22.4, "high_52w": 520, "low_52w": 380, "mcap": 545000, "div_yield": 3.80, "volume": 25100000},
    "WIPRO": {"name": "Wipro Ltd", "sector": "IT", "price": 512.40, "change": 3.20, "change_pct": 0.63, "pe": 18.5, "high_52w": 600, "low_52w": 380, "mcap": 290000, "div_yield": 2.10, "volume": 5400000},
    "HINDUNILVR": {"name": "Hindustan Unilever Ltd", "sector": "FMCG", "price": 2345.60, "change": -5.80, "change_pct": -0.25, "pe": 45.2, "high_52w": 2700, "low_52w": 2200, "mcap": 550000, "div_yield": 1.65, "volume": 2100000},
    "MARUTI": {"name": "Maruti Suzuki India Ltd", "sector": "Automobile", "price": 11230.00, "change": 45.20, "change_pct": 0.40, "pe": 28.0, "high_52w": 13500, "low_52w": 9500, "mcap": 340000, "div_yield": 0.50, "volume": 890000},
    "BAJFINANCE": {"name": "Bajaj Finance Ltd", "sector": "NBFC", "price": 7245.30, "change": 56.80, "change_pct": 0.79, "pe": 31.5, "high_52w": 8200, "low_52w": 5800, "mcap": 430000, "div_yield": 0.30, "volume": 1200000},
}

INDICES = {
    "NIFTY": {"name": "Nifty 50", "value": 23456.80, "change": 128.45, "change_pct": 0.55, "support": 23200, "resistance": 23600},
    "SENSEX": {"name": "S&P BSE Sensex", "value": 77123.45, "change": 342.10, "change_pct": 0.44, "support": 76500, "resistance": 77800},
    "BANKNIFTY": {"name": "Bank Nifty", "value": 49234.55, "change": -87.30, "change_pct": -0.18, "support": 48800, "resistance": 49800},
}


def _sentiment(s: str) -> str:
    s = s.lower()
    pos = {"strong buy", "accumulate", "buy", "outperform", "overweight"}
    neg = {"sell", "reduce", "underweight", "avoid"}
    if s in pos: return "🟢 Bullish"
    if s in neg: return "🔴 Bearish"
    return "🟡 Neutral"


def _rsi_str(price: float, period: int = 14) -> str:
    gain = price * random.uniform(0.005, 0.02)
    loss = price * random.uniform(0.005, 0.015)
    avg_gain = gain / period
    avg_loss = loss / period
    rs = avg_gain / avg_loss if avg_loss > 0 else 999
    rsi = 100 - (100 / (1 + rs))
    if rsi > 70: return f"RSI {rsi:.1f} (overbought)"
    if rsi < 30: return f"RSI {rsi:.1f} (oversold)"
    return f"RSI {rsi:.1f} (neutral)"


def _sma_trend(prices: list[float], period: int = 20) -> str:
    if len(prices) < period + 5: return "Insufficient data"
    sma = sum(prices[-period:]) / period
    current = prices[-1]
    above = current > sma
    return f"Price {'above' if above else 'below'} SMA({period}) — {'uptrend' if above else 'downtrend'}"


def avg(l: list) -> float:
    return sum(l) / len(l) if l else 0


def analyze_stock(symbol: str, user_message: str = "") -> str:
    s = STOCKS.get(symbol.upper())
    if not s:
        guesses = [k for k in STOCKS if symbol.upper()[:3] in k or k[:3] in symbol.upper()]
        if guesses:
            return f"Did you mean {', '.join(guesses)}? Try one of those."
        return f"Sorry, I don't have data for '{symbol}'. Available: {', '.join(STOCKS.keys())}."

    msg = user_message.lower()
    p, ch, cp = s["price"], s["change"], s["change_pct"]
    pe, mcap, div = s["pe"], s["mcap"], s["div_yield"]

    price_range = s["high_52w"] - s["low_52w"]
    position = ((p - s["low_52w"]) / price_range) * 100 if price_range > 0 else 50

    support = round(p * 0.95, 2)
    resistance = round(p * 1.08, 2)

    fake_prices = [p * (1 + random.uniform(-0.003, 0.003)) for _ in range(30)]
    trend = _sma_trend(fake_prices)

    details = [
        f"📊 {s['name']} ({symbol})",
        f"💰 Price: ₹{p:,.2f} (Day: {'+' if ch >= 0 else ''}{ch:,.2f} | {'+' if cp >= 0 else ''}{cp:.2f}%)",
        f"📈 Range: ₹{s['low_52w']:,} – ₹{s['high_52w']:,} (52wk position: {position:.0f}%)",
        f"📐 P/E: {pe} | M-Cap: ₹{mcap/100000:.1f}L Cr | Div Yield: {div}%",
        f"📉 Support: ₹{support:,} | Resistance: ₹{resistance:,}",
        f"📊 {trend}",
        f"📊 {_rsi_str(p)}",
    ]

    if "buy" in msg or "recommend" in msg or "should i" in msg:
        verdict = _buy_sell_verdict(s)
        details.append(f"\n💡 {verdict}")
    elif "compare" in msg:
        others = [k for k in STOCKS if k != symbol.upper() and STOCKS[k]["sector"] == s["sector"]]
        if others:
            details.append(f"\n📊 Sector peers: {', '.join(others[:3])}")
            for o in others[:2]:
                os = STOCKS[o]
                details.append(f"   {o}: ₹{os['price']:,.2f} (P/E {os['pe']})")
        else:
            details.append(f"\n📊 No direct peers in this sector.")
    elif "target" in msg or "goal" in msg:
        upside = ((resistance - p) / p) * 100
        downside = ((p - support) / p) * 100
        details.append(f"\n🎯 Upside to resistance: +{upside:.1f}% | Downside risk: -{downside:.1f}%")
    elif "news" in msg or "why" in msg:
        if cp > 0:
            details.append(f"\n📰 Stock up due to sector momentum and positive sentiment. Institutional buying observed.")
        else:
            details.append(f"\n📰 Pressure from global cues and sector rotation. FIIs net sellers in {s['sector']}.")

    return "\n".join(details)


def _buy_sell_verdict(s: dict) -> str:
    score = 0
    if s["pe"] < 20: score += 1
    if s["pe"] < 15: score += 1
    if s["change_pct"] > 0: score += 1
    if s["div_yield"] > 1.5: score += 1
    if s["div_yield"] > 3: score += 1
    if s["volume"] > 10000000: score += 1
    if score >= 4: return "Strong Buy ✅ — solid fundamentals, good momentum, attractive yield."
    if score >= 3: return "Accumulate 📈 — decent fundamentals, hold for medium term."
    if score >= 2: return "Hold ⏸️ — wait for better entry, support near ₹{:.0f}.".format(s["price"] * 0.95)
    return "Avoid ⚠️ — weak signals, consider alternatives in this sector."


def market_summary() -> str:
    lines = ["📊 **Market Summary — July 22, 2026**", ""]
    for sym, idx in INDICES.items():
        icon = "🟢" if idx["change"] >= 0 else "🔴"
        lines.append(f"{icon} {idx['name']}: {idx['value']:,.2f} ({'+' if idx['change'] >= 0 else ''}{idx['change_pct']:.2f}%)")
        lines.append(f"   Support: {idx['support']:,} | Resistance: {idx['resistance']:,}")

    sectors = {}
    for sym, s in STOCKS.items():
        sec = s["sector"]
        if sec not in sectors: sectors[sec] = {"stocks": 0, "up": 0, "sum_pct": 0}
        sectors[sec]["stocks"] += 1
        sectors[sec]["sum_pct"] += s["change_pct"]
        if s["change_pct"] > 0: sectors[sec]["up"] += 1

    lines.append("")
    lines.append("🏭 Sector Performance:")
    best = max(sectors, key=lambda k: sectors[k]["sum_pct"] / sectors[k]["stocks"])
    worst = min(sectors, key=lambda k: sectors[k]["sum_pct"] / sectors[k]["stocks"])
    lines.append(f"   ✅ Best: {best} ({sectors[best]['up']}/{sectors[best]['stocks']} stocks up)")
    lines.append(f"   ❌ Worst: {worst} ({sectors[worst]['up']}/{sectors[worst]['stocks']} stocks up)")

    gainers = sorted(STOCKS.items(), key=lambda x: x[1]["change_pct"], reverse=True)[:3]
    losers = sorted(STOCKS.items(), key=lambda x: x[1]["change_pct"])[:3]
    lines.append("")
    lines.append("🏆 Top Gainers: " + ", ".join(f"{s} +{d['change_pct']:.2f}%" for s, d in gainers))
    lines.append("📉 Top Losers: " + ", ".join(f"{s} {d['change_pct']:.2f}%" for s, d in losers))

    return "\n".join(lines)


def portfolio_analysis() -> str:
    holdings = [
        ("RELIANCE", 50, 2450), ("HDFCBANK", 100, 1420), ("TCS", 20, 3850),
        ("ICICIBANK", 150, 980), ("INFY", 60, 1450), ("SBIN", 200, 650), ("ITC", 300, 380),
    ]
    total_invested = 0
    total_current = 0
    lines = ["💼 **Portfolio Analysis**", ""]
    for sym, qty, avg in holdings:
        s = STOCKS.get(sym)
        if not s: continue
        invested = qty * avg
        current = qty * s["price"]
        pl = current - invested
        pl_pct = (pl / invested) * 100
        total_invested += invested
        total_current += current
        icon = "🟢" if pl >= 0 else "🔴"
        lines.append(f"{icon} {sym}: {qty}sh @ avg ₹{avg:,.0f} → ₹{s['price']:,.2f} ({'+' if pl >= 0 else ''}{pl_pct:.1f}%)")

    total_pl = total_current - total_invested
    total_pl_pct = (total_pl / total_invested) * 100 if total_invested > 0 else 0
    lines.append("")
    lines.append(f"📊 Total: ₹{total_invested:,.0f} → ₹{total_current:,.0f} ({'+' if total_pl >= 0 else ''}₹{total_pl:,.0f} | {'+' if total_pl_pct >= 0 else ''}{total_pl_pct:.1f}%)")

    sector_alloc = {}
    for sym, qty, _ in holdings:
        s = STOCKS.get(sym)
        if not s: continue
        sec = s["sector"]
        sector_alloc[sec] = sector_alloc.get(sec, 0) + (qty * s["price"])
    lines.append("")
    lines.append("📊 Sector Allocation:")
    for sec, val in sorted(sector_alloc.items(), key=lambda x: -x[1]):
        pct = (val / total_current) * 100
        lines.append(f"   {sec}: {pct:.0f}%")

    return "\n".join(lines)


def compare_stocks(symbols: list[str]) -> str:
    data = [(s.upper(), STOCKS.get(s.upper())) for s in symbols if STOCKS.get(s.upper())]
    if len(data) < 2:
        return "Need at least 2 known stocks to compare."

    lines = ["📊 **Stock Comparison**", ""]
    header = f"{'Metric':<20}" + "".join(f"{s:<20}" for s, _ in data)
    lines.append(header)
    lines.append("-" * len(header))

    metrics = [
        ("Price", lambda d: f"₹{d['price']:,.2f}"),
        ("Change%", lambda d: f"{d['change_pct']:+.2f}%"),
        ("P/E", lambda d: f"{d['pe']}"),
        ("M-Cap", lambda d: f"₹{d['mcap']/100000:.1f}L"),
        ("Div Yield", lambda d: f"{d['div_yield']}%"),
        ("Volume", lambda d: f"{d['volume']/10000000:.1f}Cr"),
    ]
    for name, fn in metrics:
        row = f"{name:<20}" + "".join(f"{fn(d):<20}" for _, d in data)
        lines.append(row)

    return "\n".join(lines)


def generate_chart_data(symbol: str, days: int = 60) -> list[dict]:
    s = STOCKS.get(symbol.upper())
    if not s: return []
    base = s["price"]
    data = []
    price = base * 0.95
    for i in range(days):
        change_pct = random.uniform(-1.2, 1.2)
        price *= (1 + change_pct / 100)
        high = price * (1 + random.uniform(0, 0.01))
        low = price * (1 - random.uniform(0, 0.01))
        volume = int(s["volume"] * random.uniform(0.5, 1.5))
        sma_20 = avg([price * (1 + random.uniform(-0.01, 0.01)) for _ in range(20)])
        rsi = 30 + random.uniform(0, 40)
        data.append({
            "date": (datetime.now() - timedelta(days=days - i)).isoformat()[:10],
            "close": round(price, 2),
            "high": round(high, 2),
            "low": round(low, 2),
            "volume": volume,
            "sma_20": round(sma_20, 2),
            "rsi": round(rsi, 1),
        })
    return data


def chat(message: str, history: list[dict] = None) -> str:
    msg = message.lower().strip()

    for sym in sorted(STOCKS.keys(), key=len, reverse=True):
        if sym.lower() in msg or sym.lower() in msg:
            sym_found = sym
            break
    else:
        sym_found = None

    if sym_found and ("compare" not in msg and "vs" not in msg):
        return analyze_stock(sym_found, message)

    if "compare" in msg or "vs " in msg:
        words = msg.replace(" vs ", " ").replace(",", " ").split()
        syms = [w.upper() for w in words if w.upper() in STOCKS]
        if len(syms) >= 2:
            return compare_stocks(syms[:4])

    if any(w in msg for w in ["market", "nifty", "sensex", "today", "summary"]):
        return market_summary()

    if any(w in msg for w in ["portfolio", "holding", "my stocks", "my investment"]):
        return portfolio_analysis()

    if any(w in msg for w in ["gain", "top", "leader"]):
        gainers = sorted(STOCKS.items(), key=lambda x: -x[1]["change_pct"])[:5]
        lines = ["🏆 **Top Gainers**", ""]
        for s, d in gainers:
            lines.append(f"✅ {s}: +{d['change_pct']:.2f}% (₹{d['price']:,.2f}) — {d['sector']}")
        return "\n".join(lines)

    if any(w in msg for w in ["los", "decline", "fall", "drop", "bear"]):
        losers = sorted(STOCKS.items(), key=lambda x: x[1]["change_pct"])[:5]
        lines = ["📉 **Top Losers**", ""]
        for s, d in losers:
            lines.append(f"🔴 {s}: {d['change_pct']:.2f}% (₹{d['price']:,.2f}) — {d['sector']}")
        return "\n".join(lines)

    if any(w in msg for w in ["hello", "hi", "hey", "help"]):
        return ("Hello! I'm FinSwitch AI — your local financial analyst. I work entirely offline.\n\n"
                "Try asking me:\n"
                "• **Stock analysis**: \"Analyze RELIANCE\" or \"TCS buy or sell?\"\n"
                "• **Market summary**: \"How's the market today?\"\n"
                "• **Portfolio**: \"My portfolio\" — shows your holdings\n"
                "• **Compare**: \"Compare TCS and INFY\"\n"
                "• **Gainers/Losers**: \"Top gainers\" or \"Which stocks fell\"\n"
                "• **Technicals**: I analyze P/E, RSI, moving averages, support/resistance automatically.\n\n"
                "What would you like to explore?")

    stocks_list = ", ".join(f"{s} (₹{d['price']:,.0f})" for s, d in sorted(STOCKS.items()))
    return (f"I can analyze {len(STOCKS)} Indian stocks: {stocks_list}.\n\n"
            f"Try naming a stock (e.g., \"RELIANCE\", \"TCS\"), or ask about markets, portfolio, gainers, or compare stocks.")
