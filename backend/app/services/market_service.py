class MarketService:
    async def get_indices(self):
        return []

    async def get_stocks(self, sector: str = None, page: int = 1, limit: int = 20):
        return []

    async def get_stock_detail(self, symbol: str):
        return {}

    async def get_gainers(self):
        return []

    async def get_losers(self):
        return []

    async def get_heatmap(self):
        return {}
