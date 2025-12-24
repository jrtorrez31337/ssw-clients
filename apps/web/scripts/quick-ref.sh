#!/bin/bash

################################################################################
# SSW Galaxy MMO Web Client - Quick Reference
#
# Usage: ./scripts/quick-ref.sh
################################################################################

cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                    SSW GALAXY MMO - QUICK REFERENCE                          ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  🔧 SETUP & INITIALIZATION                                                   ║
║  ──────────────────────────────────────────────────────────────────────────  ║
║  ./scripts/init-env.sh              Initialize environment (first time)      ║
║                                                                              ║
║  ▶️  APPLICATION CONTROL                                                     ║
║  ──────────────────────────────────────────────────────────────────────────  ║
║  ./scripts/start.sh                 Start application                        ║
║  ./scripts/start.sh --force         Force start (kill existing)             ║
║  ./scripts/start.sh --build         Build then start                        ║
║                                                                              ║
║  ./scripts/stop.sh                  Stop application                         ║
║  ./scripts/stop.sh --force          Force stop                              ║
║                                                                              ║
║  ./scripts/restart.sh               Graceful restart                         ║
║  ./scripts/restart.sh --hard        Hard restart (stop + start)             ║
║  ./scripts/restart.sh --build       Build then restart                      ║
║                                                                              ║
║  📊 MONITORING & LOGS                                                        ║
║  ──────────────────────────────────────────────────────────────────────────  ║
║  ./scripts/status.sh                Show application status                  ║
║  ./scripts/logs.sh                  View last 50 log lines                   ║
║  ./scripts/logs.sh --follow         Follow logs in real-time                ║
║  ./scripts/logs.sh --lines 100      View last 100 lines                     ║
║  ./scripts/logs.sh --error          Show only errors                        ║
║  ./scripts/health-check.sh          Run comprehensive health check          ║
║                                                                              ║
║  🔗 QUICK URLS                                                               ║
║  ──────────────────────────────────────────────────────────────────────────  ║
║  Frontend:  http://localhost:3000                                           ║
║  Backend:   http://localhost:8080                                           ║
║  GitHub:    https://github.com/jrtorrez31337/ssw-fe-genspark               ║
║                                                                              ║
║  🚀 COMMON WORKFLOWS                                                         ║
║  ──────────────────────────────────────────────────────────────────────────  ║
║  First Time Setup:                                                          ║
║    git clone https://github.com/jrtorrez31337/ssw-fe-genspark.git          ║
║    cd ssw-fe-genspark                                                       ║
║    ./scripts/init-env.sh                                                    ║
║    ./scripts/start.sh                                                       ║
║                                                                              ║
║  Daily Development:                                                         ║
║    ./scripts/status.sh              # Check status                          ║
║    ./scripts/logs.sh --follow       # Watch logs                            ║
║    ./scripts/restart.sh             # Apply changes                         ║
║                                                                              ║
║  Troubleshooting:                                                           ║
║    ./scripts/health-check.sh        # Diagnose issues                       ║
║    ./scripts/logs.sh --error        # Check errors                          ║
║    ./scripts/stop.sh --force        # Force stop                            ║
║    ./scripts/start.sh --force       # Force start                           ║
║                                                                              ║
║  🛠️  PM2 COMMANDS                                                            ║
║  ──────────────────────────────────────────────────────────────────────────  ║
║  pm2 list                           List all processes                       ║
║  pm2 logs ssw-web-client            Stream logs                             ║
║  pm2 monit                          Monitor resources                        ║
║  pm2 restart ssw-web-client         Restart process                         ║
║  pm2 stop ssw-web-client            Stop process                            ║
║  pm2 delete ssw-web-client          Remove process                          ║
║                                                                              ║
║  📝 NPM COMMANDS                                                             ║
║  ──────────────────────────────────────────────────────────────────────────  ║
║  npm install                        Install dependencies                     ║
║  npm run dev                        Run dev server (without PM2)            ║
║  npm run build                      Build for production                     ║
║  npm run preview                    Preview production build                ║
║                                                                              ║
║  🔍 DEBUGGING                                                                ║
║  ──────────────────────────────────────────────────────────────────────────  ║
║  Check if port is in use:           lsof -i :3000                           ║
║  Kill process on port:              fuser -k 3000/tcp                       ║
║  Check backend health:              curl http://localhost:8080/health       ║
║  Check frontend health:             curl http://localhost:3000              ║
║                                                                              ║
║  📂 KEY FILES                                                                ║
║  ──────────────────────────────────────────────────────────────────────────  ║
║  .env                               Environment configuration                ║
║  ecosystem.config.cjs               PM2 configuration                        ║
║  vite.config.ts                     Vite configuration                       ║
║  package.json                       Dependencies and scripts                 ║
║  scripts/README.md                  Detailed script documentation           ║
║                                                                              ║
║  🆘 HELP                                                                     ║
║  ──────────────────────────────────────────────────────────────────────────  ║
║  Detailed docs:      cat scripts/README.md                                  ║
║  Project docs:       cat README.md                                          ║
║  Testing guide:      cat TESTING.md                                         ║
║  Quick reference:    ./scripts/quick-ref.sh (this file)                     ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
