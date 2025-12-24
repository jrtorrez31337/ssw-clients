/**
 * Character domain logic and business rules
 */

import type { CharacterAttributes } from '@ssw/contracts';
import {
  CHARACTER_CONSTANTS,
  ATTRIBUTE_NAMES,
} from '@ssw/contracts';

/**
 * Create default character attributes with minimum values
 */
export function createDefaultAttributes(): CharacterAttributes {
  return {
    piloting: CHARACTER_CONSTANTS.MIN_ATTRIBUTE_VALUE,
    engineering: CHARACTER_CONSTANTS.MIN_ATTRIBUTE_VALUE,
    science: CHARACTER_CONSTANTS.MIN_ATTRIBUTE_VALUE,
    tactics: CHARACTER_CONSTANTS.MIN_ATTRIBUTE_VALUE,
    leadership: CHARACTER_CONSTANTS.MIN_ATTRIBUTE_VALUE,
  };
}

/**
 * Calculate total points allocated across all attributes
 */
export function calculateAttributePoints(
  attributes: CharacterAttributes
): number {
  return ATTRIBUTE_NAMES.reduce((sum, attr) => sum + attributes[attr], 0);
}

/**
 * Calculate remaining points available for allocation
 */
export function getRemainingAttributePoints(
  attributes: CharacterAttributes
): number {
  const allocated = calculateAttributePoints(attributes);
  return CHARACTER_CONSTANTS.TOTAL_ATTRIBUTE_POINTS - allocated;
}

/**
 * Check if attributes are valid for character creation
 */
export function areAttributesValid(attributes: CharacterAttributes): boolean {
  // Check total points
  const total = calculateAttributePoints(attributes);
  if (total !== CHARACTER_CONSTANTS.TOTAL_ATTRIBUTE_POINTS) {
    return false;
  }

  // Check each attribute is within bounds
  for (const attr of ATTRIBUTE_NAMES) {
    const value = attributes[attr];
    if (
      value < CHARACTER_CONSTANTS.MIN_ATTRIBUTE_VALUE ||
      value > CHARACTER_CONSTANTS.MAX_ATTRIBUTE_VALUE
    ) {
      return false;
    }
  }

  return true;
}

/**
 * Check if an attribute can be incremented
 */
export function canIncrementAttribute(
  attributes: CharacterAttributes,
  attribute: keyof CharacterAttributes
): boolean {
  return (
    attributes[attribute] < CHARACTER_CONSTANTS.MAX_ATTRIBUTE_VALUE &&
    getRemainingAttributePoints(attributes) > 0
  );
}

/**
 * Check if an attribute can be decremented
 */
export function canDecrementAttribute(
  attributes: CharacterAttributes,
  attribute: keyof CharacterAttributes
): boolean {
  return attributes[attribute] > CHARACTER_CONSTANTS.MIN_ATTRIBUTE_VALUE;
}

/**
 * Increment an attribute value safely
 */
export function incrementAttribute(
  attributes: CharacterAttributes,
  attribute: keyof CharacterAttributes
): CharacterAttributes {
  if (!canIncrementAttribute(attributes, attribute)) {
    return attributes;
  }

  return {
    ...attributes,
    [attribute]: attributes[attribute] + 1,
  };
}

/**
 * Decrement an attribute value safely
 */
export function decrementAttribute(
  attributes: CharacterAttributes,
  attribute: keyof CharacterAttributes
): CharacterAttributes {
  if (!canDecrementAttribute(attributes, attribute)) {
    return attributes;
  }

  return {
    ...attributes,
    [attribute]: attributes[attribute] - 1,
  };
}
