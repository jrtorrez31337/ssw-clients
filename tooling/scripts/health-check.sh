#!/bin/bash
# Production-grade health check and monitoring script
# Performs comprehensive health checks on all services

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

HEALTH_PASSED=true
SCRIPT_DIR="$(dirname "$0")"
ROOT_DIR="$SCRIPT_DIR/../.."

# Configuration
WEB_PORT=3000
MOBILE_PORT=3030
BACKEND_PORT=8080
HEALTH_TIMEOUT=5

# Function to check HTTP endpoint
check_http_endpoint() {
  local url=$1
  local service_name=$2
  local timeout=${3:-5}

  if curl -s --connect-timeout "$timeout" --max-time "$timeout" "$url" >/dev/null 2>&1; then
    local response_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout "$timeout" "$url" 2>/dev/null)
    echo -e "✅ ${service_name}: ${GREEN}Healthy${NC}"
    echo "   URL: $url"
    echo "   Response: HTTP $response_code"
    return 0
  else
    echo -e "❌ ${service_name}: ${RED}Unhealthy${NC}"
    echo "   URL: $url"
    echo "   Error: Endpoint not reachable"
    HEALTH_PASSED=false
    return 1
  fi
}

# Function to check process health
check_process_health() {
  local pid=$1
  local service_name=$2

  if [ -z "$pid" ]; then
    echo -e "❌ ${service_name}: ${RED}No PID${NC}"
    HEALTH_PASSED=false
    return 1
  fi

  if ps -p "$pid" > /dev/null 2>&1; then
    # Get process details
    local cpu=$(ps -p "$pid" -o %cpu= | tr -d ' ')
    local mem=$(ps -p "$pid" -o %mem= | tr -d ' ')
    local rss=$(ps -p "$pid" -o rss= | tr -d ' ')
    local rss_mb=$((rss / 1024))
    local elapsed=$(ps -p "$pid" -o etime= | tr -d ' ')

    echo -e "✅ ${service_name}: ${GREEN}Running${NC}"
    echo "   PID: $pid"
    echo "   CPU: ${cpu}%"
    echo "   Memory: ${mem}% (${rss_mb}MB)"
    echo "   Uptime: $elapsed"

    # Warning thresholds
    local cpu_int=$(echo "$cpu" | cut -d. -f1)
    if [ -n "$cpu_int" ] && [ "$cpu_int" -gt 80 ]; then
      echo -e "   ${YELLOW}⚠️  High CPU usage${NC}"
    fi

    local mem_int=$(echo "$mem" | cut -d. -f1)
    if [ -n "$mem_int" ] && [ "$mem_int" -gt 80 ]; then
      echo -e "   ${YELLOW}⚠️  High memory usage${NC}"
    fi

    return 0
  else
    echo -e "❌ ${service_name}: ${RED}Not running${NC}"
    echo "   PID: $pid (process not found)"
    HEALTH_PASSED=false
    return 1
  fi
}

# Function to check port
check_port() {
  local port=$1
  local service_name=$2

  if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
    local pid=$(lsof -ti:$port)
    echo -e "✅ Port $port (${service_name}): ${GREEN}Listening${NC}"
    echo "   PID: $pid"
    return 0
  else
    echo -e "❌ Port $port (${service_name}): ${RED}Not listening${NC}"
    HEALTH_PASSED=false
    return 1
  fi
}

# Function to check log file
check_log_health() {
  local log_file=$1
  local service_name=$2
  local error_threshold=10

  if [ ! -f "$log_file" ]; then
    echo -e "⚠️  ${service_name} Log: ${YELLOW}File not found${NC}"
    echo "   Path: $log_file"
    return 1
  fi

  local log_size=$(du -h "$log_file" | cut -f1)
  local error_count=$(grep -i "error" "$log_file" 2>/dev/null | wc -l)
  local warning_count=$(grep -i "warning\|warn" "$log_file" 2>/dev/null | wc -l)
  local last_modified=$(stat -c %y "$log_file" 2>/dev/null | cut -d. -f1)

  echo -e "📝 ${service_name} Log: ${GREEN}Present${NC}"
  echo "   Path: $log_file"
  echo "   Size: $log_size"
  echo "   Last modified: $last_modified"

  if [ "$error_count" -gt "$error_threshold" ]; then
    echo -e "   ${RED}⚠️  Errors: $error_count (threshold: $error_threshold)${NC}"
    HEALTH_PASSED=false
  else
    echo "   Errors: $error_count"
  fi

  echo "   Warnings: $warning_count"

  # Show last few lines
  echo "   Last 3 lines:"
  tail -3 "$log_file" | sed 's/^/      /'
}

