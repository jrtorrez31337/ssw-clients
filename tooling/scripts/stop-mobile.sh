#!/bin/bash
# Stop mobile client

set -e

echo "🛑 Stopping SSW Mobile Client..."

cd "$(dirname "$0")/../.."

# Stop by PID file if exists
if [ -f .pids/mobile.pid ]; then
  PID=$(cat .pids/mobile.pid)
  if ps -p $PID > /dev/null 2>&1; then
    kill $PID 2>/dev/null || true
    echo "✅ Stopped mobile client (PID: $PID)"
  fi
  rm .pids/mobile.pid
fi

# Kill any process on port 3030
if lsof -Pi :3030 -sTCP:LISTEN -t >/dev/null 2>&1; then
  echo "   Killing remaining processes on port 3030..."
  lsof -ti:3030 | xargs kill -9 2>/dev/null || true
fi

# Also kill any expo/metro processes
pkill -f "expo start" 2>/dev/null || true
pkill -f "react-native start" 2>/dev/null || true

echo "✅ Mobile client stopped"
