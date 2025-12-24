#!/bin/bash
# Backup and restore utilities script
# Manages backups of configurations, builds, and important data

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
BACKUP_ROOT="$ROOT_DIR/.backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
MAX_BACKUPS=10

# Parse command
COMMAND=${1:-help}
BACKUP_NAME=${2:-}

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

# Create full backup
create_backup() {
  local backup_name=${1:-"full_${TIMESTAMP}"}
  local backup_dir="$BACKUP_ROOT/$backup_name"

  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}Creating Backup${NC}"
  echo -e "${BLUE}========================================${NC}"
  echo "Backup name: $backup_name"
  echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
  echo ""

  cd "$ROOT_DIR"

  # Create backup directory
  mkdir -p "$backup_dir"

  log_info "Backing up configuration files..."
  mkdir -p "$backup_dir/config"

  # Backup package files
  [ -f "package.json" ] && cp "package.json" "$backup_dir/config/"
  [ -f "pnpm-lock.yaml" ] && cp "pnpm-lock.yaml" "$backup_dir/config/"
  [ -f "pnpm-workspace.yaml" ] && cp "pnpm-workspace.yaml" "$backup_dir/config/"
  [ -f "tsconfig.json" ] && cp "tsconfig.json" "$backup_dir/config/"
  [ -f "tsconfig.base.json" ] && cp "tsconfig.base.json" "$backup_dir/config/"

  # Backup app configs
  [ -f "apps/web/package.json" ] && mkdir -p "$backup_dir/config/web" && cp "apps/web/package.json" "$backup_dir/config/web/"
  [ -f "apps/web/vite.config.ts" ] && cp "apps/web/vite.config.ts" "$backup_dir/config/web/"
  [ -f "apps/web/tsconfig.json" ] && cp "apps/web/tsconfig.json" "$backup_dir/config/web/"

  [ -f "apps/mobile/package.json" ] && mkdir -p "$backup_dir/config/mobile" && cp "apps/mobile/package.json" "$backup_dir/config/mobile/"
  [ -f "apps/mobile/app.json" ] && cp "apps/mobile/app.json" "$backup_dir/config/mobile/"
  [ -f "apps/mobile/tsconfig.json" ] && cp "apps/mobile/tsconfig.json" "$backup_dir/config/mobile/"

  log_success "Configuration files backed up"
  echo ""

  log_info "Backing up environment files..."
  mkdir -p "$backup_dir/env"
  find . -maxdepth 3 -name ".env*" -not -path "*/node_modules/*" -exec cp --parents {} "$backup_dir/env/" \; 2>/dev/null || true
  log_success "Environment files backed up"
  echo ""

  log_info "Backing up build artifacts..."
  mkdir -p "$backup_dir/builds"
  if [ -d "apps/web/dist" ]; then
    cp -r "apps/web/dist" "$backup_dir/builds/web-dist"
    log_success "Web build artifacts backed up"
  else
    log_info "No web build artifacts to backup"
  fi
  echo ""

  log_info "Backing up logs..."
  mkdir -p "$backup_dir/logs"
  if [ -d "logs" ] && [ "$(ls -A logs/*.log 2>/dev/null)" ]; then
    cp logs/*.log "$backup_dir/logs/" 2>/dev/null || true
    log_success "Logs backed up"
  else
    log_info "No logs to backup"
  fi
  echo ""

  log_info "Backing up PIDs..."
  mkdir -p "$backup_dir/pids"
  if [ -d ".pids" ] && [ "$(ls -A .pids/*.pid 2>/dev/null)" ]; then
    cp .pids/*.pid "$backup_dir/pids/" 2>/dev/null || true
    log_success "PID files backed up"
  else
    log_info "No PID files to backup"
  fi
  echo ""

  # Create manifest
  log_info "Creating backup manifest..."
  cat > "$backup_dir/MANIFEST.txt" << EOF
Backup Manifest
===============

Backup Name: $backup_name
Created: $(date '+%Y-%m-%d %H:%M:%S')
Git Commit: $(git rev-parse HEAD 2>/dev/null || echo "N/A")
Git Branch: $(git branch --show-current 2>/dev/null || echo "N/A")
Node Version: $(node --version)
pnpm Version: $(pnpm --version)

Contents:
---------
$(find "$backup_dir" -type f | sed "s|$backup_dir/||" | sort)

Sizes:
------
$(du -sh "$backup_dir"/* | sed 's/^/  /')

Total Size: $(du -sh "$backup_dir" | cut -f1)
EOF

  log_success "Manifest created"
  echo ""

  # Compress backup
  log_info "Compressing backup..."
  cd "$BACKUP_ROOT"
  tar -czf "${backup_name}.tar.gz" "$backup_name" 2>/dev/null || {
    log_warning "Compression failed or not available, keeping uncompressed"
  }

  if [ -f "${backup_name}.tar.gz" ]; then
    local compressed_size=$(du -sh "${backup_name}.tar.gz" | cut -f1)
    log_success "Backup compressed: ${compressed_size}"
    rm -rf "$backup_name"
  fi

  cd "$ROOT_DIR"
  echo ""

  # Cleanup old backups
  cleanup_old_backups

  log_success "Backup completed successfully"
  echo ""
  echo "Backup location: $BACKUP_ROOT/${backup_name}.tar.gz"
}

# List backups
list_backups() {
  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}Available Backups${NC}"
  echo -e "${BLUE}========================================${NC}"
  echo ""

  cd "$ROOT_DIR"

  if [ ! -d "$BACKUP_ROOT" ] || [ -z "$(ls -A "$BACKUP_ROOT" 2>/dev/null)" ]; then
    log_info "No backups found"
    return
  fi

  echo "📦 Backup Archives:"
  echo ""

  # List compressed backups
  find "$BACKUP_ROOT" -name "*.tar.gz" -type f -printf "%T@ %p\n" 2>/dev/null | sort -rn | while read timestamp filepath; do
    local filename=$(basename "$filepath")
    local size=$(du -sh "$filepath" | cut -f1)
    local date=$(date -d "@${timestamp%.*}" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date -r "${timestamp%.*}" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
    echo "  📦 $filename"
    echo "     Size: $size"
    echo "     Date: $date"
    echo ""
  done

  # List uncompressed backups
  find "$BACKUP_ROOT" -maxdepth 1 -type d ! -path "$BACKUP_ROOT" 2>/dev/null | while read dirpath; do
    local dirname=$(basename "$dirpath")
    local size=$(du -sh "$dirpath" | cut -f1)
    echo "  📂 $dirname (uncompressed)"
    echo "     Size: $size"
    echo ""
  done

  local total_size=$(du -sh "$BACKUP_ROOT" | cut -f1)
  echo "Total backup size: $total_size"
}

# Restore backup
restore_backup() {
  local backup_name=$1

  if [ -z "$backup_name" ]; then
    log_error "Backup name required"
    echo "Usage: $0 restore <backup_name>"
    list_backups
    return 1
  fi

  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}Restoring Backup${NC}"
  echo -e "${BLUE}========================================${NC}"
  echo "Backup: $backup_name"
  echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
  echo ""

  cd "$ROOT_DIR"

  local backup_file="$BACKUP_ROOT/${backup_name}.tar.gz"
  local backup_dir="$BACKUP_ROOT/$backup_name"

  # Check if backup exists
  if [ ! -f "$backup_file" ] && [ ! -d "$backup_dir" ]; then
    log_error "Backup not found: $backup_name"
    echo ""
    list_backups
    return 1
  fi

  # Warning
  log_warning "This will restore configuration files and may overwrite current files!"
  read -p "Continue with restore? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Restore cancelled"
    return 0
  fi
  echo ""

  # Extract if compressed
  if [ -f "$backup_file" ]; then
    log_info "Extracting backup archive..."
    cd "$BACKUP_ROOT"
    tar -xzf "${backup_name}.tar.gz"
    cd "$ROOT_DIR"
    log_success "Archive extracted"
    echo ""
  fi

  # Restore configuration files
  if [ -d "$backup_dir/config" ]; then
    log_info "Restoring configuration files..."

    # Root configs
    [ -f "$backup_dir/config/package.json" ] && cp "$backup_dir/config/package.json" .
    [ -f "$backup_dir/config/pnpm-lock.yaml" ] && cp "$backup_dir/config/pnpm-lock.yaml" .
    [ -f "$backup_dir/config/pnpm-workspace.yaml" ] && cp "$backup_dir/config/pnpm-workspace.yaml" .
    [ -f "$backup_dir/config/tsconfig.json" ] && cp "$backup_dir/config/tsconfig.json" .
    [ -f "$backup_dir/config/tsconfig.base.json" ] && cp "$backup_dir/config/tsconfig.base.json" .

    # Web configs
    if [ -d "$backup_dir/config/web" ]; then
      [ -f "$backup_dir/config/web/package.json" ] && cp "$backup_dir/config/web/package.json" "apps/web/"
      [ -f "$backup_dir/config/web/vite.config.ts" ] && cp "$backup_dir/config/web/vite.config.ts" "apps/web/"
      [ -f "$backup_dir/config/web/tsconfig.json" ] && cp "$backup_dir/config/web/tsconfig.json" "apps/web/"
    fi

    # Mobile configs
    if [ -d "$backup_dir/config/mobile" ]; then
      [ -f "$backup_dir/config/mobile/package.json" ] && cp "$backup_dir/config/mobile/package.json" "apps/mobile/"
      [ -f "$backup_dir/config/mobile/app.json" ] && cp "$backup_dir/config/mobile/app.json" "apps/mobile/"
      [ -f "$backup_dir/config/mobile/tsconfig.json" ] && cp "$backup_dir/config/mobile/tsconfig.json" "apps/mobile/"
    fi

    log_success "Configuration files restored"
    echo ""
  fi

  # Restore environment files
  if [ -d "$backup_dir/env" ]; then
    log_info "Restoring environment files..."
    cp -r "$backup_dir/env/." . 2>/dev/null || true
    log_success "Environment files restored"
    echo ""
  fi

  # Restore builds (optional)
  if [ -d "$backup_dir/builds" ]; then
    log_warning "Build artifacts found in backup"
    read -p "Restore build artifacts? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      log_info "Restoring build artifacts..."
      [ -d "$backup_dir/builds/web-dist" ] && cp -r "$backup_dir/builds/web-dist" "apps/web/dist"
      log_success "Build artifacts restored"
    fi
    echo ""
  fi

  log_success "Restore completed successfully"
  echo ""
  log_info "Next steps:"
  echo "  1. Run: pnpm install (to sync dependencies)"
  echo "  2. Verify configuration files"
  echo "  3. Restart services: ./tooling/scripts/restart.sh"
}

# Delete backup
delete_backup() {
  local backup_name=$1

  if [ -z "$backup_name" ]; then
    log_error "Backup name required"
    echo "Usage: $0 delete <backup_name>"
    list_backups
    return 1
  fi

  local backup_file="$BACKUP_ROOT/${backup_name}.tar.gz"
  local backup_dir="$BACKUP_ROOT/$backup_name"

  if [ ! -f "$backup_file" ] && [ ! -d "$backup_dir" ]; then
    log_error "Backup not found: $backup_name"
    return 1
  fi

  log_warning "This will permanently delete the backup: $backup_name"
  read -p "Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Delete cancelled"
    return 0
  fi

  [ -f "$backup_file" ] && rm -f "$backup_file" && log_success "Deleted: ${backup_name}.tar.gz"
  [ -d "$backup_dir" ] && rm -rf "$backup_dir" && log_success "Deleted: $backup_name"
}

# Cleanup old backups
cleanup_old_backups() {
  local backup_count=$(find "$BACKUP_ROOT" -maxdepth 1 \( -name "*.tar.gz" -o -type d ! -path "$BACKUP_ROOT" \) 2>/dev/null | wc -l)

  if [ "$backup_count" -gt "$MAX_BACKUPS" ]; then
    log_info "Cleaning up old backups (keeping last $MAX_BACKUPS)..."

    # Remove oldest backups
    find "$BACKUP_ROOT" -maxdepth 1 -name "*.tar.gz" -type f -printf "%T@ %p\n" 2>/dev/null | \
      sort -n | head -n -$MAX_BACKUPS | cut -d' ' -f2 | while read filepath; do
      local filename=$(basename "$filepath")
      log_info "Removing old backup: $filename"
      rm -f "$filepath"
    done
  fi
}

# Main
main() {
  case $COMMAND in
    create)
      create_backup "$BACKUP_NAME"
      ;;
    list)
      list_backups
      ;;
    restore)
      restore_backup "$BACKUP_NAME"
      ;;
    delete)
      delete_backup "$BACKUP_NAME"
      ;;
    cleanup)
      cleanup_old_backups
      log_success "Cleanup completed"
      ;;
    help|--help|-h)
      echo "Backup and Restore Utilities for SSW Clients"
      echo ""
      echo "Usage: $0 <command> [backup_name]"
      echo ""
      echo "Commands:"
      echo "  create [name]         Create a new backup"
      echo "  list                  List all available backups"
      echo "  restore <name>        Restore from a backup"
      echo "  delete <name>         Delete a backup"
      echo "  cleanup               Remove old backups (keep last $MAX_BACKUPS)"
      echo "  help                  Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0 create                    # Create backup with auto name"
      echo "  $0 create before_deploy      # Create named backup"
      echo "  $0 list                      # List all backups"
      echo "  $0 restore full_20240101     # Restore specific backup"
      echo "  $0 delete old_backup         # Delete specific backup"
      echo "  $0 cleanup                   # Clean old backups"
      echo ""
      echo "What gets backed up:"
      echo "  - Configuration files (package.json, tsconfig, etc.)"
      echo "  - Environment files (.env*)"
      echo "  - Build artifacts (dist/)"
      echo "  - Logs"
      echo "  - PID files"
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
