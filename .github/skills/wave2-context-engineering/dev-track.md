# Dev track — navigating a large codebase without context overflow

## Exercise

1. Pick a repo too large to paste (this repo's `copilot-setup.sh` at ~95KB is a
   good stand-in for a large module).
2. Practice three strategies on the same task ("explain how generated assets
   stay in sync with files on disk"):
   - **Naive:** paste as much of the file as fits. Note where it truncates.
   - **Structural chunking:** feed only the heredoc markers and section
     headers first, then drill into the one section that matters.
   - **Scoped instructions:** rely on `.github/instructions/*.instructions.md`
     `applyTo:` globs to auto-inject conventions instead of restating them.
3. Compare with the `longcontext-reader` agent
   (`.github/agents/longcontext-reader.agent.md`) using a `longctx`-slot model
   from `.github/model-compatibility.json`.

## Techniques to practice

- Symbol-map first: ask for an outline (functions, heredoc targets), then load
  only the bodies you need.
- Pin the invariant: state "manifest `path` keys must stay on their own line"
  style constraints up front so generated edits respect them.

## Watch for

- Answers that sound right but cite line numbers from the truncated region —
  always verify the model actually saw the section it cites.
