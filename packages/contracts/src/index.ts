/**
 * SSW Contracts - Shared TypeScript types and interfaces
 * @packageDocumentation
 */

// Re-export all API types
export type {
  AuthResponse,
  UserProfile,
  LoginCredentials,
  SignupCredentials,
  CharacterAttributes,
  Character,
  CreateCharacterRequest,
  ShipStats,
  ShipType,
  Ship,
  CreateShipRequest,
  ApiError,
  ApiResponse,
  ApiErrorResponse,
} from './api.js';

export { isApiErrorResponse } from './api.js';

// Re-export all game types and constants
export type { ShipBonuses, CalculatedShipStats } from './game.js';

export {
  CHARACTER_CONSTANTS,
  ATTRIBUTE_NAMES,
  ATTRIBUTE_DESCRIPTIONS,
  SHIP_CONSTANTS,
  SHIP_STAT_NAMES,
  SHIP_STAT_DESCRIPTIONS,
  SHIP_TYPES,
  SHIP_TYPE_BONUSES,
  SHIP_TYPE_DESCRIPTIONS,
} from './game.js';
