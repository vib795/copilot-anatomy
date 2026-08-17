---
name: wave2-ai-estimation-planning
description: >
  Wave 2 curriculum lab (weeks 3-4, days 7-8). Use when applying AI to
  estimation, sprint planning, and task decomposition, and when factoring AI
  assistance into delivery plans rather than just execution. Keywords: AI
  estimation, sprint planning, task decomposition, delivery planning, velocity.
license: MIT
---

# Wave 2 Lab 9 — AI-First Estimation & Planning

**Module:** Delivery Integration & Reusable Assets (Weeks 3–4)
**Days:** 7–8 · **Format:** Shared concept; persona-specific labs

## Outcome

Use AI to assist with estimation, sprint planning, and task decomposition.
Factor AI into delivery planning (not just execution).

## Repo assets used

| Asset | Path | Role in this lab |
|-------|------|------------------|
| Plan agent | `.github/agents/plan.agent.md` | Decomposition engine |
| Architect prompt | `.github/prompts/architect.prompt.md` | Up-front design input to estimates |
| Feasibility reviewer | `.github/agents/feasibility-reviewer.agent.md` | Adversarial check on optimistic plans |
| Impact logs | Lab 5 schema | Your own data on where AI actually saves time |

## Lab steps (shared concept)

1. **Decompose with the plan agent.** Feed it a real upcoming epic. Compare
   its task breakdown with the team's manual one: what did it miss (integration
   work, reviews, environments) and what did it surface that you'd have missed?
2. **Estimate two ways.** For each task, estimate (a) without AI assistance and
   (b) assuming the team's accelerator catalog (Lab 8) is used. The delta must
   come from your impact-log data (Lab 5), not optimism.
3. **Red-team the plan.** Run the feasibility reviewer over the plan. Every
   "at risk" flag gets either a mitigation or an estimate bump.
4. **Plan the AI work itself.** Add explicit tasks for AI overhead: context
   preparation, output review, asset maintenance. Teams that skip these book
   the savings twice.

## Persona tracks

- **BA:** [ba-track.md](ba-track.md) — backlog decomposition and refinement velocity
- **Dev:** [dev-track.md](dev-track.md) — story-level estimates with AI-assisted delta
- **QA:** [qa-track.md](qa-track.md) — test effort estimation and risk-based scope

## Exit criteria

- One epic decomposed and estimated both ways, with data-backed deltas
- A feasibility-reviewed sprint plan including explicit AI-overhead tasks
