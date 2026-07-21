from fastapi import APIRouter, Depends
from datetime import datetime

router = APIRouter(prefix="/alerts", tags=["Alerts"])
alerts_db = {}


@router.get("/")
async def get_alerts(user_id: str = Depends(lambda: "demo_user")):
    alerts = alerts_db.get(user_id, [])
    return {"success": True, "data": alerts}


@router.post("/")
async def create_alert(data: dict, user_id: str = Depends(lambda: "demo_user")):
    if user_id not in alerts_db:
        alerts_db[user_id] = []
    alert = {
        "id": str(hash(str(datetime.now())))[:12],
        "type": data.get("type", "price"),
        "symbol": data.get("symbol", ""),
        "condition": data.get("condition", "above"),
        "threshold": data.get("threshold", 0),
        "is_active": True,
        "created_at": datetime.now().isoformat(),
    }
    alerts_db[user_id].append(alert)
    return {"success": True, "data": alert}


@router.put("/{alert_id}")
async def update_alert(alert_id: str, data: dict, user_id: str = Depends(lambda: "demo_user")):
    return {"success": True, "message": f"Alert {alert_id} updated"}


@router.delete("/{alert_id}")
async def delete_alert(alert_id: str, user_id: str = Depends(lambda: "demo_user")):
    return {"success": True, "message": f"Alert {alert_id} deleted"}
