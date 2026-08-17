#!/usr/bin/env bash
# =============================================================================
# policy-gate.sh — preToolUse policy gate (structured-decision contract)
# =============================================================================
# Copilot's preToolUse hook no longer relies on exit codes alone. A hook may
# emit a JSON decision on stdout to allow, deny, or escalate a pending tool
# call to the user:
#
#   {"permissionDecision": "allow"}
#   {"permissionDecision": "deny",  "permissionDecisionReason": "..."}
#   {"permissionDecision": "ask",   "permissionDecisionReason": "..."}
#
# This script runs the repo's three advisory policy checks and maps their
# findings onto that contract:
#
#   no findings  → allow  (silent, no interruption)
#   findings     → ask    (human decides; reason is surfaced in the UI)
#
# It deliberately never returns "deny" on its own. The underlying checks are
# heuristics — a false positive that hard-blocks an agent mid-task is worse
# than one that asks. Set COPILOT_POLICY_ESCALATE_TO=deny if your team wants a
# hard gate (recommended only once the checks are tuned on real traffic).
#
# NOTE: preToolUse command hooks fail CLOSED on error (except timeouts), so
# this script must exit 0 on every path it intends to permit.
#
# STDIN:  JSON hook payload (toolName, toolArgs, cwd, ...)
# STDOUT: a single JSON decision object
# DOCS:   https://docs.github.com/en/copilot/reference/hooks-reference
# =============================================================================
set -uo pipefail   # NOT -e: a failing check must not abort the decision

ESCALATE_TO="${COPILOT_POLICY_ESCALATE_TO:-ask}"   # ask | deny
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Consume stdin so the caller never blocks on a full pipe. The individual
# checks scan the working tree rather than the payload, so it is not forwarded.
_payload="$(cat 2>/dev/null || true)"
: "${_payload:=}"

findings=""

run_check() {
  local name="$1" script="$2" out=""
  [[ -f "$script" ]] || return 0
  out="$(bash "$script" 2>&1 || true)"
  if printf '%s' "$out" | grep -qE '^(WARN|FAIL):'; then
    findings+="${name}: $(printf '%s' "$out" | grep -E '^(WARN|FAIL):' | head -3 | tr '\n' '; ')"
  fi
}

run_check "destructive-commands" "${SCRIPT_DIR}/destructive-commands.sh"
run_check "broad-permissions"    "${SCRIPT_DIR}/broad-permissions.sh"
run_check "secret-hygiene"       "${SCRIPT_DIR}/secret-hygiene.sh"

# Emit the decision. jq is not assumed to be present, so the reason string is
# escaped by hand: backslashes first, then quotes, then tabs/newlines.
if [[ -n "$findings" ]]; then
  reason="$(printf '%s' "$findings" \
    | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/ /g' \
    | tr -d '\r' | tr '\n' ' ' | cut -c1-800)"
  printf '{"permissionDecision":"%s","permissionDecisionReason":"Repo policy checks flagged: %s"}\n' \
    "$ESCALATE_TO" "$reason"
else
  printf '{"permissionDecision":"allow"}\n'
fi

exit 0
