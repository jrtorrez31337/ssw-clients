/**
 * Feature capability matrix for SSW clients
 *
 * Tracks which features are required/optional for each platform
 * to ensure parity and controlled divergence.
 */

export type Platform = 'web' | 'mobile';

export type FeatureStatus = 'required' | 'optional' | 'not-applicable';

export interface FeatureCapability {
  id: string;
  name: string;
  description: string;
  web: FeatureStatus;
  mobile: FeatureStatus;
}

/**
 * Core feature capability matrix
 */
export const CAPABILITIES: Record<string, FeatureCapability> = {
  // Authentication features
  'auth.signup': {
    id: 'auth.signup',
    name: 'User Signup',
    description: 'Create new account with email/password',
    web: 'required',
    mobile: 'required',
  },
  'auth.login': {
    id: 'auth.login',
    name: 'User Login',
    description: 'Authenticate with email/password',
    web: 'required',
    mobile: 'required',
  },
  'auth.logout': {
    id: 'auth.logout',
    name: 'User Logout',
    description: 'Sign out and clear session',
    web: 'required',
    mobile: 'required',
  },
  'auth.token-refresh': {
    id: 'auth.token-refresh',
    name: 'Token Refresh',
    description: 'Automatic JWT token refresh',
    web: 'required',
    mobile: 'required',
  },

  // Character features
  'character.create': {
    id: 'character.create',
    name: 'Character Creation',
    description: 'Create character with attribute allocation',
    web: 'required',
    mobile: 'required',
  },
  'character.view': {
    id: 'character.view',
    name: 'View Characters',
    description: 'List and view character details',
    web: 'required',
    mobile: 'required',
  },
  'character.edit': {
    id: 'character.edit',
    name: 'Edit Character',
    description: 'Update character name',
    web: 'optional',
    mobile: 'optional',
  },
  'character.attributes': {
    id: 'character.attributes',
    name: 'Attribute Allocation',
    description: '20-point attribute system (5 attributes, 1-10 each)',
    web: 'required',
    mobile: 'required',
  },

  // Ship features
  'ship.create': {
    id: 'ship.create',
    name: 'Ship Customization',
    description: 'Create ship with stat allocation',
    web: 'required',
    mobile: 'required',
  },
  'ship.view': {
    id: 'ship.view',
    name: 'View Ships',
    description: 'List and view ship details',
    web: 'required',
    mobile: 'required',
  },
  'ship.edit': {
    id: 'ship.edit',
    name: 'Edit Ship',
    description: 'Update ship name',
    web: 'optional',
    mobile: 'optional',
  },
  'ship.stats': {
    id: 'ship.stats',
    name: 'Stat Allocation',
    description: '30-point stat system (5 stats, 1-15 each)',
    web: 'required',
    mobile: 'required',
  },
  'ship.types': {
    id: 'ship.types',
    name: 'Ship Types',
    description: 'Scout, Fighter, Trader, Explorer with bonuses',
    web: 'required',
    mobile: 'required',
  },
  'ship.preview-3d': {
    id: 'ship.preview-3d',
    name: '3D Ship Preview',
    description: 'Interactive 3D ship model with Three.js',
    web: 'optional',
    mobile: 'not-applicable',
  },

  // Dashboard features
  'dashboard.characters': {
    id: 'dashboard.characters',
    name: 'Character Dashboard',
    description: 'Display all created characters',
    web: 'required',
    mobile: 'required',
  },
  'dashboard.ships': {
    id: 'dashboard.ships',
    name: 'Ship Dashboard',
    description: 'Display all customized ships',
    web: 'required',
    mobile: 'required',
  },

  // Future features (not yet implemented)
  'navigation.space': {
    id: 'navigation.space',
    name: 'Space Navigation',
    description: 'Navigate between sectors',
    web: 'optional',
    mobile: 'optional',
  },
  'combat.system': {
    id: 'combat.system',
    name: 'Combat System',
    description: 'Real-time ship combat',
    web: 'optional',
    mobile: 'optional',
  },
  'trading.market': {
    id: 'trading.market',
    name: 'Trading System',
    description: 'Buy/sell goods at stations',
    web: 'optional',
    mobile: 'optional',
  },
  'social.chat': {
    id: 'social.chat',
    name: 'Chat System',
    description: 'Real-time chat with other players',
    web: 'optional',
    mobile: 'optional',
  },
};

/**
 * Get all required features for a platform
 */
export function getRequiredFeatures(platform: Platform): FeatureCapability[] {
  return Object.values(CAPABILITIES).filter(
    (cap) => cap[platform] === 'required'
  );
}

/**
 * Get all optional features for a platform
 */
export function getOptionalFeatures(platform: Platform): FeatureCapability[] {
  return Object.values(CAPABILITIES).filter(
    (cap) => cap[platform] === 'optional'
  );
}

/**
 * Check if a feature is required for a platform
 */
export function isFeatureRequired(
  featureId: string,
  platform: Platform
): boolean {
  const capability = CAPABILITIES[featureId];
  return capability ? capability[platform] === 'required' : false;
}

/**
 * Get features that differ between platforms
 */
export function getPlatformDifferences(): FeatureCapability[] {
  return Object.values(CAPABILITIES).filter(
    (cap) => cap.web !== cap.mobile
  );
}
