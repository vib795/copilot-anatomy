# QA track — test effort estimation and risk-based scope

## Exercise

1. For an upcoming feature, produce a risk-based test scope with your Lab 1
   planner chain, then estimate effort two ways: manual-only and
   chain-assisted (generation + human review of every generated test).
2. Price the review honestly: generated tests are cheap to produce and
   expensive to trust. Your impact log's rework rate is the multiplier.
3. Present the estimate as scope tiers: must-test (human-designed),
   should-test (chain-generated, human-reviewed), could-test (chain-generated,
   spot-checked) — with the risk each tier accepts.

## Planning questions to answer

- Which test types does generation handle well (API contract, data-driven
  cases) vs. poorly (exploratory, usability, race conditions)? Scope the
  manual budget around the second list.
- Does AI-assisted dev work upstream (more code per sprint) increase test
  demand faster than AI-assisted testing absorbs it? Plan capacity for the gap.
