import uuid
from sqlalchemy import Column, String, DateTime, JSON, Text, Boolean, ForeignKey, Numeric
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from app.core.database import Base


class NewsArticle(Base):
    __tablename__ = "news_articles"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String(500), nullable=False)
    slug = Column(String(500), unique=True, nullable=False)
    summary = Column(Text)
    content = Column(Text)
    image_url = Column(String(500))
    source = Column(String(200))
    source_url = Column(String(500))
    category = Column(String(50))
    sentiment = Column(String(20))
    sentiment_score = Column(Numeric(4, 3))
    ai_summary = Column(Text)
    is_featured = Column(Boolean, default=False)
    published_at = Column(DateTime(timezone=True))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
