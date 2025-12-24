#!/bin/bash
# Start web client on port 3000

set -e

echo "🌐 Starting SSW Web Client..."
echo "   Port: 3000"
echo "   Host: 0.0.0.0 (all interfaces)"
echo "   Local URL: http://localhost:3000"
echo "   Network URL: http://0.0.0.0:3000"
echo ""

cd "$(dirname "$0")/../.."

# Kill any existing process on port 3000
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1; then
  echo "⚠️  Port 3000 is in use. Stopping existing process..."
  lsof -ti:3000 | xargs kill -9 2>/dev/null || true
  sleep 1
fi

# Start web in background
pnpm --filter @ssw/web dev > logs/web.log 2>&1 &
WEB_PID=$!

# Save PID
mkdir -p .pids
echo $WEB_PID > .pids/web.pid

echo "✅ Web client starting (PID: $WEB_PID)"
echo "   Logs: logs/web.log"
echo "   To view logs: tail -f logs/web.log"
echo "   To stop: ./tooling/scripts/stop-web.sh"
echo ""
echo "⏳ Waiting for server to be ready..."

# Wait for server to be ready (max 30 seconds)
for i in {1..30}; do
  if curl -s http://localhost:3000 >/dev/null 2>&1; then
    echo "✅ Web client ready!"
    echo "   Access locally: http://localhost:3000"
    echo "   Access from network: http://$(hostname -I | awk '{print $1}'):3000"
    exit 0
  fi
  sleep 1
done

echo "⚠️  Web client started but may still be initializing"
echo "   Check logs/web.log if issues occur"
