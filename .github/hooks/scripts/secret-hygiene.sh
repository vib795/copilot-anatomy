#!/usr/bin/env bash
# =============================================================================
# secret-hygiene.sh — Detect secrets in code and configuration
# =============================================================================
# Scans for hardcoded secrets, API keys in environment variables,
# secrets in Dockerfile ENV/ARG, and unencrypted secret references.
#
# MODE: warn-only (exit 0 with annotations). Transition to blocking when
#       false-positive rate drops below 5% over 50 consecutive runs.
#
# USAGE: bash .github/hooks/scripts/secret-hygiene.sh
# EXIT:  0 (warn-only mode)
# =============================================================================
set -euo pipefail

MODE="warn-only"
FINDINGS=0

report() {
  local label="$1"
  local match="$2"
  echo "WARN: Secret hygiene issue '$label': $match"
  FINDINGS=$((FINDINGS + 1))
}

echo "── Policy check: secret hygiene (${MODE}) ──"

# Dockerfile secrets in ENV or ARG
echo "  Checking Dockerfiles for secrets in ENV/ARG..."
while IFS= read -r match; do
  report "Secret in Dockerfile ENV/ARG" "$match"
done < <(grep -rnE '^(ENV|ARG)\s+(PASSWORD|SECRET|TOKEN|API_KEY|APIKEY|PRIVATE_KEY|AWS_SECRET)' \
  --include="Dockerfile" --include="Dockerfile.*" \
  --exclude-dir=".git" \
  . 2>/dev/null || true)

# Hardcoded high-entropy strings that look like API keys/tokens
echo "  Checking for hardcoded API key patterns..."
while IFS= read -r match; do
  report "Hardcoded API key pattern" "$match"
done < <(grep -rnE '(api_key|apikey|api-key|secret_key|access_token)\s*[=:]\s*["\x27][A-Za-z0-9+/=]{20,}["\x27]' \
  --include="*.java" --include="*.go" --include="*.py" --include="*.ts" \
  --include="*.yaml" --include="*.yml" --include="*.properties" --include="*.env" \
  --exclude-dir=".git" --exclude-dir="vendor" --exclude-dir="node_modules" \
  . 2>/dev/null || true)

# Private keys committed to repo
echo "  Checking for private key files..."
while IFS= read -r match; do
  report "Private key marker" "$match"
done < <(grep -rnl 'BEGIN.*PRIVATE KEY' \
  --exclude-dir=".git" --exclude-dir="vendor" --exclude-dir="node_modules" \
  . 2>/dev/null | grep -v '.github/hooks/scripts/' || true)

# .env files with actual values (not references)
echo "  Checking .env files for hardcoded values..."
for f in $(find . -name ".env" -o -name ".env.*" -not -name ".env.example" \
  -not -path "./.git/*" 2>/dev/null); do
  if grep -qE '^[A-Z_]+=.{8,}' "$f" 2>/dev/null; then
    if ! grep -qE '^\s*#|^\s*$|\$\{' "$f" 2>/dev/null; then
      report ".env file with hardcoded values" "$f"
    fi
  fi
done

# Helm values.yaml with secret-looking fields
echo "  Checking Helm values for inline secrets..."
while IFS= read -r match; do
  report "Secret in values.yaml" "$match"
done < <(grep -rnE '(password|secret|token|apiKey):\s*["\x27]?[A-Za-z0-9]{8,}' \
  --include="values.yaml" --include="values.yml" \
  --exclude-dir=".git" \
  . 2>/dev/null || true)

if [[ $FINDINGS -gt 0 ]]; then
  echo ""
  echo "::notice title=policy-check::check=secret-hygiene mode=${MODE} findings=${FINDINGS}"
  echo "WARN: ${FINDINGS} secret hygiene issue(s) detected (${MODE} — not blocking)"
else
  echo ""
  echo "PASS: No secret hygiene issues detected"
fi

# Warn-only: always exit 0
exit 0
