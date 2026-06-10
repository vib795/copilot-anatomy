# QA track — a real test design or automation task through the AI stack

## Suitable tasks

- Designing a test plan for an upcoming feature
- Automating a manual regression pack (or a slice of one)
- Root-causing a flaky test and hardening it

## Suggested routing

| Task step | Primitive | Asset |
|-----------|-----------|-------|
| Risk-based test design | Agent chain | Your Lab 1 QA chain (planner → writer → coverage review) |
| Test code generation | Prompt / Agent | `.github/prompts/test-gen.prompt.md`, `.github/agents/test-writer.agent.md` |
| Coverage critique | Agent | `.github/agents/testing-reviewer.agent.md` |
| Spec + suite as context | Skill | Lab 2 QA context plan (`wave2-context-engineering/qa-track.md`) |

## Persona-specific retrospective questions

- Did generated tests assert spec behavior, or implementation detail?
- How many generated tests were duplicates of existing coverage? (Measure it —
  this is the most common silent failure.)
- Would you trust the coverage reviewer's "untested behaviors" list in a
  release decision? What would it take to get there?
