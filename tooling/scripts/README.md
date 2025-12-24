# SSW Clients - Tooling Scripts

Utility scripts for monorepo maintenance and development.

## Service Management Scripts

### `start-all.sh`
Start both web and mobile clients.

**Usage:**
```bash
./tooling/scripts/start-all.sh
# OR
pnpm start
```

**Starts:**
- Web on port 3000
- Mobile on port 3030

**Outputs:**
- PIDs saved to `.pids/`
- Logs saved to `logs/`

---

### `stop-all.sh`
Stop both web and mobile clients.

**Usage:**
```bash
./tooling/scripts/stop-all.sh
# OR
pnpm stop
```

**Cleanup:**
- Kills processes by PID
- Cleans up port bindings
- Removes PID files

---

### `start-web.sh`
Start web client only on port 3000.

**Usage:**
```bash
./tooling/scripts/start-web.sh
# OR
pnpm start:web
```

**Features:**
- Auto-kills existing process on port 3000
- Waits for server to be ready
- Saves PID to `.pids/web.pid`
- Logs to `logs/web.log`

---

### `stop-web.sh`
Stop web client.

**Usage:**
```bash
./tooling/scripts/stop-web.sh
# OR
pnpm stop:web
```

---

### `start-mobile.sh`
Start mobile client on port 3030.

**Usage:**
```bash
./tooling/scripts/start-mobile.sh
# OR
pnpm start:mobile
```

**Features:**
- Auto-kills existing process on port 3030
- Sets Metro bundler port to 3030
- Saves PID to `.pids/mobile.pid`
- Logs to `logs/mobile.log`

---

### `stop-mobile.sh`
Stop mobile client.

**Usage:**
```bash
./tooling/scripts/stop-mobile.sh
# OR
pnpm stop:mobile
```

**Cleanup:**
- Kills Metro bundler
- Kills Expo processes
- Cleans port 3030

---

### `status.sh`
Check status of all services.

**Usage:**
```bash
./tooling/scripts/status.sh
# OR
pnpm status
```

**Shows:**
- Running services and PIDs
- Port bindings (3000, 3030)
- Recent log entries
- PID file validation

---

## Quality Check Scripts

### `check-drift.sh`

Checks for code drift by scanning app directories for code that should be in shared packages.

**Usage:**
```bash
./tooling/scripts/check-drift.sh
# OR
pnpm check:drift
```

**What it checks:**
- Duplicate type definitions (should be in `@ssw/contracts`)
- Duplicate domain logic (should be in `@ssw/domain`)
- Duplicate API client code (should be in `@ssw/api`)

**Exit codes:**
- `0`: No drift detected
- `1`: Drift detected (fails CI)

**Patterns detected:**
- `interface CharacterAttributes`
- `interface Ship`
- `interface AuthResponse`
- `type ShipType`
- `calculateAttributePoints`
- `calculateStatPoints`
- `SHIP_TYPE_BONUSES`
- And more...

---

## File Structure

```
tooling/scripts/
├── start-all.sh         # Start web + mobile
├── stop-all.sh          # Stop all services
├── start-web.sh         # Start web only
├── stop-web.sh          # Stop web only
├── start-mobile.sh      # Start mobile only
├── stop-mobile.sh       # Stop mobile only
├── status.sh            # Check service status
├── check-drift.sh       # Detect code duplication
└── README.md            # This file
```

## Generated Files

Scripts create these directories and files:

```
.pids/           # Process ID files (git-ignored)
├── web.pid      # Web server PID
└── mobile.pid   # Mobile server PID

logs/            # Log files (git-ignored)
├── web.log      # Web server logs
└── mobile.log   # Mobile server logs
```

## Common Workflows

### Start Development
```bash
pnpm start              # Start both
pnpm status             # Verify running
tail -f logs/web.log    # Watch web logs
```

### Stop Development
```bash
pnpm stop               # Stop all
```

### Restart Single Service
```bash
pnpm stop:web           # Stop web
pnpm start:web          # Start web
```

### Check for Issues
```bash
pnpm status             # Service status
cat logs/web.log        # Full web logs
cat logs/mobile.log     # Full mobile logs
```

## Troubleshooting

### Port Already in Use

Scripts automatically kill existing processes on ports 3000 and 3030, but if manual cleanup is needed:

```bash
# Kill port 3000 (web)
lsof -ti:3000 | xargs kill -9

# Kill port 3030 (mobile)
lsof -ti:3030 | xargs kill -9
```

### Stale PID Files

If PID files point to dead processes:

```bash
rm .pids/*.pid
pnpm start
```

### Log Files Growing Large

```bash
# Clear logs
rm logs/*.log

# Or clear all generated files
pnpm clean
```

## Adding New Scripts

1. Create script in `tooling/scripts/`
2. Make executable: `chmod +x tooling/scripts/your-script.sh`
3. Add npm script in root `package.json`
4. Document here in README

## NPM Script Mapping

| NPM Command | Script File |
|-------------|-------------|
| `pnpm start` | `start-all.sh` |
| `pnpm stop` | `stop-all.sh` |
| `pnpm status` | `status.sh` |
| `pnpm start:web` | `start-web.sh` |
| `pnpm stop:web` | `stop-web.sh` |
| `pnpm start:mobile` | `start-mobile.sh` |
| `pnpm stop:mobile` | `stop-mobile.sh` |
| `pnpm check:drift` | `check-drift.sh` |
