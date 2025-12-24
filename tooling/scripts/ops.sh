#!/bin/bash
# Main operations CLI wrapper
# Unified interface for all operational scripts

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(dirname "$0")"
ROOT_DIR="$SCRIPT_DIR/../.."

VERSION="1.0.0"

# Display banner
show_banner() {
  echo -e "${CYAN}"
  cat << "EOF"
   _____ _______          __   ____
  / ___// ___/ |     /| / /  / __ \____  _____
  \__ \ \__ \| | /| / / /  / / / / __ \/ ___/
 ___/ /___/ /| |/ |/ / /  / /_/ / /_/ (__  )
/____/_____/ |__/|__/_/   \____/ .___/____/
                              /_/
         Operations CLI v${VERSION}
EOF
  echo -e "${NC}"
}

# Show help
show_help() {
  show_banner
  echo -e "${BOLD}USAGE${NC}"
  echo "  ops <command> [options]"
  echo ""
  echo -e "${BOLD}SERVICE MANAGEMENT${NC}"
  echo "  ${GREEN}start [--web|--mobile]${NC}    Start services"
  echo "  ${GREEN}stop [--web|--mobile]${NC}     Stop services"
  echo "  ${GREEN}restart [options]${NC}         Restart services"
  echo "  ${GREEN}status${NC}                    Show service status"
  echo ""
  echo -e "${BOLD}MONITORING & HEALTH${NC}"
  echo "  ${CYAN}health${NC}                    Run health checks"
  echo "  ${CYAN}monitor [mode]${NC}            Monitor resources"
  echo "  ${CYAN}alerts${NC}                    Check for alerts"
  echo ""
  echo -e "${BOLD}LOGS${NC}"
  echo "  ${YELLOW}logs status${NC}              Show log status"
  echo "  ${YELLOW}logs view <log>${NC}          View log file"
  echo "  ${YELLOW}logs follow <log>${NC}        Follow log in real-time"
  echo "  ${YELLOW}logs rotate${NC}              Rotate log files"
  echo "  ${YELLOW}logs clean${NC}               Clean old archives"
  echo "  ${YELLOW}logs search <pattern>${NC}    Search logs"
  echo ""
  echo -e "${BOLD}DEPLOYMENT${NC}"
  echo "  ${BLUE}deploy${NC}                    Deploy to production"
  echo "  ${BLUE}validate${NC}                  Validate environment"
  echo ""
  echo -e "${BOLD}BACKUP & RESTORE${NC}"
  echo "  ${BOLD}backup create [name]${NC}      Create backup"
  echo "  ${BOLD}backup list${NC}               List backups"
  echo "  ${BOLD}backup restore <name>${NC}     Restore backup"
  echo ""
  echo -e "${BOLD}UTILITIES${NC}"
  echo "  ${NC}version${NC}                   Show version"
  echo "  ${NC}help${NC}                      Show this help"
  echo ""
  echo -e "${BOLD}EXAMPLES${NC}"
  echo "  ops start                  # Start all services"
  echo "  ops health                 # Run health check"
  echo "  ops logs follow web        # Follow web logs"
  echo "  ops monitor snapshot       # Take resource snapshot"
  echo "  ops backup create          # Create backup"
  echo "  ops deploy                 # Deploy to production"
  echo ""
  echo -e "${BOLD}QUICK REFERENCE${NC}"
  echo "  Development:    ops start"
  echo "  Check status:   ops status && ops health"
  echo "  View logs:      ops logs follow web"
  echo "  Troubleshoot:   ops health && ops alerts"
  echo "  Before deploy:  ops validate && ops backup create"
  echo "  Deploy:         ops deploy"
  echo ""
}

# Command router
route_command() {
  local cmd=$1
  shift

  case $cmd in
    # Service management
    start)
      if [ "$1" == "--web" ]; then
        "$SCRIPT_DIR/start-web.sh"
      elif [ "$1" == "--mobile" ]; then
        "$SCRIPT_DIR/start-mobile.sh"
      else
        "$SCRIPT_DIR/start-all.sh"
      fi
      ;;

    stop)
      if [ "$1" == "--web" ]; then
        "$SCRIPT_DIR/stop-web.sh"
      elif [ "$1" == "--mobile" ]; then
        "$SCRIPT_DIR/stop-mobile.sh"
      else
        "$SCRIPT_DIR/stop-all.sh"
      fi
      ;;

    restart)
      "$SCRIPT_DIR/restart.sh" "$@"
      ;;

    status)
      "$SCRIPT_DIR/status.sh"
      ;;

    # Health & monitoring
    health)
      "$SCRIPT_DIR/health-check.sh"
      ;;

    monitor)
      "$SCRIPT_DIR/monitor.sh" "$@"
      ;;

    alerts)
      "$SCRIPT_DIR/monitor.sh" alerts
      ;;

    # Logs
    logs)
      local subcmd=${1:-status}
      shift || true
      "$SCRIPT_DIR/manage-logs.sh" "$subcmd" "$@"
      ;;

    # Deployment
    deploy)
      "$SCRIPT_DIR/deploy-prod.sh"
      ;;

    validate)
      "$SCRIPT_DIR/validate-env.sh"
      ;;

    # Backup
    backup)
      local subcmd=${1:-help}
      shift || true
      "$SCRIPT_DIR/backup.sh" "$subcmd" "$@"
      ;;

    # Utilities
    version)
      show_banner
      echo "Version: $VERSION"
      echo "Location: $SCRIPT_DIR"
      echo ""
      ;;

    help|--help|-h)
      show_help
      ;;

    # Quick commands
    up)
      echo -e "${GREEN}🚀 Starting SSW Clients${NC}"
      "$SCRIPT_DIR/start-all.sh"
      ;;

    down)
      echo -e "${YELLOW}🛑 Stopping SSW Clients${NC}"
      "$SCRIPT_DIR/stop-all.sh"
      ;;

    check)
      echo -e "${CYAN}🔍 Running comprehensive check${NC}"
      echo ""
      "$SCRIPT_DIR/validate-env.sh" || true
      echo ""
      "$SCRIPT_DIR/health-check.sh" || true
      echo ""
      "$SCRIPT_DIR/monitor.sh" alerts || true
      ;;

    *)
      echo -e "${RED}❌ Unknown command: $cmd${NC}"
      echo ""
      echo "Run 'ops help' for usage information"
      exit 1
      ;;
  esac
}

# Interactive mode
interactive_mode() {
  show_banner
  echo -e "${BOLD}Interactive Mode${NC}"
  echo "Type 'help' for commands, 'exit' to quit"
  echo ""

  while true; do
    echo -ne "${CYAN}ops>${NC} "
    read -r input

    # Trim whitespace
    input=$(echo "$input" | xargs)

    # Skip empty input
    [ -z "$input" ] && continue

    # Exit commands
    if [ "$input" == "exit" ] || [ "$input" == "quit" ] || [ "$input" == "q" ]; then
      echo "Goodbye!"
      break
    fi

    # Clear screen
    if [ "$input" == "clear" ] || [ "$input" == "cls" ]; then
      clear
      show_banner
      continue
    fi

    # Execute command
    route_command $input || true
    echo ""
  done
}

# Main
main() {
  cd "$ROOT_DIR"

  # No arguments - show help
  if [ $# -eq 0 ]; then
    show_help
    exit 0
  fi

  # Interactive mode
  if [ "$1" == "interactive" ] || [ "$1" == "-i" ]; then
    interactive_mode
    exit 0
  fi

  # Route command
  route_command "$@"
}

main "$@"
