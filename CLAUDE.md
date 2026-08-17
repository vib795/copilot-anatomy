# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is (and isn't)

This is **not an application**. It is a *reference implementation and generator* for configuring GitHub Copilot across a multi-model, polyglot team. The "code" is:

- Bash generator/operator scripts at the repo root (`copilot-*.sh`)
- A `.github/` tree of Copilot assets (prompts, skills, agents, instructions)
- A governance + evaluation system that keeps that tree consistent
- A single-page interactive visualization (`copilot-anatomy.html` + `index.html` redirect, served from GitHub Pages)

There is no Java/Go/Python source to compile here despite the conventions documented in `.github/copilot-instructions.md` — those conventions describe the *target* monorepo a consumer would `bash copilot-setup.sh` into. When working *in this repo*, treat shell scripts, JSON manifests, Markdown assets, and the HTML visualizer as the codebase.

## Common commands

All scripts run from the repo root. Most have no dependencies beyond bash + `awk`/`grep`/`find`; `copilot-onboarding.sh` checks for `node`, `jq`, `gh`, etc.

```bash
# Generate a full .github/ Copilot scaffold into another repo
bash copilot-setup.sh /path/to/target-repo

# Run all CI eval checks locally (same set CI runs on PRs)
bash .github/eval/checks/naming.sh
bash .github/eval/checks/frontmatter.sh
bash .github/eval/checks/model-refs.sh
bash .github/eval/checks/manifest-sync.sh
bash .github/eval/checks/governance.sh
bash .github/eval/checks/doc-consistency.sh   # warn-only
bash .github/eval/checks/deprecation.sh
bash .github/eval/checks/plugin-manifest.sh   # Agent Plugins 1.0 package validity

# Run a single eval check (the smallest unit of "test" in this repo)
bash .github/eval/checks/manifest-sync.sh

# Regenerate the health dashboard (.github/health-report.json + HEALTH.md)
bash copilot-health.sh
bash copilot-health.sh --json-only   # CI-friendly
bash copilot-health.sh --md-only

# Find the right asset for a task
bash copilot-discover.sh                  # interactive menu
bash copilot-discover.sh search helm      # keyword search
bash copilot-discover.sh list             # all assets by type

# Verify prerequisites + role-specific guidance
bash copilot-onboarding.sh --check-only
bash copilot-onboarding.sh --role developer   # or reviewer | platform | all
```

There is no test framework — `.github/eval/checks/*.sh` *is* the test suite. Each script exits non-zero on failure; `copilot-eval.yml` runs them on every PR that touches a Copilot asset path.

## Architecture: the governance triangle

Every Copilot asset lives at the intersection of three files. Editing one without the others will fail CI:

```
        .github/copilot-asset-manifest.json
       (single source of truth: path, owner,
         classification, generated, description)
                       │
                       │
   .github/model-compatibility.json ───── frontmatter `model:` field
   (defines named slots: fast/reason/                in the asset file
    code/thorough/longctx/balanced)
                       │
                       │
              COPILOT-CHANGELOG.md
              (Keep-a-Changelog entry under [Unreleased])
```

When you add or rename an asset (`*.agent.md`, `*.instructions.md`, `skills/*/SKILL.md`, `*.prompt.md`):

1. Add a manifest entry with `path`, `owner`, `classification` (`core`/`workflow`/`extension`), `generated` (bool), `description`.
2. If frontmatter sets `model:`, the value must exist in `model-compatibility.json` **and not be in its `deprecated` block**.
3. Filename must be kebab-case with the right double-extension. For a skill, the frontmatter `name:` must exactly match its directory name — `plugin-manifest.sh` fails otherwise.
4. Add a `COPILOT-CHANGELOG.md` entry under `[Unreleased]`.
5. New slash commands are authored as **skills**, not prompt files.

`manifest-sync.sh` enforces bidirectional consistency — orphan files on disk *and* manifest entries pointing at missing files both fail. See `.github/GOVERNANCE.md` for the full checklist (including the 60-day deprecation grace period enforced by `deprecation.sh`).

## Architecture: the Copilot primitives

Each primitive solves a different routing problem. Adding new functionality means picking the right primitive, not invading another. **Portable** marks what survives a move to another agent tool — Agent Plugins 1.0 standardises only skills and MCP servers:

