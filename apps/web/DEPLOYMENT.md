# SSW Galaxy MMO - Deployment Guide for Linux

This guide provides step-by-step instructions for deploying the SSW Galaxy MMO web client on a Linux development environment.

## 📋 Prerequisites

### System Requirements
- **OS**: Ubuntu 20.04+, Debian 10+, CentOS 8+, or similar
- **RAM**: Minimum 2GB, recommended 4GB+
- **Disk**: 2GB free space
- **Network**: Internet access for package installation

### Required Software
- **Node.js**: v18.0.0 or higher
- **npm**: v9.0.0 or higher (comes with Node.js)
- **Git**: For cloning repository
- **Bash**: Standard Linux shell

### Optional Software
- **PM2**: Installed automatically by init script
- **curl**: For health checks (usually pre-installed)

---

## 🚀 Quick Start (3 Commands)

```bash
# 1. Clone repository
git clone https://github.com/jrtorrez31337/ssw-fe-genspark.git
cd ssw-fe-genspark

# 2. Initialize environment
./scripts/init-env.sh

# 3. Start application
./scripts/start.sh
```

**That's it!** Your application will be running at http://localhost:3000

---

## 📖 Detailed Deployment Steps

### Step 1: Install Node.js (if not installed)

#### Ubuntu/Debian:
```bash
# Install Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version
npm --version
```

#### CentOS/RHEL:
```bash
# Install Node.js 18.x
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Verify installation
node --version
npm --version
```

#### Alternative: Using nvm (Node Version Manager)
```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Reload shell
source ~/.bashrc

# Install Node.js
nvm install 18
nvm use 18

# Verify
node --version
```

---

### Step 2: Clone Repository

```bash
# Clone the repository
git clone https://github.com/jrtorrez31337/ssw-fe-genspark.git

# Navigate to project directory
cd ssw-fe-genspark

# Verify files
ls -la
```

Expected files:
- `src/` - Source code
- `public/` - Static assets
- `scripts/` - Management scripts
- `package.json` - Dependencies
- `README.md` - Documentation

---

### Step 3: Initialize Environment

```bash
# Run initialization script
./scripts/init-env.sh
```

**What this does:**
1. ✅ Checks Node.js and npm versions
2. ✅ Installs PM2 globally
3. ✅ Installs project dependencies (may take 2-3 minutes)
4. ✅ Creates `.env` configuration file
5. ✅ Verifies backend API availability
6. ✅ Sets up logs directory
7. ✅ Checks Git configuration

**Expected output:**
```
==================================
SSW Galaxy MMO - Environment Setup
==================================

[SUCCESS] ✓ Node.js v18.x.x
[SUCCESS] ✓ npm v9.x.x
[SUCCESS] ✓ PM2 installed
[SUCCESS] ✓ Dependencies installed
[SUCCESS] ✓ Environment configured

Next steps:
  1. Start the backend API on port 8080
  2. Run: ./scripts/start.sh
  3. Access: http://localhost:3000
```

---

### Step 4: Configure Environment (Optional)

Edit `.env` file to customize configuration:

```bash
nano .env
```

**Default configuration:**
```bash
# Backend API URL
VITE_API_URL=http://localhost:8080/v1

# Backend host
BACKEND_API_HOST=localhost
BACKEND_API_PORT=8080

# Development server
DEV_SERVER_PORT=3000
DEV_SERVER_HOST=0.0.0.0

# Environment
NODE_ENV=development
```

**Common customizations:**
- Change `DEV_SERVER_PORT` if port 3000 is in use
- Change `BACKEND_API_HOST` if backend is on different machine
- Change `BACKEND_API_PORT` if backend uses different port

---

### Step 5: Start Backend API

**IMPORTANT**: The frontend requires the backend API to function.

```bash
# Navigate to backend directory
cd /path/to/ssw-backend

# Start backend services
# (Refer to backend documentation for specific commands)
./start-services.sh
```

**Verify backend is running:**
```bash
curl http://localhost:8080/health
# Should return: {"status":"healthy"}
```

---

### Step 6: Start Frontend Application

```bash
# Navigate to frontend directory
cd /path/to/ssw-fe-genspark

# Start application
./scripts/start.sh
```

**Expected output:**
```
==================================
SSW Galaxy MMO - Start Application
==================================

[SUCCESS] ✓ Dependencies verified
[SUCCESS] ✓ Backend API is running
[SUCCESS] ✓ Port 3000 is available
[SUCCESS] ✓ Application started successfully
[SUCCESS] ✓ Application is ready!

==================================
Application Started Successfully!
==================================

Access URLs:
  Local:    http://localhost:3000
  Network:  http://192.168.1.100:3000
```

---

### Step 7: Verify Deployment

```bash
# Check application status
./scripts/status.sh

# View logs
./scripts/logs.sh

# Run health check
./scripts/health-check.sh
```

**Test in browser:**
1. Open http://localhost:3000
2. You should see the login page
3. Try signing up with test credentials
4. Verify character creation works

---

## 🔧 Post-Deployment Configuration

### Configure Firewall (if needed)

#### Ubuntu/Debian (ufw):
```bash
# Allow port 3000
sudo ufw allow 3000/tcp

# Reload firewall
sudo ufw reload
```

