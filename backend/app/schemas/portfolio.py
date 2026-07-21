from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


class PortfolioCreate(BaseModel):
    name: str
    description: Optional[str] = None
    is_primary: bool = False


class HoldingCreate(BaseModel):
    company_id: str
    quantity: int
    average_price: float
    invested_amount: float


class HoldingResponse(BaseModel):
    symbol: str
    company_name: str
    quantity: int
    average_price: float
    current_price: float
    invested_amount: float
    current_value: float
    unrealized_pl: float
    unrealized_pl_percent: float
    allocation_percent: float


class PortfolioResponse(BaseModel):
    id: str
    name: str
    total_invested: float
    current_value: float
    total_returns: float
    returns_percent: float

    class Config:
        from_attributes = True
