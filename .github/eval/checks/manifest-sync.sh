#!/usr/bin/env bash
# =============================================================================
# manifest-sync.sh — Verify manifest ↔ filesystem consistency
# =============================================================================
# Checks that every path declared in copilot-asset-manifest.json exists on disk,
# and that no Copilot asset files exist on disk without a manifest entry.
#
# USAGE: bash .github/eval/checks/manifest-sync.sh [manifest-path]
# EXIT:  0 = in sync, 1 = drift detected
# =============================================================================
set -euo pipefail

MANIFEST="${1:-.github/copilot-asset-manifest.json}"
ERRORS=0

if [[ ! -f "$MANIFEST" ]]; then
  echo "ERROR: Manifest not found at $MANIFEST"
  exit 1
fi

echo "── Checking manifest → filesystem ──"
# Extract all "path" values from the manifest
paths=$(awk -F'"' '/"path"/ {print $4}' "$MANIFEST")

while IFS= read -r path; do
  if [[ ! -e "$path" ]]; then
    echo "DRIFT: Manifest declares '$path' but file does not exist"
    ERRORS=$((ERRORS + 1))
  fi
done <<< "$paths"

echo "── Checking filesystem → manifest ──"

# Check prompts
for f in .github/prompts/*.prompt.md; do
  [[ -e "$f" ]] || continue
  if ! grep -q "\"$f\"" "$MANIFEST"; then
    echo "DRIFT: File '$f' exists but is not in manifest"
    ERRORS=$((ERRORS + 1))
  fi
done

# Check instruction files
for f in .github/instructions/*.instructions.md; do
  [[ -e "$f" ]] || continue
  if ! grep -q "\"$f\"" "$MANIFEST"; then
    echo "DRIFT: File '$f' exists but is not in manifest"
    ERRORS=$((ERRORS + 1))
  fi
done

# Check chatmodes
for f in .github/chatmodes/*.chatmode.md; do
  [[ -e "$f" ]] || continue
  if ! grep -q "\"$f\"" "$MANIFEST"; then
    echo "DRIFT: File '$f' exists but is not in manifest"
    ERRORS=$((ERRORS + 1))
  fi
done

# Check core workflows
for f in .github/workflows/copilot-setup-steps.yml .github/workflows/copilot-hooks.yml; do
  [[ -e "$f" ]] || continue
  if ! grep -q "\"$f\"" "$MANIFEST"; then
    echo "DRIFT: File '$f' exists but is not in manifest"
    ERRORS=$((ERRORS + 1))
  fi
done

if [[ $ERRORS -gt 0 ]]; then
  echo ""
  echo "FAIL: $ERRORS drift issue(s) detected"
  exit 1
else
  echo ""
  echo "PASS: Manifest and filesystem are in sync"
  exit 0
fi
