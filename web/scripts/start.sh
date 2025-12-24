#!/bin/bash

################################################################################
# SSW Galaxy MMO Web Client - Application Startup Script
#
# This script starts the web client using PM2 process manager.
# It handles port cleanup, health checks, and provides useful output.
#
# Usage: ./scripts/start.sh [options]
# Options:
#   --force    Force restart if already running
#   --dev      Start in development mode (default)
#   --build    Build before starting
################################################################################

set -e

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

# Parse arguments
FORCE_RESTART=false
BUILD_FIRST=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --force) FORCE_RESTART=true ;;
        --build) BUILD_FIRST=true ;;
        --dev) ;; # Default mode
        *) log_error "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

echo "=================================="
echo "SSW Galaxy MMO - Start Application"
echo "=================================="
echo ""

cd "$PROJECT_ROOT"

################################################################################
# Step 1: Check dependencies
################################################################################
log_info "Step 1: Checking dependencies..."

if [ ! -d "node_modules" ]; then
    log_error "node_modules not found. Please run ./scripts/init-env.sh first"
    exit 1
fi

if ! command -v pm2 &> /dev/null; then
    log_error "PM2 is not installed. Please run ./scripts/init-env.sh first"
    exit 1
fi

log_success "Dependencies verified"
echo ""

################################################################################
# Step 2: Check backend availability
################################################################################
log_info "Step 2: Checking backend API..."

if curl -s -f -o /dev/null http://localhost:8080/health 2>/dev/null; then
    log_success "Backend API is running"
else
    log_warning "Backend API not responding at http://localhost:8080"
    log_warning "Frontend will start but API calls will fail"
    log_warning "Make sure to start the backend service"
fi
echo ""

################################################################################
# Step 3: Check if already running
################################################################################
log_info "Step 3: Checking application status..."

if pm2 list | grep -q "$APP_NAME.*online"; then
    if [ "$FORCE_RESTART" = true ]; then
        log_info "Application is running. Force restarting..."
        ./scripts/stop.sh
        sleep 2
    else
        log_warning "Application is already running!"
        echo ""
        pm2 list | grep "$APP_NAME" || true
        echo ""
        echo "Options:"
        echo "  - Use './scripts/stop.sh' to stop it first"
        echo "  - Use './scripts/start.sh --force' to force restart"
        echo "  - Use './scripts/restart.sh' to restart"
        echo "  - Use './scripts/status.sh' to check status"
        exit 0
    fi
fi
echo ""

################################################################################
# Step 4: Clean up port
################################################################################
log_info "Step 4: Cleaning up port $PORT..."

if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    log_warning "Port $PORT is in use. Attempting to free it..."
    fuser -k $PORT/tcp 2>/dev/null || true
    sleep 1
    log_success "Port cleaned up"
else
    log_success "Port $PORT is available"
fi
echo ""

################################################################################
# Step 5: Build if requested
################################################################################
if [ "$BUILD_FIRST" = true ]; then
    log_info "Step 5: Building application..."
    npm run build
    log_success "Build completed"
    echo ""
fi

################################################################################
# Step 6: Start application with PM2
################################################################################
log_info "Starting $APP_NAME with PM2..."

pm2 start ecosystem.config.cjs

log_success "Application started successfully"
echo ""

################################################################################
# Step 7: Wait for application to be ready
################################################################################
log_info "Waiting for application to be ready..."

MAX_WAIT=30
COUNTER=0

while [ $COUNTER -lt $MAX_WAIT ]; do
    if curl -s -f -o /dev/null http://localhost:$PORT 2>/dev/null; then
        log_success "Application is ready!"
        break
    fi
    
    sleep 1
    COUNTER=$((COUNTER + 1))
    
    if [ $COUNTER -eq $MAX_WAIT ]; then
        log_error "Application failed to start within ${MAX_WAIT}s"
        log_info "Checking PM2 logs..."
        pm2 logs $APP_NAME --nostream --lines 20
        exit 1
    fi
done
echo ""

################################################################################
# Step 8: Display status and information
################################################################################
echo "=================================="
echo "Application Started Successfully!"
echo "=================================="
echo ""

# PM2 status
pm2 list | grep -E "id|$APP_NAME" || pm2 list

echo ""
log_success "✓ Application is running"
log_success "✓ Process managed by PM2"
echo ""
echo "Access URLs:"
echo "  Local:    http://localhost:$PORT"
echo "  Network:  http://$(hostname -I | awk '{print $1}'):$PORT"
echo ""
echo "Useful commands:"
echo "  ./scripts/status.sh    - Check application status"
echo "  ./scripts/logs.sh      - View application logs"
echo "  ./scripts/stop.sh      - Stop application"
echo "  ./scripts/restart.sh   - Restart application"
echo ""
echo "PM2 commands:"
echo "  pm2 list               - List all PM2 processes"
echo "  pm2 logs $APP_NAME     - Stream logs"
echo "  pm2 monit              - Monitor resources"
echo ""

################################################################################
# Step 9: Show recent logs
################################################################################
log_info "Recent logs (last 10 lines):"
echo "---"
pm2 logs $APP_NAME --nostream --lines 10 2>/dev/null || echo "No logs available yet"
echo "---"
echo ""

log_info "Use './scripts/logs.sh' to view full logs"
echo ""
