#!/bin/bash
# Log management and rotation script
# Handles log rotation, compression, archival, and cleanup

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
LOG_DIR="$ROOT_DIR/logs"
ARCHIVE_DIR="$ROOT_DIR/logs/archive"
MAX_LOG_SIZE_MB=100
MAX_ARCHIVE_AGE_DAYS=30
MAX_ARCHIVES=10

# Parse command
COMMAND=${1:-status}

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

# Show log status
show_log_status() {
  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}Log Management - Status${NC}"
  echo -e "${BLUE}========================================${NC}"
  echo ""

  if [ ! -d "$LOG_DIR" ]; then
    log_warning "Log directory does not exist: $LOG_DIR"
    return
  fi

  cd "$ROOT_DIR"

  # Current logs
  echo "📝 Active Logs:"
  echo ""

  for log_file in logs/*.log; do
    if [ -f "$log_file" ]; then
      local filename=$(basename "$log_file")
      local size=$(du -h "$log_file" | cut -f1)
      local size_mb=$(du -m "$log_file" | cut -f1)
      local line_count=$(wc -l < "$log_file")
      local last_modified=$(stat -c %y "$log_file" 2>/dev/null | cut -d. -f1 || stat -f "%Sm" "$log_file" 2>/dev/null)

      echo "  📄 $filename"
      echo "     Size: $size (${size_mb}MB)"
      echo "     Lines: $line_count"
      echo "     Modified: $last_modified"

      if [ "$size_mb" -gt "$MAX_LOG_SIZE_MB" ]; then
        echo -e "     ${YELLOW}⚠️  Exceeds size limit (${MAX_LOG_SIZE_MB}MB)${NC}"
      fi

      # Show last few lines
      echo "     Last 3 lines:"
      tail -3 "$log_file" | sed 's/^/        /'
      echo ""
    fi
  done

  # Archives
  if [ -d "$ARCHIVE_DIR" ]; then
    echo "📦 Archived Logs:"
    echo ""

    local archive_count=$(find "$ARCHIVE_DIR" -name "*.log.gz" 2>/dev/null | wc -l)
    local total_archive_size=$(du -sh "$ARCHIVE_DIR" 2>/dev/null | cut -f1 || echo "0")

    echo "  Count: $archive_count"
    echo "  Total size: $total_archive_size"
    echo ""

    if [ "$archive_count" -gt 0 ]; then
      echo "  Recent archives:"
      find "$ARCHIVE_DIR" -name "*.log.gz" -type f -printf "%T@ %p\n" 2>/dev/null | sort -rn | head -5 | while read timestamp filepath; do
        local filename=$(basename "$filepath")
        local size=$(du -h "$filepath" | cut -f1)
        local date=$(date -d "@${timestamp%.*}" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date -r "${timestamp%.*}" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
        echo "     - $filename ($size) - $date"
      done
    fi
    echo ""
  fi

  # Disk usage
  echo "💾 Disk Usage:"
  local log_disk_usage=$(du -sh "$LOG_DIR" 2>/dev/null | cut -f1 || echo "0")
  echo "  Log directory: $log_disk_usage"
  echo ""
}

# Rotate logs
rotate_logs() {
  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}Log Management - Rotation${NC}"
  echo -e "${BLUE}========================================${NC}"
  echo ""

  cd "$ROOT_DIR"

  if [ ! -d "$LOG_DIR" ]; then
    log_warning "Log directory does not exist: $LOG_DIR"
    return
  fi

  mkdir -p "$ARCHIVE_DIR"

  local timestamp=$(date +%Y%m%d_%H%M%S)
  local rotated_count=0

  for log_file in logs/*.log; do
    if [ -f "$log_file" ]; then
      local filename=$(basename "$log_file" .log)
      local size_mb=$(du -m "$log_file" | cut -f1)

      # Check if rotation is needed
      if [ "$size_mb" -gt "$MAX_LOG_SIZE_MB" ] || [ "${2:-}" == "--force" ]; then
        log_info "Rotating $log_file (${size_mb}MB)..."

        # Archive current log
        local archive_name="${filename}_${timestamp}.log"
        cp "$log_file" "$ARCHIVE_DIR/$archive_name"

        # Compress archive
        gzip "$ARCHIVE_DIR/$archive_name"
        log_success "Archived to $ARCHIVE_DIR/${archive_name}.gz"

        # Truncate original log
        > "$log_file"
        log_success "Truncated $log_file"

        rotated_count=$((rotated_count + 1))
        echo ""
      else
        log_info "$log_file is within size limit (${size_mb}MB/${MAX_LOG_SIZE_MB}MB)"
      fi
    fi
  done

  if [ $rotated_count -eq 0 ]; then
    log_info "No logs needed rotation"
  else
    log_success "Rotated $rotated_count log file(s)"
  fi
  echo ""
}

# Clean old archives
clean_archives() {
  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}Log Management - Cleanup${NC}"
  echo -e "${BLUE}========================================${NC}"
  echo ""

  cd "$ROOT_DIR"

  if [ ! -d "$ARCHIVE_DIR" ]; then
    log_info "No archive directory to clean"
    return
  fi

  # Remove archives older than MAX_ARCHIVE_AGE_DAYS
  log_info "Removing archives older than $MAX_ARCHIVE_AGE_DAYS days..."
  local old_archives=$(find "$ARCHIVE_DIR" -name "*.log.gz" -type f -mtime +$MAX_ARCHIVE_AGE_DAYS 2>/dev/null)

  if [ -n "$old_archives" ]; then
    echo "$old_archives" | while read archive; do
      local filename=$(basename "$archive")
      log_info "Removing old archive: $filename"
      rm -f "$archive"
    done
    log_success "Old archives removed"
  else
    log_info "No old archives to remove"
  fi
  echo ""

  # Keep only MAX_ARCHIVES most recent
  log_info "Keeping only $MAX_ARCHIVES most recent archives per log..."
  for log_pattern in web mobile; do
    local archive_count=$(find "$ARCHIVE_DIR" -name "${log_pattern}_*.log.gz" 2>/dev/null | wc -l)

    if [ "$archive_count" -gt "$MAX_ARCHIVES" ]; then
      local to_remove=$((archive_count - MAX_ARCHIVES))
      log_info "Removing $to_remove old ${log_pattern} archive(s)..."

      find "$ARCHIVE_DIR" -name "${log_pattern}_*.log.gz" -type f -printf "%T@ %p\n" 2>/dev/null | \
        sort -n | head -n $to_remove | cut -d' ' -f2 | while read archive; do
        local filename=$(basename "$archive")
        log_info "Removing: $filename"
        rm -f "$archive"
      done
    fi
  done
  log_success "Archive cleanup completed"
  echo ""
}

# View logs with filtering
view_logs() {
  local log_file=${2:-web}
  local filter=${3:-}
  local lines=${4:-50}

  cd "$ROOT_DIR"

  if [ ! -f "logs/${log_file}.log" ]; then
    log_error "Log file not found: logs/${log_file}.log"
    return 1
  fi

  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}Viewing: logs/${log_file}.log${NC}"
  echo -e "${BLUE}========================================${NC}"
  echo ""

  if [ -n "$filter" ]; then
    log_info "Filter: $filter"
    log_info "Lines: Last $lines matching entries"
    echo ""
    grep -i "$filter" "logs/${log_file}.log" | tail -n "$lines"
  else
    log_info "Lines: Last $lines"
    echo ""
    tail -n "$lines" "logs/${log_file}.log"
  fi
}

# Follow logs (like tail -f)
follow_logs() {
  local log_file=${2:-web}

  cd "$ROOT_DIR"

  if [ ! -f "logs/${log_file}.log" ]; then
    log_error "Log file not found: logs/${log_file}.log"
    return 1
  fi

  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}Following: logs/${log_file}.log${NC}"
  echo -e "${BLUE}Press Ctrl+C to stop${NC}"
  echo -e "${BLUE}========================================${NC}"
  echo ""

  tail -f "logs/${log_file}.log"
}

# Search across all logs
search_logs() {
  local pattern=${2:-}

  if [ -z "$pattern" ]; then
    log_error "Search pattern required"
    echo "Usage: $0 search <pattern>"
    return 1
  fi

  cd "$ROOT_DIR"

  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}Searching logs for: $pattern${NC}"
  echo -e "${BLUE}========================================${NC}"
  echo ""

  # Search active logs
  log_info "Searching active logs..."
  echo ""
  grep -r -i --color=always "$pattern" logs/*.log 2>/dev/null || log_info "No matches in active logs"
  echo ""

  # Search archives
  if [ -d "$ARCHIVE_DIR" ] && [ "$(find "$ARCHIVE_DIR" -name "*.log.gz" | wc -l)" -gt 0 ]; then
    log_info "Searching archived logs..."
    echo ""
    zgrep -r -i --color=always "$pattern" "$ARCHIVE_DIR"/*.log.gz 2>/dev/null || log_info "No matches in archives"
  fi
}

# Main
main() {
  case $COMMAND in
    status)
      show_log_status
      ;;
    rotate)
      rotate_logs "$@"
      ;;
    clean)
      clean_archives
      ;;
    view)
      view_logs "$@"
      ;;
    follow)
      follow_logs "$@"
      ;;
    search)
      search_logs "$@"
      ;;
    help|--help|-h)
      echo "Log Management Script for SSW Clients"
      echo ""
      echo "Usage: $0 <command> [options]"
      echo ""
      echo "Commands:"
      echo "  status                    Show current log status"
      echo "  rotate [--force]          Rotate logs (archives large logs)"
      echo "  clean                     Clean old archived logs"
      echo "  view <log> [filter] [n]   View last n lines of log (optionally filtered)"
      echo "  follow <log>              Follow log in real-time"
      echo "  search <pattern>          Search all logs for pattern"
      echo "  help                      Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0 status                 # Show log status"
      echo "  $0 rotate                 # Rotate logs if needed"
      echo "  $0 rotate --force         # Force rotate all logs"
      echo "  $0 clean                  # Clean old archives"
      echo "  $0 view web               # View last 50 lines of web log"
      echo "  $0 view web error 100     # View last 100 lines with 'error'"
      echo "  $0 follow mobile          # Follow mobile log"
      echo "  $0 search 'API error'     # Search all logs for 'API error'"
      echo ""
      ;;
    *)
      log_error "Unknown command: $COMMAND"
      echo ""
      echo "Run '$0 help' for usage information"
      exit 1
      ;;
  esac
}

main "$@"
