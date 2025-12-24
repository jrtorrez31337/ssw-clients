#!/bin/bash
# Stop web client

set -e

echo "🛑 Stopping SSW Web Client..."

cd "$(dirname "$0")/../.."

# Stop by PID file if exists
if [ -f .pids/web.pid ]; then
  PID=$(cat .pids/web.pid)
  if ps -p $PID > /dev/null 2>&1; then
    kill $PID 2>/dev/null || true
    echo "✅ Stopped web client (PID: $PID)"
  fi
  rm .pids/web.pid
fi

# Kill any process on port 3000
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1; then
  echo "   Killing remaining processes on port 3000..."
  lsof -ti:3000 | xargs kill -9 2>/dev/null || true
fi

echo "✅ Web client stopped"
