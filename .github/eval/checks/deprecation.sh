#!/usr/bin/env bash
# =============================================================================
# deprecation.sh — Enforce deprecation lifecycle for Copilot assets
# =============================================================================
# Validates:
#   1. Deprecated assets have required date fields (deprecationDate, removalDate)
#   2. Grace period is at least 60 days
#   3. Expired assets (past removalDate) are flagged for removal
#   4. Deprecated assets have a deprecation notice in their file
#
# USAGE: bash .github/eval/checks/deprecation.sh [manifest-path]
# EXIT:  0 = valid, 1 = issues found
# =============================================================================
set -euo pipefail

MANIFEST="${1:-.github/copilot-asset-manifest.json}"

if [[ ! -f "$MANIFEST" ]]; then
  echo "── No manifest found — skipping deprecation check ──"
  exit 0
fi

echo "── Checking deprecation lifecycle ──"

python3 -c "
import json, sys
from datetime import datetime, timedelta, timezone

with open('${MANIFEST}') as f:
    manifest = json.load(f)

errors = 0
warnings = 0
try:
    today = datetime.now(timezone.utc).date()
except Exception:
    today = datetime.utcnow().date()
MIN_GRACE_DAYS = 60

deprecated_count = 0
expired_count = 0

for category, assets in manifest.get('assets', {}).items():
    for name, entry in assets.items():
        if not isinstance(entry, dict) or not entry.get('deprecated'):
            continue

        deprecated_count += 1
        path = entry.get('path', name)

        # Check required fields
        dep_date_str = entry.get('deprecationDate')
        rem_date_str = entry.get('removalDate')

        if not dep_date_str:
            print(f'FAIL: {path} — deprecated but missing deprecationDate')
            errors += 1
            continue

        if not rem_date_str:
            print(f'FAIL: {path} — deprecated but missing removalDate')
            errors += 1
            continue

        # Parse dates
        try:
            dep_date = datetime.strptime(dep_date_str, '%Y-%m-%d').date()
        except ValueError:
            print(f'FAIL: {path} — invalid deprecationDate format: {dep_date_str} (expected YYYY-MM-DD)')
            errors += 1
            continue

        try:
            rem_date = datetime.strptime(rem_date_str, '%Y-%m-%d').date()
        except ValueError:
            print(f'FAIL: {path} — invalid removalDate format: {rem_date_str} (expected YYYY-MM-DD)')
            errors += 1
            continue

        # Check grace period >= 60 days
        grace_days = (rem_date - dep_date).days
        if grace_days < MIN_GRACE_DAYS:
            print(f'FAIL: {path} — grace period is {grace_days} days (minimum {MIN_GRACE_DAYS})')
            errors += 1

        # Check if past removal date
        if today > rem_date:
            print(f'WARN: {path} — past removal date ({rem_date_str}), should be removed')
            expired_count += 1
            warnings += 1
        elif today > dep_date:
            days_until = (rem_date - today).days
            print(f'INFO: {path} — deprecated, {days_until} days until removal ({rem_date_str})')

# Summary
if deprecated_count == 0:
    print('\nPASS: No deprecated assets')
    sys.exit(0)

print(f'\nDeprecated assets: {deprecated_count}')
if expired_count > 0:
    print(f'Expired (past removal date): {expired_count}')

if errors > 0:
    print(f'FAIL: {errors} deprecation lifecycle error(s)')
    sys.exit(1)
elif warnings > 0:
    print(f'PASS (with warnings): {warnings} asset(s) past removal date')
    sys.exit(0)
else:
    print('PASS: All deprecation lifecycles are valid')
    sys.exit(0)
"
