#!/usr/bin/env node
/**
 * Check capability matrix and report on platform parity
 */

import { CAPABILITIES, getRequiredFeatures, getPlatformDifferences } from './capabilities.js';

console.log('📊 SSW Clients - Feature Capability Matrix\n');

// Count features by status
const platforms = ['web', 'mobile'];
platforms.forEach((platform) => {
  const required = getRequiredFeatures(platform);
  const optional = Object.values(CAPABILITIES).filter(
    (cap) => cap[platform] === 'optional'
  );
  const notApplicable = Object.values(CAPABILITIES).filter(
    (cap) => cap[platform] === 'not-applicable'
  );

  console.log(`${platform.toUpperCase()}:`);
  console.log(`  ✓ Required: ${required.length}`);
  console.log(`  ○ Optional: ${optional.length}`);
  console.log(`  ✗ Not Applicable: ${notApplicable.length}`);
  console.log();
});

// Show platform differences
const differences = getPlatformDifferences();
if (differences.length > 0) {
  console.log('⚠️  Platform Differences:');
  differences.forEach((cap) => {
    console.log(`  - ${cap.name}:`);
    console.log(`      Web: ${cap.web}, Mobile: ${cap.mobile}`);
  });
  console.log();
}

// Show required features
console.log('✅ Required Features for Both Platforms:');
const requiredBoth = Object.values(CAPABILITIES).filter(
  (cap) => cap.web === 'required' && cap.mobile === 'required'
);
requiredBoth.forEach((cap) => {
  console.log(`  - ${cap.name}`);
});
console.log();

console.log(`Total features tracked: ${Object.keys(CAPABILITIES).length}`);
console.log('✅ Capability matrix check complete!');
