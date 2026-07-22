#!/bin/bash
set -e

echo "╔═══════════════════════════════════════╗"
echo "║     FinSwitch — Local Dev Startup     ║"
echo "╚═══════════════════════════════════════╝"

# Website (Next.js)
echo ""
echo "→ Starting website (Next.js)..."
cd "$(dirname "$0")/website"
npm run dev &
WEB_PID=$!
echo "  Website PID: $WEB_PID (port 3000)"

echo ""
echo "╔═══════════════════════════════════════╗"
echo "║  Website is running!                  ║"
echo "║                                       ║"
echo "║  Website:  http://localhost:3000      ║"
echo "║                                       ║"
echo "║  Press Ctrl+C to stop all services    ║"
echo "╚═══════════════════════════════════════╝"

trap "kill $WEB_PID 2>/dev/null; echo 'Stopped.'" EXIT INT TERM
wait
