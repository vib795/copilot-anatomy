---
name: wave2-ai-delivery-playbook
description: >
  Wave 2 curriculum lab (weeks 3-4, days 9-10). Use when a cohort documents its
  AI Delivery Playbook: which tasks use AI, which agents are standard, what the
  review process is, and how impact is tracked. Keywords: AI delivery playbook,
  team documentation, standard agents, review process, operating model.
license: MIT
---

# Wave 2 Lab 10 — The AI Delivery Playbook

**Module:** Delivery Integration & Reusable Assets (Weeks 3–4)
**Days:** 9–10 · **Format:** Shared

## Outcome

Each cohort produces a documented "AI Delivery Playbook" for their team: which
tasks use AI, which agents are standard, what the review process looks like,
how impact is tracked.

## Repo assets used

| Asset | Path | Role in this lab |
|-------|------|------------------|
| Cheatsheet | `COPILOT-CHEATSHEET.md` | The structural model: task → primitive → model routing |
| Model matrix | `.github/model-compatibility.json` | Slot-based routing your playbook should reuse |
| MCP profiles | `.github/copilot-mcp-profiles.json` | Privilege tiers section of the playbook |
| Governance | `.github/GOVERNANCE.md` | Asset lifecycle section |
| Health dashboard | `copilot-health.sh` | Impact tracking section (Lab 5 rollup) |

## Playbook structure (one section per Wave 2 lab)

1. **Task routing table** — which delivery tasks use AI, which primitive and
   model slot, and which are deliberately human-only. Model it on the
   cheatsheet's routing table; "we don't use AI for X" entries are as
   important as the rest.
2. **Standard agent catalog** — the Lab 8 catalog: name, owner, what it does,
   handoffs, MCP profile required.
3. **Context standards** — the Lab 2 patterns: what's always-on, what's scoped
   via `applyTo:`, how large artifacts get chunked.
4. **Guardrails & review process** — Lab 3 checkpoints + Lab 8 quality gates:
   what runs automatically, what needs human eyes, what blocks.
5. **Estimation guidance** — Lab 9 findings: where AI deltas are real, what
   AI-overhead tasks every plan includes.
6. **Impact tracking** — the Lab 5 schema, who rolls it up, where it's reported.

## Lab steps

1. Draft each section from the corresponding lab's exit artifacts (you already
   wrote the content — this lab is assembly and reconciliation).
2. Reconcile conflicts between persona tracks in a working session; the
   playbook is one document, not three.
3. Run a tabletop test: a hypothetical new joiner follows only the playbook
   through a small task. Every place they'd get stuck is a defect — fix it.
4. Version it like code: in the team repo, changelog discipline, named owner.

## Exit criteria

- A complete playbook covering all six sections, owned and version-controlled
- Tabletop test passed by someone outside the authoring group
