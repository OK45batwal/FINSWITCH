from fastapi import APIRouter, Depends
from datetime import datetime

router = APIRouter(prefix="/ai", tags=["AI"])

chat_history = {}


STOCK_KB = {
    "reliance": "Reliance Industries (₹2,845.30, +1.16%) — Oil & Gas leader with Jio (460M+ subs) and Retail (₹2.5L Cr revenue). P/E 24.5. Key support ₹2,700, resistance ₹2,950. Dividend yield: 0.35%.",
    "ril": "Reliance Industries (₹2,845.30, +1.16%) — Oil & Gas leader with Jio (460M+ subs) and Retail (₹2.5L Cr revenue). P/E 24.5. Key support ₹2,700, resistance ₹2,950. Dividend yield: 0.35%.",
    "tcs": "TCS (₹3,920.00, -0.47%) — IT bellwether. Recent $2.5B UK deal win strengthens pipeline. P/E 28.6. Strong buy on dips below ₹3,800. Dividend yield: 1.2%.",
    "hdfc": "HDFC Bank (₹1,635.75, +0.55%) — P/E 18.5, ROE 16.8%, NIM 4.1%. Post-merger CASA ratio 38%. GNPA at 1.12%. Strong hold for long-term.",
    "icici": "ICICI Bank (₹1,124.90, +0.60%) — P/E 17.8, ROE 15.2%, NIM 4.5%. Strong growth trajectory. Target ₹1,250.",
    "infy": "Infosys (₹1,482.55, -0.82%) — IT major. P/E 26.2. Recent deal pipeline strong. Weakness due to global rate uncertainty.",
    "sbi": "State Bank of India (₹782.30, +0.58%) — P/E 12.3 (cheapest among large banks). Strong dividend yield of 3.2%. Target ₹850.",
    "bharti": "Bharti Airtel (₹1,345.60, +1.19%) — Telecom leader. ARPU improving to ₹209. 5G rollout driving growth. Target ₹1,500.",
    "airtel": "Bharti Airtel (₹1,345.60, +1.19%) — Telecom leader. ARPU improving to ₹209. 5G rollout driving growth. Target ₹1,500.",
    "itc": "ITC (₹432.15, -0.53%) — FMCG conglomerate. Hotels and agri business growing. Strong dividend yield of 3.8%. Accumulate on dips.",
    "wipro": "Wipro (₹512.40, +0.63%) — IT services. Recent restructuring improving deal wins. P/E 18.5. Hold for turnaround.",
    "maruti": "Maruti Suzuki (₹11,230.00, +0.40%) — Auto leader. Strong SUV pipeline. CNG segment growing. P/E 28.0.",
    "bajaj": "Bajaj Finance (₹7,245.30, +0.79%) — NBFC leader. AUM growth at 25% YoY. Strong asset quality. Target ₹8,000.",
}

STOCK_ALIASES = {k: v for k, v in STOCK_KB.items()}


@router.post("/chat")
async def chat(data: dict, user_id: str = Depends(lambda: "demo_user")):
    message = data.get("message", "")
    chat_id = data.get("chat_id", str(hash(str(datetime.now())))[:12])

    if chat_id not in chat_history:
        chat_history[chat_id] = {"id": chat_id, "messages": []}

    chat_history[chat_id]["messages"].append({"role": "user", "content": message, "created_at": datetime.now().isoformat()})

    msg_lower = message.lower()

    # Stock queries — match by keyword
    for key, info in STOCK_KB.items():
        if key in msg_lower:
            response = info
            break
    else:
        if "nifty" in msg_lower and ("fall" in msg_lower or "down" in msg_lower):
            response = "The Nifty 50 is down 0.3% today, largely driven by selling in IT stocks. Key reasons: 1) Global tech weakness due to US rate uncertainty, 2) FII outflows of ₹15,000 Cr this month, 3) Profit booking after recent highs. However, banking and FMCG stocks are showing resilience. Support level at 23,200."
        elif "compare" in msg_lower and ("hdfc" in msg_lower or "icici" in msg_lower):
            response = "**HDFC Bank vs ICICI Bank Comparison:**\n- P/E: HDFC 18.5 vs ICICI 17.8\n- ROE: HDFC 16.8% vs ICICI 15.2%\n- NIM: HDFC 4.1% vs ICICI 4.5%\n- GNPA: HDFC 1.12% vs ICICI 1.82%\n- Market Cap: HDFC ₹12.5L Cr vs ICICI ₹8.2L Cr\nVerdict: HDFC offers better asset quality, ICICI offers better growth rate."
        elif "portfolio" in msg_lower:
            response = "Your portfolio analysis:\n- Total Value: ₹15,82,340\n- Returns: +27.1% (Excellent!)\n- Risk Score: 6.5/10 (Moderate)\n- Diversification: Good across 4 sectors\n- Suggestion: Consider increasing mid-cap allocation from 20% to 25%."
        elif "pe" in msg_lower and ("ratio" in msg_lower or "p/e" in msg_lower):
            response = "P/E Ratio (Price-to-Earnings) measures a company's current share price relative to its per-share earnings. A P/E of 20 means investors pay ₹20 for every ₹1 of earnings. In the Indian context: P/E 15-20 is fair for large-caps, 20-30+ for high-growth companies. The Nifty 50 currently trades at ~22x P/E, slightly above its 5-year average of 20x."
        elif ("market" in msg_lower and "today" in msg_lower) or "summary" in msg_lower:
            response = "**Market Summary for July 22, 2026:**\n- Nifty: 23,456.80 (+0.55%)\n- Sensex: 77,123.45 (+0.44%)\n- Bank Nifty: 49,234.55 (-0.18%)\n- Advance-Decline ratio: 1.8:1\n- Sector: Telecom (+1.2%), Oil & Gas (+1.1%), Banking (+0.5%), IT (-0.7%)"
        elif "gain" in msg_lower:
            response = "**Top Gainers:** RELIANCE +1.16%, BHARTIARTL +1.19%, BAJFINANCE +0.79%, WIPRO +0.63%, ICICIBANK +0.60%. Broad-based buying in energy and telecom."
        elif "los" in msg_lower or "decline" in msg_lower:
            response = "**Top Losers:** INFY -0.82%, ITC -0.53%, TCS -0.47%, HINDUNILVR -0.25%. IT under pressure from global rate uncertainty."
        elif "hello" in msg_lower or "hi" in msg_lower:
            response = "Hello! I'm FinSwitch AI. I can help you with stock analysis, market trends, portfolio insights, and financial concepts. Try asking about a specific stock like RELIANCE or TCS, or ask about markets today."
        else:
            response = "I'm your AI financial analyst. I can help with:\n\n• **Stocks**: Try \"RELIANCE\", \"TCS\", \"HDFC Bank\", \"ICICI\" — I know all NSE stocks\n• **Markets**: \"Market summary\", \"Nifty today\"\n• **Portfolio**: \"Portfolio analysis\", \"My investments\"\n• **Gainers/Losers**: \"Top gainers\", \"Which stocks fell\"\n• **Concepts**: \"What is P/E ratio\"\n\nWhat would you like to explore?"

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
