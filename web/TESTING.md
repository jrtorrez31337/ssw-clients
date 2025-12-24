# SSW Galaxy MMO - Testing Guide

## Application Access

**Public URL**: https://3000-ii6xx8ayzce5eft1yioym-583b4d74.sandbox.novita.ai

**Backend API**: The backend must be running on `http://localhost:8080` for the application to work properly. The Vite dev server proxies all `/v1` requests to the backend.

## Testing Flow

### 1. Signup & Authentication

1. **Navigate to Signup**
   - Open the public URL above
   - You'll be redirected to `/login`
   - Click "Create one" to go to signup page

2. **Create Account**
   - Enter a display name (e.g., "Captain Test")
   - Enter a valid email (e.g., "test@galaxy.com")
   - Enter a password (minimum 8 characters)
   - Click "Create Account"
   - On success, you'll be automatically logged in and redirected to dashboard

3. **Login (for existing accounts)**
   - Enter email and password
   - Click "Sign In"
   - On success, redirected to dashboard

### 2. Character Creation

1. **Start Character Creation**
   - From dashboard, click "Create New Character"
   - Or navigate to `/character-create`

2. **Configure Character**
   - Enter character name (3-32 characters)
   - See home sector is set to "Sol System"
   
3. **Allocate Attributes (20 points total)**
   - Use +/- buttons to adjust each attribute
   - Minimum: 1 point per attribute
   - Maximum: 10 points per attribute
   - Must allocate all 20 points (remaining shows 0/20)
   
   **Attributes:**
   - 🚀 Piloting: Ship maneuverability and flight control
   - 🔧 Engineering: Tech/repair bonuses and ship systems
   - 🔬 Science: Research, discovery, and scanning
   - ⚔️ Tactics: Combat effectiveness and strategy
   - 👑 Leadership: Crew bonuses and faction influence

4. **Create Character**
   - Click "Create Character" (disabled until all points allocated)
   - On success, redirected to ship customization

### 3. Ship Customization

1. **Select Ship Type**
   - **Scout**: Fast reconnaissance (+2 Speed, +2 Sensors)
   - **Fighter**: Heavy combat (+300 Hull HP, +100 Shield)
   - **Trader**: Cargo hauler (+100 Hull HP, +40 Cargo)
   - **Explorer**: Long-range vessel (+1 Speed, +10 Cargo, +2 Sensors)
   - Click on a ship type card to select it

2. **View 3D Preview**
   - Interactive 3D ship model in right sidebar
   - Auto-rotates with starfield background
   - Zoom with mouse wheel
   - Drag to rotate
   - Different geometry for each ship type

3. **Optional: Name Your Ship**
   - Enter ship name (3-32 characters, optional)
   - Leave blank for unnamed ship

4. **Allocate Stats (30 points total)**
   - Use +/- buttons to adjust each stat
   - Minimum: 1 point per stat
   - Maximum: 15 points per stat
   - Must allocate all 30 points (remaining shows 0/30)
   
   **Stats:**
   - 🛡️ Hull Strength: Durability (×100 HP)
   - ✨ Shield Capacity: Energy shields (×50 Shield)
   - ⚡ Speed: Travel and combat speed
   - 📦 Cargo Space: Storage capacity (×10 units)
   - 📡 Sensors: Detection and scanning range

5. **View Final Stats**
   - Right sidebar shows calculated final stats with bonuses
   - Hull Max = (hull_strength × 100) + type_bonus
   - Shield Max = (shield_capacity × 50) + type_bonus
   - Speed = speed + type_bonus
   - Cargo = (cargo_space × 10) + type_bonus
   - Sensors = sensors + type_bonus

6. **Launch Ship**
   - Click "Launch Ship" (disabled until all points allocated)
   - On success, redirected to dashboard

### 4. Dashboard

1. **View Characters**
   - See all created characters with their attributes
   - Character name and home sector displayed
   - All five attributes shown with values

2. **View Ships**
   - See all customized ships with their stats
   - Ship type badge, name (if provided)
   - Hull, Shield, and Cargo displayed
   - Current location sector shown

3. **Quick Actions**
   - "Create New Character" button
   - "Customize New Ship" button

4. **Logout**
   - Click "Logout" button in header
   - Redirected to login page
   - Session cleared

## API Validation Testing

### Test Invalid Inputs

**Character Creation:**
- Try allocating 19 points (should show error)
- Try allocating 21 points (should be prevented by UI)
- Try attribute value > 10 (should be prevented by UI)
- Try name < 3 characters (should show validation error)

**Ship Customization:**
- Try allocating 29 points (should show error)
- Try allocating 31 points (should be prevented by UI)
- Try stat value > 15 (should be prevented by UI)

### Test Authentication

**Token Refresh:**
- Access tokens expire in 15 minutes (900s)
- After expiration, next API call should automatically refresh
- Check browser DevTools > Network for `/v1/auth/refresh` call

**Protected Routes:**
- Try accessing `/dashboard` without login
- Should redirect to `/login`
- After login, should redirect back to dashboard

## Expected Behaviors

### Success Cases
- ✅ Signup creates account and logs in
- ✅ Login authenticates and redirects to dashboard
- ✅ Character creation validates points and creates character
- ✅ Ship creation validates points and creates ship
- ✅ Dashboard displays all characters and ships
- ✅ 3D preview updates when ship type changes
- ✅ Final stats update in real-time as you allocate
- ✅ Logout clears session and redirects

### Error Cases
- ❌ Signup with existing email shows error
- ❌ Login with wrong credentials shows error
- ❌ Invalid point allocation shows validation error
- ❌ Character/ship creation errors display error message
- ❌ Backend unavailable shows network error

## Browser Console

Open DevTools (F12) to:
- Check for JavaScript errors
- Monitor API requests in Network tab
- Verify localStorage contains tokens
- Check WebGL for 3D rendering

## Common Issues

**Issue**: Backend connection failed
**Solution**: Ensure backend is running on http://localhost:8080

**Issue**: 3D preview doesn't load
**Solution**: Check browser supports WebGL. Try Chrome/Firefox latest.

**Issue**: Token expired
**Solution**: Refresh should happen automatically. If not, logout and login again.

**Issue**: Point allocation stuck
**Solution**: Ensure you've allocated exactly the required points (0 remaining).

## API Endpoints Used

All endpoints are proxied through Vite dev server at `/v1`:

**Auth:**
- POST `/v1/auth/signup`
- POST `/v1/auth/login`
- POST `/v1/auth/refresh`
- GET `/v1/auth/me`

**Characters:**
- POST `/v1/characters`
- GET `/v1/characters/by-profile/:profile_id`

**Ships:**
- POST `/v1/ships`
- GET `/v1/ships/by-owner/:owner_id`

## Performance Notes

- Initial Vite build: ~333ms
- 3D rendering: 60fps on modern hardware
- API response times: <100ms (local)
- Token refresh: Automatic and transparent

## Browser Compatibility

**Tested and Supported:**
- Chrome 120+
- Firefox 120+
- Safari 17+
- Edge 120+

**Requires:**
- WebGL support for 3D preview
- LocalStorage for session persistence
- Modern ES2015+ JavaScript
