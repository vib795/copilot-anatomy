---
name: wave2-chaining-agents
description: >
  Wave 2 curriculum lab (weeks 1-2, days 1-2). Use when learning to chain two or
  three custom agents into a multi-step workflow, wire agent handoffs, or build a
  pipeline like brief to stories to acceptance criteria, or spec to code to test
  to review. Keywords: agent chaining, handoffs, multi-step workflow, pipeline.
license: MIT
---

# Wave 2 Lab 1 — Chaining Agents: From Single Task to Workflow

**Module:** Advanced Agent Building & Multi-Step Workflows (Weeks 1–2)
**Days:** 1–2 · **Format:** Shared concept; persona-specific labs

## Outcome

Chain 2–3 agents together to complete a multi-step delivery task — e.g. BA:
brief → stories → acceptance criteria pipeline; Dev: spec → code → test → review.

## Repo assets used

| Asset | Path | Role in this lab |
|-------|------|------------------|
| Plan agent | `.github/agents/plan.agent.md` | First link — study its `handoffs:` frontmatter |
| Implement agent | `.github/agents/implement.agent.md` | Receives the plan handoff |
| Review agent | `.github/agents/review.agent.md` | Final link — closes the chain |
| Cheatsheet | `COPILOT-CHEATSHEET.md` | Task → model routing for each link |
| Agent schema | `.github/GOVERNANCE.md` | Frontmatter rules your new agents must follow |

## Lab steps (shared concept)

1. Read the `handoffs:` frontmatter in `plan.agent.md` and trace how it names
   `implement` as the next agent. This is the chain mechanism.
2. Run the existing chain on a toy task: invoke the plan agent from the agent
   picker, accept its handoff to implement, then to review.
3. Sketch your own 2–3 link chain for a task from your persona track (below).
4. Author the agents as `.github/agents/*.agent.md` drafts in a scratch branch —
   each with `name`, `description`, `model`, and a `handoffs:` list.
5. Run the chain end-to-end and capture where context was lost between links.

## Persona tracks

- **BA:** [ba-track.md](ba-track.md) — brief → user stories → acceptance criteria
- **Dev:** [dev-track.md](dev-track.md) — spec → code → test → review
- **QA:** [qa-track.md](qa-track.md) — feature spec → test plan → test code → coverage review

## Exit criteria

- A working chain of at least 2 agents completing your persona task
- A one-paragraph note on what context each handoff must carry to avoid rework
