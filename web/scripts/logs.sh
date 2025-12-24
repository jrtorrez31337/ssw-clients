#!/bin/bash

################################################################################
# SSW Galaxy MMO Web Client - Logs Viewer Script
#
# This script displays application logs with various options.
#
# Usage: ./scripts/logs.sh [options]
# Options:
#   --follow   Follow logs in real-time (like tail -f)
#   --lines N  Show last N lines (default: 50)
#   --error    Show only error logs
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

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Project configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="ssw-web-client"

# Default options
FOLLOW=false
LINES=50
ERROR_ONLY=false

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --follow|-f) FOLLOW=true ;;
        --lines) LINES="$2"; shift ;;
        --error|-e) ERROR_ONLY=true ;;
        *) log_error "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

echo "=================================="
echo "SSW Galaxy MMO - Application Logs"
echo "=================================="
echo ""

cd "$PROJECT_ROOT"

################################################################################
# Check if PM2 is available
################################################################################
if ! command -v pm2 &> /dev/null; then
    log_error "PM2 is not installed"
    exit 1
fi

################################################################################
# Check if application is registered
################################################################################
if ! pm2 list | grep -q "$APP_NAME"; then
    log_warning "Application '$APP_NAME' is not registered with PM2"
    echo ""
    echo "Available PM2 processes:"
    pm2 list
    exit 1
fi

################################################################################
# Display logs based on options
################################################################################
if [ "$FOLLOW" = true ]; then
    log_info "Following logs for $APP_NAME (press Ctrl+C to stop)..."
    echo ""
    
    if [ "$ERROR_ONLY" = true ]; then
        pm2 logs $APP_NAME --err
    else
        pm2 logs $APP_NAME
    fi
else
    if [ "$ERROR_ONLY" = true ]; then
        log_info "Showing last $LINES error log lines:"
        echo "---"
        pm2 logs $APP_NAME --err --nostream --lines $LINES 2>/dev/null || echo "No error logs available"
    else
        log_info "Showing last $LINES log lines:"
        echo "---"
        pm2 logs $APP_NAME --nostream --lines $LINES 2>/dev/null || echo "No logs available"
    fi
    
    echo "---"
    echo ""
    echo "Tip: Use './scripts/logs.sh --follow' to stream logs in real-time"
fi
