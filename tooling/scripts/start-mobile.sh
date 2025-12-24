#!/bin/bash
# Start mobile client on port 3030

set -e

echo "📱 Starting SSW Mobile Client..."
echo "   Metro Port: 3030"
echo "   Dev Server: http://localhost:3030"
echo ""

cd "$(dirname "$0")/../.."

# Kill any existing process on port 3030
if lsof -Pi :3030 -sTCP:LISTEN -t >/dev/null 2>&1; then
  echo "⚠️  Port 3030 is in use. Stopping existing process..."
  lsof -ti:3030 | xargs kill -9 2>/dev/null || true
  sleep 1
fi

# Start mobile in background with custom port
cd apps/mobile
RCT_METRO_PORT=3030 pnpm start --port 3030 > ../../logs/mobile.log 2>&1 &
MOBILE_PID=$!
cd ../..

# Save PID
mkdir -p .pids
echo $MOBILE_PID > .pids/mobile.pid

echo "✅ Mobile client starting (PID: $MOBILE_PID)"
echo "   Logs: logs/mobile.log"
echo "   To view logs: tail -f logs/mobile.log"
echo "   To stop: ./tooling/scripts/stop-mobile.sh"
echo ""
echo "📲 Next steps:"
echo "   1. Open Expo Go app on your device"
echo "   2. Scan the QR code from logs/mobile.log"
echo "   OR"
echo "   3. For web preview: pnpm mobile:start-web"
