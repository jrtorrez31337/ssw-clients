#!/bin/bash

################################################################################
# SSW Galaxy MMO Web Client - Application Status Script
#
# This script displays the current status of the web client.
#
# Usage: ./scripts/status.sh
################################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Project configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="ssw-web-client"
PORT=3000

echo "=================================="
echo "SSW Galaxy MMO - Application Status"
echo "=================================="
echo ""

cd "$PROJECT_ROOT"

################################################################################
# Check PM2
################################################################################
log_info "PM2 Process Status:"
echo ""

if ! command -v pm2 &> /dev/null; then
    log_warning "PM2 is not installed"
else
    if pm2 list | grep -q "$APP_NAME"; then
        pm2 list | grep -E "id|$APP_NAME" || pm2 list
    else
        log_warning "Application is not registered with PM2"
    fi
fi
echo ""

################################################################################
# Check Port
################################################################################
log_info "Port $PORT Status:"
echo ""

if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    log_success "Port $PORT is in use"
    
    PID=$(lsof -Pi :$PORT -sTCP:LISTEN -t)
    log_info "Process ID: $PID"
    
    ps -p $PID -o pid,ppid,%cpu,%mem,cmd --no-headers 2>/dev/null || true
else
    log_warning "Port $PORT is not in use"
fi
echo ""

################################################################################
# Check Application Health
################################################################################
log_info "Application Health:"
echo ""

if curl -s -f -o /dev/null http://localhost:$PORT 2>/dev/null; then
    log_success "Application is responding at http://localhost:$PORT"
    
    # Check response time
    RESPONSE_TIME=$(curl -o /dev/null -s -w '%{time_total}' http://localhost:$PORT 2>/dev/null || echo "N/A")
    log_info "Response time: ${RESPONSE_TIME}s"
else
    log_error "Application is not responding at http://localhost:$PORT"
fi
echo ""

################################################################################
# Check Backend
################################################################################
log_info "Backend API Status:"
echo ""

if curl -s -f -o /dev/null http://localhost:8080/health 2>/dev/null; then
    log_success "Backend API is responding at http://localhost:8080"
else
    log_warning "Backend API is not responding at http://localhost:8080"
fi
echo ""

################################################################################
# System Resources
################################################################################
log_info "System Resources:"
echo ""

if command -v pm2 &> /dev/null && pm2 list | grep -q "$APP_NAME.*online"; then
    # Get memory and CPU from PM2
    PM2_INFO=$(pm2 info $APP_NAME 2>/dev/null)
    
    if [ ! -z "$PM2_INFO" ]; then
        echo "$PM2_INFO" | grep -E "cpu|memory|uptime|restarts" || true
    fi
else
    # Get from system if running
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        PID=$(lsof -Pi :$PORT -sTCP:LISTEN -t)
        ps -p $PID -o pid,%cpu,%mem,vsz,rss,etime --no-headers 2>/dev/null || true
    fi
fi
echo ""

################################################################################
# Recent Logs
################################################################################
log_info "Recent Logs (last 5 lines):"
echo "---"

if command -v pm2 &> /dev/null && pm2 list | grep -q "$APP_NAME"; then
    pm2 logs $APP_NAME --nostream --lines 5 2>/dev/null || echo "No logs available"
else
    echo "PM2 not running or app not registered"
fi

echo "---"
echo ""

################################################################################
# Summary
################################################################################
echo "=================================="
echo "Available Commands:"
echo "=================================="
echo ""
echo "  ./scripts/start.sh     - Start the application"
echo "  ./scripts/stop.sh      - Stop the application"
echo "  ./scripts/restart.sh   - Restart the application"
echo "  ./scripts/logs.sh      - View full logs"
echo ""
