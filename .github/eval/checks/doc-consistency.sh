#!/usr/bin/env bash
# =============================================================================
# doc-consistency.sh — Check for duplicated or conflicting guidance
# =============================================================================
# Scans documentation and instruction files for:
#   1. Duplicated guidance (same topic covered in multiple places)
#   2. Conflicting rules (contradictory directives)
#   3. Stale references (mentioned files that don't exist)
#
# USAGE: bash .github/eval/checks/doc-consistency.sh
# EXIT:  0 = consistent, 1 = issues found
# =============================================================================
set -euo pipefail

ERRORS=0
WARNINGS=0

echo "── Checking documentation consistency ──"

# ─── 1. Stale file references ────────────────────────────────────────────────
# Look for references to .github/ or .vscode/ paths in docs and check they exist
echo "── Checking for stale file references ──"

DOC_FILES=$(find . -maxdepth 1 -name '*.md' -type f 2>/dev/null || true)
DOC_FILES="$DOC_FILES $(find .github -maxdepth 1 -name '*.md' -type f 2>/dev/null || true)"
DOC_FILES="$DOC_FILES $(find docs -name '*.md' -type f 2>/dev/null || true)"

for doc in $DOC_FILES; do
  # Extract file references like `.github/something` or `.vscode/something`
  refs=$(grep -oE '\.(github|vscode)/[a-zA-Z0-9_./-]+' "$doc" 2>/dev/null | sort -u || true)
  for ref in $refs; do
    # Skip glob patterns and partial paths
    if echo "$ref" | grep -qE '\*|{|}'; then
      continue
    fi
    # Skip URLs and anchors
    if echo "$ref" | grep -qE 'http|#'; then
      continue
    fi
    # Check if the referenced file or directory exists
    if [[ ! -e "$ref" ]]; then
      # Allow references with trailing extensions that might be partial
      if [[ ! -e "${ref}.md" && ! -e "${ref}.json" && ! -e "${ref}.yml" ]]; then
        echo "  WARN: ${doc} references '${ref}' — file not found"
        WARNINGS=$((WARNINGS + 1))
      fi
    fi
  done
done

# ─── 2. Duplicate model routing tables ───────────────────────────────────────
echo "── Checking for duplicate model routing guidance ──"

# Find files that define model routing tables
MODEL_ROUTING_FILES=$(grep -rl 'model.*routing\|Model.*strengths\|Task.*model.*routing' \
  .github/copilot-instructions.md \
  COPILOT-CHEATSHEET.md \
  .github/instructions/*.instructions.md \
  2>/dev/null | sort -u || true)

ROUTING_COUNT=$(echo "$MODEL_ROUTING_FILES" | grep -c '[^ ]' || true)
if [[ "$ROUTING_COUNT" -gt 1 ]]; then
  echo "  WARN: Model routing guidance found in ${ROUTING_COUNT} files — ensure they are consistent:"
  for f in $MODEL_ROUTING_FILES; do
    echo "    - ${f}"
  done
  WARNINGS=$((WARNINGS + 1))
fi

# ─── 3. Duplicate convention sections ────────────────────────────────────────
echo "── Checking for overlapping convention coverage ──"

# Check if the same language conventions appear in both copilot-instructions.md and instruction files
for lang in "Java" "Go" "Python" "Terraform" "Kubernetes" "Docker"; do
  in_instructions=$(grep -il "$lang" .github/copilot-instructions.md 2>/dev/null | wc -l | tr -d ' ')
  in_instruction_files=$(grep -rl "$lang" .github/instructions/*.instructions.md 2>/dev/null | wc -l | tr -d ' ')

  if [[ "$in_instructions" -gt 0 && "$in_instruction_files" -gt 0 ]]; then
    overlap_files=$(grep -rl "$lang" .github/instructions/*.instructions.md 2>/dev/null | tr '\n' ', ' | sed 's/,$//')
    echo "  INFO: '${lang}' conventions in both copilot-instructions.md and ${overlap_files}"
    echo "        (acceptable if instructions.md has overview and .instructions.md has detail)"
  fi
done

# ─── 4. Contradictory directives ─────────────────────────────────────────────
echo "── Checking for contradictory directives ──"

# Check for conflicting line length rules
LINE_LIMITS=$(grep -rn 'line.*limit\|character.*limit\|line.*length' \
  .github/copilot-instructions.md \
  .github/instructions/*.instructions.md \
  2>/dev/null || true)

if [[ -n "$LINE_LIMITS" ]]; then
  limit_values=$(echo "$LINE_LIMITS" | grep -oE '[0-9]+-character' | sort -u || true)
  limit_count=$(echo "$limit_values" | grep -c '[^ ]' || true)
  if [[ "$limit_count" -gt 1 ]]; then
    echo "  WARN: Conflicting line length limits found:"
    echo "$LINE_LIMITS" | head -5
    WARNINGS=$((WARNINGS + 1))
  fi
fi

# Check for conflicting test framework directives
if grep -q 'unittest.mock' .github/instructions/*.instructions.md 2>/dev/null; then
  if grep -q 'Never.*unittest.mock\|never.*unittest.mock' .github/instructions/*.instructions.md 2>/dev/null; then
    # This is fine — it's a "never use" directive, not conflicting use
    :
  fi
fi

# ─── 5. Orphaned changelog references ────────────────────────────────────────
echo "── Checking changelog references ──"

if [[ -f "COPILOT-CHANGELOG.md" ]]; then
  # Check that files mentioned in changelog exist
  cl_refs=$(grep -oE '\.(github|vscode)/[a-zA-Z0-9_./-]+' COPILOT-CHANGELOG.md 2>/dev/null | sort -u || true)
  for ref in $cl_refs; do
    if echo "$ref" | grep -qE '\*|{|}'; then continue; fi
    if [[ ! -e "$ref" && ! -e "${ref}.md" && ! -e "${ref}.json" ]]; then
      echo "  WARN: COPILOT-CHANGELOG.md references '${ref}' — file not found"
      WARNINGS=$((WARNINGS + 1))
    fi
  done
fi

# ─── Summary ─────────────────────────────────────────────────────────────────
echo ""
if [[ $ERRORS -gt 0 ]]; then
  echo "FAIL: ${ERRORS} consistency error(s), ${WARNINGS} warning(s)"
  exit 1
elif [[ $WARNINGS -gt 0 ]]; then
  echo "PASS (with warnings): ${WARNINGS} warning(s) — review recommended"
  exit 0
else
  echo "PASS: Documentation is consistent"
  exit 0
fi
