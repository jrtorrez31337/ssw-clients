#!/bin/bash

################################################################################
# SSW Galaxy MMO Web Client - Application Stop Script
#
# This script gracefully stops the web client and cleans up resources.
#
# Usage: ./scripts/stop.sh [options]
# Options:
#   --force    Force kill if graceful stop fails
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
FORCE_KILL=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --force) FORCE_KILL=true ;;
        *) log_error "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

echo "=================================="
echo "SSW Galaxy MMO - Stop Application"
echo "=================================="
echo ""

cd "$PROJECT_ROOT"

################################################################################
# Step 1: Check if PM2 is installed
################################################################################
if ! command -v pm2 &> /dev/null; then
    log_warning "PM2 is not installed. Attempting direct port cleanup..."
    
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        log_info "Killing processes on port $PORT..."
        fuser -k $PORT/tcp 2>/dev/null || true
        log_success "Port $PORT cleaned up"
    else
        log_info "No process running on port $PORT"
    fi
    
    exit 0
fi

################################################################################
# Step 2: Check if application is running
################################################################################
log_info "Checking application status..."

if ! pm2 list | grep -q "$APP_NAME"; then
    log_warning "Application '$APP_NAME' is not registered with PM2"
    
    # Check if port is still in use
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        log_warning "But port $PORT is in use. Cleaning up..."
        fuser -k $PORT/tcp 2>/dev/null || true
        log_success "Port $PORT cleaned up"
    fi
    
    exit 0
fi

if ! pm2 list | grep -q "$APP_NAME.*online"; then
    log_info "Application is not running. Cleaning up PM2 entry..."
    pm2 delete $APP_NAME 2>/dev/null || true
    log_success "PM2 entry removed"
    exit 0
fi

################################################################################
# Step 3: Stop application gracefully
################################################################################
log_info "Stopping $APP_NAME..."

pm2 stop $APP_NAME

log_success "Application stopped"
echo ""

################################################################################
# Step 4: Delete from PM2
################################################################################
log_info "Removing from PM2..."

pm2 delete $APP_NAME

log_success "Removed from PM2"
echo ""

################################################################################
# Step 5: Verify port is free
################################################################################
log_info "Verifying port $PORT is free..."

sleep 1

if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    if [ "$FORCE_KILL" = true ]; then
        log_warning "Port still in use. Force killing..."
        fuser -k $PORT/tcp 2>/dev/null || true
        log_success "Port cleaned up"
    else
        log_warning "Port $PORT is still in use by another process"
        log_info "Use './scripts/stop.sh --force' to force kill"
    fi
else
    log_success "Port $PORT is free"
fi
echo ""

################################################################################
# Step 6: Save PM2 configuration
################################################################################
log_info "Saving PM2 configuration..."
pm2 save --force > /dev/null 2>&1 || true
echo ""

################################################################################
# Summary
################################################################################
echo "=================================="
echo "Application Stopped Successfully!"
echo "=================================="
echo ""
log_success "✓ Application stopped"
log_success "✓ Resources cleaned up"
echo ""
echo "To start again:"
echo "  ./scripts/start.sh"
echo ""
