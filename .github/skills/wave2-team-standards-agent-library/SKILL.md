---
name: wave2-team-standards-agent-library
description: >
  Wave 2 curriculum lab (weeks 3-4, days 5-6). Use when a team collaboratively
  defines AI standards: naming conventions, a shared agent catalog, prompt
  review process, and quality gates for AI-generated output. Keywords: team
  standards, shared agent library, agent catalog, quality gates, review process.
license: MIT
---

# Wave 2 Lab 8 — Team Standards & Shared Agent Library

**Module:** Delivery Integration & Reusable Assets (Weeks 3–4)
**Days:** 5–6 · **Format:** Shared

## Outcome

Collaboratively define team-level AI standards: naming conventions, shared
agent catalog, prompt review process, quality gates for AI-generated output.

## Repo assets used

| Asset | Path | Role in this lab |
|-------|------|------------------|
| Governance model | `.github/GOVERNANCE.md` | Reference standard to adapt, not adopt blindly |
| Manifest | `.github/copilot-asset-manifest.json` | Catalog structure: ownership + classification taxonomy |
| Naming check | `.github/eval/checks/naming.sh` | Executable naming convention |
| Frontmatter check | `.github/eval/checks/frontmatter.sh` | Executable metadata standard |
| Deprecation check | `.github/eval/checks/deprecation.sh` | Lifecycle: 60-day grace period pattern |
| Changelog | `COPILOT-CHANGELOG.md` | Change-communication standard |

## Lab steps

1. **Inventory.** Pool the accelerators everyone built in Lab 7. Deduplicate:
   where two people built the same thing, pick one and record why.
2. **Naming convention.** Agree on prefixes/structure for team assets (this
   repo uses kebab-case + double extensions, enforced by `naming.sh`). Write
   the rule down as a check script, not a wiki page — executable standards
   don't rot.
3. **Catalog with ownership.** Build your team's manifest: every shared asset
   gets an owner and a classification. Unowned assets are deleted, not "shared".
4. **Prompt/agent review process.** Define what review a new asset needs before
   entering the catalog. Minimum: a second person runs it cold; eval checks
   pass; changelog entry written.
5. **Quality gates for AI output.** Decide what AI-generated work products
   require before merge/delivery — e.g. human review of generated tests,
   impact log entry, policy-script scan (Lab 3 guardrails).

## Exit criteria

- A deduplicated team agent catalog with named owners
- Naming + metadata conventions captured as runnable checks
- A one-page asset review process and output quality gates the team agreed to
