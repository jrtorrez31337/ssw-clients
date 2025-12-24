/**
 * Validation utilities for game entities
 */

import { CHARACTER_CONSTANTS, SHIP_CONSTANTS } from '@ssw/contracts';

/**
 * Validate character name
 */
export function validateCharacterName(name: string): {
  valid: boolean;
  error?: string;
} {
  if (!name || name.trim().length === 0) {
    return { valid: false, error: 'Name is required' };
  }

  const trimmed = name.trim();

  if (trimmed.length < CHARACTER_CONSTANTS.MIN_NAME_LENGTH) {
    return {
      valid: false,
      error: `Name must be at least ${CHARACTER_CONSTANTS.MIN_NAME_LENGTH} characters`,
    };
  }

  if (trimmed.length > CHARACTER_CONSTANTS.MAX_NAME_LENGTH) {
    return {
      valid: false,
      error: `Name must be at most ${CHARACTER_CONSTANTS.MAX_NAME_LENGTH} characters`,
    };
  }

  // Only allow alphanumeric, spaces, hyphens, and apostrophes
  if (!/^[a-zA-Z0-9\s'-]+$/.test(trimmed)) {
    return {
      valid: false,
      error: 'Name can only contain letters, numbers, spaces, hyphens, and apostrophes',
    };
  }

  return { valid: true };
}

/**
 * Validate ship name (optional, but if provided must meet requirements)
 */
export function validateShipName(name: string | undefined): {
  valid: boolean;
  error?: string;
} {
  // Ship name is optional
  if (!name || name.trim().length === 0) {
    return { valid: true };
  }

  const trimmed = name.trim();

  if (trimmed.length > SHIP_CONSTANTS.MAX_NAME_LENGTH) {
    return {
      valid: false,
      error: `Name must be at most ${SHIP_CONSTANTS.MAX_NAME_LENGTH} characters`,
    };
  }

  // Only allow alphanumeric, spaces, hyphens, and apostrophes
  if (!/^[a-zA-Z0-9\s'-]+$/.test(trimmed)) {
    return {
      valid: false,
      error: 'Name can only contain letters, numbers, spaces, hyphens, and apostrophes',
    };
  }

  return { valid: true };
}

/**
 * Validate email format
 */
export function validateEmail(email: string): {
  valid: boolean;
  error?: string;
} {
  if (!email || email.trim().length === 0) {
    return { valid: false, error: 'Email is required' };
  }

  // Simple email regex
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return { valid: false, error: 'Invalid email format' };
  }

  return { valid: true };
}

/**
 * Validate password strength
 */
export function validatePassword(password: string): {
  valid: boolean;
  error?: string;
} {
  if (!password || password.length === 0) {
    return { valid: false, error: 'Password is required' };
  }

  if (password.length < 8) {
    return { valid: false, error: 'Password must be at least 8 characters' };
  }

  if (password.length > 128) {
    return { valid: false, error: 'Password must be at most 128 characters' };
  }

  return { valid: true };
}
