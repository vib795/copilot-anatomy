#!/usr/bin/env bash
# =============================================================================
# governance.sh — Validate governance metadata in the asset manifest
# =============================================================================
# Checks that every asset in copilot-asset-manifest.json has the required
# governance fields: owner, classification, and description.
#
# Also validates that:
#   - owner values reference a defined ownership entry
#   - classification values are one of: core, workflow, extension
#   - deprecated assets have deprecationDate and removalDate
#
# USAGE: bash .github/eval/checks/governance.sh [manifest-path]
# EXIT:  0 = all valid, 1 = governance issues found
# =============================================================================
set -euo pipefail

MANIFEST="${1:-.github/copilot-asset-manifest.json}"

if [[ ! -f "$MANIFEST" ]]; then
  echo "ERROR: Manifest not found at $MANIFEST"
  exit 1
fi

echo "── Checking governance metadata ──"

python3 -c "
import json, sys

with open('${MANIFEST}') as f:
    manifest = json.load(f)

valid_classifications = {'core', 'workflow', 'extension'}
valid_owners = set(manifest.get('ownership', {}).keys())
if not valid_owners:
    valid_owners = {'platform-team', 'security-team'}

errors = 0

for category, assets in manifest.get('assets', {}).items():
    for name, entry in assets.items():
        if not isinstance(entry, dict) or 'path' not in entry:
            continue
        path = entry['path']

        if 'owner' not in entry:
            print(f'FAIL: {path} — missing owner field')
            errors += 1
        elif entry['owner'] not in valid_owners:
            print(f'FAIL: {path} — owner \"{entry[\"owner\"]}\" not in ownership registry')
            errors += 1

        if 'classification' not in entry:
            print(f'FAIL: {path} — missing classification field')
            errors += 1
        elif entry['classification'] not in valid_classifications:
            print(f'FAIL: {path} — classification \"{entry[\"classification\"]}\" not valid (must be: core, workflow, extension)')
            errors += 1

        if 'description' not in entry:
            print(f'FAIL: {path} — missing description field')
            errors += 1

        if entry.get('deprecated') is True:
            if 'deprecationDate' not in entry:
                print(f'FAIL: {path} — deprecated but missing deprecationDate')
                errors += 1
            if 'removalDate' not in entry:
                print(f'FAIL: {path} — deprecated but missing removalDate')
                errors += 1

if errors > 0:
    print(f'\nFAIL: {errors} governance issue(s) detected')
    sys.exit(1)
else:
    print(f'\nPASS: All governance metadata is valid')
    sys.exit(0)
"
