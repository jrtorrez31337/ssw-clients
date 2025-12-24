# SSW Galaxy MMO - Client Monorepo

A unified monorepo containing web and mobile clients for the SSW Galaxy MMO game.

## Quick Start

### Prerequisites
- Node.js 18+
- pnpm 8+ (install: `npm install -g pnpm`)
- Backend API running (default: http://localhost:8080)

### Installation

```bash
# Install all dependencies across workspace
pnpm install
```

### Running Apps

#### Quick Start (Recommended)
```bash
# Start both web and mobile
pnpm start

# Check status
pnpm status

# Stop all services
pnpm stop
```

#### Individual Apps

**Web Client** (http://localhost:3000)
```bash
# Start web only
pnpm start:web

# Stop web
pnpm stop:web

# Or use direct command
pnpm web:dev
```

**Mobile Client** (Metro on port 3030)
```bash
# Start mobile only
pnpm start:mobile

# Stop mobile
pnpm stop:mobile

# Or use direct command
pnpm mobile:start

# Web preview
pnpm mobile:start-web

# iOS simulator
pnpm mobile:ios

# Android emulator
pnpm mobile:android
```

**Service Ports:**
- Web: http://localhost:3000
- Mobile Metro: http://localhost:3030
- Logs: `logs/web.log` and `logs/mobile.log`

## Repository Structure

```
ssw-clients/
├── apps/
│   ├── web/              # React + Vite web client
│   └── mobile/           # Expo + React Native mobile client
├── packages/             # Shared packages (will be populated)
│   ├── contracts/        # Shared TypeScript types/interfaces
│   ├── api/              # Shared API client
│   ├── domain/           # Shared game logic
│   └── flags/            # Feature flags/capabilities
├── tooling/              # Build tools and scripts
│   └── scripts/          # Utility scripts
├── .github/
│   └── workflows/        # CI/CD pipelines
├── package.json          # Root workspace configuration
├── pnpm-workspace.yaml   # PNPM workspace definition
└── tsconfig.base.json    # Base TypeScript config
```

## Available Commands

### Root Commands
```bash
pnpm install:all      # Install all dependencies
pnpm typecheck        # Type check all packages
pnpm lint             # Lint all packages
pnpm test             # Run all tests
pnpm clean            # Clean all build artifacts
```

### App-Specific Commands
See individual app READMEs:
- [Web Client](./apps/web/README.md)
- [Mobile Client](./apps/mobile/README.md)

## Technology Stack

### Web App
- **Framework**: React 18 + TypeScript
- **Build Tool**: Vite 7
- **State**: Zustand + React Query
- **HTTP**: Axios
- **3D**: Three.js + React Three Fiber
- **Routing**: React Router v6

### Mobile App
- **Framework**: React Native 0.81 + TypeScript
- **Platform**: Expo 54
- **Routing**: Expo Router v6
- **State**: Zustand + React Query
- **HTTP**: Fetch API
- **Storage**: AsyncStorage

### Shared
- TypeScript 5.9
- React Query 5.90
- Zustand 5.0

## Development Workflow

### Adding Dependencies
```bash
# Add to web app
pnpm --filter @ssw/web add <package>

# Add to mobile app
pnpm --filter @ssw/mobile add <package>

# Add to shared package
pnpm --filter @ssw/contracts add <package>

# Add to root (dev tools)
pnpm add -Dw <package>
```

### Creating a Shared Package
```bash
# Example: Creating a new shared package
mkdir -p packages/my-package
cd packages/my-package
pnpm init
# Add "name": "@ssw/my-package" to package.json
```

## Migration Status

### ✅ Phase 0: Complete
- Baseline documentation
- Repository initialization

### ✅ Phase 1: Complete
- Monorepo workspace configured
- Apps moved to `apps/` directory
- PNPM workspaces setup

### 🚧 Phase 2: In Progress
- Extract shared contracts/types

### ⏳ Phase 3: Pending
- Create shared API client

### ⏳ Phase 4: Pending
- Extract shared domain logic

### ⏳ Phase 5: Pending
- Feature flags/capabilities

### ⏳ Phase 6: Pending
- CI/CD and drift prevention

## Backend Integration

Both clients connect to the SSW Galaxy MMO backend:
- **API Gateway**: http://localhost:8080
- **API Version**: v1
- **Services**: Identity, Characters, Ships, World Simulation
- **Database**: CockroachDB
- **Messaging**: NATS with JetStream

### API Endpoints
- `POST /v1/auth/signup` - Create account
- `POST /v1/auth/login` - Authenticate
- `POST /v1/auth/refresh` - Refresh token
- `GET /v1/auth/me` - Get user profile
- `POST /v1/characters` - Create character
- `GET /v1/characters/:id` - Get character
- `POST /v1/ships` - Create ship
- `GET /v1/ships/:id` - Get ship

## Contributing

See [BASELINE_RUNBOOK.md](./BASELINE_RUNBOOK.md) for original setup instructions and migration notes.

## License

All rights reserved.