#### CentOS/RHEL (firewalld):
```bash
# Allow port 3000
sudo firewall-cmd --permanent --add-port=3000/tcp

# Reload firewall
sudo firewall-cmd --reload
```

---

### Enable PM2 Startup on Boot

```bash
# Generate startup script
pm2 startup

# Follow the instructions provided
# Usually requires running a command with sudo

# Save current PM2 processes
pm2 save
```

Now the application will automatically start after system reboot.

---

### Set Up Log Rotation

```bash
# Install PM2 log rotation module
pm2 install pm2-logrotate

# Configure (optional)
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7
```

---

## 🎯 Common Deployment Scenarios

### Scenario 1: Fresh Server Deployment

```bash
# 1. Update system
sudo apt update && sudo apt upgrade -y

# 2. Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs git

# 3. Clone and setup
git clone https://github.com/jrtorrez31337/ssw-fe-genspark.git
cd ssw-fe-genspark
./scripts/init-env.sh

# 4. Start application
./scripts/start.sh

# 5. Enable auto-start
pm2 startup
pm2 save
```

---

### Scenario 2: Update Existing Deployment

```bash
# 1. Stop application
./scripts/stop.sh

# 2. Pull latest changes
git pull origin main

# 3. Update dependencies
npm install

# 4. Restart application
./scripts/start.sh
```

---

### Scenario 3: Deploy on Different Port

```bash
# 1. Edit .env
nano .env
# Change: DEV_SERVER_PORT=3001

# 2. Update vite.config.ts
nano vite.config.ts
# Change port in server config

# 3. Restart
./scripts/restart.sh --hard
```

---

### Scenario 4: Deploy Behind Reverse Proxy

#### Nginx Configuration:
```nginx
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# Enable configuration
sudo ln -s /etc/nginx/sites-available/ssw-galaxy /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## 🛡️ Security Considerations

### 1. Don't Expose Directly to Internet
- Use reverse proxy (Nginx, Apache)
- Use firewall rules
- Use HTTPS/SSL certificates

### 2. Secure Environment Variables
```bash
# Set restrictive permissions
chmod 600 .env

# Don't commit .env to git
# (already in .gitignore)
```

### 3. Regular Updates
```bash
# Update dependencies regularly
npm audit
npm audit fix
npm update
```

### 4. Monitor Logs
```bash
# Check for suspicious activity
./scripts/logs.sh --error

# Set up log monitoring
./scripts/health-check.sh
```

---

## 📊 Monitoring & Maintenance

### Daily Checks
```bash
# Quick status check
./scripts/status.sh

# Health check
./scripts/health-check.sh
```

### Weekly Maintenance
```bash
# Review logs
./scripts/logs.sh --lines 500

# Update dependencies
npm update

# Restart application
./scripts/restart.sh
```

### Monthly Tasks
```bash
# Full system update
sudo apt update && sudo apt upgrade -y

# Clear old logs
pm2 flush

# Check disk space
df -h

# Check memory
free -h
```

---

## 🆘 Troubleshooting

### Issue: Port 3000 Already in Use

**Solution:**
```bash
# Force stop
./scripts/stop.sh --force

# Or kill manually
fuser -k 3000/tcp

# Start again
./scripts/start.sh
```

---

### Issue: Backend Not Responding

**Check:**
```bash
curl http://localhost:8080/health
```

**Solution:**
```bash
# Start backend first
cd /path/to/backend
./start-backend.sh

# Then start frontend
cd /path/to/frontend
./scripts/start.sh
```

---

### Issue: Application Won't Start

**Diagnose:**
```bash
# Check logs
./scripts/logs.sh --error

# Run health check
./scripts/health-check.sh

# Check dependencies
ls node_modules/ | wc -l  # Should be ~260+
```

**Solution:**
```bash
# Reinstall dependencies
rm -rf node_modules
npm install

# Restart
./scripts/start.sh --force
```

---

### Issue: Out of Memory

**Check:**
```bash
free -h
```

**Solution:**
```bash
# Increase swap space
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

---

## 📚 Additional Resources

- **Scripts Documentation**: `scripts/README.md`
- **Quick Reference**: `./scripts/quick-ref.sh`
- **Testing Guide**: `TESTING.md`
- **Project README**: `README.md`
- **GitHub Repository**: https://github.com/jrtorrez31337/ssw-fe-genspark

---

## ✅ Deployment Checklist

- [ ] Node.js 18+ installed
- [ ] Repository cloned
- [ ] Environment initialized (`./scripts/init-env.sh`)
- [ ] Backend API running on port 8080
- [ ] Frontend started (`./scripts/start.sh`)
- [ ] Application accessible at http://localhost:3000
- [ ] Health check passing (`./scripts/health-check.sh`)
- [ ] PM2 startup configured (optional)
- [ ] Firewall configured (if needed)
- [ ] Logs rotating properly (optional)
- [ ] Monitoring set up (optional)

---

**Deployment Version**: 1.0  
**Last Updated**: 2025-12-23  
**Supported Platforms**: Ubuntu 20.04+, Debian 10+, CentOS 8+
