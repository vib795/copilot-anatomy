---
name: wave2-context-engineering
description: >
  Wave 2 curriculum lab (weeks 1-2, days 3-4). Use when learning to manage large
  context windows, chunk long specs or large codebases, inject references, and
  prioritize context for real-world artifacts. Keywords: context engineering,
  chunking, context window, reference injection, long documents, large codebase.
license: MIT
---

# Wave 2 Lab 2 — Context Engineering for Complex Tasks

**Module:** Advanced Agent Building & Multi-Step Workflows (Weeks 1–2)
**Days:** 3–4 · **Format:** Shared concept; persona-specific labs

## Outcome

Manage large context windows effectively — chunking strategies, reference
injection, and context prioritization for real-world artifacts (long specs,
large codebases).

## Repo assets used

| Asset | Path | Role in this lab |
|-------|------|------------------|
| Long-context agent | `.github/agents/longcontext-reader.agent.md` | The repo's pattern for big-artifact reading |
| Model matrix | `.github/model-compatibility.json` | `longctx` slot — which models hold 1M tokens |
| Scoped instructions | `.github/instructions/*.instructions.md` | `applyTo:` globs = automatic context injection |
| Team prompt | `.github/copilot-instructions.md` | Always-on context — study what it deliberately excludes |
| Cheatsheet | `COPILOT-CHEATSHEET.md` | Context-budget guidance per primitive |

## Lab steps (shared concept)

1. Read `.github/copilot-instructions.md` and note its size discipline: always-on
   context eats every request's budget, so only non-negotiables live there.
2. Compare with one `instructions/*.instructions.md` file — scoped injection via
   `applyTo:` globs is the cheaper alternative. When would you use each?
3. Open `longcontext-reader.agent.md` and identify its chunking instructions.
4. Feed an oversized artifact (a 100+ page spec, or this repo's `copilot-setup.sh`)
   to a default agent, then to the long-context pattern. Compare answer quality.
5. Build a context plan for your persona artifact: what gets injected whole,
   what gets chunked, what gets summarized-then-referenced.

## Persona tracks

- **BA:** [ba-track.md](ba-track.md) — 100-page requirements doc → queryable context
- **Dev:** [dev-track.md](dev-track.md) — large codebase navigation without context overflow
- **QA:** [qa-track.md](qa-track.md) — regression suite + spec history as prioritized context

## Exit criteria

- A written context plan (inject / chunk / summarize decision per artifact section)
- A before/after comparison showing the plan beat naive whole-artifact pasting
