#!/bin/bash

################################################################################
# SSW Galaxy MMO Web Client - Health Check Script
#
# This script performs comprehensive health checks on the application
# and its dependencies.
#
# Usage: ./scripts/health-check.sh
# Exit codes:
#   0 - All checks passed
#   1 - Critical failure
#   2 - Warnings present
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
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0

# Project configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="ssw-web-client"
PORT=3000

echo "=========================================="
echo "SSW Galaxy MMO - Comprehensive Health Check"
echo "=========================================="
echo ""

cd "$PROJECT_ROOT"

################################################################################
# Check 1: Node.js
################################################################################
log_info "Check 1: Node.js installation"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    log_success "Node.js installed: $NODE_VERSION"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    log_error "Node.js is not installed"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi
echo ""

################################################################################
# Check 2: npm
################################################################################
log_info "Check 2: npm installation"
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    log_success "npm installed: v$NPM_VERSION"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    log_error "npm is not installed"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi
echo ""

################################################################################
# Check 3: PM2
################################################################################
log_info "Check 3: PM2 process manager"
if command -v pm2 &> /dev/null; then
    PM2_VERSION=$(pm2 --version)
    log_success "PM2 installed: v$PM2_VERSION"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    log_warning "PM2 is not installed (optional but recommended)"
    CHECKS_WARNING=$((CHECKS_WARNING + 1))
fi
echo ""

################################################################################
# Check 4: Dependencies
################################################################################
log_info "Check 4: Project dependencies"
if [ -d "node_modules" ]; then
    log_success "node_modules directory exists"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    log_error "node_modules not found. Run: npm install"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi
echo ""

################################################################################
# Check 5: Application Status
################################################################################
log_info "Check 5: Application status"
if command -v pm2 &> /dev/null && pm2 list | grep -q "$APP_NAME.*online"; then
    log_success "Application is running"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    log_warning "Application is not running"
    CHECKS_WARNING=$((CHECKS_WARNING + 1))
fi
echo ""

################################################################################
# Check 6: Port Availability/Usage
################################################################################
log_info "Check 6: Port $PORT status"
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    log_success "Port $PORT is in use (application running)"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    log_warning "Port $PORT is free (application not running)"
    CHECKS_WARNING=$((CHECKS_WARNING + 1))
fi
echo ""

################################################################################
# Check 7: HTTP Response
################################################################################
log_info "Check 7: HTTP endpoint health"
if curl -s -f -o /dev/null http://localhost:$PORT 2>/dev/null; then
    RESPONSE_TIME=$(curl -o /dev/null -s -w '%{time_total}' http://localhost:$PORT 2>/dev/null)
    log_success "Application responding (${RESPONSE_TIME}s)"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    log_warning "Application not responding on http://localhost:$PORT"
    CHECKS_WARNING=$((CHECKS_WARNING + 1))
fi
echo ""

################################################################################
# Check 8: Backend API
################################################################################
log_info "Check 8: Backend API availability"
if curl -s -f -o /dev/null http://localhost:8080/health 2>/dev/null; then
    log_success "Backend API is responding"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    log_warning "Backend API not responding at http://localhost:8080"
    CHECKS_WARNING=$((CHECKS_WARNING + 1))
fi
echo ""

################################################################################
# Check 9: Disk Space
################################################################################
log_info "Check 9: Disk space"
DISK_USAGE=$(df "$PROJECT_ROOT" | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 90 ]; then
    log_success "Disk space OK (${DISK_USAGE}% used)"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
elif [ "$DISK_USAGE" -lt 95 ]; then
    log_warning "Disk space running low (${DISK_USAGE}% used)"
    CHECKS_WARNING=$((CHECKS_WARNING + 1))
else
    log_error "Disk space critical (${DISK_USAGE}% used)"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi
echo ""

################################################################################
# Check 10: Memory Usage
################################################################################
log_info "Check 10: Memory availability"
AVAILABLE_MEM=$(free -m | awk 'NR==2{print $7}')
if [ "$AVAILABLE_MEM" -gt 500 ]; then
    log_success "Memory OK (${AVAILABLE_MEM}MB available)"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
elif [ "$AVAILABLE_MEM" -gt 200 ]; then
    log_warning "Memory running low (${AVAILABLE_MEM}MB available)"
    CHECKS_WARNING=$((CHECKS_WARNING + 1))
else
    log_error "Memory critical (${AVAILABLE_MEM}MB available)"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi
echo ""

################################################################################
# Summary
################################################################################
echo "=========================================="
echo "Health Check Summary"
echo "=========================================="
echo ""
echo -e "${GREEN}✓ Passed:  $CHECKS_PASSED${NC}"
echo -e "${YELLOW}⚠ Warnings: $CHECKS_WARNING${NC}"
echo -e "${RED}✗ Failed:  $CHECKS_FAILED${NC}"
echo ""

TOTAL_CHECKS=$((CHECKS_PASSED + CHECKS_WARNING + CHECKS_FAILED))
echo "Total checks: $TOTAL_CHECKS"
echo ""

# Determine exit code
if [ $CHECKS_FAILED -gt 0 ]; then
    echo "Status: CRITICAL - Some checks failed"
    exit 1
elif [ $CHECKS_WARNING -gt 0 ]; then
    echo "Status: WARNING - Application may not be fully operational"
    exit 2
else
    echo "Status: HEALTHY - All systems operational"
    exit 0
fi
