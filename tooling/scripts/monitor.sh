#!/bin/bash
# Resource monitoring and alerting script
# Monitors CPU, memory, disk, and process metrics

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(dirname "$0")"
ROOT_DIR="$SCRIPT_DIR/../.."

# Configuration
MONITOR_INTERVAL=5
MONITOR_DURATION=60
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=85

# Parse arguments
MODE=${1:-snapshot}
INTERVAL=${2:-$MONITOR_INTERVAL}
DURATION=${3:-$MONITOR_DURATION}

log_info() {
  echo -e "${BLUE}$1${NC}"
}

log_success() {
  echo -e "${GREEN}$1${NC}"
}

log_warning() {
  echo -e "${YELLOW}$1${NC}"
}

log_error() {
  echo -e "${RED}$1${NC}"
}

log_metric() {
  echo -e "${CYAN}$1${NC}"
}

# Get CPU usage
get_cpu_usage() {
  if command -v mpstat &> /dev/null; then
    mpstat 1 1 | awk '/Average/ {print 100-$NF}'
  elif [ -f /proc/stat ]; then
    local cpu_line=$(head -n 1 /proc/stat)
    echo "$cpu_line" | awk '{print ($2+$3+$4)*100/($2+$3+$4+$5)}'
  else
    local cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    echo "${cpu:-0}"
  fi
}

# Get memory usage
get_memory_usage() {
  if command -v free &> /dev/null; then
    free | awk 'NR==2 {printf "%.1f", $3/$2 * 100}'
  else
    echo "0"
  fi
}

# Get memory details
get_memory_details() {
  if command -v free &> /dev/null; then
    local total=$(free -h | awk 'NR==2 {print $2}')
    local used=$(free -h | awk 'NR==2 {print $3}')
    local available=$(free -h | awk 'NR==2 {print $7}')
    echo "${used}/${total} (${available} available)"
  else
    echo "N/A"
  fi
}

# Get disk usage
get_disk_usage() {
  df -h "$ROOT_DIR" | awk 'NR==2 {print $5}' | tr -d '%'
}

# Get disk details
get_disk_details() {
  df -h "$ROOT_DIR" | awk 'NR==2 {print $3"/"$2" ("$4" available)"}'
}

# Get load average
get_load_average() {
  if command -v uptime &> /dev/null; then
    uptime | awk -F'load average:' '{print $2}' | sed 's/^ //'
  else
    echo "N/A"
  fi
}

# Get process metrics
get_process_metrics() {
  local pid=$1
  local service_name=$2

  if [ -z "$pid" ] || ! ps -p "$pid" > /dev/null 2>&1; then
    echo -e "${service_name}: ${RED}Not running${NC}"
    return
  fi

  local cpu=$(ps -p "$pid" -o %cpu= | tr -d ' ')
  local mem=$(ps -p "$pid" -o %mem= | tr -d ' ')
  local rss=$(ps -p "$pid" -o rss= | tr -d ' ')
  local rss_mb=$((rss / 1024))
  local vsz=$(ps -p "$pid" -o vsz= | tr -d ' ')
  local vsz_mb=$((vsz / 1024))
  local threads=$(ps -p "$pid" -o nlwp= | tr -d ' ')

  echo -e "${service_name}:"
  echo "  PID: $pid"
  echo "  CPU: ${cpu}%"
  echo "  Memory: ${mem}% (RSS: ${rss_mb}MB, VSZ: ${vsz_mb}MB)"
  echo "  Threads: $threads"

  # Warnings
  local cpu_int=$(echo "$cpu" | cut -d. -f1)
  if [ -n "$cpu_int" ] && [ "$cpu_int" -gt "$CPU_THRESHOLD" ]; then
    echo -e "  ${YELLOW}⚠️  High CPU usage${NC}"
  fi

  local mem_int=$(echo "$mem" | cut -d. -f1)
  if [ -n "$mem_int" ] && [ "$mem_int" -gt "$MEM_THRESHOLD" ]; then
    echo -e "  ${YELLOW}⚠️  High memory usage${NC}"
  fi
}

