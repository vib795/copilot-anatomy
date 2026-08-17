# BA track — brief → stories → acceptance criteria pipeline

Build a three-link chain that turns a one-page business brief into sprint-ready
work items.

## Chain design

1. **Brief analyst agent** — ingests the brief, extracts goals, actors,
   constraints, and open questions. Model slot: `reason` (see
   `.github/model-compatibility.json`).
2. **Story writer agent** — converts the structured analysis into INVEST user
   stories. Receives the analyst's output via `handoffs:`.
3. **Acceptance criteria agent** — expands each story into Given/When/Then
   criteria and flags untestable stories back to the analyst.

## Exercise

1. Pick a real (or provided) one-page brief.
2. Draft the three agents; reuse `.github/agents/plan.agent.md` as the
   frontmatter template.
3. Run the chain. Compare the criteria output against what you would have
   written by hand — log the delta in your AI impact log (Lab 5).

## Watch for

- Stories that drift from the brief's stated constraints — the handoff must
  carry the constraint list verbatim, not a summary.
- Acceptance criteria that restate the story instead of testing it.
