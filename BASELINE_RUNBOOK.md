# Baseline Runbook - Pre-Monorepo State

This document captures the original setup and run instructions for both apps before monorepo consolidation.

## Web App (Vite + React)

### Technology Stack
- **Framework**: React 18 + TypeScript
- **Build Tool**: Vite 7
- **State Management**: Zustand
- **Data Fetching**: React Query + Axios
- **3D Rendering**: Three.js + React Three Fiber
- **Routing**: React Router v6

### Prerequisites
- Node.js 18+
- Backend API running on http://localhost:8080

### Original Location
`/home/jon/code/ssw-clients/web/`

### Installation (Original)
```bash
cd web
npm install
```

### Development Server (Original)
```bash
# Option 1: Direct development (recommended for local)
npm run dev

# Option 2: Using PM2 (used in sandbox environments)
pm2 start ecosystem.config.cjs
pm2 logs ssw-web-client
```

### Build (Original)
```bash
npm run build
```

### Environment
- **Dev URL**: http://localhost:3000
- **API Proxy**: `/v1` → `http://localhost:8080`
- **Token Storage**: localStorage
- **Required Backend**: http://localhost:8080

### Key Features
- Email/password authentication
- Character creation (20 attribute points)
- Ship customization (30 stat points, 4 ship types)
- 3D ship preview with Three.js
- Dashboard with character/ship management

### Directory Structure
```
web/
├── src/
│   ├── api/           # API client (axios)
│   ├── components/    # Reusable UI
│   ├── features/      # Feature modules (auth store)
│   ├── pages/         # Route pages
│   ├── scenes/        # Three.js 3D scenes
│   ├── hooks/         # Shared hooks
│   └── main.tsx       # Entry point
├── package.json
├── vite.config.ts
└── ecosystem.config.cjs
```

---

## Mobile App (Expo + React Native)

### Technology Stack
- **Framework**: React Native 0.81.5
- **Platform**: Expo ~54.0.30
- **Routing**: Expo Router v6
- **State Management**: Zustand
- **Data Fetching**: React Query + fetch API
- **Storage**: AsyncStorage

### Prerequisites
- Node.js (with nvm recommended)
- Bun (optional, npm also works)
- Expo Go app (for device testing)

### Original Location
`/home/jon/code/ssw-clients/mobile/`

### Installation (Original)
```bash
cd mobile
npm install
# OR
bun i
```

### Development Server (Original)
```bash
# Start development server
npm run start
# Then press "i" for iOS Simulator or "a" for Android

# OR start directly on iOS
npm run ios

# OR start directly on Android
npm run android

# Web preview (for quick testing)
npm run start-web
```

### Testing on Device (Original)
1. Install Expo Go app on iOS/Android
2. Run `npm run start`
3. Scan QR code from terminal

### Environment
- **API Base URL**: Configurable via constants/config.ts
- **Token Storage**: AsyncStorage (secure)
- **Required Backend**: Configurable backend URL

### Key Features
- File-based routing with Expo Router
- Tab navigation
- Modal screens
- Cross-platform (iOS, Android, Web)
- TypeScript support
- Vector icons (Lucide)

### Directory Structure
```
mobile/
├── app/               # Expo Router screens
│   ├── (tabs)/       # Tab navigation
│   ├── _layout.tsx   # Root layout
│   └── [routes].tsx  # Other screens
├── api/              # API client (fetch)
├── components/       # Reusable components
├── contexts/         # React contexts
├── types/            # TypeScript types
├── utils/            # Utility functions
├── constants/        # App constants
├── app.json          # Expo config
└── package.json
```

---

## Shared Elements Identified

### Common Dependencies
- `@tanstack/react-query` (v5.90.12 in both)
- `zustand` (v5.x in both)
- `react` (v19.x in both)
- `typescript` (v5.9.x in both)

### Common API Endpoints
Both apps use the same backend API structure:
- `POST /v1/auth/signup` - Create account
- `POST /v1/auth/login` - Authenticate
- `POST /v1/auth/refresh` - Refresh token
- `GET /v1/auth/me` - Get profile
- `POST /v1/characters` - Create character
- `GET /v1/characters/:id` - Get character
- `GET /v1/characters/by-profile/:profile_id` - List characters
- `POST /v1/ships` - Create ship
- `GET /v1/ships/:id` - Get ship
- `GET /v1/ships/by-owner/:owner_id` - List ships

### Common Types/Models
Both apps define similar types:
- `AuthResponse` - JWT tokens and session
- `UserProfile` - Account and profile info
- `Character` - With CharacterAttributes (5 attributes)
- `Ship` - With ShipStats (5 stats) and ShipType
- `ApiResponse<T>` / `ApiErrorResponse` - Wrapper types

### Game Logic
Both apps implement:
- **Character Attributes**: 20 points total across 5 attributes (1-10 each)
  - Piloting, Engineering, Science, Tactics, Leadership
- **Ship Stats**: 30 points total across 5 stats (1-15 each)
  - Hull Strength, Shield Capacity, Speed, Cargo Space, Sensors
- **Ship Type Bonuses**:
  - Scout: +2 Speed, +2 Sensors
  - Fighter: +300 Hull HP, +100 Shield
  - Trader: +100 Hull HP, +40 Cargo
  - Explorer: +1 Speed, +10 Cargo, +2 Sensors

### Differences Requiring Platform Abstraction

| Feature | Web | Mobile |
|---------|-----|--------|
| HTTP Client | Axios | Fetch API |
| Token Storage | localStorage | AsyncStorage |
| API Base URL | `/v1` (proxied) | Full URL from config |
| Navigation | React Router | Expo Router |
| 3D Rendering | Three.js | Not implemented |

---

## Migration Strategy Notes

### Phase 1 Priority: Keep It Working
- Both apps must run unchanged from monorepo
- Preserve all npm scripts
- No dependency upgrades initially

### Phase 2-4: Extraction Targets
1. **Shared Contracts** (`packages/contracts/`)
   - All TypeScript interfaces from `types/api.ts`
   - Game constants and validation rules

2. **Shared API Client** (`packages/api/`)
   - Unified client with platform-specific token stores
   - Typed endpoint functions

3. **Shared Domain Logic** (`packages/domain/`)
   - Point allocation algorithms
   - Ship bonus calculations
   - Validation functions

### Phase 5-6: Parity & CI
- Feature capability matrix
- Automated drift detection
- TypeScript checks across all packages

---

**Document Created**: 2025-12-24
**Purpose**: Preserve original setup instructions before monorepo migration
