---
name: wave2-guardrails-error-recovery
description: >
  Wave 2 curriculum lab (weeks 1-2, days 5-6). Use when learning to build agents
  with explicit guardrails, fallback behaviors, validation checkpoints, and error
  recovery so they are reliable enough for production use. Keywords: guardrails,
  error recovery, validation checkpoints, fallback, hooks, policy checks, reliability.
license: MIT
---

# Wave 2 Lab 3 — Agent Guardrails & Error Recovery

**Module:** Advanced Agent Building & Multi-Step Workflows (Weeks 1–2)
**Days:** 5–6 · **Format:** Shared

## Outcome

Build agents with explicit guardrails, fallback behaviors, and validation
checkpoints. Make agents reliable enough for production use, not just demos.

## Repo assets used

| Asset | Path | Role in this lab |
|-------|------|------------------|
| Hook config | `.github/hooks/copilot-hooks.json` | `preToolUse` blocking = hard guardrail |
| Policy: destructive commands | `.github/hooks/scripts/destructive-commands.sh` | Scans for `rm -rf`, `DROP TABLE`, force-push |
| Policy: broad permissions | `.github/hooks/scripts/broad-permissions.sh` | Catches IAM wildcards, admin policies |
| Policy: secret hygiene | `.github/hooks/scripts/secret-hygiene.sh` | Catches keys/secrets in generated output |
| MCP profiles | `.github/copilot-mcp-profiles.json` | Least-privilege tiers: read-only → standard → elevated |
| Eval checks | `.github/eval/checks/*.sh` | Deterministic validation checkpoints |

## Lab steps

1. **Map the guardrail layers.** Read `copilot-hooks.json` and trace how a
   `preToolUse` hook with non-zero exit blocks the pending tool call. This is
   prevention; the eval checks are detection.
2. **Trip a guardrail on purpose.** Ask an agent to generate a script containing
   `rm -rf` and watch `destructive-commands.sh` flag it. Document the failure mode.
3. **Add a validation checkpoint.** Write a small check script (style:
   `set -euo pipefail`, exit non-zero on failure) that validates one property of
   your Lab 1 chain's output — e.g. "every story has at least one acceptance
   criterion."
4. **Design fallbacks.** For each link in your Lab 1 chain, write the fallback
   rule: on validation failure, does the agent retry with the error appended,
   hand back to the previous link, or stop and ask a human?
5. **Right-size privileges.** Decide which MCP profile your chain actually needs.
   Default is read-only; justify any escalation in writing, per the repo's
   security posture.

## Exit criteria

- One new validation checkpoint script wired into your chain
- A written fallback rule per chain link (retry / hand back / escalate to human)
- Your chain's MCP profile documented with justification