# Snapshot monitoring
snapshot_monitor() {
  cd "$ROOT_DIR"

  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}Resource Monitor - Snapshot${NC}"
  echo -e "${BLUE}========================================${NC}"
  echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
  echo ""

  # System-wide metrics
  echo "🖥️  System Metrics:"
  echo ""

  local cpu_usage=$(get_cpu_usage)
  local cpu_int=$(echo "$cpu_usage" | cut -d. -f1)
  if [ -n "$cpu_int" ] && [ "$cpu_int" -gt "$CPU_THRESHOLD" ]; then
    log_metric "  CPU Usage: ${cpu_usage}% ${YELLOW}⚠️  HIGH${NC}"
  else
    log_metric "  CPU Usage: ${cpu_usage}%"
  fi

  local mem_usage=$(get_memory_usage)
  local mem_int=$(echo "$mem_usage" | cut -d. -f1)
  if [ -n "$mem_int" ] && [ "$mem_int" -gt "$MEM_THRESHOLD" ]; then
    log_metric "  Memory Usage: ${mem_usage}% ${YELLOW}⚠️  HIGH${NC}"
  else
    log_metric "  Memory Usage: ${mem_usage}%"
  fi
  log_metric "  Memory: $(get_memory_details)"

  local disk_usage=$(get_disk_usage)
  if [ "$disk_usage" -gt "$DISK_THRESHOLD" ]; then
    log_metric "  Disk Usage: ${disk_usage}% ${YELLOW}⚠️  HIGH${NC}"
  else
    log_metric "  Disk Usage: ${disk_usage}%"
  fi
  log_metric "  Disk: $(get_disk_details)"

  log_metric "  Load Average: $(get_load_average)"
  echo ""

  # Process-specific metrics
  echo "📊 Process Metrics:"
  echo ""

  if [ -f ".pids/web.pid" ]; then
    WEB_PID=$(cat .pids/web.pid)
    get_process_metrics "$WEB_PID" "Web Client"
    echo ""
  else
    log_warning "  Web Client: Not started"
    echo ""
  fi

  if [ -f ".pids/mobile.pid" ]; then
    MOBILE_PID=$(cat .pids/mobile.pid)
    get_process_metrics "$MOBILE_PID" "Mobile Client"
    echo ""
  else
    log_warning "  Mobile Client: Not started"
    echo ""
  fi

  # Network connections
  echo "🌐 Network Connections:"
  echo ""
  echo "  Port 3000 (Web):"
  if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    local conn_count=$(netstat -an 2>/dev/null | grep ":3000" | grep ESTABLISHED | wc -l || echo "N/A")
    log_metric "    Status: Listening"
    log_metric "    Connections: $conn_count"
  else
    log_warning "    Status: Not listening"
  fi
  echo ""

  echo "  Port 3030 (Mobile):"
  if lsof -Pi :3030 -sTCP:LISTEN -t >/dev/null 2>&1; then
    local conn_count=$(netstat -an 2>/dev/null | grep ":3030" | grep ESTABLISHED | wc -l || echo "N/A")
    log_metric "    Status: Listening"
    log_metric "    Connections: $conn_count"
  else
    log_warning "    Status: Not listening"
  fi
  echo ""
}

# Continuous monitoring
continuous_monitor() {
  cd "$ROOT_DIR"

  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}Resource Monitor - Continuous${NC}"
  echo -e "${BLUE}========================================${NC}"
  echo "Interval: ${INTERVAL}s"
  echo "Duration: ${DURATION}s"
  echo "Press Ctrl+C to stop"
  echo ""

  local iterations=$((DURATION / INTERVAL))
  local count=0

  # CSV header
  echo "timestamp,cpu_usage,mem_usage,disk_usage,web_cpu,web_mem,mobile_cpu,mobile_mem"

  while [ $count -lt $iterations ]; do
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local cpu_usage=$(get_cpu_usage)
    local mem_usage=$(get_memory_usage)
    local disk_usage=$(get_disk_usage)

    local web_cpu="0"
    local web_mem="0"
    if [ -f ".pids/web.pid" ]; then
      WEB_PID=$(cat .pids/web.pid)
      if ps -p "$WEB_PID" > /dev/null 2>&1; then
        web_cpu=$(ps -p "$WEB_PID" -o %cpu= | tr -d ' ')
        web_mem=$(ps -p "$WEB_PID" -o %mem= | tr -d ' ')
      fi
    fi

    local mobile_cpu="0"
    local mobile_mem="0"
    if [ -f ".pids/mobile.pid" ]; then
      MOBILE_PID=$(cat .pids/mobile.pid)
      if ps -p "$MOBILE_PID" > /dev/null 2>&1; then
        mobile_cpu=$(ps -p "$MOBILE_PID" -o %cpu= | tr -d ' ')
        mobile_mem=$(ps -p "$MOBILE_PID" -o %mem= | tr -d ' ')
      fi
    fi

    echo "$timestamp,$cpu_usage,$mem_usage,$disk_usage,$web_cpu,$web_mem,$mobile_cpu,$mobile_mem"

    sleep "$INTERVAL"
    count=$((count + 1))
  done

  echo ""
  log_success "Monitoring completed"
}

