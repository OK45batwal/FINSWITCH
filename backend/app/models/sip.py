import uuid
from sqlalchemy import Column, String, DateTime, JSON, Numeric, Integer, Date, ForeignKey, Boolean
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base


class SIPPlan(Base):
    __tablename__ = "sip_plans"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    name = Column(String(200), nullable=False)
    goal_type = Column(String(50), nullable=False)
    target_amount = Column(Numeric(15, 2))
    monthly_amount = Column(Numeric(12, 2), nullable=False)
    expected_return = Column(Numeric(5, 2), default=12.0)
    inflation_rate = Column(Numeric(5, 2), default=6.0)
    frequency = Column(String(20), default="monthly")
    start_date = Column(Date, nullable=False)
    end_date = Column(Date)
    current_value = Column(Numeric(15, 2), default=0)
    total_invested = Column(Numeric(15, 2), default=0)
    projected_value = Column(Numeric(15, 2))
    status = Column(String(20), default="active")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    user = relationship("User", back_populates="sip_plans")


class SIPAllocation(Base):
    __tablename__ = "sip_allocations"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    sip_id = Column(UUID(as_uuid=True), ForeignKey("sip_plans.id"), nullable=False)
    company_id = Column(UUID(as_uuid=True), ForeignKey("companies.id"))
    allocation_percent = Column(Numeric(5, 2), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
