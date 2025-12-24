#!/bin/bash
# Start both web and mobile clients

set -e

echo "🚀 Starting SSW Clients Monorepo"
echo "================================="
echo ""

cd "$(dirname "$0")"

# Create logs directory
mkdir -p ../../logs

# Start web
echo "1️⃣  Starting Web Client..."
./start-web.sh
echo ""

# Wait a bit
sleep 2

# Start mobile
echo "2️⃣  Starting Mobile Client..."
./start-mobile.sh
echo ""

echo "================================="
echo "✅ All clients started!"
echo ""
echo "📊 Service Status:"
echo "   Web (0.0.0.0:3000):"
echo "     Local:   http://localhost:3000"
echo "     Network: http://$(hostname -I | awk '{print $1}'):3000"
echo "   Mobile (0.0.0.0:3030):"
echo "     Local:   http://localhost:3030 (Metro bundler)"
echo "     Network: http://$(hostname -I | awk '{print $1}'):3030"
echo ""
echo "📝 Logs:"
echo "   Web:    tail -f logs/web.log"
echo "   Mobile: tail -f logs/mobile.log"
echo ""
echo "🛑 To stop all:"
echo "   ./tooling/scripts/stop-all.sh"
