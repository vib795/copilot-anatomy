# QA track — packaging the test design pipeline as a shared skill

## What to package

1. **A test design skill** — `skills/<team>-test-design/SKILL.md` containing
   your risk-based charter template, the planner → writer → coverage-review
   chain pointers, and your "watch for" list from Labs 1–2.
2. **Your coverage reviewer agent** (Lab 1 QA track) as a cataloged
   `*.agent.md`, generalized to read any Given/When/Then criteria format.

## Generalization checklist

- Charter template works for both UI and API features (test it on one of each)
- The skill's `description:` includes the phrases teammates actually search:
  "test plan", "regression selection", "coverage gaps"
- Framework-specific test code examples moved to a clearly-marked optional
  section, so the skill survives a framework change

## Acceptance test

A QA from another team produces a risk-based test plan for an unfamiliar
feature using only your skill, and the coverage reviewer flags at least one
genuine gap in their first draft.
