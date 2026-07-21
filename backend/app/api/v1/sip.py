from fastapi import APIRouter, Depends
from datetime import datetime, date

router = APIRouter(prefix="/sip", tags=["SIP Plans"])
sip_db = {}


@router.get("/")
async def get_sip_plans(user_id: str = Depends(lambda: "demo_user")):
    plans = sip_db.get(user_id, [])
    return {"success": True, "data": plans}


@router.post("/")
async def create_sip_plan(data: dict, user_id: str = Depends(lambda: "demo_user")):
    if user_id not in sip_db:
        sip_db[user_id] = []
    plan = {
        "id": str(hash(str(datetime.now())))[:12],
        "name": data.get("name", "My SIP"),
        "goal_type": data.get("goal_type", "retirement"),
        "target_amount": data.get("target_amount", 0),
        "monthly_amount": data.get("monthly_amount", 5000),
        "expected_return": data.get("expected_return", 12.0),
        "start_date": str(date.today()),
        "current_value": 0,
        "total_invested": 0,
        "status": "active",
    }
    sip_db[user_id].append(plan)
    return {"success": True, "data": plan}


@router.post("/calculate")
async def calculate_sip(data: dict):
    monthly = data.get("monthly_amount", 5000)
    rate = data.get("expected_return", 12.0) / 100 / 12
    years = data.get("years", 10)
    months = years * 12

    if rate == 0:
        total = monthly * months
    else:
        total = monthly * (((1 + rate) ** months - 1) / rate) * (1 + rate)

    invested = monthly * months
    returns = total - invested

    return {
        "success": True,
        "data": {
            "monthly_amount": monthly,
            "years": years,
            "total_invested": round(invested, 2),
            "expected_returns": round(returns, 2),
            "maturity_value": round(total, 2),
            "expected_return_rate": data.get("expected_return", 12.0),
        },
    }
