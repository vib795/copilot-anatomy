---
name: wave2-reusable-accelerators
description: >
  Wave 2 curriculum lab (weeks 3-4, days 3-4). Use when converting your best
  prompts, agents, and instructions into shareable documented assets — template
  libraries, team-level copilot-instructions, shared agents — that pass this
  repo's governance checks. Keywords: reusable accelerators, asset authoring,
  template library, shareable agents, governance.
license: MIT
---

# Wave 2 Lab 7 — Building Reusable Accelerators

**Module:** Delivery Integration & Reusable Assets (Weeks 3–4)
**Days:** 3–4 · **Format:** Fully persona-specific

## Outcome

Convert your best prompts, agents, and instructions into shareable, documented
assets (template libraries, team-level copilot-instructions, shared agents).

## Repo assets used

| Asset | Path | Role in this lab |
|-------|------|------------------|
| Governance checklist | `.github/GOVERNANCE.md` | The bar an asset must clear to be shareable |
| Asset manifest | `.github/copilot-asset-manifest.json` | Every shared asset needs an entry (path, owner, classification, description) |
| Eval checks | `.github/eval/checks/naming.sh`, `frontmatter.sh`, `model-refs.sh`, `manifest-sync.sh` | The definition of "documented and consistent" |
| Changelog | `COPILOT-CHANGELOG.md` | Keep-a-Changelog entry under `[Unreleased]` |
| Model matrix | `.github/model-compatibility.json` | Any `model:` frontmatter must reference a defined slot |

## Lab steps (all personas)

1. **Pick your best artifact from Labs 1–6** — the chain, prompt, or context
   plan that saved the most time in your impact log.
2. **Choose the right primitive.** One-shot task → `*.prompt.md`. Multi-step
   runbook → `skills/<name>/SKILL.md`. Persona/behavior → `*.agent.md`.
   Always-on convention → `instructions/*.instructions.md` with an `applyTo:` glob.
3. **Generalize it.** Strip engagement-specific names; replace with
   placeholders and a "customize these" section. An accelerator nobody else
   can run is a diary entry.
4. **Make discovery work.** Write the `description:` field as natural-language
   search keywords — it is the only thing auto-discovery sees.
5. **Clear governance.** Add the manifest entry and changelog line; run the
   four eval checks locally until green.

## Persona tracks

- **BA:** [ba-track.md](ba-track.md) — story/criteria chain → shared agent + template library
- **Dev:** [dev-track.md](dev-track.md) — conventions → scoped instructions; chain → shared agents
- **QA:** [qa-track.md](qa-track.md) — test design chain → shared skill with charter templates

## Exit criteria

- One asset generalized, documented, manifest-registered, and changelog-logged
- All eval checks pass locally
- A teammate from a *different* engagement runs it successfully without your help
