---
agent: ask
model: claude-sonnet-4-5
description: "Code review: correctness, security, performance, style, tests"
---

<!--
  SLASH COMMAND: /review
  MODEL: claude-sonnet-4-5 — best for structured multi-step code analysis
  AGENT: ask — read-only, produces a review report without editing files
-->

Review the selected code or active file. Work through these lenses in order
and group findings by lens:

## 1. Correctness
- Logic errors, off-by-one, unchecked nulls, missing error handling
- Java: unclosed resources, missing `@Transactional` rollback rules
- Go: goroutine leaks, missing `defer cancel()`, ignored error returns
- Python: mutable default args, bare `except:`, unvalidated user input

## 2. Security
- SQL/command/log injection risks
- Hardcoded credentials, tokens, or API keys
- Overly broad RBAC/IAM in YAML configs
- Missing authentication or authorisation checks

## 3. Performance
- N+1 queries or missing batch fetching
- Unnecessary allocations in hot paths
- Synchronous blocking calls that should be async

## 4. Style and maintainability
- Follows `.github/copilot-instructions.md` conventions?
- Magic numbers/strings that should be named constants
- Methods over ~40 lines that should be extracted
- Variable names that describe type rather than content

## 5. Tests
- Happy path covered?
- Primary failure/edge case covered?
- Are mocks testing the mock rather than real behaviour?

---
For each finding: **line range → issue in one sentence → concrete fix**.
End with:
- Overall verdict: `LGTM` / `needs minor changes` / `needs major rework`
- Top-priority fix if any changes are needed
