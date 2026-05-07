---
agent: agent
model: claude-sonnet-4-5
description: "Generate tests for the selected code following project conventions"
---

<!--
  SLASH COMMAND: /test-gen
  MODEL: claude-sonnet-4-5 — produces realistic, convention-following tests
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
