import uuid
from sqlalchemy import Column, String, DateTime, JSON, Numeric, Integer, Text, ForeignKey, Boolean
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base


class Portfolio(Base):
    __tablename__ = "portfolios"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    name = Column(String(100), nullable=False)
    description = Column(Text)
    is_primary = Column(Boolean, default=False)
    total_invested = Column(Numeric(15, 2), default=0)
    current_value = Column(Numeric(15, 2), default=0)
    total_returns = Column(Numeric(15, 2), default=0)
    returns_percent = Column(Numeric(6, 2), default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    user = relationship("User", back_populates="portfolios")
    holdings = relationship("PortfolioHolding", back_populates="portfolio")
    transactions = relationship("Transaction", back_populates="portfolio")


class PortfolioHolding(Base):
    __tablename__ = "portfolio_holdings"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    portfolio_id = Column(UUID(as_uuid=True), ForeignKey("portfolios.id"), nullable=False)
    company_id = Column(UUID(as_uuid=True), ForeignKey("companies.id"))
    quantity = Column(Integer, nullable=False)
    average_price = Column(Numeric(12, 2), nullable=False)
    invested_amount = Column(Numeric(15, 2), nullable=False)
    current_value = Column(Numeric(15, 2))
    unrealized_pl = Column(Numeric(12, 2))
    unrealized_pl_percent = Column(Numeric(6, 2))
    allocation_percent = Column(Numeric(6, 2))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    portfolio = relationship("Portfolio", back_populates="holdings")


class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    portfolio_id = Column(UUID(as_uuid=True), ForeignKey("portfolios.id"), nullable=False)
    company_id = Column(UUID(as_uuid=True), ForeignKey("companies.id"))
    transaction_type = Column(String(20), nullable=False)
    quantity = Column(Integer, nullable=False)
    price = Column(Numeric(12, 2), nullable=False)
    total_amount = Column(Numeric(15, 2), nullable=False)
    brokerage = Column(Numeric(12, 2), default=0)
    transaction_date = Column(DateTime(timezone=True), nullable=False)
    notes = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    portfolio = relationship("Portfolio", back_populates="transactions")
