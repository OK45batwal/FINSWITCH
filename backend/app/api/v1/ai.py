from fastapi import APIRouter, Depends
from datetime import datetime
from app.services.local_ai import chat as local_chat, generate_chart_data, analyze_stock

router = APIRouter(prefix="/ai", tags=["AI"])

chat_history = {}


@router.post("/chat")
async def chat(data: dict, user_id: str = Depends(lambda: "demo_user")):
    message = data.get("message", "")
    chat_id = data.get("chat_id", str(hash(str(datetime.now())))[:12])

    if chat_id not in chat_history:
        chat_history[chat_id] = {"id": chat_id, "messages": []}

    chat_history[chat_id]["messages"].append({"role": "user", "content": message, "created_at": datetime.now().isoformat()})

    response = local_chat(message)

    chat_history[chat_id]["messages"].append({"role": "assistant", "content": response, "created_at": datetime.now().isoformat()})

    return {"success": True, "data": {"response": response, "chat_id": chat_id}}


@router.post("/analyze")
async def analyze(data: dict):
    symbol = data.get("symbol", "").upper()
    return {"success": True, "data": analyze_stock(symbol)}


@router.post("/chart")
async def chart(data: dict):
    symbol = data.get("symbol", "").upper()
    days = data.get("days", 60)
    return {"success": True, "data": generate_chart_data(symbol, days)}


@router.get("/chats")
async def get_chats(user_id: str = Depends(lambda: "demo_user")):
    return {"success": True, "data": list(chat_history.values())}


@router.get("/chats/{chat_id}")
async def get_chat_detail(chat_id: str):
    chat = chat_history.get(chat_id)
    if not chat:
        return {"success": False, "error": "Chat not found"}
    return {"success": True, "data": chat}