# Top processes
show_top_processes() {
  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}Top Processes by Resource Usage${NC}"
  echo -e "${BLUE}========================================${NC}"
  echo ""

  echo "🔥 Top 10 CPU consumers:"
  echo ""
  ps aux --sort=-%cpu | head -11 | awk 'NR==1 || NR>1 {printf "  %-8s %5s %5s %s\n", $2, $3"%", $4"%", $11}'
  echo ""

  echo "💾 Top 10 Memory consumers:"
  echo ""
  ps aux --sort=-%mem | head -11 | awk 'NR==1 || NR>1 {printf "  %-8s %5s %5s %s\n", $2, $3"%", $4"%", $11}'
  echo ""
}

# Alert check
check_alerts() {
  cd "$ROOT_DIR"

  local alerts=()

  # Check CPU
  local cpu_usage=$(get_cpu_usage)
  local cpu_int=$(echo "$cpu_usage" | cut -d. -f1)
  if [ -n "$cpu_int" ] && [ "$cpu_int" -gt "$CPU_THRESHOLD" ]; then
    alerts+=("HIGH CPU: ${cpu_usage}% (threshold: ${CPU_THRESHOLD}%)")
  fi

  # Check memory
  local mem_usage=$(get_memory_usage)
  local mem_int=$(echo "$mem_usage" | cut -d. -f1)
  if [ -n "$mem_int" ] && [ "$mem_int" -gt "$MEM_THRESHOLD" ]; then
    alerts+=("HIGH MEMORY: ${mem_usage}% (threshold: ${MEM_THRESHOLD}%)")
  fi

  # Check disk
  local disk_usage=$(get_disk_usage)
  if [ "$disk_usage" -gt "$DISK_THRESHOLD" ]; then
    alerts+=("HIGH DISK: ${disk_usage}% (threshold: ${DISK_THRESHOLD}%)")
  fi

  # Check processes
  if [ -f ".pids/web.pid" ]; then
    WEB_PID=$(cat .pids/web.pid)
    if ! ps -p "$WEB_PID" > /dev/null 2>&1; then
      alerts+=("PROCESS DOWN: Web client (PID: $WEB_PID)")
    fi
  fi

  if [ -f ".pids/mobile.pid" ]; then
    MOBILE_PID=$(cat .pids/mobile.pid)
    if ! ps -p "$MOBILE_PID" > /dev/null 2>&1; then
      alerts+=("PROCESS DOWN: Mobile client (PID: $MOBILE_PID)")
    fi
  fi

  # Display alerts
  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}Alert Status${NC}"
  echo -e "${BLUE}========================================${NC}"
  echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
  echo ""

  if [ ${#alerts[@]} -eq 0 ]; then
    log_success "✅ No alerts - All systems normal"
    return 0
  else
    log_error "⚠️  ${#alerts[@]} Alert(s) detected:"
    echo ""
    for alert in "${alerts[@]}"; do
      log_warning "  - $alert"
    done
    return 1
  fi
}

# Main
main() {
  case $MODE in
    snapshot)
      snapshot_monitor
      ;;
    continuous)
      continuous_monitor
      ;;
    top)
      show_top_processes
      ;;
    alerts)
      check_alerts
      ;;
    help|--help|-h)
      echo "Resource Monitoring Script for SSW Clients"
      echo ""
      echo "Usage: $0 <mode> [interval] [duration]"
      echo ""
      echo "Modes:"
      echo "  snapshot              Take a single snapshot of resource usage"
      echo "  continuous [int] [dur]  Continuous monitoring (CSV output)"
      echo "  top                   Show top processes by resource usage"
      echo "  alerts                Check for resource alerts"
      echo "  help                  Show this help message"
      echo ""
      echo "Parameters:"
      echo "  interval              Monitoring interval in seconds (default: 5)"
      echo "  duration              Total monitoring duration in seconds (default: 60)"
      echo ""
      echo "Examples:"
      echo "  $0 snapshot           # Single snapshot"
      echo "  $0 continuous         # Monitor for 60s at 5s intervals"
      echo "  $0 continuous 10 300  # Monitor for 300s at 10s intervals"
      echo "  $0 top                # Show top processes"
      echo "  $0 alerts             # Check for alerts"
      echo ""
      echo "Configuration:"
      echo "  CPU Threshold: ${CPU_THRESHOLD}%"
      echo "  Memory Threshold: ${MEM_THRESHOLD}%"
      echo "  Disk Threshold: ${DISK_THRESHOLD}%"
      echo ""
      ;;
    *)
      log_error "Unknown mode: $MODE"
      echo ""
      echo "Run '$0 help' for usage information"
      exit 1
      ;;
  esac
}

main "$@"
