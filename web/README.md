# SSW Galaxy MMO - Web Client

A React + TypeScript web client for the SSW Galaxy MMO game. Features character creation with attribute allocation, ship customization with stat allocation, and 3D ship preview.

## Project Overview

- **Name**: SSW Galaxy MMO Web Client
- **Goal**: Full-featured game client for character creation, ship customization, and space exploration
- **Tech Stack**: React 18 + TypeScript + Vite + Three.js + Zustand + React Query

## Features

### Currently Completed

✅ **Authentication System**
- Email/password signup and login
- JWT token management with automatic refresh
- Protected routes with auth guards
- Persistent session management

✅ **Character Creation**
- Space-themed attribute allocation (20 points total)
- Five attributes: Piloting, Engineering, Science, Tactics, Leadership
- Point allocation UI with increment/decrement controls
- Visual progress bars and validation
- Character name customization

✅ **Ship Customization**
- Four ship types: Scout, Fighter, Trader, Explorer
- Stat allocation system (30 points total)
- Five stats: Hull Strength, Shield Capacity, Speed, Cargo Space, Sensors
- Type-specific bonuses automatically applied
- Real-time stat calculations displayed
- Optional ship naming

✅ **3D Ship Preview**
- Interactive 3D WebGL rendering using Three.js
- Auto-rotating camera with zoom controls
- Different geometries for each ship type
- Starfield background for space atmosphere
- Metallic materials with emissive glow

✅ **Dashboard**
- Display all created characters with attributes
- Display all customized ships with stats
- Quick action buttons for creation flows
- Logout functionality

## URLs

- **Development**: http://localhost:3000
- **Public URL**: https://3000-ii6xx8ayzce5eft1yioym-583b4d74.sandbox.novita.ai
- **Backend API**: http://localhost:8080/v1 (proxied through Vite)
- **GitHub**: https://github.com/jrtorrez31337/ssw-fe-genspark

## Data Architecture

### API Endpoints Used

**Authentication:**
- `POST /v1/auth/signup` - Create new account
- `POST /v1/auth/login` - Authenticate user
- `POST /v1/auth/refresh` - Refresh access token
- `GET /v1/auth/me` - Get user profile

**Characters:**
- `POST /v1/characters` - Create character with attributes
- `GET /v1/characters/:id` - Get character by ID
- `GET /v1/characters/by-profile/:profile_id` - Get all characters for profile

**Ships:**
- `POST /v1/ships` - Create ship with stat allocation
- `GET /v1/ships/:id` - Get ship by ID
- `GET /v1/ships/by-owner/:owner_id` - Get all ships for owner

### State Management

- **Zustand**: Auth state (tokens, profile info)
- **React Query**: API data caching and synchronization
- **LocalStorage**: Persistent token storage

### Data Models

**Character Attributes (20 points total):**
- Piloting (1-10): Ship maneuverability
- Engineering (1-10): Tech/repair bonuses
- Science (1-10): Research and discovery
- Tactics (1-10): Combat effectiveness
- Leadership (1-10): Crew bonuses

**Ship Stats (30 points total):**
- Hull Strength (1-15): Durability × 100 HP
- Shield Capacity (1-15): Shields × 50
- Speed (1-15): Travel speed
- Cargo Space (1-15): Capacity × 10 units
- Sensors (1-15): Detection range

**Ship Type Bonuses:**
- Scout: +2 Speed, +2 Sensors
- Fighter: +300 Hull HP, +100 Shield
- Trader: +100 Hull HP, +40 Cargo
- Explorer: +1 Speed, +10 Cargo, +2 Sensors

## User Guide

### Getting Started

1. **Sign Up**: Create an account with email and password
2. **Create Character**: Allocate 20 points across 5 attributes
3. **Customize Ship**: Choose ship type and allocate 30 stat points
4. **Dashboard**: View all your characters and ships

### Character Creation

