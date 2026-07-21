from fastapi import APIRouter, Depends
from datetime import datetime

router = APIRouter(prefix="/ai", tags=["AI"])

chat_history = {}


@router.post("/chat")
async def chat(data: dict, user_id: str = Depends(lambda: "demo_user")):
    message = data.get("message", "")
    chat_id = data.get("chat_id", str(hash(str(datetime.now())))[:12])

    if chat_id not in chat_history:
        chat_history[chat_id] = {"id": chat_id, "messages": []}

    chat_history[chat_id]["messages"].append({"role": "user", "content": message, "created_at": datetime.now().isoformat()})

    msg_lower = message.lower()
    if "hdfc" in msg_lower and "bank" in msg_lower:
        response = "HDFC Bank shows strong fundamentals: P/E of 18.5 (below 5-year avg of 22.3), ROE of 16.8%, NIM at 4.1%. Post-merger, the bank has strengthened its balance sheet with CASA ratio of 38%. Asset quality remains robust with GNPA at 1.12%. The stock has delivered 15% returns in the past year. Consider the manageable valuation and strong franchise value."
    elif "nifty" in msg_lower and "fall" in msg_lower:
        response = "The Nifty 50 is down 0.3% today, largely driven by selling in IT stocks. Key reasons: 1) Global tech weakness due to US rate uncertainty, 2) FII outflows of ₹15,000 Cr this month, 3) Profit booking after recent highs. However, banking and FMCG stocks are showing resilience. Support level at 23,200."
    elif "compare" in msg_lower and ("hdfc" in msg_lower or "icici" in msg_lower):
        response = "**HDFC Bank vs ICICI Bank Comparison:**\n- P/E: HDFC 18.5 vs ICICI 17.8\n- ROE: HDFC 16.8% vs ICICI 15.2%\n- NIM: HDFC 4.1% vs ICICI 4.5%\n- GNPA: HDFC 1.12% vs ICICI 1.82%\n- Market Cap: HDFC ₹12.5L Cr vs ICICI ₹8.2L Cr\nVerdict: HDFC offers better asset quality, ICICI offers better growth rate. Choose based on your risk profile."
    elif "portfolio" in msg_lower:
        response = "Your portfolio analysis:\n- Total Value: ₹15,82,340\n- Returns: +27.1% (Excellent!)\n- Risk Score: 6.5/10 (Moderate)\n- Diversification: Good across 4 sectors\n- Suggestion: Consider increasing mid-cap allocation from 20% to 25% for better growth potential. Your large-cap heavy (65%) portfolio provides stability."
    elif "pe ratio" in msg_lower or "p/e" in msg_lower:
        response = "P/E Ratio (Price-to-Earnings) measures a company's current share price relative to its per-share earnings. A P/E of 20 means investors pay ₹20 for every ₹1 of earnings. In the Indian context: P/E 15-20 is fair for large-caps, 20-30+ for high-growth companies. The Nifty 50 currently trades at ~22x P/E, slightly above its 5-year average of 20x."
    elif "market" in msg_lower and "today" in msg_lower:
        response = "**Market Summary for July 21, 2026:**\n- Nifty: 23,456.80 (+0.55%)\n- Sensex: 77,123.45 (+0.44%)\n- Bank Nifty: 49,234.55 (-0.18%)\n- Advance-Decline ratio: 1.8:1\n- Sector performance: Telecom (+1.2%), Oil & Gas (+1.1%), Banking (+0.5%), IT (-0.7%)\n- FII activity: Net sellers (-₹2,100 Cr)\n- DII activity: Net buyers (+₹1,850 Cr)"
    else:
        response = "I understand you're asking about financial topics. I can help with stock analysis, market trends, portfolio insights, financial concepts, and company comparisons. Could you be more specific about what you'd like to know?"

    chat_history[chat_id]["messages"].append({"role": "assistant", "content": response, "created_at": datetime.now().isoformat()})

    return {"success": True, "data": {"response": response, "chat_id": chat_id}}


@router.get("/chats")
async def get_chats(user_id: str = Depends(lambda: "demo_user")):
    return {"success": True, "data": list(chat_history.values())}


@router.get("/chats/{chat_id}")
async def get_chat_detail(chat_id: str):
    chat = chat_history.get(chat_id)
    if not chat:
        return {"success": False, "error": "Chat not found"}
    return {"success": True, "data": chat}
