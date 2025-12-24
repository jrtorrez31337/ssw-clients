# SSW Clients - Operations Scripts

Production-grade operational scripts for managing the SSW Clients monorepo.

## Table of Contents

- [Quick Start](#quick-start)
- [Operations CLI](#operations-cli)
- [Scripts Overview](#scripts-overview)
- [Service Management](#service-management)
- [Health & Monitoring](#health--monitoring)
- [Log Management](#log-management)
- [Deployment](#deployment)
- [Backup & Restore](#backup--restore)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Quick Start

### Using the Ops CLI (Recommended)

The `ops.sh` script provides a unified interface for all operations:

```bash
# From project root
./tooling/scripts/ops.sh help

# Or create an alias for convenience
alias ops='./tooling/scripts/ops.sh'
ops help
```

### Common Operations

```bash
# Start services
ops start              # Start all services
ops start --web        # Start only web
ops start --mobile     # Start only mobile

# Check status
ops status             # Service status
ops health             # Health check
ops check              # Comprehensive check (env + health + alerts)

# View logs
ops logs follow web    # Follow web logs
ops logs view mobile   # View mobile logs

# Restart
ops restart            # Restart all gracefully
ops restart --web      # Restart only web

# Monitor
ops monitor snapshot   # Resource snapshot
ops alerts             # Check alerts

# Deploy
ops validate           # Validate environment
ops backup create      # Create backup
ops deploy             # Deploy to production
```

## Operations CLI

The `ops.sh` script is the main entry point for all operational tasks.

### Commands

#### Service Management
- `ops start [--web|--mobile]` - Start services
- `ops stop [--web|--mobile]` - Stop services
- `ops restart [options]` - Gracefully restart services
- `ops status` - Show current service status

#### Health & Monitoring
- `ops health` - Run comprehensive health checks
- `ops monitor [mode]` - Monitor system resources
- `ops alerts` - Check for resource alerts

#### Logs
- `ops logs status` - Show log file status
- `ops logs view <log> [filter] [lines]` - View log file
- `ops logs follow <log>` - Follow log in real-time
- `ops logs rotate` - Rotate large log files
- `ops logs clean` - Clean old archived logs
- `ops logs search <pattern>` - Search all logs

#### Deployment
- `ops validate` - Validate environment prerequisites
- `ops deploy` - Build and deploy for production

#### Backup & Restore
- `ops backup create [name]` - Create a backup
- `ops backup list` - List all backups
- `ops backup restore <name>` - Restore from backup

#### Utilities
- `ops version` - Show version information
- `ops help` - Show help message
- `ops interactive` - Enter interactive mode

## Scripts Overview

### Complete Script List

```
tooling/scripts/
├── ops.sh               # Main CLI wrapper ⭐
├── start-all.sh         # Start all services
├── start-web.sh         # Start web only
├── start-mobile.sh      # Start mobile only
├── stop-all.sh          # Stop all services
├── stop-web.sh          # Stop web only
├── stop-mobile.sh       # Stop mobile only
├── restart.sh           # Graceful restart ⭐
├── status.sh            # Service status
├── validate-env.sh      # Environment validation ⭐
├── health-check.sh      # Health monitoring ⭐
├── monitor.sh           # Resource monitoring ⭐
├── manage-logs.sh       # Log management ⭐
├── deploy-prod.sh       # Production deployment ⭐
├── backup.sh            # Backup/restore ⭐
├── check-drift.sh       # Code drift detection
└── README.md            # This file
```

⭐ = New production-grade scripts

### Service Management Scripts

#### `start-all.sh`, `start-web.sh`, `start-mobile.sh`

Start services in development mode.

```bash
# All services
./tooling/scripts/start-all.sh
pnpm start
ops start

# Individual services
ops start --web
ops start --mobile
```

**Features:**
- Auto-kills existing processes
- PID tracking
- Health verification
- Log streaming

#### `stop-all.sh`, `stop-web.sh`, `stop-mobile.sh`

Stop running services.

```bash
ops stop
ops stop --web
ops stop --mobile
```

#### `restart.sh` ⭐

Graceful restart with zero-downtime support.

```bash
ops restart              # Graceful restart
ops restart --web        # Web only
ops restart --force      # Force immediate restart
```

#### `status.sh`

Show comprehensive service status.

```bash
ops status
```

### Health & Monitoring Scripts ⭐

#### `validate-env.sh`

Validates all prerequisites before deployment.

```bash
ops validate
```

**Validates:**
- Node.js >= 18
- pnpm >= 8
- System resources
- Port availability
- Dependencies
- Backend connectivity

#### `health-check.sh`

Comprehensive health monitoring.

```bash
ops health
```

**Monitors:**
- Process health
- HTTP endpoints
- Log health
- System resources
- Network connections

#### `monitor.sh`

Resource monitoring and alerting.

```bash
ops monitor snapshot      # Single snapshot
ops monitor continuous    # Continuous CSV output
ops monitor top           # Top processes
ops alerts                # Check alert thresholds
```

### Log Management Scripts ⭐

#### `manage-logs.sh`

Complete log lifecycle management.

```bash
ops logs status           # Log status
ops logs view web         # View logs
ops logs follow mobile    # Follow logs
ops logs rotate           # Rotate large logs
ops logs clean            # Clean archives
ops logs search "error"   # Search all logs
```

**Features:**
- 100MB rotation threshold
- Gzip compression
- 30-day retention
- Full-text search

### Deployment Scripts ⭐

#### `deploy-prod.sh`

Production build and deployment pipeline.

```bash
ops deploy
```

**Pipeline:**
1. Environment validation
2. Backup creation
3. Testing (typecheck, lint, drift, capabilities)
4. Production build
5. Build manifest generation
6. Post-build validation

### Backup & Restore Scripts ⭐

#### `backup.sh`

Configuration and artifact backup/restore.

```bash
ops backup create [name]
ops backup list
ops backup restore <name>
ops backup delete <name>
```

**Backs up:**
- Configuration files
- Environment variables
- Build artifacts
- Logs
- PID files

## Service Management

### Starting Services

```bash
# Development mode
ops start                 # All services
pnpm start

# Individual services
ops start --web
ops start --mobile
```

**Ports:**
- Web: http://localhost:3000
- Mobile: http://localhost:3030

### Stopping Services

```bash
ops stop                  # All
ops stop --web            # Web only
ops stop --mobile         # Mobile only
```

### Restarting Services

```bash
ops restart               # Graceful restart
ops restart --web         # Web only
ops restart --force       # Force restart
```

### Checking Status

```bash
ops status                # Quick status
ops health                # Detailed health
ops check                 # Full validation
```

## Health & Monitoring

### Environment Validation

```bash
ops validate
```

Validates Node.js, pnpm, dependencies, disk space, memory, ports.

### Health Checks

```bash
ops health
```

Monitors processes, endpoints, logs, resources.

### Resource Monitoring

```bash
ops monitor snapshot      # Current state
ops monitor continuous    # Time-series data
ops monitor top           # Top processes
ops alerts                # Alert check
```

**Thresholds:**
- CPU: 80%
- Memory: 80%
- Disk: 85%

## Log Management

### Viewing Logs

```bash
ops logs follow web       # Real-time
ops logs view web 100     # Last 100 lines
ops logs view web error   # Filter by keyword
```

### Log Rotation

```bash
ops logs status           # Check sizes
ops logs rotate           # Rotate if > 100MB
ops logs rotate --force   # Force rotation
```

### Searching Logs

```bash
ops logs search "authentication failed"
```

Searches active logs and compressed archives.

### Cleanup

```bash
ops logs clean            # Remove old archives
```

## Deployment

### Pre-deployment Checklist

1. `ops validate` - Environment check
2. `ops health` - Services check
3. `ops backup create` - Create backup
4. `git status` - Verify git state

### Production Deployment

```bash
ops deploy
```

**Process:**
- ✅ Validation & testing
- ✅ Production build
- ✅ Artifact generation
- ✅ Build manifest

**Output:**
- `apps/web/dist/` - Web build
- `apps/web/dist/build-manifest.json` - Build info

### Post-deployment

```bash
# Preview
cd apps/web && pnpm preview

# Mobile builds (use EAS)
cd apps/mobile
eas build --platform ios
eas build --platform android
```

## Backup & Restore

### Creating Backups

```bash
ops backup create                    # Auto-named
ops backup create before_deploy      # Named
```

### Listing & Restoring

```bash
ops backup list
ops backup restore full_20240101_120000
```

### Cleanup

```bash
ops backup delete old_backup
ops backup cleanup               # Keep last 10
```

## Best Practices

### Daily Operations

**Start of day:**
```bash
ops validate
ops start
ops health
```

**During development:**
```bash
ops logs follow web
ops monitor snapshot
```

**End of day:**
```bash
ops stop
ops logs rotate
```

### Weekly Maintenance

**Monday:**
```bash
ops validate
ops health
ops backup create
```

**Friday:**
```bash
ops logs clean
ops backup cleanup
```

### Before Deployment

```bash
ops validate
ops health
ops backup create
ops deploy
```

## Troubleshooting

### Port Already in Use

```bash
lsof -i :3000
kill -9 <PID>
# Or
ops restart --force
```

### Services Won't Start

```bash
ops validate
ops logs view web
rm -rf .pids/*
pnpm install
ops start
```

### High Memory Usage

```bash
ops monitor snapshot
ops monitor top
ops restart
```

### Deployment Fails

```bash
ops validate
git status
pnpm install
df -h
ops deploy
```

## Legacy NPM Script Mapping

| NPM Command | New Ops Command |
|-------------|-----------------|
| `pnpm start` | `ops start` |
| `pnpm stop` | `ops stop` |
| `pnpm status` | `ops status` |
| `pnpm start:web` | `ops start --web` |
| `pnpm check:drift` | `ops deploy` (includes drift check) |

## Generated Files & Directories

```
.pids/              # Process IDs
├── web.pid
└── mobile.pid

logs/               # Service logs
├── web.log
├── mobile.log
└── archive/        # Compressed archives

.backups/           # Configuration backups
└── *.tar.gz

apps/web/dist/      # Production builds
```

## Getting Help

```bash
ops help                          # Main help
ops <command> help                # Command-specific help
./tooling/scripts/<script>.sh --help
```

## License

MIT License - See repository root for details.
