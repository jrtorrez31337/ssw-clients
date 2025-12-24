# @ssw/api

Shared API client for SSW Galaxy MMO clients with platform-specific token storage.

## Features

- **Platform Agnostic**: Works with any JavaScript environment (web, React Native, Node.js)
- **Automatic Token Refresh**: Handles JWT refresh automatically on 401 responses
- **Pluggable Token Storage**: Inject your own storage implementation
- **Type-Safe**: Full TypeScript support with types from `@ssw/contracts`
- **Fetch-Based**: Uses native `fetch` API (available everywhere)

## Usage

### Web (localStorage)

```typescript
import { ApiClient, WebTokenStore, createAuthApi } from '@ssw/api';

// Create client with web token store
const client = new ApiClient({
  baseURL: '/v1', // or full URL
  tokenStore: new WebTokenStore(),
  onUnauthorized: () => {
    // Handle logout, e.g., redirect to login
    window.location.href = '/login';
  },
});

// Create API endpoints
const authApi = createAuthApi(client);

// Use the API
const response = await authApi.login({
  email: 'user@example.com',
  password: 'password',
});
```

### React Native (AsyncStorage)

```typescript
import { ApiClient, createAuthApi } from '@ssw/api';
import AsyncStorage from '@react-native-async-storage/async-storage';
import type { TokenStore } from '@ssw/api';

// Create mobile token store
class MobileTokenStore implements TokenStore {
  async getAccessToken() {
    return AsyncStorage.getItem('access_token');
  }

  async getRefreshToken() {
    return AsyncStorage.getItem('refresh_token');
  }

  async setTokens(accessToken: string, refreshToken: string) {
    await AsyncStorage.multiSet([
      ['access_token', accessToken],
      ['refresh_token', refreshToken],
    ]);
  }

  async setAccessToken(accessToken: string) {
    await AsyncStorage.setItem('access_token', accessToken);
  }

  async clearTokens() {
    await AsyncStorage.multiRemove(['access_token', 'refresh_token', 'profile_id']);
  }
}

const client = new ApiClient({
  baseURL: 'https://api.example.com/v1',
  tokenStore: new MobileTokenStore(),
  onUnauthorized: () => {
    // Handle logout
    navigation.navigate('Login');
  },
});
```

## Available Endpoints

### Authentication

```typescript
import { createAuthApi } from '@ssw/api';

const authApi = createAuthApi(client);

await authApi.signup({ email, password, display_name });
await authApi.login({ email, password });
await authApi.getMe();
await authApi.refresh(refreshToken);
```

### Characters

```typescript
import { createCharacterApi } from '@ssw/api';

const characterApi = createCharacterApi(client);

await characterApi.create({
  profile_id: '...',
  name: 'Captain Smith',
  home_sector: 'Alpha',
  attributes: { piloting: 5, engineering: 4, ... },
});

await characterApi.getById(characterId);
await characterApi.getByProfile(profileId);
await characterApi.update(characterId, newName);
```

### Ships

```typescript
import { createShipApi } from '@ssw/api';

const shipApi = createShipApi(client);

await shipApi.create({
  owner_id: characterId,
  ship_type: 'scout',
  name: 'Explorer One',
  stat_allocation: { hull_strength: 5, shield_capacity: 3, ... },
});

await shipApi.getById(shipId);
await shipApi.getByOwner(characterId);
await shipApi.update(shipId, newName);
```

## Token Storage Interface

Implement this interface for your platform:

```typescript
interface TokenStore {
  getAccessToken(): Promise<string | null> | string | null;
  getRefreshToken(): Promise<string | null> | string | null;
  setTokens(accessToken: string, refreshToken: string): Promise<void> | void;
  setAccessToken(accessToken: string): Promise<void> | void;
  clearTokens(): Promise<void> | void;
}
```

Both sync and async implementations are supported.
