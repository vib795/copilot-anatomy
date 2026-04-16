---
date: 2026-04-15
topic: copilot-setup-modernization
source_requirements: docs/brainstorms/2026-04-15-copilot-setup-modernization-requirements.md
---

# Copilot Setup Modernization Plan

## Planning Basis

This plan implements the requirements in docs/brainstorms/2026-04-15-copilot-setup-modernization-requirements.md.

## Workstreams and Order

1. Discovery Gate (timeboxed)

- Resolve deferred planning research for R2 (evaluation harness shape), R5 (MCP profile mapping), and R6 (false-positive thresholds).
- Record decisions in enforceable repository artifacts.

2. Phase 1 Foundation (R1-R4)

- Manifest and drift control.
- Hybrid evaluation gates in CI.
- Model compatibility matrix and fallback policy enforcement.
- Release-level Copilot asset changelog discipline.

3. Phase 2 Governance Hardening (R5-R7)

- Least-privilege MCP profiles with default read-only posture.
- High-risk policy checks with warn-only burn-in and controlled transition to blocking.
- Governance checklist enforcement in planning/execution workflows.

4. Phase 3 DX and Maintenance Scale (R8-R12)

- Guided onboarding and role-based quick starts.
- Prompt/skill/agent discoverability improvements.
- Health artifact dual output (JSON canonical, Markdown summary).
- Documentation consistency checks and deprecation lifecycle operations.

5. Phase Exit and Pivot Controls

- Advance only when linked success criteria are met.
- Pivot/reorder if criteria are missed in two consecutive iterations or merge-time overhead regresses.

## File-Level Change Plan

- .atv/install-manifest.json
- copilot-setup.sh
- .github/workflows/copilot-setup-steps.yml
- .github/copilot-setup-steps.yml
- .vscode/settings.json
- .github/copilot-mcp-config.json
- .vscode/mcp.json
- .github/workflows/copilot-hooks.yml
- .github/hooks/copilot-hooks.json
- .github/hooks/scripts/observe.js
- .github/skills/ce-plan/SKILL.md
- .github/skills/ce-work/SKILL.md
- .github/skills/setup/SKILL.md
- COPILOT-CHEATSHEET.md
- .github/copilot-instructions.md
- .copilotignore

## Validation Strategy

1. Foundation validation

- Manifest schema and ownership/boundary checks.
- Deterministic and rubric evaluation gate checks with bounded retries.
- Compatibility matrix lint and fallback-policy validation.

2. Governance validation

- MCP profile diffs: read-only baseline and controlled elevation deltas.
- Policy checks for destructive commands, broad cloud permissions, and secret hygiene.
- Warn-only vs blocking mode transition validation with false-positive thresholds.

3. DX and maintenance validation

- Onboarding prerequisite and quick-start validation.
- Discoverability checks for representative tasks.
- Consistency checker for duplicated/conflicting guidance.
- Deprecation grace-period enforcement checks.

4. End-to-end validation

- Full CI path for setup/eval/compatibility.
- Full hook path in warn-only and blocking simulations.
- Setup-to-health-artifact generation flow.

## Risks and Mitigations

- Over-gating slows adoption: mitigate with phased warn-only rollout and threshold-based block transitions.
- Manifest drift persists: mitigate with explicit generated-vs-committed boundaries and CI drift checks.
- Model outages break workflows: mitigate with fail-closed gated paths and controlled advisory fallback reporting.
- Governance becomes ceremony: mitigate with metadata checks and CI-enforced checklist requirements.
- Documentation drift returns: mitigate with designated canonical owners and consistency checks.

## /ce-work Handoff Checklist

1. Create a dedicated modernization branch.
2. Execute Discovery Gate decisions for R2, R5, and R6.
3. Implement Phase 1 and pass phase-specific checks.
4. Implement Phase 2 in warn-only mode first.
5. Promote eligible checks to blocking after threshold criteria are met.
6. Implement Phase 3 onboarding/discoverability/consistency/deprecation work.
7. Run end-to-end acceptance against requirements success criteria.
8. Prepare release-level Copilot asset changelog entries.
9. Run final review and resolve blockers before merge.
