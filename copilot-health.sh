#!/usr/bin/env bash
# =============================================================================
# copilot-health.sh — Generate Copilot asset health dashboard
# =============================================================================
# Produces dual output:
#   1. JSON canonical report (machine-readable) → .github/health-report.json
#   2. Markdown summary (human-readable) → .github/HEALTH.md
#
# USAGE:  bash copilot-health.sh [--json-only | --md-only]
# =============================================================================
set -euo pipefail

JSON_ONLY=false
MD_ONLY=false
JSON_OUT=".github/health-report.json"
MD_OUT=".github/HEALTH.md"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json-only) JSON_ONLY=true; shift ;;
    --md-only)   MD_ONLY=true; shift ;;
    -h|--help)   echo "Usage: bash copilot-health.sh [--json-only | --md-only]"; exit 0 ;;
    *)           echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ─── Gather counts ───────────────────────────────────────────────────────────
PROMPT_COUNT=$(find .github/prompts -name '*.prompt.md' 2>/dev/null | wc -l | tr -d ' ')
AGENT_COUNT=$(find .github/agents -name '*.agent.md' 2>/dev/null | wc -l | tr -d ' ')
SKILL_COUNT=$(find .github/skills -name 'SKILL.md' 2>/dev/null | wc -l | tr -d ' ')
CHATMODE_COUNT=$(find .github/chatmodes -name '*.chatmode.md' 2>/dev/null | wc -l | tr -d ' ')
INSTRUCTION_COUNT=$(find .github/instructions -name '*.instructions.md' 2>/dev/null | wc -l | tr -d ' ')
TOTAL_ASSETS=$((PROMPT_COUNT + AGENT_COUNT + SKILL_COUNT + CHATMODE_COUNT + INSTRUCTION_COUNT))

# ─── Run eval checks ─────────────────────────────────────────────────────────
CHECKS=()
CHECK_NAMES=(naming frontmatter model-refs manifest-sync governance doc-consistency deprecation)
PASS_COUNT=0
FAIL_COUNT=0

for check in "${CHECK_NAMES[@]}"; do
  script=".github/eval/checks/${check}.sh"
  if [[ -f "$script" ]]; then
    if bash "$script" > /dev/null 2>&1; then
      CHECKS+=("${check}:pass")
      PASS_COUNT=$((PASS_COUNT + 1))
    else
      CHECKS+=("${check}:fail")
      FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
  else
    CHECKS+=("${check}:missing")
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
done

