from fastapi import APIRouter
from app.api.v1.markets import router as markets_router
from app.api.v1.portfolio import router as portfolio_router
from app.api.v1.news import router as news_router
from app.api.v1.ai import router as ai_router
from app.api.v1.watchlist import router as watchlist_router

api_router = APIRouter()
api_router.include_router(markets_router)
api_router.include_router(portfolio_router)
api_router.include_router(news_router)
api_router.include_router(ai_router)
api_router.include_router(watchlist_router)
