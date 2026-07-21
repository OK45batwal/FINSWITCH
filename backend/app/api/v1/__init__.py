from fastapi import APIRouter
from app.api.v1.auth import router as auth_router
from app.api.v1.markets import router as markets_router
from app.api.v1.portfolio import router as portfolio_router
from app.api.v1.news import router as news_router
from app.api.v1.ai import router as ai_router
from app.api.v1.watchlist import router as watchlist_router
from app.api.v1.alerts import router as alerts_router
from app.api.v1.sip import router as sip_router
from app.api.v1.learning import router as learning_router
from app.api.v1.users import router as users_router

api_router = APIRouter()
api_router.include_router(auth_router)
api_router.include_router(markets_router)
api_router.include_router(portfolio_router)
api_router.include_router(news_router)
api_router.include_router(ai_router)
api_router.include_router(watchlist_router)
api_router.include_router(alerts_router)
api_router.include_router(sip_router)
api_router.include_router(learning_router)
api_router.include_router(users_router)
