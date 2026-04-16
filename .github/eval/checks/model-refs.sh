#!/usr/bin/env bash
# =============================================================================
# model-refs.sh — Validate model references against compatibility matrix
# =============================================================================
# Checks that every model: field in prompts, agents, and chatmodes references
# a model listed in the compatibility matrix.
#
# USAGE: bash .github/eval/checks/model-refs.sh [matrix-path]
# EXIT:  0 = all valid, 1 = invalid model references found
# =============================================================================
set -euo pipefail

MATRIX="${1:-.github/model-compatibility.json}"
ERRORS=0

if [[ ! -f "$MATRIX" ]]; then
  echo "ERROR: Model compatibility matrix not found at $MATRIX"
  echo "Create it first or pass the correct path."
  exit 1
fi

# Extract valid model names from the matrix
VALID_MODELS=$(awk -F'"' '/"name"/ {print $4}' "$MATRIX" | sort -u)

check_model_ref() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    return
  fi

  # Extract model field from YAML frontmatter (multi-line format)
  local model
  model=$(sed -n '/^---$/,/^---$/p' "$file" | awk -F: '/^model\s*:/ {gsub(/[ "'"'"']/, "", $2); print $2; exit}')

  # Fallback: single-line frontmatter format
  if [[ -z "$model" ]]; then
    model=$(awk '{
      if (match($0, /^---[^-].*---/)) {
        s = substr($0, 4)
        idx = index(s, "---")
        if (idx > 0) {
          fm = substr(s, 1, idx - 1)
          n = split(fm, parts, "model:")
          if (n > 1) {
            val = parts[2]
            sub(/[[:space:]]*/, "", val)
            sub(/[^a-zA-Z0-9._-].*/, "", val)
            print val
          }
        }
      }
    }' "$file")
  fi

  if [[ -z "$model" ]]; then
    return  # No model field — acceptable (uses picker default)
  fi

  if ! echo "$VALID_MODELS" | grep -qx "$model"; then
    echo "FAIL: $file — model '$model' not in compatibility matrix"
    ERRORS=$((ERRORS + 1))
  fi
}

echo "── Checking prompt model references ──"
for f in .github/prompts/*.prompt.md; do
  [[ -e "$f" ]] || continue
  check_model_ref "$f"
done

echo "── Checking agent model references ──"
for f in .github/agents/*.agent.md; do
  [[ -e "$f" ]] || continue
  check_model_ref "$f"
done

echo "── Checking chatmode model references ──"
for f in .github/chatmodes/*.chatmode.md; do
  [[ -e "$f" ]] || continue
  check_model_ref "$f"
done

if [[ $ERRORS -gt 0 ]]; then
  echo ""
  echo "FAIL: $ERRORS invalid model reference(s) found"
  exit 1
else
  echo ""
  echo "PASS: All model references are valid"
  exit 0
fi
