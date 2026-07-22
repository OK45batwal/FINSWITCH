from fastapi import APIRouter, Query
from typing import Optional

router = APIRouter(prefix="/news", tags=["News"])

NEWS = [
    {"id": "1", "title": "RBI keeps repo rate unchanged at 6.50% for 8th consecutive time", "summary": "The MPC voted 5-1 to maintain status quo, maintaining its withdrawal of accommodation stance.", "category": "economy", "sentiment": "neutral", "source": "Economic Times", "published_at": "2026-07-21T09:30:00Z", "image_url": ""},
    {"id": "2", "title": "Reliance Industries Q1 net profit rises 12% to ₹22,500 crore", "summary": "Revenue from operations increased 8% YoY driven by strong performance in retail and telecom segments.", "category": "markets", "sentiment": "positive", "source": "Moneycontrol", "published_at": "2026-07-21T08:45:00Z", "image_url": ""},
    {"id": "3", "title": "HDFC Bank reports 15% growth in net profit for Q1 FY27", "summary": "Net interest margin improved to 4.1% with strong growth in advances and deposits.", "category": "stocks", "sentiment": "positive", "source": "Bloomberg", "published_at": "2026-07-21T07:30:00Z", "image_url": ""},
    {"id": "4", "title": "SEBI introduces new framework for SME IPOs to protect investors", "summary": "The regulator mandates higher disclosure norms and track record requirements for SME listings.", "category": "ipo", "sentiment": "positive", "source": "Business Standard", "published_at": "2026-07-20T18:00:00Z", "image_url": ""},
    {"id": "5", "title": "Rupee weakens to 83.75 against US dollar amid FII outflows", "summary": "Foreign institutional investors have pulled out ₹15,000 crore from Indian equities this month.", "category": "economy", "sentiment": "negative", "source": "Reuters", "published_at": "2026-07-20T15:45:00Z", "image_url": ""},
    {"id": "6", "title": "TCS wins $2.5 billion deal from UK-based banking giant", "summary": "The 5-year deal involves digital transformation of the bank's legacy systems.", "category": "stocks", "sentiment": "positive", "source": "Financial Express", "published_at": "2026-07-20T14:20:00Z", "image_url": ""},
    {"id": "7", "title": "Gold prices hit all-time high of ₹76,500 per 10 grams", "summary": "Geopolitical tensions and US interest rate cut expectations drive safe-haven demand.", "category": "commodities", "sentiment": "neutral", "source": "CNBC TV18", "published_at": "2026-07-20T11:00:00Z", "image_url": ""},
    {"id": "8", "title": "Zomato turns profitable for second consecutive quarter", "summary": "Food delivery giant reports net profit of ₹450 crore driven by quick commerce growth.", "category": "stocks", "sentiment": "positive", "source": "Livemint", "published_at": "2026-07-19T16:30:00Z", "image_url": ""},
]


@router.get("/")
async def get_news(category: Optional[str] = Query(None), sentiment: Optional[str] = Query(None), page: int = Query(1, ge=1), limit: int = Query(10, ge=1, le=50)):
    data = NEWS
    if category:
        data = [n for n in data if n["category"] == category]
    if sentiment:
        data = [n for n in data if n["sentiment"] == sentiment]
    start = (page - 1) * limit
    return {"success": True, "data": data[start:start + limit], "total": len(data), "page": page, "limit": limit}


@router.get("/{news_id}")
async def get_news_detail(news_id: str):
    article = next((n for n in NEWS if n["id"] == news_id), None)
    if not article:
        return {"success": False, "error": "Article not found"}
    return {"success": True, "data": {**article, "content": article["summary"]}}
