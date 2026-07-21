import uuid
from sqlalchemy import Column, String, Boolean, DateTime, JSON, Numeric, BigInteger, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base


class Company(Base):
    __tablename__ = "companies"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    symbol = Column(String(20), unique=True, nullable=False, index=True)
    name = Column(String(255), nullable=False)
    sector = Column(String(100))
    industry = Column(String(100))
    description = Column(Text)
    logo_url = Column(String(500))
    website = Column(String(500))
    isin = Column(String(20), unique=True)
    bse_code = Column(String(20))
    nse_symbol = Column(String(20))
    market_cap = Column(Numeric(20, 2))
    face_value = Column(Numeric(10, 2))
    listed_shares = Column(BigInteger)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
