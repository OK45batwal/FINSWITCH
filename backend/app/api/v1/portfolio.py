from fastapi import APIRouter, Depends, HTTPException
from typing import List
from datetime import datetime

router = APIRouter(prefix="/portfolio", tags=["Portfolio"])
user_portfolios = {}


@router.get("/")
async def get_portfolios(user_id: str = Depends(lambda: "demo_user")):
    portfolios = user_portfolios.get(user_id, [])
    return {"success": True, "data": portfolios}


@router.post("/")
async def create_portfolio(data: dict, user_id: str = Depends(lambda: "demo_user")):
    if user_id not in user_portfolios:
        user_portfolios[user_id] = []
    portfolio = {
        "id": str(hash(str(datetime.now())))[:12],
        "name": data.get("name", "My Portfolio"),
        "total_invested": 0,
        "current_value": 0,
        "total_returns": 0,
        "returns_percent": 0,
        "holdings": [],
        "created_at": datetime.now().isoformat(),
    }
    user_portfolios[user_id].append(portfolio)
    return {"success": True, "data": portfolio}


@router.get("/summary")
async def get_portfolio_summary(user_id: str = Depends(lambda: "demo_user")):
    return {
        "success": True,
        "data": {
            "total_invested": 1245000.00,
            "current_value": 1582340.00,
            "total_returns": 337340.00,
            "returns_percent": 27.10,
            "today_pl": 3240.00,
            "today_pl_percent": 0.21,
            "allocation": {
                "large_cap": {"percent": 65, "value": 1028521.00},
                "mid_cap": {"percent": 20, "value": 316468.00},
                "small_cap": {"percent": 10, "value": 158234.00},
                "cash": {"percent": 5, "value": 79117.00},
            },
            "risk_score": 6.5,
            "diversification_score": 7.2,
        },
    }


@router.get("/holdings")
async def get_holdings(user_id: str = Depends(lambda: "demo_user")):
    return {
        "success": True,
        "data": [
            {"symbol": "RELIANCE", "name": "Reliance Industries", "quantity": 50, "avg_price": 2450.00, "ltp": 2845.30, "invested": 122500.00, "value": 142265.00, "pl": 19765.00, "pl_percent": 16.13, "allocation": 8.99},
            {"symbol": "HDFCBANK", "name": "HDFC Bank", "quantity": 100, "avg_price": 1420.00, "ltp": 1635.75, "invested": 142000.00, "value": 163575.00, "pl": 21575.00, "pl_percent": 15.19, "allocation": 10.34},
            {"symbol": "TCS", "name": "Tata Consultancy Services", "quantity": 20, "avg_price": 3850.00, "ltp": 3920.00, "invested": 77000.00, "value": 78400.00, "pl": 1400.00, "pl_percent": 1.82, "allocation": 4.95},
            {"symbol": "ICICIBANK", "name": "ICICI Bank", "quantity": 150, "avg_price": 980.00, "ltp": 1124.90, "invested": 147000.00, "value": 168735.00, "pl": 21735.00, "pl_percent": 14.79, "allocation": 10.66},
            {"symbol": "INFY", "name": "Infosys", "quantity": 60, "avg_price": 1450.00, "ltp": 1482.55, "invested": 87000.00, "value": 88953.00, "pl": 1953.00, "pl_percent": 2.24, "allocation": 5.62},
            {"symbol": "SBIN", "name": "SBI", "quantity": 200, "avg_price": 650.00, "ltp": 782.30, "invested": 130000.00, "value": 156460.00, "pl": 26460.00, "pl_percent": 20.35, "allocation": 9.89},
            {"symbol": "ITC", "name": "ITC Ltd", "quantity": 300, "avg_price": 380.00, "ltp": 432.15, "invested": 114000.00, "value": 129645.00, "pl": 15645.00, "pl_percent": 13.72, "allocation": 8.19},
        ],
    }
