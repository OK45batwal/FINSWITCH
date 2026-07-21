from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class StockResponse(BaseModel):
    symbol: str
    name: str
    sector: Optional[str]
    last_price: float
    change: float
    change_percent: float
    day_high: Optional[float]
    day_low: Optional[float]
    volume: Optional[int]

    class Config:
        from_attributes = True


class IndexResponse(BaseModel):
    symbol: str
    name: str
    last_value: float
    change: float
    change_percent: float
    updated_at: datetime


class MarketMovers(BaseModel):
    symbol: str
    name: str
    last_price: float
    change: float
    change_percent: float
