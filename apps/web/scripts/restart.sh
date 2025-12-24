#!/bin/bash

################################################################################
# SSW Galaxy MMO Web Client - Application Restart Script
#
# This script restarts the web client with zero-downtime if possible.
#
# Usage: ./scripts/restart.sh [options]
# Options:
#   --hard     Perform hard restart (stop then start)
#   --build    Build before restarting
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

# Parse arguments
HARD_RESTART=false
BUILD_FIRST=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --hard) HARD_RESTART=true ;;
        --build) BUILD_FIRST=true ;;
        *) log_error "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

echo "=================================="
echo "SSW Galaxy MMO - Restart Application"
echo "=================================="
echo ""

cd "$PROJECT_ROOT"

################################################################################
# Build if requested
################################################################################
if [ "$BUILD_FIRST" = true ]; then
    log_info "Building application..."
    npm run build
    log_success "Build completed"
    echo ""
fi

################################################################################
# Restart based on mode
################################################################################
if [ "$HARD_RESTART" = true ]; then
    log_info "Performing hard restart..."
    echo ""
    
    ./scripts/stop.sh
    sleep 2
    ./scripts/start.sh
else
    log_info "Performing graceful restart with PM2..."
    echo ""
    
    if ! command -v pm2 &> /dev/null; then
        log_error "PM2 is not installed. Use --hard for hard restart"
        exit 1
    fi
    
    if ! pm2 list | grep -q "$APP_NAME"; then
        log_warning "Application is not running. Starting fresh..."
        ./scripts/start.sh
    else
        pm2 restart $APP_NAME
        
        log_success "Application restarted"
        echo ""
        
        # Wait for readiness
        log_info "Waiting for application to be ready..."
        sleep 3
        
        if curl -s -f -o /dev/null http://localhost:3000 2>/dev/null; then
            log_success "Application is ready!"
        else
            log_warning "Application may not be ready yet"
        fi
        
        echo ""
        echo "=================================="
        echo "Restart Complete!"
        echo "=================================="
        echo ""
        
        pm2 list | grep -E "id|$APP_NAME" || pm2 list
        echo ""
    fi
fi
