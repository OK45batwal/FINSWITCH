import uuid
from sqlalchemy import Column, String, DateTime, JSON, Numeric, BigInteger, Date, ForeignKey, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from app.core.database import Base


class StockPrice(Base):
    __tablename__ = "stock_prices"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    company_id = Column(UUID(as_uuid=True), ForeignKey("companies.id"))
    date = Column(Date, nullable=False)
    open = Column(Numeric(12, 2), nullable=False)
    high = Column(Numeric(12, 2), nullable=False)
    low = Column(Numeric(12, 2), nullable=False)
    close = Column(Numeric(12, 2), nullable=False)
    volume = Column(BigInteger, nullable=False)
    adjusted_close = Column(Numeric(12, 2))
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    __table_args__ = (UniqueConstraint("company_id", "date"),)


class MarketSnapshot(Base):
    __tablename__ = "market_snapshot"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    company_id = Column(UUID(as_uuid=True), ForeignKey("companies.id"))
    last_price = Column(Numeric(12, 2), nullable=False)
    change = Column(Numeric(12, 2), nullable=False)
    change_percent = Column(Numeric(6, 2), nullable=False)
    day_high = Column(Numeric(12, 2))
    day_low = Column(Numeric(12, 2))
    volume = Column(BigInteger)
    bid = Column(Numeric(12, 2))
    ask = Column(Numeric(12, 2))
    updated_at = Column(DateTime(timezone=True), server_default=func.now())
