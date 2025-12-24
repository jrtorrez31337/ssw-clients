# SSW Galaxy MMO Web Client - Management Scripts

This directory contains comprehensive management scripts for setting up, running, and maintaining the SSW Galaxy MMO web client.

## 📋 Available Scripts

### 🔧 Setup & Initialization

#### `init-env.sh`
Initializes the complete development environment.

**What it does:**
- Verifies Node.js and npm installation
- Installs PM2 globally
- Installs project dependencies
- Creates `.env` configuration file
- Checks backend API availability
- Verifies Git configuration
- Sets up logs directory

**Usage:**
```bash
./scripts/init-env.sh
```

**Requirements:**
- Node.js 18+ installed
- npm installed
- Internet connection for package installation

**First-time setup:**
```bash
# Clone the repository
git clone https://github.com/jrtorrez31337/ssw-fe-genspark.git
cd ssw-fe-genspark

# Run initialization
./scripts/init-env.sh
```

---

### ▶️ Application Control

#### `start.sh`
Starts the application using PM2 process manager.

**Usage:**
```bash
./scripts/start.sh [options]
```

**Options:**
- `--force` - Force restart if already running
- `--build` - Build before starting
- `--dev` - Start in development mode (default)

**Examples:**
```bash
# Normal start
./scripts/start.sh

# Force restart if running
./scripts/start.sh --force

# Build and start
./scripts/start.sh --build
```

**What it does:**
- Checks dependencies
- Verifies backend availability
- Cleans up port 3000
- Starts application with PM2
- Waits for application to be ready
- Displays status and URLs

---

#### `stop.sh`
Stops the application gracefully.

**Usage:**
```bash
./scripts/stop.sh [options]
```

**Options:**
- `--force` - Force kill if graceful stop fails

**Examples:**
```bash
# Normal stop
./scripts/stop.sh

# Force stop
./scripts/stop.sh --force
```

**What it does:**
- Stops PM2 process
- Removes from PM2 list
- Cleans up port 3000
- Verifies resources are freed

---

#### `restart.sh`
Restarts the application with minimal downtime.

**Usage:**
```bash
./scripts/restart.sh [options]
```

**Options:**
- `--hard` - Perform hard restart (stop then start)
- `--build` - Build before restarting

**Examples:**
```bash
# Graceful restart
./scripts/restart.sh

# Hard restart
./scripts/restart.sh --hard

# Build and restart
./scripts/restart.sh --build
```

---

### 📊 Monitoring & Logs

#### `status.sh`
Displays comprehensive application status.

**Usage:**
```bash
./scripts/status.sh
```

**Shows:**
- PM2 process status
- Port 3000 status
- Application health
- Backend API status
- System resources
- Recent logs

**Example output:**
```
PM2 Process Status:
✓ ssw-web-client is online

Port 3000 Status:
✓ Port 3000 is in use

Application Health:
✓ Application responding (0.123s)

Backend API Status:
✓ Backend API is responding
```

---

#### `logs.sh`
Views application logs with various options.

**Usage:**
```bash
./scripts/logs.sh [options]
```

**Options:**
- `--follow` or `-f` - Follow logs in real-time
- `--lines N` - Show last N lines (default: 50)
- `--error` or `-e` - Show only error logs

**Examples:**
```bash
# View last 50 lines
./scripts/logs.sh

# View last 100 lines
./scripts/logs.sh --lines 100

# Follow logs in real-time
./scripts/logs.sh --follow

# View only errors
./scripts/logs.sh --error

# Follow error logs
./scripts/logs.sh --follow --error
```

---

#### `health-check.sh`
Performs comprehensive health checks.

**Usage:**
```bash
./scripts/health-check.sh
```

**Checks:**
1. Node.js installation
2. npm installation
3. PM2 installation
4. Project dependencies
5. Application status
6. Port 3000 status
7. HTTP endpoint health
8. Backend API availability
9. Disk space
10. Memory availability

**Exit codes:**
- `0` - All checks passed (healthy)
- `1` - Critical failure
- `2` - Warnings present

**Example:**
```bash
./scripts/health-check.sh

# Use in monitoring scripts
if ./scripts/health-check.sh; then
    echo "System healthy"
else
    echo "System has issues"
fi
```

---

## 🚀 Quick Start Guide

