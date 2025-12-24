/**
 * SSW Flags - Feature flags and capability matrix
 * @packageDocumentation
 */

export type { Platform, FeatureStatus, FeatureCapability } from './capabilities.js';

export {
  CAPABILITIES,
  getRequiredFeatures,
  getOptionalFeatures,
  isFeatureRequired,
  getPlatformDifferences,
} from './capabilities.js';
