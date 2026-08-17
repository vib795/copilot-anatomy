# Dev track — a real implementation task through the AI stack

## Suitable tasks

- A sprint story with clear acceptance criteria (feature slice, bug fix)
- A refactor with existing test coverage
- Adding tests to an under-covered module

## Suggested routing

| Task step | Primitive | Asset |
|-----------|-----------|-------|
| Plan the change | Agent | `.github/agents/plan.agent.md` (hands off to implement) |
| Implement | Agent | `.github/agents/implement.agent.md` |
| Generate tests | Prompt | `.github/prompts/test-gen.prompt.md` or `test-writer` agent |
| Pre-PR review | Prompt | `.github/prompts/review.prompt.md` |
| Conventions | Instructions | `.github/instructions/*.instructions.md` (verify the `applyTo:` glob hits your files) |

## Persona-specific retrospective questions

- Did scoped instructions actually fire for your language, or did you restate
  conventions in chat? (If restated — that's an `applyTo:` gap to log.)
- What fraction of the generated diff survived your own review?
- Did the plan→implement handoff carry enough context, or did you re-explain?
