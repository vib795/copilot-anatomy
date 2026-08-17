---
agent: agent
model: claude-sonnet-5
description: "Generate tests for the selected code following project conventions"
---

> [!WARNING]
> **DEPRECATED (2026-08-17) — removal 2026-11-16.** Prompt files run only in the
> Local agent harness. Copilot CLI, the Copilot cloud agent, and Agent Plugins
> express slash commands as **skills**. This command now lives at
> `.github/skills/test-gen/SKILL.md`; edit that file, not this one.
> See `.github/GOVERNANCE.md` → "Deprecating an asset".


<!--
  SLASH COMMAND: /test-gen
  MODEL: claude-sonnet-5 — produces realistic, convention-following tests
  AGENT: agent — autonomous mode that adds test files or test cases
-->

Generate tests for the selected code. Follow `.github/instructions/testing.instructions.md`.

## What to produce

1. **Happy path test** — the normal case with valid inputs
2. **Boundary / edge cases** — empty input, max values, type boundaries
3. **Primary failure path** — the most likely error scenario
4. **At least one integration-adjacent test** — real repository / real HTTP

## Naming conventions
- Java: `shouldDescribeScenario()` e.g. `shouldReturn404WhenUserNotFound()`
- Go: `TestFunctionName/scenario_description` table-driven sub-test
- Python: `test_describes_scenario` e.g. `test_raises_not_found_when_user_missing`

## What NOT to do
- Do not test implementation details (private methods, internal state)
- Do not write tests that only test mocks
- Do not use `Thread.sleep` or real clocks — use fixed time sources
- Do not generate trivial tests: `assert user != null` alone is not a test
