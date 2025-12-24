#!/bin/bash

################################################################################
# SSW Galaxy MMO Web Client - Environment Initialization Script
# 
# This script sets up the complete development environment including:
# - Node.js and npm verification
# - PM2 process manager installation
# - Project dependencies installation
# - Environment configuration
# - Git setup
#
# Usage: ./scripts/init-env.sh
################################################################################

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

echo "=================================="
echo "SSW Galaxy MMO - Environment Setup"
echo "=================================="
echo ""

# Get project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

log_info "Project root: $PROJECT_ROOT"
echo ""

################################################################################
# Step 1: Check Node.js
################################################################################
log_info "Step 1: Checking Node.js installation..."

if ! command -v node &> /dev/null; then
    log_error "Node.js is not installed!"
    echo ""
    echo "Please install Node.js 18 or higher:"
    echo "  Ubuntu/Debian: curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt-get install -y nodejs"
    echo "  RHEL/CentOS:   curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash - && sudo yum install -y nodejs"
    echo "  Or visit: https://nodejs.org/"
    exit 1
fi

NODE_VERSION=$(node --version)
log_success "Node.js is installed: $NODE_VERSION"

# Check Node.js version (require v18+)
NODE_MAJOR_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_MAJOR_VERSION" -lt 18 ]; then
    log_error "Node.js version must be 18 or higher. Current: $NODE_VERSION"
    exit 1
fi

################################################################################
# Step 2: Check npm
################################################################################
log_info "Step 2: Checking npm installation..."

if ! command -v npm &> /dev/null; then
    log_error "npm is not installed!"
    exit 1
fi

NPM_VERSION=$(npm --version)
log_success "npm is installed: v$NPM_VERSION"
echo ""

################################################################################
# Step 3: Install PM2 globally
################################################################################
log_info "Step 3: Checking PM2 process manager..."

if ! command -v pm2 &> /dev/null; then
    log_warning "PM2 is not installed. Installing globally..."
    npm install -g pm2
    log_success "PM2 installed successfully"
else
    PM2_VERSION=$(pm2 --version)
    log_success "PM2 is already installed: v$PM2_VERSION"
fi
echo ""

################################################################################
# Step 4: Install project dependencies
################################################################################
log_info "Step 4: Installing project dependencies..."

if [ ! -d "node_modules" ]; then
    log_info "Installing npm packages (this may take a few minutes)..."
    npm install
    log_success "Dependencies installed successfully"
else
    log_info "node_modules exists. Running npm install to ensure everything is up to date..."
    npm install
    log_success "Dependencies verified"
fi
echo ""

################################################################################
# Step 5: Create .env file if it doesn't exist
################################################################################
log_info "Step 5: Setting up environment configuration..."

if [ ! -f ".env" ]; then
    log_info "Creating .env file..."
    cat > .env << 'EOF'
# SSW Galaxy MMO Web Client - Environment Variables

# Backend API URL (used by Vite proxy)
VITE_API_URL=http://localhost:8080/v1

# Backend API base (without /v1)
BACKEND_API_HOST=localhost
BACKEND_API_PORT=8080

# Development server
DEV_SERVER_PORT=3000
DEV_SERVER_HOST=0.0.0.0

# Node environment
NODE_ENV=development
EOF
    log_success ".env file created"
else
    log_info ".env file already exists"
fi
echo ""

################################################################################
# Step 6: Verify backend availability (optional check)
################################################################################
log_info "Step 6: Checking backend API availability..."

if curl -s -f -o /dev/null http://localhost:8080/health 2>/dev/null; then
    log_success "Backend API is running and healthy"
else
    log_warning "Backend API is not responding at http://localhost:8080"
    log_warning "Make sure to start the backend before running the frontend"
fi
echo ""

################################################################################
# Step 7: Git configuration
################################################################################
log_info "Step 7: Checking Git configuration..."

if [ -d ".git" ]; then
    log_success "Git repository initialized"
    
    # Check if remote is configured
    if git remote -v | grep -q "origin"; then
        REMOTE_URL=$(git remote get-url origin)
        log_success "Git remote configured: $REMOTE_URL"
    else
        log_info "No git remote configured"
    fi
else
    log_warning "Not a git repository. Run 'git init' if needed."
fi
echo ""

################################################################################
# Step 8: Check port availability
################################################################################
log_info "Step 8: Checking port availability..."

if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    log_warning "Port 3000 is already in use"
    log_info "Run './scripts/stop.sh' to stop any running instances"
else
    log_success "Port 3000 is available"
fi
echo ""

################################################################################
# Step 9: Create logs directory
################################################################################
log_info "Step 9: Setting up logs directory..."

if [ ! -d "logs" ]; then
    mkdir -p logs
    log_success "Logs directory created"
else
    log_info "Logs directory already exists"
fi
echo ""

################################################################################
# Summary
################################################################################
echo "=================================="
echo "Environment Setup Complete!"
echo "=================================="
echo ""
log_success "✓ Node.js $NODE_VERSION"
log_success "✓ npm v$NPM_VERSION"
log_success "✓ PM2 installed"
log_success "✓ Project dependencies installed"
log_success "✓ Environment configured"
echo ""
echo "Next steps:"
echo "  1. Start the backend API on port 8080"
echo "  2. Run: ./scripts/start.sh"
echo "  3. Access: http://localhost:3000"
echo ""
echo "Available commands:"
echo "  ./scripts/start.sh     - Start the application"
echo "  ./scripts/stop.sh      - Stop the application"
echo "  ./scripts/restart.sh   - Restart the application"
echo "  ./scripts/status.sh    - Check application status"
echo "  ./scripts/logs.sh      - View application logs"
echo ""
