/**
 * Shared game logic types and constants for SSW Galaxy MMO
 * These define the rules and constraints for character and ship customization
 */

import type { CharacterAttributes, ShipStats, ShipType } from './api.js';

// ============================================================================
// Character Constants
// ============================================================================

export const CHARACTER_CONSTANTS = {
  TOTAL_ATTRIBUTE_POINTS: 20,
  MIN_ATTRIBUTE_VALUE: 1,
  MAX_ATTRIBUTE_VALUE: 10,
  MIN_NAME_LENGTH: 3,
  MAX_NAME_LENGTH: 32,
} as const;

export const ATTRIBUTE_NAMES: readonly (keyof CharacterAttributes)[] = [
  'piloting',
  'engineering',
  'science',
  'tactics',
  'leadership',
] as const;

export const ATTRIBUTE_DESCRIPTIONS: Record<keyof CharacterAttributes, string> = {
  piloting: 'Ship maneuverability and control',
  engineering: 'Technology and repair bonuses',
  science: 'Research and discovery capabilities',
  tactics: 'Combat effectiveness and strategy',
  leadership: 'Crew bonuses and command abilities',
};

// ============================================================================
// Ship Constants
// ============================================================================

export const SHIP_CONSTANTS = {
  TOTAL_STAT_POINTS: 30,
  MIN_STAT_VALUE: 1,
  MAX_STAT_VALUE: 15,
  MIN_NAME_LENGTH: 0,
  MAX_NAME_LENGTH: 32,
} as const;

export const SHIP_STAT_NAMES: readonly (keyof ShipStats)[] = [
  'hull_strength',
  'shield_capacity',
  'speed',
  'cargo_space',
  'sensors',
] as const;

export const SHIP_STAT_DESCRIPTIONS: Record<keyof ShipStats, string> = {
  hull_strength: 'Durability and damage resistance',
  shield_capacity: 'Energy shield strength',
  speed: 'Travel and maneuver speed',
  cargo_space: 'Storage capacity for goods',
  sensors: 'Detection range and scanning',
};

export const SHIP_TYPES: readonly ShipType[] = [
  'scout',
  'fighter',
  'trader',
  'explorer',
] as const;

// ============================================================================
// Ship Type Bonuses
// ============================================================================

export interface ShipBonuses {
  hull_hp: number;
  shield_points: number;
  speed: number;
  cargo: number;
  sensors: number;
}

export const SHIP_TYPE_BONUSES: Record<ShipType, ShipBonuses> = {
  scout: {
    hull_hp: 0,
    shield_points: 0,
    speed: 2,
    cargo: 0,
    sensors: 2,
  },
  fighter: {
    hull_hp: 300,
    shield_points: 100,
    speed: 0,
    cargo: 0,
    sensors: 0,
  },
  trader: {
    hull_hp: 100,
    shield_points: 0,
    speed: 0,
    cargo: 40,
    sensors: 0,
  },
  explorer: {
    hull_hp: 0,
    shield_points: 0,
    speed: 1,
    cargo: 10,
    sensors: 2,
  },
};

export const SHIP_TYPE_DESCRIPTIONS: Record<ShipType, string> = {
  scout: 'Fast and stealthy with enhanced sensors',
  fighter: 'Heavy armor and shields for combat',
  trader: 'Large cargo capacity for commerce',
  explorer: 'Balanced for long-range exploration',
};

// ============================================================================
// Calculation Helpers (Type-only, implementations in domain package)
// ============================================================================

export interface CalculatedShipStats {
  hull_max: number;
  shield_max: number;
  final_speed: number;
  cargo_capacity: number;
  final_sensors: number;
}
