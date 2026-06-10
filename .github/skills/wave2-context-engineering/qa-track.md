# QA track — regression suite and spec history as prioritized context

## Exercise

1. Gather three artifact types: the current spec, the regression test
   inventory, and the last release's defect list.
2. Build a context plan for the question "which regression tests should run
   for this change, and what's untested?":
   - **Inject whole:** the change description and defect list (small, high-signal).
   - **Chunk:** the test inventory, grouped by feature area — load only areas
     the change touches.
   - **Summarize-then-reference:** spec history; keep version deltas, drop
     unchanged sections.
3. Run the question with naive everything-pasted context, then with the plan.
   Compare: does the prioritized version surface the same untested behaviors?

## Techniques to practice

- Order context by recency of change — newest spec deltas first, stable
  sections last (or referenced only).
- Use defect clusters as a relevance filter: areas with historical defects get
  full-text injection; clean areas get one-line summaries.

## Watch for

- The model recommending tests that exist in the suite name list but assert
  nothing relevant — chunk test *bodies* for the areas that matter, not just
  test names.
