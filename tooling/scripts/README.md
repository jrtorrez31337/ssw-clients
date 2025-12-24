# SSW Clients - Tooling Scripts

Utility scripts for monorepo maintenance.

## Available Scripts

### `check-drift.sh`

Checks for code drift by scanning app directories for code that should be in shared packages.

**Usage:**
```bash
./tooling/scripts/check-drift.sh
```

**What it checks:**
- Duplicate type definitions (should be in `@ssw/contracts`)
- Duplicate domain logic (should be in `@ssw/domain`)
- Duplicate API client code (should be in `@ssw/api`)

**Exit codes:**
- `0`: No drift detected
- `1`: Drift detected (fails CI)

## Adding New Scripts

Place new scripts in this directory and update this README.
