---
name: wave2-cross-persona-collaboration
description: >
  Wave 2 curriculum lab (weeks 1-2, days 7-8). Use when BA, Dev, and QA pairs
  build complementary agents that hand off artifacts to each other, such as a BA
  agent producing stories that a Dev agent turns into an implementation plan.
  Keywords: cross-persona, pairing, agent handoff, BA Dev QA collaboration.
license: MIT
---

# Wave 2 Lab 4 — Cross-Persona Agent Collaboration

**Module:** Advanced Agent Building & Multi-Step Workflows (Weeks 1–2)
**Days:** 7–8 · **Format:** Shared (run in mixed BA+Dev or Dev+QA pairs)

## Outcome

Work in mixed BA+Dev or Dev+QA pairs to build complementary agents that hand
off artifacts to each other — e.g. BA agent produces stories → Dev agent
generates implementation plan.

## Repo assets used

| Asset | Path | Role in this lab |
|-------|------|------------------|
| Handoff examples | `.github/agents/plan.agent.md`, `.github/agents/implement.agent.md` | The handoff contract pattern to copy |
| Spec flow analyzer | `.github/agents/spec-flow-analyzer.agent.md` | Bridges spec language → implementation language |
| Test writer | `.github/agents/test-writer.agent.md` | The Dev→QA handoff target |
| Governance | `.github/GOVERNANCE.md` | Both agents must pass the same frontmatter rules |

## Lab steps

1. **Pair up across personas.** Each pair picks one boundary: BA→Dev (stories →
   implementation plan) or Dev→QA (implementation → test plan).
2. **Define the artifact contract first.** Before writing either agent, agree in
   writing what crosses the boundary: format, required fields, what "done"
   means. This contract goes in both agents' instructions.
3. **Build your side.** Each person authors their persona's agent from the Lab 1
   chain pattern, with `handoffs:` pointing at the partner's agent.
4. **Run the handoff both directions.** Producer runs first; consumer must work
   *only* from the handed-off artifact — no side-channel explanations.
5. **Fix the contract, not the output.** When the consumer agent misreads the
   artifact, amend the contract and regenerate, rather than hand-editing the result.

## Exit criteria

- A written artifact contract both agents reference
- One successful producer→consumer run with no human translation in between
- A list of contract amendments made and why (this becomes Lab 8 input)
