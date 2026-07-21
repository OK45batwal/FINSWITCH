class AIService:
    async def analyze_stock(self, symbol: str) -> dict:
        return {"symbol": symbol, "analysis": "AI stock analysis pending"}

    async def analyze_portfolio(self, user_id: str) -> dict:
        return {"user_id": user_id, "analysis": "AI portfolio analysis pending"}

    async def compare_companies(self, symbols: list[str]) -> dict:
        return {"symbols": symbols, "comparison": "AI comparison pending"}

    async def summarize_news(self, news_id: str) -> str:
        return "AI news summary pending"

    async def chat(self, user_id: str, message: str, chat_id: str = None) -> dict:
        return {"response": "AI chat response pending", "chat_id": chat_id}
