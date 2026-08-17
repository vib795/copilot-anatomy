# QA track — feature spec → test plan → test code → coverage review pipeline

Build a chain that turns a feature spec into executable tests with a coverage
verdict.

## Chain design

1. **Test planner agent** — decomposes the spec into risk areas and test
   charters. Model slot: `reason`.
2. **Test writer** (`.github/agents/test-writer.agent.md`) — generates test
   code per charter; reuse rather than rebuild.
3. **Coverage reviewer agent** — compares tests against the spec's acceptance
   criteria and lists untested behaviors. Base it on
   `.github/agents/testing-reviewer.agent.md`.

## Exercise

1. Take the acceptance criteria a BA pair produced in their track (or a sample
   spec) as chain input.
2. Author the test planner and coverage reviewer agents; wire `handoffs:`
   through all three links.
3. Run the chain and count: how many spec behaviors reached test code without
   human re-prompting?

## Watch for

- Test plans organized by file structure instead of risk — the planner prompt
  must demand risk-based charters.
- The coverage reviewer passing tests that merely execute code without
  asserting the criteria.
