# AGENTS.md

> Cross-tool instructions for AI coding agents working in this repository.
> Recognized by GitHub Copilot, Claude Code, Cursor, Aider, and other agents
> that read `AGENTS.md` (alongside `CLAUDE.md`, `GEMINI.md`).

## What this repo is

A reference implementation and generator for configuring GitHub Copilot
across a multi-model team. The "code" is bash generators, JSON manifests,
Markdown asset files (prompts, instructions, agents, skills), and an HTML
visualizer. **There is no Java/Go/Python source to compile here** — the
language conventions documented in `.github/copilot-instructions.md`
describe the *target* monorepo a consumer would `bash copilot-setup.sh`
into.

When working *in this repo*, treat shell scripts, JSON manifests, Markdown
assets, and the HTML visualizer as the codebase.

## How to verify your changes

There is no test framework. The `.github/eval/checks/*.sh` scripts are the
test suite. Run them locally before committing:

```bash
bash .github/eval/checks/naming.sh
bash .github/eval/checks/frontmatter.sh
bash .github/eval/checks/model-refs.sh
bash .github/eval/checks/manifest-sync.sh
bash .github/eval/checks/governance.sh
bash .github/eval/checks/doc-consistency.sh   # warn-only
bash .github/eval/checks/deprecation.sh
```

Or run the bundled health dashboard:

```bash
bash copilot-health.sh
```

## The governance triangle

Every Copilot asset must be consistent across three places. Editing one
without the others will fail CI:

1. **`.github/copilot-asset-manifest.json`** — single source of truth
   (path, owner, classification, generated, description).
2. **`.github/model-compatibility.json`** — any `model:` value in
   frontmatter must exist here.
3. **`COPILOT-CHANGELOG.md`** — every change gets a `[Unreleased]` entry.

`manifest-sync.sh` enforces bidirectional consistency: orphan files on
disk *and* manifest entries pointing at missing files both fail.

## The generator/disk-drift trap

`copilot-setup.sh` is a ~95KB bash script of `cat > path << 'HEREDOC'`
blocks. It is the canonical body for every asset whose manifest entry
has `"generated": true`.

**If you edit a generated asset only on disk, the next run of
`copilot-setup.sh` will overwrite your change.** Always edit the heredoc
body in `copilot-setup.sh` *and* the file on disk together. Hand-maintained
assets (`"generated": false`) live only in `.github/`.

## Conventions specific to this repo

- Shell scripts: `set -euo pipefail` at top.
- Match existing color helpers (`pass`/`fail`/`warn`/`info`/`header`) when
  adding to the operator scripts (`copilot-onboarding.sh`,
  `copilot-discover.sh`, `copilot-health.sh`).
- `manifest-sync.sh` parses the manifest with `awk -F'"' '/"path"/'` —
  keep `"path":` keys on their own line so this regex still works.
- Frontmatter is YAML between `---` fences. `frontmatter.sh` enforces
  required fields per asset type.
- Skill discoverability hinges entirely on the `description:` field —
  write it as natural-language search keywords, not a title.
- Conventional Commits enforced: `<type>(<scope>): <subject>` with types
  `feat | fix | chore | docs | refactor | test | ci | perf`.

## Asset primitives at a glance

| Primitive    | Path                               | Trigger                           |
| ------------ | ---------------------------------- | --------------------------------- |
| Team prompt  | `.github/copilot-instructions.md`  | Always-on                         |
| Instructions | `.github/instructions/*.instructions.md` | Auto, by `applyTo:` glob    |
| Prompts      | `.github/prompts/*.prompt.md`      | Manual `/command`                 |
| Skills       | `.github/skills/<name>/SKILL.md`   | Auto-discovered via description   |
| Custom Agents| `.github/agents/*.agent.md`        | Agent picker, chained via `handoffs:`, or autonomous |

> Custom Agents subsume the legacy `.chatmode.md` primitive. Persona agents
> and task agents (plan / implement / review + 50+ specialist reviewers) all
> live in `agents/` with a unified frontmatter schema (`name`, `description`,
> `model`, `tools`, `agents`, `handoffs`, `user-invocable`,
> `disable-model-invocation`, `target`, `mcp-servers`, `hooks`).

## Where to look first

- `README.md` — overview and quick start
- `CLAUDE.md` — guidance for Claude Code (architecture, commands, traps)
- `COPILOT-CHEATSHEET.md` — the comprehensive guide
- `.github/GOVERNANCE.md` — checklist for adding/deprecating assets
- `COPILOT-CHANGELOG.md` — recent asset changes
- `docs/plans/` and `docs/decisions/` — design rationale
