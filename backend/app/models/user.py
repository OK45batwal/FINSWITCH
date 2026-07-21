import uuid
from sqlalchemy import Column, String, Boolean, DateTime, JSON, Enum as SAEnum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base
import enum


class UserRole(str, enum.Enum):
    USER = "user"
    PREMIUM = "premium"
    ADMIN = "admin"
    SUPER_ADMIN = "super_admin"


class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String, unique=True, nullable=False, index=True)
    phone = Column(String(15), unique=True)
    password_hash = Column(String(255), nullable=False)
    display_name = Column(String(100))
    avatar_url = Column(String(500))
    role = Column(SAEnum(UserRole), default=UserRole.USER)
    firebase_uid = Column(String(128), unique=True)
    is_verified = Column(Boolean, default=False)
    is_active = Column(Boolean, default=True)
    preferences = Column(JSON, default=dict)
    last_login_at = Column(DateTime(timezone=True))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    portfolios = relationship("Portfolio", back_populates="user")
    watchlists = relationship("Watchlist", back_populates="user")
    alerts = relationship("Alert", back_populates="user")
    sip_plans = relationship("SIPPlan", back_populates="user")
    ai_chats = relationship("AIChat", back_populates="user")
    notifications = relationship("Notification", back_populates="user")
