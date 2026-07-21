class NotificationService:
    async def send_push(self, user_id: str, title: str, body: str, data: dict = None):
        pass

    async def send_email(self, user_id: str, subject: str, body: str):
        pass

    async def create_notification(self, user_id: str, type: str, title: str, body: str = None):
        pass

    async def get_notifications(self, user_id: str, page: int = 1, limit: int = 20):
        return []

    async def mark_read(self, notification_id: str):
        pass
