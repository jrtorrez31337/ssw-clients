#!/bin/bash
# Graceful restart script with zero-downtime support
# Performs health checks and graceful shutdown before restart

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(dirname "$0")"
ROOT_DIR="$SCRIPT_DIR/../.."

# Configuration
GRACEFUL_TIMEOUT=10
FORCE_TIMEOUT=30

# Parse arguments
TARGET="all"
FORCE_RESTART=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --web)
      TARGET="web"
      shift
      ;;
    --mobile)
      TARGET="mobile"
      shift
      ;;
    --force)
      FORCE_RESTART=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--web|--mobile] [--force]"
      exit 1
      ;;
  esac
done

log_info() {
  echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
  echo -e "${RED}❌ $1${NC}"
}

# Check if process is running
is_process_running() {
  local pid=$1
  if [ -z "$pid" ]; then
    return 1
  fi
  ps -p "$pid" > /dev/null 2>&1
  return $?
}

# Graceful shutdown
graceful_shutdown() {
  local pid=$1
  local service_name=$2
  local timeout=${3:-$GRACEFUL_TIMEOUT}

  if ! is_process_running "$pid"; then
    log_warning "$service_name not running (PID: $pid)"
    return 0
  fi

  log_info "Gracefully stopping $service_name (PID: $pid)..."

  # Send SIGTERM for graceful shutdown
  kill -TERM "$pid" 2>/dev/null || true

  # Wait for process to exit
  local waited=0
  while is_process_running "$pid" && [ $waited -lt $timeout ]; do
    sleep 1
    waited=$((waited + 1))
    if [ $((waited % 5)) -eq 0 ]; then
      log_info "Waiting for $service_name to stop... (${waited}s)"
    fi
  done

  if is_process_running "$pid"; then
    log_warning "$service_name did not stop gracefully, forcing..."
    kill -9 "$pid" 2>/dev/null || true
    sleep 1
  fi

  if is_process_running "$pid"; then
    log_error "Failed to stop $service_name"
    return 1
  else
    log_success "$service_name stopped"
    return 0
  fi
}

# Wait for service to be healthy
wait_for_healthy() {
  local url=$1
  local service_name=$2
  local timeout=${3:-30}

  log_info "Waiting for $service_name to be healthy..."

  local waited=0
  while [ $waited -lt $timeout ]; do
    if curl -s --connect-timeout 2 "$url" >/dev/null 2>&1; then
      log_success "$service_name is healthy"
      return 0
    fi
    sleep 2
    waited=$((waited + 2))
    if [ $((waited % 10)) -eq 0 ]; then
      log_info "Still waiting for $service_name... (${waited}s)"
    fi
  done

  log_warning "$service_name did not become healthy within ${timeout}s"
  return 1
}

# Restart web client
restart_web() {
  log_info "Restarting Web Client..."
  echo ""

  cd "$ROOT_DIR"

  # Check if running
  if [ -f ".pids/web.pid" ]; then
    WEB_PID=$(cat .pids/web.pid)

    if $FORCE_RESTART; then
      log_warning "Force restart requested"
      "$SCRIPT_DIR/stop-web.sh"
    else
      # Health check before restart
      if curl -s http://localhost:3000 >/dev/null 2>&1; then
        log_info "Current web instance is responding"

        # Ask for confirmation unless forced
        if ! $FORCE_RESTART; then
          read -p "Proceed with restart? (y/N): " -n 1 -r
          echo
          if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Restart cancelled"
            return 0
          fi
        fi
      fi

      # Graceful shutdown
      graceful_shutdown "$WEB_PID" "Web Client" "$GRACEFUL_TIMEOUT"
    fi
  else
    log_info "Web client not currently running"
  fi

  # Start web
  log_info "Starting web client..."
  "$SCRIPT_DIR/start-web.sh"
  echo ""

  # Verify startup
  wait_for_healthy "http://localhost:3000" "Web Client" 30
  echo ""

  log_success "Web client restart completed"
  echo ""
}

# Restart mobile client
restart_mobile() {
  log_info "Restarting Mobile Client..."
  echo ""

  cd "$ROOT_DIR"

  # Check if running
  if [ -f ".pids/mobile.pid" ]; then
    MOBILE_PID=$(cat .pids/mobile.pid)

    if $FORCE_RESTART; then
      log_warning "Force restart requested"
      "$SCRIPT_DIR/stop-mobile.sh"
    else
      # Graceful shutdown
      graceful_shutdown "$MOBILE_PID" "Mobile Client" "$GRACEFUL_TIMEOUT"
    fi
  else
    log_info "Mobile client not currently running"
  fi

  # Start mobile
  log_info "Starting mobile client..."
  "$SCRIPT_DIR/start-mobile.sh"
  echo ""

  log_success "Mobile client restart completed"
  echo ""
}

# Main restart process
main() {
  cd "$ROOT_DIR"

  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}SSW Clients - Graceful Restart${NC}"
  echo -e "${BLUE}========================================${NC}"
  echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "Target: $TARGET"
  if $FORCE_RESTART; then
    echo "Mode: FORCE"
  else
    echo "Mode: GRACEFUL"
  fi
  echo ""

  # Pre-restart health check
  if [ -f "$SCRIPT_DIR/health-check.sh" ] && ! $FORCE_RESTART; then
    log_info "Running pre-restart health check..."
    "$SCRIPT_DIR/health-check.sh" || log_warning "Health check failed, continuing anyway..."
    echo ""
  fi

  # Perform restart based on target
  case $TARGET in
    web)
      restart_web
      ;;
    mobile)
      restart_mobile
      ;;
    all)
      restart_web
      restart_mobile
      ;;
    *)
      log_error "Unknown target: $TARGET"
      exit 1
      ;;
  esac

  # Post-restart health check
  if [ -f "$SCRIPT_DIR/health-check.sh" ]; then
    log_info "Running post-restart health check..."
    "$SCRIPT_DIR/health-check.sh" || log_warning "Post-restart health check failed"
    echo ""
  fi

  # Summary
  echo -e "${BLUE}========================================${NC}"
  log_success "Restart completed successfully!"
  echo ""
  echo "📊 Current status:"
  "$SCRIPT_DIR/status.sh" 2>/dev/null || true
}

# Show usage if --help
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
  echo "Graceful Restart Script for SSW Clients"
  echo ""
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --web         Restart only web client"
  echo "  --mobile      Restart only mobile client"
  echo "  --force       Force immediate restart (skip graceful shutdown)"
  echo "  --help, -h    Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0                  # Restart both clients gracefully"
  echo "  $0 --web            # Restart only web client"
  echo "  $0 --force          # Force restart both clients"
  echo "  $0 --web --force    # Force restart web client only"
  echo ""
  exit 0
fi

# Run main function
main "$@"
