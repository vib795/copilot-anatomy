---
agent: agent
model: claude-sonnet-4-5
description: "Diagnose root cause and fix the bug in the active file"
---

<!--
  SLASH COMMAND: /fix-issue
  MODEL: claude-sonnet-4-5 — reliable at targeted code edits
  AGENT: agent — autonomous mode that modifies files directly
-->

Fix the bug or implement the small feature. Follow these steps exactly:

## Step 1 — State the problem
One sentence. If there's a JIRA/GitHub issue number, acknowledge it.

## Step 2 — Root cause
Trace the execution path. State WHY it fails before writing any code.
Do not skip this — guessing the fix without the root cause leads to regressions.

## Step 3 — Apply the fix
- Minimal change targeting the root cause only.
- Do not refactor unrelated code in the same edit.
- If the fix touches a public API, note callers that may break.
- Add an inline comment where the logic is non-obvious.

## Step 4 — Add or update a test
- Update the existing test if one covers this code path.
- Otherwise add a new test named after the scenario:
  - Java: `shouldReturn404WhenUserNotFound()`
  - Go: table-driven sub-test entry, not a new top-level function
  - Python: `test_raises_not_found_when_user_missing`

## Step 5 — Verification commands
Provide the exact commands to verify the fix:
```bash
# Java
./mvnw test -pl <module> -Dtest=<TestClass>

# Go
go test ./... -run TestTarget -race

# Python
pytest tests/test_target.py -v
```

---
Do not change unrelated files. Do not bump version numbers.
