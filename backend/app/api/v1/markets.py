from fastapi import APIRouter, Query
from typing import Optional

router = APIRouter(prefix="/markets", tags=["Markets"])

INDICES = [
    {"symbol": "NIFTY", "name": "Nifty 50", "last_value": 23456.80, "change": 128.45, "change_percent": 0.55},
    {"symbol": "SENSEX", "name": "S&P BSE Sensex", "last_value": 77123.45, "change": 342.10, "change_percent": 0.44},
    {"symbol": "BANKNIFTY", "name": "Bank Nifty", "last_value": 49234.55, "change": -87.30, "change_percent": -0.18},
    {"symbol": "MIDCAP", "name": "Nifty Midcap 100", "last_value": 51234.20, "change": 215.60, "change_percent": 0.42},
    {"symbol": "SMALLCAP", "name": "Nifty Smallcap 100", "last_value": 16123.90, "change": 89.45, "change_percent": 0.56},
]

STOCKS = [
    {"symbol": "RELIANCE", "name": "Reliance Industries Ltd", "sector": "Oil & Gas", "last_price": 2845.30, "change": 32.50, "change_percent": 1.16, "volume": 12400000},
    {"symbol": "TCS", "name": "Tata Consultancy Services", "sector": "IT", "last_price": 3920.00, "change": -18.40, "change_percent": -0.47, "volume": 3800000},
    {"symbol": "HDFCBANK", "name": "HDFC Bank Ltd", "sector": "Banking", "last_price": 1635.75, "change": 8.90, "change_percent": 0.55, "volume": 18200000},
    {"symbol": "INFY", "name": "Infosys Ltd", "sector": "IT", "last_price": 1482.55, "change": -12.20, "change_percent": -0.82, "volume": 8600000},
    {"symbol": "ICICIBANK", "name": "ICICI Bank Ltd", "sector": "Banking", "last_price": 1124.90, "change": 6.75, "change_percent": 0.60, "volume": 14100000},
    {"symbol": "SBIN", "name": "State Bank of India", "sector": "Banking", "last_price": 782.30, "change": 4.50, "change_percent": 0.58, "volume": 22500000},
    {"symbol": "BHARTIARTL", "name": "Bharti Airtel Ltd", "sector": "Telecom", "last_price": 1345.60, "change": 15.80, "change_percent": 1.19, "volume": 7300000},
    {"symbol": "ITC", "name": "ITC Ltd", "sector": "FMCG", "last_price": 432.15, "change": -2.30, "change_percent": -0.53, "volume": 25100000},
    {"symbol": "WIPRO", "name": "Wipro Ltd", "sector": "IT", "last_price": 512.40, "change": 3.20, "change_percent": 0.63, "volume": 5400000},
    {"symbol": "HINDUNILVR", "name": "Hindustan Unilever Ltd", "sector": "FMCG", "last_price": 2345.60, "change": -5.80, "change_percent": -0.25, "volume": 2100000},
    {"symbol": "MARUTI", "name": "Maruti Suzuki India Ltd", "sector": "Automobile", "last_price": 11230.00, "change": 45.20, "change_percent": 0.40, "volume": 890000},
    {"symbol": "BAJFINANCE", "name": "Bajaj Finance Ltd", "sector": "NBFC", "last_price": 7245.30, "change": 56.80, "change_percent": 0.79, "volume": 1200000},
]


@router.get("/indices")
async def get_indices():
    return {"success": True, "data": INDICES}


@router.get("/stocks")
async def get_stocks(sector: Optional[str] = Query(None), page: int = Query(1, ge=1), limit: int = Query(20, ge=1, le=100)):
    data = [s for s in STOCKS if not sector or s["sector"].lower() == sector.lower()]
    start = (page - 1) * limit
    return {"success": True, "data": data[start:start + limit], "total": len(data), "page": page, "limit": limit}


@router.get("/stocks/{symbol}")
async def get_stock_detail(symbol: str):
    stock = next((s for s in STOCKS if s["symbol"] == symbol.upper()), None)
    if not stock:
        return {"success": False, "error": "Stock not found"}
    detail = {**stock,
        "day_high": round(stock["last_price"] * 1.02, 2),
        "day_low": round(stock["last_price"] * 0.98, 2),
        "open": round(stock["last_price"] - stock["change"], 2),
        "previous_close": round(stock["last_price"] - stock["change"], 2),
        "market_cap": stock["last_price"] * 1000000000,
        "pe_ratio": round(22.5 + (hash(stock["symbol"]) % 100) / 10 - 5, 2),
        "dividend_yield": round((hash(stock["symbol"]) % 20) / 10, 2),
        "52_week_high": round(stock["last_price"] * 1.15, 2),
        "52_week_low": round(stock["last_price"] * 0.75, 2),
    }
    return {"success": True, "data": detail}


@router.get("/gainers")
async def get_top_gainers(limit: int = Query(5)):
    sorted_stocks = sorted(STOCKS, key=lambda s: s["change_percent"], reverse=True)
    return {"success": True, "data": sorted_stocks[:limit]}


@router.get("/losers")
async def get_top_losers(limit: int = Query(5)):
    sorted_stocks = sorted(STOCKS, key=lambda s: s["change_percent"])
    return {"success": True, "data": sorted_stocks[:limit]}