1. Enter a unique character name (3-32 characters)
2. Allocate 20 points across five attributes
3. Use +/- buttons to adjust each attribute (min 1, max 10)
4. Ensure all 20 points are allocated (remaining shows 0/20)
5. Click "Create Character" to proceed to ship customization

### Ship Customization

1. Select ship type to see bonuses
2. Optionally enter a ship name
3. Allocate 30 points across five stats
4. Use +/- buttons (min 1, max 15 per stat)
5. Preview ship in 3D viewer (auto-rotates, zoom with mouse wheel)
6. Check "Final Stats" panel to see calculated values with bonuses
7. Click "Launch Ship" to complete

## Development

### Prerequisites

- Node.js 18+
- Backend API running on http://localhost:8080

### Installation

```bash
cd /home/user/webapp
npm install
```

### Development Server

```bash
# Using PM2 (recommended for sandbox)
pm2 start ecosystem.config.cjs
pm2 logs ssw-web-client

# Direct (for local development)
npm run dev
```

### Build

```bash
npm run build
```

## Deployment

- **Platform**: Vite dev server (development)
- **Status**: ✅ Active in development
- **Last Updated**: 2025-12-23

## Project Structure

```
src/
├── api/                    # API client layer
│   ├── client.ts          # Axios instance with interceptors
│   ├── auth.ts            # Auth endpoints
│   ├── characters.ts      # Character endpoints
│   └── ships.ts           # Ship endpoints
├── components/            # Reusable UI components
│   ├── ui/                # Base components (Button, Input, Card)
│   └── layout/            # Layout components (ProtectedRoute)
├── features/              # Feature modules
│   └── auth/             
│       ├── store.ts       # Auth state (Zustand)
│       └── hooks/         # useAuth hook
├── pages/                 # Route pages
│   ├── LoginPage.tsx
│   ├── SignupPage.tsx
│   ├── CharacterCreatePage.tsx
│   ├── ShipCustomizePage.tsx
│   └── DashboardPage.tsx
├── scenes/                # Three.js 3D scenes
│   └── ShipPreview.tsx    # 3D ship viewer
├── hooks/                 # Shared hooks
│   └── usePointAllocation.ts
├── App.tsx               # Main app component
├── router.tsx            # React Router config
└── main.tsx              # Entry point
```

## Known Issues & Future Improvements

### Known Issues
- Ship stat_allocation may show zeros on GET (backend issue, doesn't affect bonuses)

### Features Not Yet Implemented
- [ ] Space navigation and sector exploration
- [ ] Real-time combat system
- [ ] Trading and economy features
- [ ] Faction system and reputation
- [ ] Chat and social features
- [ ] Character equipment and inventory
- [ ] Advanced ship models (currently using basic geometries)
- [ ] Sound effects and music
- [ ] Mobile responsive improvements

### Recommended Next Steps
1. Add character editing functionality
2. Add ship editing and upgrade system
3. Implement space navigation with sector map
4. Add inventory and equipment system
5. Create combat UI and mechanics
6. Add trading interface with market data
7. Implement chat system
8. Add faction UI and reputation tracking
9. Create GLTF ship models for better 3D preview
10. Add tutorial/onboarding flow

## Technology Choices

- **React 18**: Modern hooks and concurrent features
- **TypeScript**: Type safety and better DX
- **Vite**: Fast HMR and modern build tooling
- **React Router v6**: Client-side routing
- **Zustand**: Lightweight state management
- **React Query**: Powerful API caching
- **Axios**: HTTP client with interceptors
- **Three.js**: 3D WebGL rendering
- **React-Three-Fiber**: Declarative Three.js in React

## Backend Integration

This frontend connects to the SSW Galaxy MMO backend:
- **Repository**: github.com/jrtorrez31337/ssw
- **API Gateway**: http://localhost:8080
- **Services**: 10 microservices (Identity, World Sim, Combat, Economy, Social, etc.)
- **Database**: CockroachDB for distributed SQL
- **Messaging**: NATS with JetStream
- **Caching**: Redis

## License

This is a game development project. All rights reserved.
