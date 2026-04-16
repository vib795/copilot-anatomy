#!/usr/bin/env bash
# =============================================================================
# broad-permissions.sh — Detect overly broad cloud permission patterns
# =============================================================================
# Scans for wildcard IAM policies, admin-level roles, and unrestricted
# security group rules that violate least-privilege principles.
#
# MODE: warn-only (exit 0 with annotations). Transition to blocking when
#       false-positive rate drops below 3% over 50 consecutive runs.
#
# USAGE: bash .github/hooks/scripts/broad-permissions.sh
# EXIT:  0 (warn-only mode)
# =============================================================================
set -euo pipefail

MODE="warn-only"
FINDINGS=0

report() {
  local label="$1"
  local match="$2"
  echo "WARN: Broad permission '$label' found: $match"
  FINDINGS=$((FINDINGS + 1))
}

echo "── Policy check: broad cloud permissions (${MODE}) ──"

# AWS IAM wildcard actions
echo "  Checking AWS IAM wildcards..."
while IFS= read -r match; do
  report "IAM wildcard action (*)" "$match"
done < <(grep -rnE '"Action"\s*:\s*"\*"' \
  --include="*.json" --include="*.tf" --include="*.yaml" --include="*.yml" \
  --exclude-dir=".git" --exclude-dir="node_modules" --exclude-dir="vendor" \
  . 2>/dev/null || true)

# AWS IAM wildcard resources
while IFS= read -r match; do
  report "IAM wildcard resource (*)" "$match"
done < <(grep -rnE '"Resource"\s*:\s*"\*"' \
  --include="*.json" --include="*.tf" --include="*.yaml" --include="*.yml" \
  --exclude-dir=".git" --exclude-dir="node_modules" --exclude-dir="vendor" \
  . 2>/dev/null || true)

# Terraform admin-level policies
echo "  Checking Terraform admin policies..."
while IFS= read -r match; do
  report "Terraform admin policy" "$match"
done < <(grep -rnE 'arn:aws:iam::.*:policy/(AdministratorAccess|PowerUserAccess)' \
  --include="*.tf" --include="*.tfvars" \
  --exclude-dir=".git" --exclude-dir=".terraform" \
  . 2>/dev/null || true)

# Azure contributor/owner at subscription scope
echo "  Checking Azure broad roles..."
while IFS= read -r match; do
  report "Azure broad role assignment" "$match"
done < <(grep -rnE '(Contributor|Owner).*subscription' \
  --include="*.tf" --include="*.bicep" --include="*.json" \
  --exclude-dir=".git" --exclude-dir="node_modules" \
  --exclude="copilot-mcp-profiles.json" \
  --exclude="copilot-asset-manifest.json" \
  --exclude="model-compatibility.json" \
  . 2>/dev/null || true)

# Unrestricted security group ingress (0.0.0.0/0 on sensitive ports)
echo "  Checking unrestricted security groups..."
while IFS= read -r match; do
  report "Unrestricted ingress (0.0.0.0/0)" "$match"
done < <(grep -rnE 'cidr_blocks\s*=\s*\[.*"0\.0\.0\.0/0"' \
  --include="*.tf" \
  --exclude-dir=".git" --exclude-dir=".terraform" \
  . 2>/dev/null || true)

if [[ $FINDINGS -gt 0 ]]; then
  echo ""
  echo "::notice title=policy-check::check=broad-permissions mode=${MODE} findings=${FINDINGS}"
  echo "WARN: ${FINDINGS} broad permission pattern(s) detected (${MODE} — not blocking)"
else
  echo ""
  echo "PASS: No broad permission patterns detected"
fi

# Warn-only: always exit 0
exit 0
