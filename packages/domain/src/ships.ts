/**
 * Ship domain logic and business rules
 */

import type { ShipStats, ShipType } from '@ssw/contracts';
import {
  SHIP_CONSTANTS,
  SHIP_STAT_NAMES,
  SHIP_TYPE_BONUSES,
} from '@ssw/contracts';

/**
 * Create default ship stats with minimum values
 */
export function createDefaultShipStats(): ShipStats {
  return {
    hull_strength: SHIP_CONSTANTS.MIN_STAT_VALUE,
    shield_capacity: SHIP_CONSTANTS.MIN_STAT_VALUE,
    speed: SHIP_CONSTANTS.MIN_STAT_VALUE,
    cargo_space: SHIP_CONSTANTS.MIN_STAT_VALUE,
    sensors: SHIP_CONSTANTS.MIN_STAT_VALUE,
  };
}

/**
 * Calculate total points allocated across all stats
 */
export function calculateStatPoints(stats: ShipStats): number {
  return SHIP_STAT_NAMES.reduce((sum, stat) => sum + stats[stat], 0);
}

/**
 * Calculate remaining points available for allocation
 */
export function getRemainingStatPoints(stats: ShipStats): number {
  const allocated = calculateStatPoints(stats);
  return SHIP_CONSTANTS.TOTAL_STAT_POINTS - allocated;
}

/**
 * Check if stats are valid for ship creation
 */
export function areStatsValid(stats: ShipStats): boolean {
  // Check total points
  const total = calculateStatPoints(stats);
  if (total !== SHIP_CONSTANTS.TOTAL_STAT_POINTS) {
    return false;
  }

  // Check each stat is within bounds
  for (const stat of SHIP_STAT_NAMES) {
    const value = stats[stat];
    if (
      value < SHIP_CONSTANTS.MIN_STAT_VALUE ||
      value > SHIP_CONSTANTS.MAX_STAT_VALUE
    ) {
      return false;
    }
  }

  return true;
}

/**
 * Check if a stat can be incremented
 */
export function canIncrementStat(
  stats: ShipStats,
  stat: keyof ShipStats
): boolean {
  return (
    stats[stat] < SHIP_CONSTANTS.MAX_STAT_VALUE &&
    getRemainingStatPoints(stats) > 0
  );
}

/**
 * Check if a stat can be decremented
 */
export function canDecrementStat(
  stats: ShipStats,
  stat: keyof ShipStats
): boolean {
  return stats[stat] > SHIP_CONSTANTS.MIN_STAT_VALUE;
}

/**
 * Increment a stat value safely
 */
export function incrementStat(
  stats: ShipStats,
  stat: keyof ShipStats
): ShipStats {
  if (!canIncrementStat(stats, stat)) {
    return stats;
  }

  return {
    ...stats,
    [stat]: stats[stat] + 1,
  };
}

/**
 * Decrement a stat value safely
 */
export function decrementStat(
  stats: ShipStats,
  stat: keyof ShipStats
): ShipStats {
  if (!canDecrementStat(stats, stat)) {
    return stats;
  }

  return {
    ...stats,
    [stat]: stats[stat] - 1,
  };
}

/**
 * Calculate final ship stats with type bonuses applied
 */
export interface CalculatedShipStats {
  hull_max: number;
  shield_max: number;
  final_speed: number;
  cargo_capacity: number;
  final_sensors: number;
}

export function calculateFinalShipStats(
  stats: ShipStats,
  shipType: ShipType
): CalculatedShipStats {
  const bonuses = SHIP_TYPE_BONUSES[shipType];

  return {
    hull_max: stats.hull_strength * 100 + bonuses.hull_hp,
    shield_max: stats.shield_capacity * 50 + bonuses.shield_points,
    final_speed: stats.speed + bonuses.speed,
    cargo_capacity: stats.cargo_space * 10 + bonuses.cargo,
    final_sensors: stats.sensors + bonuses.sensors,
  };
}

/**
 * Get formatted description of ship bonuses
 */
export function getShipBonusDescription(shipType: ShipType): string[] {
  const bonuses = SHIP_TYPE_BONUSES[shipType];
  const descriptions: string[] = [];

  if (bonuses.hull_hp > 0) {
    descriptions.push(`+${bonuses.hull_hp} Hull HP`);
  }
  if (bonuses.shield_points > 0) {
    descriptions.push(`+${bonuses.shield_points} Shield`);
  }
  if (bonuses.speed > 0) {
    descriptions.push(`+${bonuses.speed} Speed`);
  }
  if (bonuses.cargo > 0) {
    descriptions.push(`+${bonuses.cargo} Cargo`);
  }
  if (bonuses.sensors > 0) {
    descriptions.push(`+${bonuses.sensors} Sensors`);
  }

  return descriptions;
}
