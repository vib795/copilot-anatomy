---
name: wave2-embedding-ai-project
description: >
  Wave 2 curriculum lab (weeks 3-4, days 1-2). Use when taking a real task from
  a current engagement and executing it with the AI stack, then documenting what
  worked, what did not, and what to change. Keywords: real project, engagement,
  embedding AI, production task, retrospective, copilot-setup.
license: MIT
---

# Wave 2 Lab 6 — Embedding AI in Your Actual Project

**Module:** Delivery Integration & Reusable Assets (Weeks 3–4)
**Days:** 1–2 · **Format:** Fully persona-specific

## Outcome

Take a real task from your current engagement and execute it using the AI
stack. Document: what worked, what didn't, what you'd change.

## Repo assets used

| Asset | Path | Role in this lab |
|-------|------|------------------|
| Generator | `copilot-setup.sh` | Scaffolds the full `.github/` Copilot stack into your project repo |
| Onboarding | `copilot-onboarding.sh` | `--role developer\|reviewer\|platform` verifies prerequisites |
| Discovery | `copilot-discover.sh` | `search <keyword>` finds the right asset for your task |
| Cheatsheet | `COPILOT-CHEATSHEET.md` | Task → primitive → model routing |

## Lab steps (all personas)

1. **Scaffold your engagement repo** (or a sandbox copy):
   `bash copilot-setup.sh /path/to/your-repo`, then
   `bash copilot-onboarding.sh --check-only` to verify the toolchain.
2. **Pick a real task** from your current sprint — something due anyway, not a
   demo. It should take 2–6 hours by your normal estimate.
3. **Route before you prompt.** Use `copilot-discover.sh search <keyword>` and
   the cheatsheet to pick the primitive (prompt? skill? agent chain?) before
   opening chat. Record the routing decision.
4. **Execute with the stack**, logging impact entries (Lab 5 schema) as you go.
5. **Write the retrospective** — three sections, no padding: what worked, what
   didn't, what you'd change. Include at least one thing you'd change about the
   *assets* (not just your prompting) — that feeds Lab 7.

## Persona tracks

- **BA:** [ba-track.md](ba-track.md) — requirements/refinement task from your backlog
- **Dev:** [dev-track.md](dev-track.md) — implementation task from your sprint
- **QA:** [qa-track.md](qa-track.md) — test design/automation task from your plan

## Exit criteria

- A real engagement task completed with the AI stack, with impact log entries
- A what-worked / what-didn't / what-to-change retrospective
- At least one concrete asset improvement identified for Lab 7
