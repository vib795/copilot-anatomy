# Dev track — spec → code → test → review pipeline

Build (or extend) the chain that already exists in this repo: plan → implement
→ review.

## Chain design

1. **Plan** (`.github/agents/plan.agent.md`) — turns a spec into an
   implementation plan. Already hands off to implement.
2. **Implement** (`.github/agents/implement.agent.md`) — writes the code from
   the plan.
3. **Test writer** (`.github/agents/test-writer.agent.md`) — your job: insert
   this link between implement and review by adding a `handoffs:` entry.
4. **Review** (`.github/agents/review.agent.md`) — final gate; compare with the
   specialist reviewers (`correctness-reviewer`, `security-reviewer`).

## Exercise

1. Trace the existing plan → implement handoff and note exactly what artifact
   is passed (plan text? file list? both?).
2. On a scratch branch, modify the chain so implement hands off to test-writer
   before review.
3. Run the full chain on a small spec (e.g. "add a `--json` flag to
   `copilot-discover.sh`") and record where the chain needed human correction.

## Watch for

- The implement agent silently dropping plan steps — handoffs need an explicit
  checklist the next agent must confirm.
- Test-writer testing the implementation as written rather than the spec.
