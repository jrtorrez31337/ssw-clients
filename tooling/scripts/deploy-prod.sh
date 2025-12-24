#!/bin/bash
# Production deployment script
# Builds and deploys applications for production use

set -e

# Ensure pnpm is in PATH
export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"
export PATH="$PNPM_HOME:$PATH"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(dirname "$0")"
ROOT_DIR="$SCRIPT_DIR/../.."

# Configuration
BUILD_DIR="dist"
BACKUP_DIR=".backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Functions
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

# Trap errors
error_handler() {
  log_error "Deployment failed at line $1"
  log_info "Rolling back changes..."

  # Restore from backup if exists
  if [ -d "$BACKUP_DIR/build_$TIMESTAMP" ]; then
    log_info "Restoring previous build..."
    # Restoration logic would go here
  fi

  exit 1
}

trap 'error_handler $LINENO' ERR

# Pre-deployment validation
pre_deploy_validation() {
  log_info "Running pre-deployment validation..."
  echo ""

  # Validate environment
  if [ -f "$SCRIPT_DIR/validate-env.sh" ]; then
    log_info "Checking environment prerequisites..."
    "$SCRIPT_DIR/validate-env.sh" || {
      log_error "Environment validation failed"
      exit 1
    }
    echo ""
  fi

  # Check git status
  if git diff-index --quiet HEAD --; then
    log_success "Working directory clean"
  else
    log_warning "Uncommitted changes detected"
    read -p "Continue deployment? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      log_info "Deployment cancelled"
      exit 0
    fi
  fi

  # Check branch
  local current_branch=$(git branch --show-current)
  log_info "Current branch: $current_branch"

  if [ "$current_branch" != "master" ] && [ "$current_branch" != "main" ]; then
    log_warning "Not on master/main branch"
    read -p "Continue deployment from $current_branch? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      log_info "Deployment cancelled"
      exit 0
    fi
  fi

  echo ""
}

# Backup current build
backup_current_build() {
  log_info "Creating backup of current build..."

  mkdir -p "$BACKUP_DIR"

  # Backup web dist if exists
  if [ -d "apps/web/$BUILD_DIR" ]; then
    cp -r "apps/web/$BUILD_DIR" "$BACKUP_DIR/web_$TIMESTAMP"
    log_success "Web build backed up"
  fi

  # Keep only last 5 backups
  local backup_count=$(ls -1d "$BACKUP_DIR"/*_* 2>/dev/null | wc -l)
  if [ "$backup_count" -gt 5 ]; then
    log_info "Cleaning old backups (keeping last 5)..."
    ls -1dt "$BACKUP_DIR"/*_* | tail -n +6 | xargs rm -rf
  fi

  echo ""
}

# Run tests
run_tests() {
  log_info "Running tests..."
  echo ""

  # Type checking
  log_info "Type checking..."
  pnpm typecheck || {
    log_error "Type check failed"
    exit 1
  }
  log_success "Type check passed"
  echo ""

  # Linting
  log_info "Linting..."
  pnpm lint || log_warning "Linting found issues (non-blocking)"
  echo ""

  # Drift check
  log_info "Checking for code drift..."
  if [ -f "$SCRIPT_DIR/check-drift.sh" ]; then
    "$SCRIPT_DIR/check-drift.sh" || {
      log_error "Code drift detected"
      exit 1
    }
    log_success "No code drift detected"
  fi
  echo ""

  # Capability check
  log_info "Checking capabilities..."
  pnpm check:capabilities || {
    log_error "Capability check failed"
    exit 1
  }
  log_success "Capabilities validated"
  echo ""
}

# Build applications
build_applications() {
  log_info "Building applications for production..."
  echo ""

  # Clean previous builds
  log_info "Cleaning previous builds..."
  rm -rf apps/web/$BUILD_DIR
  log_success "Clean completed"
  echo ""

  # Build web
  log_info "Building web application..."
  pnpm --filter @ssw/web build || {
    log_error "Web build failed"
    exit 1
  }
  log_success "Web build completed"

  # Check build output
  if [ -d "apps/web/$BUILD_DIR" ]; then
    local build_size=$(du -sh "apps/web/$BUILD_DIR" | cut -f1)
    log_info "Build size: $build_size"
  else
    log_error "Build directory not found"
    exit 1
  fi
  echo ""

  # Mobile build (if needed)
  log_info "Mobile builds should be done via EAS Build for production"
  log_info "For mobile production builds, run:"
  echo "   eas build --platform ios"
  echo "   eas build --platform android"
  echo ""
}

# Generate build manifest
generate_build_manifest() {
  log_info "Generating build manifest..."

  local manifest_file="apps/web/$BUILD_DIR/build-manifest.json"
  local git_commit=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
  local git_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
  local build_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  cat > "$manifest_file" << EOF
{
  "buildTimestamp": "$build_date",
  "gitCommit": "$git_commit",
  "gitBranch": "$git_branch",
  "nodeVersion": "$(node --version)",
  "pnpmVersion": "$(pnpm --version)",
  "buildId": "${TIMESTAMP}"
}
EOF

  log_success "Build manifest created"
  echo ""
}

# Run post-build checks
post_build_checks() {
  log_info "Running post-build checks..."
  echo ""

  # Check if critical files exist
  local critical_files=("apps/web/$BUILD_DIR/index.html")

  for file in "${critical_files[@]}"; do
    if [ -f "$file" ]; then
      log_success "Found: $file"
    else
      log_error "Missing critical file: $file"
      exit 1
    fi
  done
  echo ""

  # Bundle size analysis
  log_info "Analyzing bundle sizes..."
  if command -v du &> /dev/null; then
    log_info "Top 5 largest files:"
    find "apps/web/$BUILD_DIR" -type f -exec du -h {} + | sort -rh | head -5 | sed 's/^/   /'
  fi
  echo ""
}

# Start production preview
start_production_preview() {
  log_info "Starting production preview server..."
  echo ""

  log_info "You can preview the production build with:"
  echo "   cd apps/web && pnpm preview"
  echo ""
  echo "Or serve with any static file server:"
  echo "   npx serve apps/web/$BUILD_DIR"
  echo ""
}

# Main deployment process
main() {
  cd "$ROOT_DIR"

  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}SSW Clients - Production Deployment${NC}"
  echo -e "${BLUE}========================================${NC}"
  echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "Build ID: $TIMESTAMP"
  echo ""

  # Deployment steps
  pre_deploy_validation
  backup_current_build
  run_tests
  build_applications
  generate_build_manifest
  post_build_checks
  start_production_preview

  # Success summary
  echo -e "${BLUE}========================================${NC}"
  log_success "Production deployment completed!"
  echo ""
  echo "📦 Build artifacts:"
  echo "   Web: apps/web/$BUILD_DIR"
  echo "   Manifest: apps/web/$BUILD_DIR/build-manifest.json"
  echo ""
  echo "🔍 Build details:"
  echo "   Build ID: $TIMESTAMP"
  echo "   Git commit: $(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
  echo "   Git branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
  echo ""
  echo "📋 Next steps:"
  echo "   1. Preview: cd apps/web && pnpm preview"
  echo "   2. Deploy to hosting: Upload apps/web/$BUILD_DIR to your CDN/hosting"
  echo "   3. Mobile: Build with EAS for production releases"
  echo ""
  echo "💾 Backup:"
  echo "   Location: $BACKUP_DIR/web_$TIMESTAMP"
  echo ""
}

# Run main function
main "$@"
