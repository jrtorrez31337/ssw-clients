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
echo "   Web:    http://localhost:3000"
echo "   Mobile: http://localhost:3030 (Metro bundler)"
echo ""
echo "📝 Logs:"
echo "   Web:    tail -f logs/web.log"
echo "   Mobile: tail -f logs/mobile.log"
echo ""
echo "🛑 To stop all:"
echo "   ./tooling/scripts/stop-all.sh"
