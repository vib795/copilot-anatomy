---
agent: ask
model: gpt-5.6-sol
description: "System design, trade-off analysis, and Architecture Decision Records"
---

> [!WARNING]
> **DEPRECATED (2026-08-17) — removal 2026-11-16.** Prompt files run only in the
> Local agent harness. Copilot CLI, the Copilot cloud agent, and Agent Plugins
> express slash commands as **skills**. This command now lives at
> `.github/skills/architect/SKILL.md`; edit that file, not this one.
> See `.github/GOVERNANCE.md` → "Deprecating an asset".


<!--
  SLASH COMMAND: /architect
  MODEL: gpt-5.6-sol — best for multi-step reasoning and weighing complex trade-offs
  AGENT: ask — produces design documents for team review
-->

Produce a structured architecture analysis for the described problem.

## Before proposing anything, clarify
1. Expected load / scale constraints
2. Consistency vs availability requirements
3. Team operational maturity (what complexity can be sustained on-call?)
4. Existing infrastructure constraints (what's already running?)

## Output format

### Options considered
For each option (minimum 2, maximum 4):
```
Option N: <name>
  What: <one paragraph describing the approach>
  Optimises for: <what this wins at>
  Trade-offs: <what this costs>
  Operational complexity: Low / Medium / High
  When to choose this: <specific conditions where this is the right call>
```

### Recommendation
State the recommended option and the exact conditions under which you'd
switch to an alternative.

### ADR (Architecture Decision Record)
```markdown
## ADR-NNN: <Title>

**Status**: Proposed | Accepted | Deprecated | Superseded by ADR-NNN

**Context**
<What problem are we solving? What constraints exist? What happens if we do nothing?>

**Decision**
<What are we doing?>

**Consequences**
Positive: <what gets better>
Negative: <what gets harder or more expensive>
Risks: <what could go wrong>

**Alternatives considered**
<What else did we look at and why did we reject it?>
```

---
Do not recommend complexity the team isn't ready to operate on a pager.
