#!/bin/bash
# Production-grade environment validation script
# Validates all prerequisites and dependencies before deployment

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

VALIDATION_PASSED=true

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}SSW Clients - Environment Validation${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to check command existence
check_command() {
  local cmd=$1
  local required_version=$2
  local display_name=${3:-$cmd}

  if command -v "$cmd" &> /dev/null; then
    local version=$($cmd --version 2>&1 | head -n1)
    echo -e "✅ ${display_name}: ${GREEN}Installed${NC}"
    echo "   Version: $version"

    if [ -n "$required_version" ]; then
      echo "   Required: >= $required_version"
    fi
  else
    echo -e "❌ ${display_name}: ${RED}Not found${NC}"
    if [ -n "$required_version" ]; then
      echo "   Required version: >= $required_version"
    fi
    VALIDATION_PASSED=false
  fi
  echo ""
}

# Function to check Node.js version
check_node_version() {
  if command -v node &> /dev/null; then
    local node_version=$(node --version | sed 's/v//')
    local major_version=$(echo "$node_version" | cut -d. -f1)

    echo -e "✅ Node.js: ${GREEN}Installed${NC}"
    echo "   Version: v$node_version"

    if [ "$major_version" -ge 18 ]; then
      echo -e "   Status: ${GREEN}Version OK${NC} (>= v18 required)"
    else
      echo -e "   Status: ${RED}Version too old${NC} (>= v18 required)"
      VALIDATION_PASSED=false
    fi
  else
    echo -e "❌ Node.js: ${RED}Not found${NC}"
    echo "   Required version: >= v18"
    VALIDATION_PASSED=false
  fi
  echo ""
}

# Function to check pnpm version
check_pnpm_version() {
  if command -v pnpm &> /dev/null; then
    local pnpm_version=$(pnpm --version)
    local major_version=$(echo "$pnpm_version" | cut -d. -f1)

    echo -e "✅ pnpm: ${GREEN}Installed${NC}"
    echo "   Version: $pnpm_version"

    if [ "$major_version" -ge 8 ]; then
      echo -e "   Status: ${GREEN}Version OK${NC} (>= v8 required)"
    else
      echo -e "   Status: ${RED}Version too old${NC} (>= v8 required)"
      VALIDATION_PASSED=false
    fi
  else
    echo -e "❌ pnpm: ${RED}Not found${NC}"
    echo "   Required version: >= v8"
    echo "   Install: npm install -g pnpm"
    VALIDATION_PASSED=false
  fi
  echo ""
}

# Function to check port availability
check_port() {
  local port=$1
  local service_name=$2

  if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
    local pid=$(lsof -ti:$port)
    echo -e "⚠️  Port $port (${service_name}): ${YELLOW}In use${NC}"
    echo "   Process: PID $pid"
    echo "   Note: Will be cleared on startup"
  else
    echo -e "✅ Port $port (${service_name}): ${GREEN}Available${NC}"
  fi
  echo ""
}

# Function to check directory structure
check_directory_structure() {
  local dirs=("apps/web" "apps/mobile" "packages/contracts" "packages/api" "packages/domain" "packages/flags")
  local all_exist=true

  echo "📁 Directory Structure:"
  for dir in "${dirs[@]}"; do
    if [ -d "$dir" ]; then
      echo -e "   ✅ $dir"
    else
      echo -e "   ❌ $dir ${RED}(missing)${NC}"
      all_exist=false
      VALIDATION_PASSED=false
    fi
  done

  if $all_exist; then
    echo -e "   Status: ${GREEN}All required directories present${NC}"
  else
    echo -e "   Status: ${RED}Missing required directories${NC}"
  fi
  echo ""
}

# Function to check dependencies installed
check_dependencies() {
  echo "📦 Dependencies:"

  if [ -d "node_modules" ]; then
    echo -e "   ✅ Root node_modules: ${GREEN}Present${NC}"
  else
    echo -e "   ⚠️  Root node_modules: ${YELLOW}Missing${NC}"
    echo "      Run: pnpm install"
    VALIDATION_PASSED=false
  fi

  if [ -d "apps/web/node_modules" ]; then
    echo -e "   ✅ Web node_modules: ${GREEN}Present${NC}"
  else
    echo -e "   ⚠️  Web node_modules: ${YELLOW}Missing${NC}"
    VALIDATION_PASSED=false
  fi

  if [ -d "apps/mobile/node_modules" ]; then
    echo -e "   ✅ Mobile node_modules: ${GREEN}Present${NC}"
  else
    echo -e "   ⚠️  Mobile node_modules: ${YELLOW}Missing${NC}"
    VALIDATION_PASSED=false
  fi
  echo ""
}

# Function to check disk space
check_disk_space() {
  local available=$(df -h . | awk 'NR==2 {print $4}')
  local available_mb=$(df -m . | awk 'NR==2 {print $4}')

  echo "💾 Disk Space:"
  echo "   Available: $available"

  if [ "$available_mb" -lt 1000 ]; then
    echo -e "   Status: ${RED}Low disk space${NC} (< 1GB)"
    VALIDATION_PASSED=false
  elif [ "$available_mb" -lt 5000 ]; then
    echo -e "   Status: ${YELLOW}Moderate disk space${NC}"
  else
    echo -e "   Status: ${GREEN}Sufficient${NC}"
  fi
  echo ""
}

# Function to check memory
check_memory() {
  if command -v free &> /dev/null; then
    local available_mb=$(free -m | awk 'NR==2 {print $7}')
    local total_mb=$(free -m | awk 'NR==2 {print $2}')

    echo "🧠 Memory:"
    echo "   Available: ${available_mb}MB / ${total_mb}MB"

    if [ "$available_mb" -lt 512 ]; then
      echo -e "   Status: ${RED}Low memory${NC} (< 512MB available)"
      VALIDATION_PASSED=false
    elif [ "$available_mb" -lt 1024 ]; then
      echo -e "   Status: ${YELLOW}Moderate memory${NC}"
    else
      echo -e "   Status: ${GREEN}Sufficient${NC}"
    fi
  else
    echo "🧠 Memory: Unable to check (free command not available)"
  fi
  echo ""
}

# Function to check backend connectivity
check_backend() {
  echo "🔌 Backend Connectivity:"

  if curl -s --connect-timeout 5 http://localhost:8080/health >/dev/null 2>&1; then
    echo -e "   ✅ Backend API: ${GREEN}Reachable${NC}"
    echo "      URL: http://localhost:8080"
  else
    echo -e "   ⚠️  Backend API: ${YELLOW}Not reachable${NC}"
    echo "      URL: http://localhost:8080"
    echo "      Note: Backend must be running for full functionality"
  fi
  echo ""
}

# Run all checks
cd "$(dirname "$0")/../.."

echo "🔍 System Requirements:"
echo ""
check_node_version
check_pnpm_version
check_command "git" "" "Git"
check_command "curl" "" "cURL"
check_command "lsof" "" "lsof"

echo "🌐 Port Availability:"
echo ""
check_port 3000 "Web Client"
check_port 3030 "Mobile Client"
check_port 8080 "Backend API"

check_directory_structure
check_dependencies
check_disk_space
check_memory
check_backend

# Summary
echo -e "${BLUE}========================================${NC}"
if $VALIDATION_PASSED; then
  echo -e "${GREEN}✅ Environment validation PASSED${NC}"
  echo ""
  echo "Your environment is ready for deployment!"
  echo ""
  echo "Next steps:"
  echo "  - Install dependencies: pnpm install"
  echo "  - Start development: ./tooling/scripts/start-all.sh"
  echo "  - Build for production: ./tooling/scripts/deploy-prod.sh"
  exit 0
else
  echo -e "${RED}❌ Environment validation FAILED${NC}"
  echo ""
  echo "Please fix the issues above before proceeding."
  echo ""
  echo "Common fixes:"
  echo "  - Install Node.js >= v18: https://nodejs.org"
  echo "  - Install pnpm >= v8: npm install -g pnpm"
  echo "  - Install dependencies: pnpm install"
  echo "  - Free up disk space if needed"
  exit 1
fi
