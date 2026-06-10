# Dev track — packaging code conventions and the build chain as shared assets

## What to package

1. **Scoped instructions** — the conventions you kept restating in chat during
   Lab 6 become `instructions/<lang>-<framework>.instructions.md` with a
   precise `applyTo:` glob. This is usually the highest-leverage accelerator.
2. **Your extended chain** (plan → implement → test-writer → review, from Lab 1)
   as team-cataloged `*.agent.md` files.
3. Optionally a **one-shot prompt** for your most repeated task (e.g. a
   migration template, an endpoint scaffold) as `*.prompt.md` with a pinned
   `model:` from the matrix.

## Generalization checklist

- `applyTo:` glob tested against your repo layout (a glob that never fires is
  invisible failure)
- No hardcoded module names in agent instructions — reference "the files in
  the plan" instead
- `model:` values exist in `.github/model-compatibility.json` (run
  `bash .github/eval/checks/model-refs.sh`)

## Acceptance test

A dev on another codebase scaffolds with `copilot-setup.sh`, drops in your
assets, and completes a small story through your chain without asking you
anything.
