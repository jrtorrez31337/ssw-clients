/**
 * Shared API types and interfaces for SSW Galaxy MMO clients
 * These types define the contracts between clients and the backend API
 */

// ============================================================================
// Authentication Types
// ============================================================================

export interface AuthResponse {
  access_token: string;
  refresh_token: string;
  token_type: string;
  expires_in: number;
  session_id: string;
}

export interface UserProfile {
  account_id: string;
  email: string;
  status: string;
  home_region: string;
  profile_id: string;
  display_name: string;
  active_sessions: number;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface SignupCredentials {
  email: string;
  password: string;
  display_name: string;
}

// ============================================================================
// Character Types
// ============================================================================

export interface CharacterAttributes {
  piloting: number;
  engineering: number;
  science: number;
  tactics: number;
  leadership: number;
}

export interface Character {
  id: string;
  profile_id: string;
  name: string;
  home_sector: string;
  attributes: CharacterAttributes;
  created_at: string;
}

export interface CreateCharacterRequest {
  name: string;
  attributes: CharacterAttributes;
  home_sector?: string;
}

// ============================================================================
// Ship Types
// ============================================================================

export interface ShipStats {
  hull_strength: number;
  shield_capacity: number;
  speed: number;
  cargo_space: number;
  sensors: number;
}

export type ShipType = 'scout' | 'fighter' | 'trader' | 'explorer';

export interface Ship {
  id: string;
  owner_id: string;
  ship_type: ShipType;
  name?: string;
  hull_points: number;
  hull_max: number;
  shield_points: number;
  shield_max: number;
  cargo_capacity: number;
  location_sector: string;
  created_at: string;
  stat_allocation?: ShipStats;
}

export interface CreateShipRequest {
  owner_id: string;
  ship_type: ShipType;
  name?: string;
  stat_allocation: ShipStats;
}

// ============================================================================
// API Response Wrappers
// ============================================================================

export interface ApiError {
  code: string;
  message: string;
}

export interface ApiResponse<T> {
  data: T;
}

export interface ApiErrorResponse {
  error: ApiError;
}

// ============================================================================
// Type Guards
// ============================================================================

export function isApiErrorResponse(
  response: unknown
): response is ApiErrorResponse {
  return (
    typeof response === 'object' &&
    response !== null &&
    'error' in response &&
    typeof (response as ApiErrorResponse).error === 'object'
  );
}
