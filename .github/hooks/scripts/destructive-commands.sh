#!/usr/bin/env bash
# =============================================================================
# destructive-commands.sh — Detect destructive command patterns
# =============================================================================
# Scans for patterns like rm -rf, DROP TABLE, git push --force, git reset --hard,
# kubectl delete namespace, etc.
#
# MODE: warn-only (exit 0 with annotations). Transition to blocking when
#       false-positive rate drops below 5% over 50 consecutive runs.
#
# USAGE: bash .github/hooks/scripts/destructive-commands.sh
# EXIT:  0 (warn-only mode)
# =============================================================================
set -euo pipefail

MODE="warn-only"
FINDINGS=0

# Labels and patterns as parallel arrays
LABELS=(
  "rm -rf /"
  "DROP TABLE/DATABASE"
  "git push --force"
  "git reset --hard"
  "kubectl delete namespace"
  "kubectl delete --all"
  "terraform destroy"
  "truncate table"
)
REGEXES=(
  'rm\s+-[a-zA-Z]*r[a-zA-Z]*f[a-zA-Z]*\s+/'
  'DROP\s+(TABLE|DATABASE)\s'
  'git\s+push\s+.*--force'
  'git\s+reset\s+--hard'
  'kubectl\s+delete\s+(namespace|ns)\s'
  'kubectl\s+delete\s+.*--all'
  'terraform\s+destroy\s'
  'TRUNCATE\s+TABLE\s'
)

# File types to scan
INCLUDE_PATTERNS=(
  "*.sh" "*.bash" "*.zsh"
  "*.py" "*.go" "*.java"
  "*.yaml" "*.yml"
  "*.sql"
  "*.md"
  "Makefile" "Jenkinsfile" "Dockerfile"
)

scan_for_pattern() {
  local label="$1"
  local pattern="$2"

  for ext in "${INCLUDE_PATTERNS[@]}"; do
    while IFS= read -r match; do
      # Skip self-references (this script and its sibling scripts)
      case "$match" in ./.github/hooks/scripts/*) continue ;; esac
      echo "WARN: Destructive pattern '$label' found: $match"
      FINDINGS=$((FINDINGS + 1))
    done < <(grep -rnE "$pattern" --include="$ext" \
      --exclude-dir=".git" --exclude-dir="vendor" --exclude-dir="node_modules" \
      . 2>/dev/null || true)
  done
}

echo "── Policy check: destructive command patterns (${MODE}) ──"

for i in "${!LABELS[@]}"; do
  scan_for_pattern "${LABELS[$i]}" "${REGEXES[$i]}"
done

if [[ $FINDINGS -gt 0 ]]; then
  echo ""
  echo "::notice title=policy-check::check=destructive-commands mode=${MODE} findings=${FINDINGS}"
  echo "WARN: ${FINDINGS} destructive pattern(s) detected (${MODE} — not blocking)"
else
  echo ""
  echo "PASS: No destructive command patterns detected"
fi

# Warn-only: always exit 0
exit 0