| Primitive       | Path                              | Trigger                         | Portable | When to extend                                    |
| --------------- | --------------------------------- | ------------------------------- | -------- | ------------------------------------------------- |
| Team prompt     | `.github/copilot-instructions.md` | Always-on                       | Copilot  | Project-wide non-negotiables only (eats context)  |
| `AGENTS.md`     | root or any subdirectory          | Always-on; nearest file wins    | **Yes**  | Cross-tool context; supports `@path` includes     |
| Instructions    | `instructions/*.instructions.md`  | Auto, by `applyTo:` glob        | Copilot  | Language/framework conventions; `excludeAgent:` to scope |
| Skills          | `skills/<name>/SKILL.md`          | Auto-discovered via description, or `/name` | **Yes** | Runbooks **and** slash commands; description = keywords; `name` must match the directory |
| Custom Agents   | `agents/*.agent.md`               | Agent picker, chained via `handoffs:`, or autonomous | Copilot | Personas (formerly chatmodes) and task agents (plan→implement→review + 50+ specialist reviewers) |
| Hooks           | `hooks/*.json`                    | 14 lifecycle events             | Copilot  | Policy gates, audit, observability                |
| Agent Plugin    | `plugin.json` + `skills/` + `mcp.json` | Marketplace install        | **Yes**  | Shipping the whole bundle to other teams          |
| Prompts ⚠️      | `prompts/*.prompt.md`             | Manual `/command`               | No       | **Legacy — do not add new ones.** Write a skill.  |

Model selection priority: frontmatter `model:` > model picker > Auto. Custom-agent frontmatter overrides the user's picker. Skills have **no `model:` field** — they are cross-tool. See `COPILOT-CHEATSHEET.md` for the comprehensive task → model routing table.

> **Prompt files run only in the Local agent harness.** Copilot CLI, the Copilot cloud agent, and Agent Plugins express slash commands as skills. All 10 `.prompt.md` files here were migrated to `.github/skills/<name>/SKILL.md` on 2026-08-17 and deprecated with removal on 2026-11-16; the originals are retained so the legacy format stays documented.

> The legacy `.chatmode.md` primitive was deprecated by GitHub Copilot in 2026; persona "chat modes" are now Custom Agents. The `.github/chatmodes/` directory and the legacy `experimental.chatModes` setting were removed in this repo on 2026-05-07.

> GitHub renamed **"Copilot coding agent" → "Copilot cloud agent"** in April 2026. Use the current name in new content.

## Architecture: model roster currency

`.github/model-compatibility.json` is the source of truth and carries `lastVerified` + `sourceOfTruth`. **Copilot's roster turns over faster than anything else in this repo** — every model this repo originally routed to (`o3`, `o4-mini`, `gpt-4.1`, `gemini-2.5-pro`, `gemini-2.0-flash`) has since been retired, and Claude Sonnet 4.5/4.6 + Opus 4.5/4.6 retire 2026-09-01.

- Re-verify quarterly against <https://docs.github.com/en/copilot/reference/ai-models/supported-models>.
- Retiring a model means **moving it into the `deprecated` block with a `replaceWith`**, not deleting it — that is what makes `model-refs.sh` failures self-explaining.
- The `slots` block and `github.copilot.chat.models` in `.vscode/settings.json` mirror each other; change both.
- 1M context and reasoning level are now per-model **capabilities**, not tiers. Prefer raising reasoning effort over escalating to a pricier model.

## Architecture: the generator (`copilot-setup.sh`)

`copilot-setup.sh` is a ~95KB bash script of `cat > path << 'HEREDOC'` blocks. It is the canonical body for every "generated" asset in the manifest. Implications:

- If `manifest.json` marks an asset `"generated": true`, **edit it inside the heredoc in `copilot-setup.sh`** rather than only the file on disk — otherwise re-running the generator overwrites the change and the two drift.
- Hand-maintained assets (`"generated": false`) live only in `.github/` and are never touched by the generator.
- `manifest-sync.sh` does not detect generator/file drift directly; doc-consistency and reviewer judgment do.

## MCP security posture

Three profiles in `.github/copilot-mcp-profiles.json`: **read-only** (default, context7 only), **standard** (adds GitHub reads), **elevated** (write ops, deployments, PR creation). Never assume elevated; agent/skill authors should document which profile their workflow needs.

## Conventions specific to working in this repo

- Shell scripts: `set -euo pipefail` at the top. Match the existing style of color helpers (`pass`/`fail`/`warn`/`info`/`header`) when adding to `copilot-onboarding.sh` / `copilot-discover.sh` / `copilot-health.sh`.
- `manifest-sync.sh` parses the manifest with `awk -F'"' '/"path"/'` — keep `"path":` keys on their own line so this regex still works.
- Frontmatter is YAML between `---` fences; `frontmatter.sh` enforces required fields per asset type (see `GOVERNANCE.md` table).
- Skill discoverability hinges entirely on the `description:` field — write it as natural-language search keywords, not a title.
- Conventional Commits enforced: `<type>(<scope>): <subject>` with types `feat|fix|chore|docs|refactor|test|ci|perf`.

## Where to look first

- `README.md` — top-level overview and quick start
- `COPILOT-CHEATSHEET.md` — the comprehensive guide; cite this for "how does X work" questions
- `.github/GOVERNANCE.md` — checklist for adding/deprecating assets
- `COPILOT-CHANGELOG.md` — recent asset changes, including the modernization plan tags (R1–R12)
- `docs/plans/` and `docs/decisions/` — design rationale for the governance system
