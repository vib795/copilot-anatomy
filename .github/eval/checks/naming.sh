#!/usr/bin/env bash
# =============================================================================
# naming.sh — Validate file naming conventions for Copilot assets
# =============================================================================
# Checks that Copilot asset files follow kebab-case naming conventions
# and use correct extensions.
#
# USAGE: bash .github/eval/checks/naming.sh
# EXIT:  0 = all valid, 1 = naming issues found
# =============================================================================
set -euo pipefail

ERRORS=0

echo "── Checking prompt naming ──"
for f in .github/prompts/*; do
  [[ -e "$f" ]] || continue
  base=$(basename "$f")
  if [[ ! "$base" =~ ^[a-z][a-z0-9-]*\.prompt\.md$ ]]; then
    echo "FAIL: $f — expected kebab-case.prompt.md (got: $base)"
    ERRORS=$((ERRORS + 1))
  fi
done

echo "── Checking agent naming ──"
for f in .github/agents/*; do
  [[ -e "$f" ]] || continue
  base=$(basename "$f")
  if [[ ! "$base" =~ ^[a-z][a-z0-9-]*\.agent\.md$ ]]; then
    echo "FAIL: $f — expected kebab-case.agent.md (got: $base)"
    ERRORS=$((ERRORS + 1))
  fi
done

echo "── Checking chatmode naming ──"
for f in .github/chatmodes/*; do
  [[ -e "$f" ]] || continue
  base=$(basename "$f")
  if [[ ! "$base" =~ ^[a-z][a-z0-9-]*\.chatmode\.md$ ]]; then
    echo "FAIL: $f — expected kebab-case.chatmode.md (got: $base)"
    ERRORS=$((ERRORS + 1))
  fi
done

echo "── Checking instruction naming ──"
for f in .github/instructions/*; do
  [[ -e "$f" ]] || continue
  base=$(basename "$f")
  if [[ ! "$base" =~ ^[a-z][a-z0-9-]*\.instructions\.md$ ]]; then
    echo "FAIL: $f — expected kebab-case.instructions.md (got: $base)"
    ERRORS=$((ERRORS + 1))
  fi
done

echo "── Checking skill directory naming ──"
for d in .github/skills/*/; do
  [[ -d "$d" ]] || continue
  base=$(basename "$d")
  if [[ ! "$base" =~ ^[a-z][a-z0-9_-]*$ ]]; then
    echo "FAIL: $d — expected kebab-case directory name (got: $base)"
    ERRORS=$((ERRORS + 1))
  fi
  if [[ ! -f "${d}SKILL.md" ]]; then
    echo "FAIL: $d — missing SKILL.md"
    ERRORS=$((ERRORS + 1))
  fi
done

if [[ $ERRORS -gt 0 ]]; then
  echo ""
  echo "FAIL: $ERRORS naming issue(s) detected"
  exit 1
else
  echo ""
  echo "PASS: All naming conventions followed"
  exit 0
fi
