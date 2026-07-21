from fastapi import APIRouter, Depends
from datetime import datetime

router = APIRouter(prefix="/watchlist", tags=["Watchlist"])
watchlists_db = {}


@router.get("/")
async def get_watchlists(user_id: str = Depends(lambda: "demo_user")):
    lists = watchlists_db.get(user_id, [{"id": "default", "name": "Default", "items": []}])
    return {"success": True, "data": lists}


@router.post("/")
async def create_watchlist(data: dict, user_id: str = Depends(lambda: "demo_user")):
    if user_id not in watchlists_db:
        watchlists_db[user_id] = []
    wl = {"id": str(hash(str(datetime.now())))[:12], "name": data.get("name", "New Watchlist"), "items": []}
    watchlists_db[user_id].append(wl)
    return {"success": True, "data": wl}


@router.post("/{watchlist_id}/items")
async def add_watchlist_item(watchlist_id: str, data: dict, user_id: str = Depends(lambda: "demo_user")):
    lists = watchlists_db.get(user_id, [])
    wl = next((w for w in lists if w["id"] == watchlist_id), None)
    if not wl:
        return {"success": False, "error": "Watchlist not found"}
    item = {"symbol": data["symbol"], "name": data.get("name", ""), "added_at": datetime.now().isoformat()}
    wl["items"].append(item)
    return {"success": True, "data": item}


@router.delete("/{watchlist_id}/items/{symbol}")
async def remove_watchlist_item(watchlist_id: str, symbol: str, user_id: str = Depends(lambda: "demo_user")):
    return {"success": True, "message": f"{symbol} removed from watchlist"}
