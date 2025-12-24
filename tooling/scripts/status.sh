#!/bin/bash
# Check status of all services

echo "📊 SSW Clients - Service Status"
echo "================================="
echo ""

cd "$(dirname "$0")/../.."

# Check web
echo "🌐 Web Client (port 3000):"
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1; then
  PID=$(lsof -ti:3000)
  echo "   ✅ Running (PID: $PID)"
  if [ -f .pids/web.pid ]; then
    SAVED_PID=$(cat .pids/web.pid)
    if [ "$PID" = "$SAVED_PID" ]; then
      echo "   📝 Tracked PID matches"
    else
      echo "   ⚠️  Different process running (tracked: $SAVED_PID)"
    fi
  fi
else
  echo "   ❌ Not running"
fi
echo ""

# Check mobile
echo "📱 Mobile Client (port 3030):"
if lsof -Pi :3030 -sTCP:LISTEN -t >/dev/null 2>&1; then
  PID=$(lsof -ti:3030)
  echo "   ✅ Running (PID: $PID)"
  if [ -f .pids/mobile.pid ]; then
    SAVED_PID=$(cat .pids/mobile.pid)
    if [ "$PID" = "$SAVED_PID" ]; then
      echo "   📝 Tracked PID matches"
    else
      echo "   ⚠️  Different process running (tracked: $SAVED_PID)"
    fi
  fi
else
  echo "   ❌ Not running"
fi
echo ""

# Check logs
echo "📝 Recent Logs:"
echo ""
if [ -f logs/web.log ]; then
  echo "Web (last 3 lines):"
  tail -3 logs/web.log | sed 's/^/   /'
  echo ""
fi

if [ -f logs/mobile.log ]; then
  echo "Mobile (last 3 lines):"
  tail -3 logs/mobile.log | sed 's/^/   /'
  echo ""
fi

echo "================================="
echo "💡 Quick commands:"
echo "   Start all:  ./tooling/scripts/start-all.sh"
echo "   Stop all:   ./tooling/scripts/stop-all.sh"
echo "   View logs:  tail -f logs/{web,mobile}.log"
