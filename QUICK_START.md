# Quick Start Guide

Get the SSW Clients monorepo up and running in 3 steps!

## Prerequisites

- Node.js 18+ ([Install with nvm](https://github.com/nvm-sh/nvm))
- pnpm 8+ (will be used via npx if not globally installed)

## 🚀 Three Steps to Launch

### 1. Install Dependencies
```bash
pnpm install
```

### 2. Start Both Apps
```bash
pnpm start
```

This will start:
- **Web** on http://localhost:3000
- **Mobile** on http://localhost:3030 (Metro bundler)

### 3. Open Your Browser
- Web: Visit http://localhost:3000
- Mobile: Open Expo Go app and scan QR code from terminal

## 📊 Check Status

```bash
pnpm status
```

Output shows:
- Which services are running
- Process IDs (PIDs)
- Recent log entries

## 🛑 Stop Everything

```bash
pnpm stop
```

## 🔧 Advanced Usage

### Start Individual Services

**Web only:**
```bash
pnpm start:web
```

**Mobile only:**
```bash
pnpm start:mobile
```

### View Logs

**Live tail:**
```bash
# Web logs
tail -f logs/web.log

# Mobile logs
tail -f logs/mobile.log

# Both at once
tail -f logs/*.log
```

**All logs:**
```bash
cat logs/web.log
cat logs/mobile.log
```

### Stop Individual Services

```bash
pnpm stop:web      # Stop web only
pnpm stop:mobile   # Stop mobile only
```

## 🏗️ Development Workflow

### Typical Development Day

1. **Morning startup:**
   ```bash
   pnpm start
   pnpm status  # Verify both running
   ```

2. **During development:**
   - Edit files in `apps/web/` or `apps/mobile/`
   - Hot reload happens automatically
   - Check logs if issues: `tail -f logs/*.log`

3. **End of day:**
   ```bash
   pnpm stop
   ```

### Making Changes to Shared Packages

When editing `packages/*`:

1. Changes auto-reload in apps (thanks to workspace linking)
2. Run type checks: `pnpm typecheck`
3. Check for drift: `pnpm check:drift`

## 📱 Mobile Development

### Testing on Physical Device

1. Install **Expo Go** app:
   - [iOS App Store](https://apps.apple.com/app/expo-go/id982107779)
   - [Google Play Store](https://play.google.com/store/apps/details?id=host.exp.exponent)

2. Start mobile: `pnpm start:mobile`

3. Scan QR code from terminal with Expo Go

### Testing in Simulator/Emulator

**iOS (requires macOS + Xcode):**
```bash
pnpm mobile:ios
```

**Android (requires Android Studio):**
```bash
pnpm mobile:android
```

### Testing in Browser

```bash
pnpm mobile:start-web
```

Opens at http://localhost:3030 (or next available port)

## 🐛 Troubleshooting

### Port Already in Use

**Web (port 3000):**
```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9

# Or use stop script (handles cleanup)
pnpm stop:web
```

**Mobile (port 3030):**
```bash
# Kill process on port 3030
lsof -ti:3030 | xargs kill -9

# Or use stop script
pnpm stop:mobile
```

### Services Won't Start

1. Check logs: `cat logs/web.log` or `cat logs/mobile.log`
2. Verify dependencies: `pnpm install`
3. Check ports: `lsof -i :3000` and `lsof -i :3030`
4. Clean restart:
   ```bash
   pnpm stop
   pnpm clean
   pnpm install
   pnpm start
   ```

### Stale Processes

```bash
# Nuclear option - kill all node processes
pkill -9 node

# Then restart
pnpm start
```

### Mobile App Not Updating

1. Stop Metro: `pnpm stop:mobile`
2. Clear Metro cache: `rm -rf apps/mobile/.expo`
3. Restart: `pnpm start:mobile`

## 📚 More Information

- **Full README**: [README.md](README.md)
- **Migration Details**: [MIGRATION_COMPLETE.md](MIGRATION_COMPLETE.md)
- **Original Setup**: [BASELINE_RUNBOOK.md](BASELINE_RUNBOOK.md)
- **API Docs**: [packages/api/README.md](packages/api/README.md)

## 🎯 Common Commands Reference

| Command | Description |
|---------|-------------|
| `pnpm start` | Start web + mobile |
| `pnpm stop` | Stop all services |
| `pnpm status` | Check service status |
| `pnpm start:web` | Start web only (port 3000) |
| `pnpm start:mobile` | Start mobile only (port 3030) |
| `pnpm typecheck` | Type check all packages |
| `pnpm lint` | Lint all packages |
| `pnpm ci` | Run all quality checks |
| `tail -f logs/web.log` | Watch web logs |
| `tail -f logs/mobile.log` | Watch mobile logs |

---

**Need help?** Check the logs in `logs/` directory or run `pnpm status` to diagnose issues.
