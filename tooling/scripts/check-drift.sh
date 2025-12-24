#!/bin/bash
# Check for code drift - ensure shared code hasn't been duplicated back into apps

set -e

echo "🔍 Checking for code drift..."

# Check for duplicate type definitions that should be in @ssw/contracts
echo "Checking for duplicate type definitions..."

# Patterns that indicate types that should be in contracts
FORBIDDEN_PATTERNS=(
  "interface CharacterAttributes"
  "interface Ship {"
  "interface AuthResponse"
  "type ShipType ="
  "interface ApiResponse"
)

DRIFT_FOUND=false

for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
  echo "  Searching for: $pattern"

  # Search in app directories (excluding node_modules)
  if grep -r "$pattern" apps/*/src apps/*/api 2>/dev/null | grep -v node_modules; then
    echo "  ⚠️  Found duplicate definition in app code!"
    DRIFT_FOUND=true
  fi
done

# Check for duplicate domain logic
echo ""
echo "Checking for duplicate domain logic..."

DOMAIN_PATTERNS=(
  "calculateAttributePoints"
  "calculateStatPoints"
  "SHIP_TYPE_BONUSES"
  "CHARACTER_CONSTANTS"
)

for pattern in "${DOMAIN_PATTERNS[@]}"; do
  echo "  Searching for: $pattern"

  if grep -r "$pattern" apps/*/src apps/*/api 2>/dev/null | grep -v "from '@ssw/" | grep -v node_modules; then
    echo "  ⚠️  Found duplicate domain logic in app code!"
    DRIFT_FOUND=true
  fi
done

echo ""
if [ "$DRIFT_FOUND" = true ]; then
  echo "❌ Code drift detected! Shared code found in app directories."
  echo "   Move duplicated code to appropriate shared packages:"
  echo "   - Types -> packages/contracts"
  echo "   - API client -> packages/api"
  echo "   - Game logic -> packages/domain"
  exit 1
else
  echo "✅ No code drift detected!"
  exit 0
fi
