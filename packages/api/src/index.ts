/**
 * SSW API - Shared API client for all platforms
 * @packageDocumentation
 */

export { ApiClient } from './client.js';
export type { ApiClientConfig } from './client.js';

export { WebTokenStore } from './token-store.js';
export type { TokenStore } from './token-store.js';

export { createAuthApi } from './endpoints/auth.js';
export type { AuthApi } from './endpoints/auth.js';

export { createCharacterApi } from './endpoints/characters.js';
export type { CharacterApi, CreateCharacterRequest } from './endpoints/characters.js';

export { createShipApi } from './endpoints/ships.js';
export type { ShipApi } from './endpoints/ships.js';
