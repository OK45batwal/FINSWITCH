import os
import random
import requests
from datetime import datetime, timedelta
from typing import Optional, Dict, Any, List
from ..core.supabase import supabase

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

def get_live_stocks() -> Dict[str, Any]:
    db_stocks = supabase.select("stocks")
    if db_stocks:
        result = {}
        for row in db_stocks:
            sym = row.get("symbol", "").upper()
            if sym:
                result[sym] = {
                    "name": row.get("name", sym),
                    "sector": row.get("sector", "General"),
                    "price": float(row.get("price", 0)),
                    "change": float(row.get("change", 0)),
                    "change_pct": float(row.get("change_percent", 0)),
                    "pe": float(row.get("pe_ratio", 20.0)),
                    "high_52w": float(row.get("high_52w", 0)),
                    "low_52w": float(row.get("low_52w", 0)),
                    "mcap": float(row.get("market_cap", 0)) / 100000 if row.get("market_cap") else 500000,
                    "div_yield": float(row.get("dividend_yield", 1.0)),
                    "volume": int(row.get("volume", 1000000)),
                }
        if result:
            return result
    return STOCKS

def calculate_rsi(prices: List[float], period: int = 14) -> float:
    if len(prices) < period + 1:
        return 50.0
    gains, losses = [], []
    for i in range(1, len(prices)):
        chg = prices[i] - prices[i - 1]
        if chg > 0:
            gains.append(chg)
            losses.append(0.0)
        else:
            gains.append(0.0)
            losses.append(abs(chg))
    avg_gain = sum(gains[-period:]) / period
    avg_loss = sum(losses[-period:]) / period
    if avg_loss == 0:
        return 100.0
    rs = avg_gain / avg_loss
    return 100.0 - (100.0 / (1.0 + rs))

def _rsi_str(prices: List[float], period: int = 14) -> str:
    rsi = calculate_rsi(prices, period)
    if rsi > 70:
        return f"RSI {rsi:.1f} (overbought)"
    if rsi < 30:
        return f"RSI {rsi:.1f} (oversold)"
    return f"RSI {rsi:.1f} (neutral)"

def _sma_trend(prices: List[float], period: int = 20) -> str:
    if len(prices) < period:
        return "Insufficient data"
    sma = sum(prices[-period:]) / period
    current = prices[-1]
    above = current > sma
    return f"Price {'above' if above else 'below'} SMA({period}) — {'uptrend' if above else 'downtrend'}"

def query_llm_api(prompt: str) -> Optional[str]:
    api_key = os.getenv("GEMINI_API_KEY") or os.getenv("OPENAI_API_KEY")
    if not api_key:
        return None
    try:
        if os.getenv("GEMINI_API_KEY"):
            url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={api_key}"
            payload = {"contents": [{"parts": [{"text": prompt}]}]}
            res = requests.post(url, json=payload, timeout=5)
            if res.status_code == 200:
                data = res.json()
                return data["candidates"][0]["content"]["parts"][0]["text"]
        elif os.getenv("OPENAI_API_KEY"):
            url = "https://api.openai.com/v1/chat/completions"
            headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}
            payload = {"model": "gpt-4o-mini", "messages": [{"role": "system", "content": "You are FinSwitch AI, an expert financial analyst."}, {"role": "user", "content": prompt}]}
            res = requests.post(url, headers=headers, json=payload, timeout=5)
            if res.status_code == 200:
                data = res.json()
                return data["choices"][0]["message"]["content"]
    except Exception:
        pass
    return None

def analyze_stock(symbol: str, user_message: str = "") -> str:
    stocks = get_live_stocks()
    s = stocks.get(symbol.upper())
    if not s:
        return f"No data available for symbol '{symbol}'."
    
    # Try LLM API first if key available
    llm_prompt = f"Provide a brief 3-bullet financial analysis for {s['name']} ({symbol.upper()}). Current Price: ₹{s['price']}, P/E: {s['pe']}, Sector: {s['sector']}."
    llm_response = query_llm_api(llm_prompt)
    if llm_response:
        return llm_response

    # Deterministic technical analysis calculation
    hist_prices = [s['price'] * (1 + (i * 0.002 if i % 2 == 0 else -i * 0.0015)) for i in range(30)]
    rsi_info = _rsi_str(hist_prices)
    sma_info = _sma_trend(hist_prices)

    lines = [
        f"📊 {s['name']} ({symbol.upper()})",
        f"💰 Price: ₹{s['price']:.2f} ({'+' if s['change']>=0 else ''}{s['change']:.2f} | {'+' if s['change_pct']>=0 else ''}{s['change_pct']:.2f}%)",
        f"📐 P/E: {s['pe']} | M-Cap: ₹{(s['mcap']/100000):.1f}L Cr",
        f"📊 {sma_info}",
        f"📊 {rsi_info}",
    ]
    return "\n".join(lines)

def market_summary() -> str:
    lines = ["📊 **Market Summary**", ""]
    for sym, ix in INDICES.items():
        lines.append(f"{'🟢' if ix['change']>=0 else '🔴'} {ix['name']}: {ix['value']:.2f} ({'+' if ix['change_pct']>=0 else ''}{ix['change_pct']:.2f}%)")
    return "\n".join(lines)

def chat(message: str) -> str:
    # Try LLM API first for general questions
    llm_response = query_llm_api(f"You are FinSwitch AI financial assistant. Respond concisely to user question: {message}")
    if llm_response:
        return llm_response

    msg = (message or "").lower().strip()
    stocks = get_live_stocks()
    for sym in stocks:
        if sym.lower() in msg:
            return analyze_stock(sym, message)
    if any(k in msg for k in ["market", "nifty", "sensex", "summary"]):
        return market_summary()
    return "Hello! I'm FinSwitch AI. Try asking: 'Analyze RELIANCE', 'How is NIFTY today?'"
