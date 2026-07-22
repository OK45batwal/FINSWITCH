#!/bin/bash
set -e

echo "╔═══════════════════════════════════════╗"
echo "║     FinSwitch — Local Dev Startup     ║"
echo "╚═══════════════════════════════════════╝"

# Backend
echo ""
echo "→ Starting backend API server..."
cd "$(dirname "$0")/backend"
if [ -d ".venv" ]; then
  source .venv/bin/activate
fi
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload &
BACKEND_PID=$!
echo "  Backend PID: $BACKEND_PID (port 8000)"

# Website (Next.js)
echo ""
echo "→ Starting website (Next.js)..."
cd "$(dirname "$0")/website"
npm run dev &
WEB_PID=$!
echo "  Website PID: $WEB_PID (port 3000)"

echo ""
echo "╔═══════════════════════════════════════╗"
echo "║  ✅  All services running!            ║"
echo "║                                       ║"
echo "║  Website:  http://localhost:3000      ║"
echo "║  Backend:  http://localhost:8000      ║"
echo "║  API Docs: http://localhost:8000/api/docs  ║"
echo "║                                       ║"
echo "║  Press Ctrl+C to stop all services    ║"
echo "╚═══════════════════════════════════════╝"

trap "kill $BACKEND_PID $WEB_PID 2>/dev/null; echo 'Stopped.'" EXIT INT TERM
wait
