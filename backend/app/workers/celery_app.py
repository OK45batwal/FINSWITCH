from celery import Celery
from app.core.config import settings

celery_app = Celery(
    "finswitch",
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND,
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="Asia/Kolkata",
    enable_utc=True,
)


@celery_app.task
def fetch_market_data():
    pass


@celery_app.task
def process_news_article(news_id: str):
    pass


@celery_app.task
def send_scheduled_notifications():
    pass


@celery_app.task
def cleanup_expired_sessions():
    pass