### First Time Setup

```bash
# 1. Clone repository
git clone https://github.com/jrtorrez31337/ssw-fe-genspark.git
cd ssw-fe-genspark

# 2. Make scripts executable
chmod +x scripts/*.sh

# 3. Initialize environment
./scripts/init-env.sh

# 4. Start application
./scripts/start.sh
```

### Daily Development Workflow

```bash
# Check status
./scripts/status.sh

# View logs
./scripts/logs.sh

# Restart after code changes
./scripts/restart.sh

# Stop for the day
./scripts/stop.sh
```

### Troubleshooting

```bash
# Run health check
./scripts/health-check.sh

# View error logs
./scripts/logs.sh --error

# Force stop and restart
./scripts/stop.sh --force
./scripts/start.sh --force
```

---

## 📝 Common Scenarios

### Scenario 1: Fresh Installation

```bash
# After cloning repository
./scripts/init-env.sh      # Set up environment
./scripts/start.sh          # Start application
./scripts/status.sh         # Verify running
```

### Scenario 2: After Code Changes

```bash
./scripts/restart.sh        # Restart to apply changes
```

### Scenario 3: After Dependency Changes

```bash
npm install                 # Install new dependencies
./scripts/restart.sh --hard # Hard restart
```

### Scenario 4: Debugging Issues

```bash
./scripts/health-check.sh   # Check system health
./scripts/logs.sh --error   # View errors
./scripts/status.sh         # Check detailed status
```

### Scenario 5: Complete Rebuild

```bash
./scripts/stop.sh           # Stop application
npm run build               # Build fresh
./scripts/start.sh          # Start application
```

---

## 🔍 Script Dependencies

All scripts require:
- Bash shell
- Basic Unix utilities (lsof, fuser, curl, ps)

Optional but recommended:
- PM2 (installed by init-env.sh)

---

## 📂 Files Created by Scripts

The scripts create and manage these files/directories:

- `.env` - Environment configuration (created by init-env.sh)
- `logs/` - Application logs directory (created by init-env.sh)
- `~/.pm2/` - PM2 configuration and logs

---

## 🛡️ Safety Features

All scripts include:
- ✅ Error checking (`set -e`)
- ✅ Colored output for clarity
- ✅ Detailed logging
- ✅ Graceful error handling
- ✅ Port cleanup
- ✅ Process verification

---

## ⚙️ Environment Variables

Scripts use these environment variables (from `.env`):

```bash
VITE_API_URL=http://localhost:8080/v1
BACKEND_API_HOST=localhost
BACKEND_API_PORT=8080
DEV_SERVER_PORT=3000
DEV_SERVER_HOST=0.0.0.0
NODE_ENV=development
```

---

## 🔧 Customization

### Change Default Port

Edit `.env`:
```bash
DEV_SERVER_PORT=3001
```

Then restart:
```bash
./scripts/restart.sh --hard
```

### Change Backend URL

Edit `.env`:
```bash
VITE_API_URL=http://production-api.com/v1
```

### Add Custom Scripts

Place custom scripts in `scripts/custom/` directory.

---

## 📞 Troubleshooting

### Issue: "Permission denied"

**Solution:**
```bash
chmod +x scripts/*.sh
```

### Issue: "Port 3000 already in use"

**Solution:**
```bash
./scripts/stop.sh --force
./scripts/start.sh
```

### Issue: "PM2 not found"

**Solution:**
```bash
npm install -g pm2
# Or run init-env.sh again
./scripts/init-env.sh
```

### Issue: "Backend not responding"

**Solution:**
```bash
# Start backend first
cd /path/to/backend
./start-backend.sh

# Then start frontend
./scripts/start.sh
```

---

## 🎯 Best Practices

1. **Always run init-env.sh first** after cloning
2. **Use status.sh** to check before starting
3. **Use logs.sh --follow** during development
4. **Run health-check.sh** regularly
5. **Use restart.sh** instead of stop/start for code changes

---

## 📚 Additional Resources

- **Main README**: `../README.md`
- **Testing Guide**: `../TESTING.md`
- **Project Summary**: `../PROJECT_SUMMARY.md`
- **GitHub**: https://github.com/jrtorrez31337/ssw-fe-genspark

---

**Scripts Version**: 1.0  
**Last Updated**: 2025-12-23
