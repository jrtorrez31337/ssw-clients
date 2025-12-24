/**
 * SSW Domain - Shared game logic and business rules
 * @packageDocumentation
 */

// Character domain logic
export {
  createDefaultAttributes,
  calculateAttributePoints,
  getRemainingAttributePoints,
  areAttributesValid,
  canIncrementAttribute,
  canDecrementAttribute,
  incrementAttribute,
  decrementAttribute,
} from './characters.js';

// Ship domain logic
export type { CalculatedShipStats } from './ships.js';
export {
  createDefaultShipStats,
  calculateStatPoints,
  getRemainingStatPoints,
  areStatsValid,
  canIncrementStat,
  canDecrementStat,
  incrementStat,
  decrementStat,
  calculateFinalShipStats,
  getShipBonusDescription,
} from './ships.js';

// Validation
export {
  validateCharacterName,
  validateShipName,
  validateEmail,
  validatePassword,
} from './validation.js';