TOTAL_CHECKS=${#CHECK_NAMES[@]}

# ─── Run policy checks ───────────────────────────────────────────────────────
POLICY_NAMES=(destructive-commands broad-permissions secret-hygiene)
POLICY_RESULTS=()
POLICY_WARNINGS=0

for policy in "${POLICY_NAMES[@]}"; do
  script=".github/hooks/scripts/${policy}.sh"
  if [[ -f "$script" ]]; then
    output=$(bash "$script" 2>&1 || true)
    warning_count=$(echo "$output" | grep -c "WARN:" || true)
    POLICY_RESULTS+=("${policy}:${warning_count}")
    POLICY_WARNINGS=$((POLICY_WARNINGS + warning_count))
  else
    POLICY_RESULTS+=("${policy}:missing")
  fi
done

# ─── Check key files ─────────────────────────────────────────────────────────
has_manifest=$([[ -f ".github/copilot-asset-manifest.json" ]] && echo "true" || echo "false")
has_model_matrix=$([[ -f ".github/model-compatibility.json" ]] && echo "true" || echo "false")
has_mcp_profiles=$([[ -f ".github/copilot-mcp-profiles.json" ]] && echo "true" || echo "false")
has_governance=$([[ -f ".github/GOVERNANCE.md" ]] && echo "true" || echo "false")
has_changelog=$([[ -f "COPILOT-CHANGELOG.md" ]] && echo "true" || echo "false")

# ─── Check for deprecated assets ─────────────────────────────────────────────
DEPRECATED_COUNT=0
if [[ -f ".github/copilot-asset-manifest.json" ]]; then
  DEPRECATED_COUNT=$(python3 -c "
import json
with open('.github/copilot-asset-manifest.json') as f:
    m = json.load(f)
count = 0
for cat, assets in m.get('assets', {}).items():
    for name, entry in assets.items():
        if isinstance(entry, dict) and entry.get('deprecated'):
            count += 1
print(count)
" 2>/dev/null || echo "0")
fi

# ─── Timestamp ────────────────────────────────────────────────────────────────
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Health score: percentage of checks passing
if [[ $TOTAL_CHECKS -gt 0 ]]; then
  HEALTH_SCORE=$(( (PASS_COUNT * 100) / TOTAL_CHECKS ))
else
  HEALTH_SCORE=0
fi

# ─── Generate JSON ────────────────────────────────────────────────────────────
if ! $MD_ONLY; then
  # Build check results JSON
  CHECKS_JSON=""
  for entry in "${CHECKS[@]}"; do
    IFS=':' read -r name status <<< "$entry"
    if [[ -n "$CHECKS_JSON" ]]; then CHECKS_JSON="${CHECKS_JSON},"; fi
    CHECKS_JSON="${CHECKS_JSON}\"${name}\":\"${status}\""
  done

  # Build policy results JSON
  POLICY_JSON=""
  for entry in "${POLICY_RESULTS[@]}"; do
    IFS=':' read -r name count <<< "$entry"
    if [[ -n "$POLICY_JSON" ]]; then POLICY_JSON="${POLICY_JSON},"; fi
    if [[ "$count" == "missing" ]]; then
      POLICY_JSON="${POLICY_JSON}\"${name}\":{\"status\":\"missing\"}"
    else
      POLICY_JSON="${POLICY_JSON}\"${name}\":{\"warnings\":${count}}"
    fi
  done

  cat > "$JSON_OUT" << ENDJSON
{
  "timestamp": "${TIMESTAMP}",
  "healthScore": ${HEALTH_SCORE},
  "assets": {
    "prompts": ${PROMPT_COUNT},
    "agents": ${AGENT_COUNT},
    "skills": ${SKILL_COUNT},
    "chatmodes": ${CHATMODE_COUNT},
    "instructions": ${INSTRUCTION_COUNT},
    "total": ${TOTAL_ASSETS},
    "deprecated": ${DEPRECATED_COUNT}
  },
  "evalChecks": {
    "passed": ${PASS_COUNT},
    "failed": ${FAIL_COUNT},
    "total": ${TOTAL_CHECKS},
    "results": {${CHECKS_JSON}}
  },
  "policyChecks": {
    "totalWarnings": ${POLICY_WARNINGS},
    "results": {${POLICY_JSON}}
  },
  "infrastructure": {
    "manifest": ${has_manifest},
    "modelMatrix": ${has_model_matrix},
    "mcpProfiles": ${has_mcp_profiles},
    "governance": ${has_governance},
    "changelog": ${has_changelog}
  }
}
ENDJSON

  echo "Generated: ${JSON_OUT}"
fi

# ─── Generate Markdown ────────────────────────────────────────────────────────
if ! $JSON_ONLY; then
  # Determine health badge
  if [[ $HEALTH_SCORE -eq 100 ]]; then
    BADGE="Healthy"
  elif [[ $HEALTH_SCORE -ge 80 ]]; then
    BADGE="Warning"
  else
    BADGE="Critical"
  fi

  cat > "$MD_OUT" << ENDMD
# Copilot Health Dashboard

> Generated: ${TIMESTAMP}
> Health Score: **${HEALTH_SCORE}%** (${BADGE})

## Asset Inventory

| Type | Count |
|------|-------|
| Prompts | ${PROMPT_COUNT} |
| Agents | ${AGENT_COUNT} |
| Skills | ${SKILL_COUNT} |
| Chat modes | ${CHATMODE_COUNT} |
| Instruction files | ${INSTRUCTION_COUNT} |
| **Total** | **${TOTAL_ASSETS}** |
| Deprecated | ${DEPRECATED_COUNT} |

## Eval Checks (${PASS_COUNT}/${TOTAL_CHECKS} passing)

| Check | Status |
|-------|--------|
ENDMD

  for entry in "${CHECKS[@]}"; do
    IFS=':' read -r name status <<< "$entry"
    if [[ "$status" == "pass" ]]; then
      echo "| ${name} | Pass |" >> "$MD_OUT"
    elif [[ "$status" == "fail" ]]; then
      echo "| ${name} | **FAIL** |" >> "$MD_OUT"
    else
      echo "| ${name} | Missing |" >> "$MD_OUT"
    fi
  done

  cat >> "$MD_OUT" << ENDMD

## Policy Checks (${POLICY_WARNINGS} warning(s))

| Policy | Warnings |
|--------|----------|
ENDMD

  for entry in "${POLICY_RESULTS[@]}"; do
    IFS=':' read -r name count <<< "$entry"
    if [[ "$count" == "missing" ]]; then
      echo "| ${name} | Missing |" >> "$MD_OUT"
    elif [[ "$count" -eq 0 ]]; then
      echo "| ${name} | 0 |" >> "$MD_OUT"
    else
      echo "| ${name} | ${count} |" >> "$MD_OUT"
    fi
  done

  cat >> "$MD_OUT" << ENDMD

## Infrastructure

| Component | Present |
|-----------|---------|
| Asset manifest | ${has_manifest} |
| Model compatibility matrix | ${has_model_matrix} |
| MCP profiles | ${has_mcp_profiles} |
| Governance checklist | ${has_governance} |
| Changelog | ${has_changelog} |
ENDMD

  echo "Generated: ${MD_OUT}"
fi
