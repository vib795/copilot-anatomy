# Wave 2 Curriculum — From Individual Proficiency → Delivery-Integrated, Team-Scale AI Execution

Source: *Wave 2 Proposed Curriculum* (curriculum sheet, two modules of two
weeks each). Every lab is implemented as a governed skill under
`.github/skills/wave2-*/`, and each capstone as a prompt under
`.github/prompts/`. All assets are registered in
`.github/copilot-asset-manifest.json` and pass the eval checks.

Personas: **BA**, **Dev**, **QA**. Labs marked persona-specific have
`ba-track.md` / `dev-track.md` / `qa-track.md` files alongside their `SKILL.md`.

## Weeks 1–2 — Advanced Agent Building & Multi-Step Workflows

| Days | Lab | Format | Asset |
|------|-----|--------|-------|
| 1–2 | Chaining Agents: From Single Task to Workflow | Shared concept; persona labs | [`wave2-chaining-agents`](../../../.github/skills/wave2-chaining-agents/SKILL.md) |
| 3–4 | Context Engineering for Complex Tasks | Shared concept; persona labs | [`wave2-context-engineering`](../../../.github/skills/wave2-context-engineering/SKILL.md) |
| 5–6 | Agent Guardrails & Error Recovery | Shared | [`wave2-guardrails-error-recovery`](../../../.github/skills/wave2-guardrails-error-recovery/SKILL.md) |
| 7–8 | Cross-Persona Agent Collaboration | Shared (mixed pairs) | [`wave2-cross-persona-collaboration`](../../../.github/skills/wave2-cross-persona-collaboration/SKILL.md) |
| 9–10 | Measuring What Matters: AI Impact Tracking | Shared | [`wave2-impact-tracking`](../../../.github/skills/wave2-impact-tracking/SKILL.md) |
| Capstone | End-to-End Delivery Scenario (Multi-Agent) | Mixed teams | [`/wave2-capstone-delivery`](../../../.github/prompts/wave2-capstone-delivery.prompt.md) |

## Weeks 3–4 — Delivery Integration & Reusable Assets

| Days | Lab | Format | Asset |
|------|-----|--------|-------|
| 1–2 | Embedding AI in Your Actual Project | Fully persona-specific | [`wave2-embedding-ai-project`](../../../.github/skills/wave2-embedding-ai-project/SKILL.md) |
| 3–4 | Building Reusable Accelerators | Fully persona-specific | [`wave2-reusable-accelerators`](../../../.github/skills/wave2-reusable-accelerators/SKILL.md) |
| 5–6 | Team Standards & Shared Agent Library | Shared | [`wave2-team-standards-agent-library`](../../../.github/skills/wave2-team-standards-agent-library/SKILL.md) |
| 7–8 | AI-First Estimation & Planning | Shared concept; persona labs | [`wave2-ai-estimation-planning`](../../../.github/skills/wave2-ai-estimation-planning/SKILL.md) |
| 9–10 | The AI Delivery Playbook | Shared | [`wave2-ai-delivery-playbook`](../../../.github/skills/wave2-ai-delivery-playbook/SKILL.md) |
| Capstone | Hackathon: Build an Accelerator | Mixed teams, judged | [`/wave2-capstone-accelerator`](../../../.github/prompts/wave2-capstone-accelerator.prompt.md) |

## How the labs thread together

- Lab 1 chains feed Labs 3 (guardrails on those chains), 4 (cross-persona
  handoffs between them), and the week 1–2 capstone.
- Lab 5's impact-log schema is used in every subsequent lab and is the
  evidence base for Lab 9 estimation and the hackathon problem pitches.
- Labs 6–8 turn individual results into team assets; Lab 10 assembles every
  lab's exit artifact into the team's AI Delivery Playbook.

## Running a cohort

1. Scaffold a sandbox repo per team: `bash copilot-setup.sh /path/to/sandbox`
2. Verify each participant: `bash copilot-onboarding.sh --role developer|reviewer|platform`
3. Find lab assets anytime: `bash copilot-discover.sh search wave2`