# Function to check dependencies
check_dependencies_health() {
  echo "📦 Dependencies Health:"

  # Check if node_modules are up to date
  if [ -f "$ROOT_DIR/package.json" ] && [ -d "$ROOT_DIR/node_modules" ]; then
    local package_modified=$(stat -c %Y "$ROOT_DIR/package.json" 2>/dev/null || stat -f %m "$ROOT_DIR/package.json" 2>/dev/null)
    local nodemodules_modified=$(stat -c %Y "$ROOT_DIR/node_modules" 2>/dev/null || stat -f %m "$ROOT_DIR/node_modules" 2>/dev/null)

    if [ "$package_modified" -gt "$nodemodules_modified" ]; then
      echo -e "   ⚠️  ${YELLOW}package.json newer than node_modules${NC}"
      echo "      Consider running: pnpm install"
    else
      echo -e "   ✅ Dependencies: ${GREEN}Up to date${NC}"
    fi
  else
    echo -e "   ❌ Dependencies: ${RED}node_modules missing${NC}"
    HEALTH_PASSED=false
  fi
  echo ""
}

# Function to check system resources
check_system_resources() {
  echo "💻 System Resources:"

  # CPU load
  if command -v uptime &> /dev/null; then
    local load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')
    echo "   Load Average: $load"
  fi

  # Memory
  if command -v free &> /dev/null; then
    local total=$(free -h | awk 'NR==2 {print $2}')
    local used=$(free -h | awk 'NR==2 {print $3}')
    local available=$(free -h | awk 'NR==2 {print $7}')
    local percent=$(free | awk 'NR==2 {printf "%.0f", $3/$2 * 100}')

    echo "   Memory: ${used} / ${total} (${percent}% used, ${available} available)"

    if [ "$percent" -gt 90 ]; then
      echo -e "   ${RED}⚠️  High memory usage${NC}"
      HEALTH_PASSED=false
    elif [ "$percent" -gt 80 ]; then
      echo -e "   ${YELLOW}⚠️  Elevated memory usage${NC}"
    fi
  fi

  # Disk space
  local disk_usage=$(df -h "$ROOT_DIR" | awk 'NR==2 {print $5}' | tr -d '%')
  local disk_available=$(df -h "$ROOT_DIR" | awk 'NR==2 {print $4}')

  echo "   Disk: ${disk_usage}% used (${disk_available} available)"

  if [ "$disk_usage" -gt 90 ]; then
    echo -e "   ${RED}⚠️  Low disk space${NC}"
    HEALTH_PASSED=false
  elif [ "$disk_usage" -gt 80 ]; then
    echo -e "   ${YELLOW}⚠️  Disk space running low${NC}"
  fi
  echo ""
}

# Main health check
main() {
  cd "$ROOT_DIR"

  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}SSW Clients - Health Check${NC}"
  echo -e "${BLUE}========================================${NC}"
  echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
  echo ""

  # Check if services are supposed to be running
  echo "🔍 Service Status:"
  echo ""

  # Web Client
  echo "🌐 Web Client:"
  if [ -f ".pids/web.pid" ]; then
    WEB_PID=$(cat .pids/web.pid)
    check_process_health "$WEB_PID" "Web Process"
    echo ""
    check_port "$WEB_PORT" "Web"
    echo ""
    check_http_endpoint "http://localhost:$WEB_PORT" "Web Endpoint" "$HEALTH_TIMEOUT"
  else
    echo -e "   ⚠️  ${YELLOW}Not started${NC} (no PID file)"
    echo "      Start with: ./tooling/scripts/start-web.sh"
  fi
  echo ""

  # Mobile Client
  echo "📱 Mobile Client:"
  if [ -f ".pids/mobile.pid" ]; then
    MOBILE_PID=$(cat .pids/mobile.pid)
    check_process_health "$MOBILE_PID" "Mobile Process"
    echo ""
    check_port "$MOBILE_PORT" "Mobile Metro"
  else
    echo -e "   ⚠️  ${YELLOW}Not started${NC} (no PID file)"
    echo "      Start with: ./tooling/scripts/start-mobile.sh"
  fi
  echo ""

  # Backend API
  echo "🔌 Backend API:"
  check_http_endpoint "http://localhost:$BACKEND_PORT/health" "Backend Health Endpoint" "$HEALTH_TIMEOUT" || true
  echo ""

  # Logs
  echo "📋 Log Files:"
  echo ""
  if [ -f "logs/web.log" ]; then
    check_log_health "logs/web.log" "Web"
    echo ""
  fi

  if [ -f "logs/mobile.log" ]; then
    check_log_health "logs/mobile.log" "Mobile"
    echo ""
  fi

  # Dependencies
  check_dependencies_health

  # System resources
  check_system_resources

  # Summary
  echo -e "${BLUE}========================================${NC}"
  if $HEALTH_PASSED; then
    echo -e "${GREEN}✅ All health checks PASSED${NC}"
    echo ""
    echo "System is healthy and operational."
    exit 0
  else
    echo -e "${RED}❌ Some health checks FAILED${NC}"
    echo ""
    echo "Review the issues above and take corrective action."
    echo ""
    echo "Common fixes:"
    echo "  - Restart services: ./tooling/scripts/restart.sh"
    echo "  - Check logs: tail -f logs/{web,mobile}.log"
    echo "  - Validate environment: ./tooling/scripts/validate-env.sh"
    exit 1
  fi
}

# Run main function
main "$@"
