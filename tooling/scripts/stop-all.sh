#!/bin/bash
# Stop both web and mobile clients

set -e

echo "🛑 Stopping SSW Clients Monorepo"
echo "================================="
echo ""

cd "$(dirname "$0")"

# Stop web
echo "1️⃣  Stopping Web Client..."
./stop-web.sh
echo ""

# Stop mobile
echo "2️⃣  Stopping Mobile Client..."
./stop-mobile.sh
echo ""

echo "================================="
echo "✅ All clients stopped!"
