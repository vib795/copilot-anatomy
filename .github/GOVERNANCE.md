# Copilot Asset Governance

## Adding New Assets

Before merging a new prompt, skill, agent, or instruction file, complete
this checklist. CI will enforce manifest sync and frontmatter validation automatically.

### Required checklist

- [ ] **Manifest entry** — asset added to `.github/copilot-asset-manifest.json` with:
  - `path`: relative file path
  - `owner`: team responsible for maintenance
  - `classification`: `core`, `workflow`, or `extension`
  - `generated`: `true` if produced by `copilot-setup.sh`, `false` if hand-maintained
  - `description`: one-line purpose description

- [ ] **Frontmatter** — YAML frontmatter includes required fields:
  - Skills: `name` (**must exactly match the directory name**) and `description`
    (≤1024 chars, written as search keywords). Optional: `argument-hint`,
    `user-invocable`, `disable-model-invocation`, `context: fork`.
    Skills have **no `model:` field** — they are cross-tool.
  - Agents: `description` (model optional). Custom Agents (the persona kind,
    formerly chat modes) additionally take `name`, `user-invocable`, `target`.
  - Instructions: `applyTo:` glob; optional `excludeAgent:` to scope a rule
    to (or away from) code review vs. the cloud agent.
  - Prompts (**legacy**): `model`, `description`

- [ ] **Primitive choice** — new slash commands are authored as **skills**, not
  prompt files. Prompt files run only in the Local agent harness and are not
  portable to Copilot CLI, the cloud agent, or an Agent Plugin. Adding a new
  `.prompt.md` requires an explicit justification in the PR description.

- [ ] **Model reference** — if `model:` is set, it references a model in
  `.github/model-compatibility.json` that is **not** in that file's `deprecated`
  block

- [ ] **Naming** — file follows kebab-case convention:
  - `my-skill/SKILL.md` (directory is kebab-case, and `name:` matches it)
  - `my-agent.agent.md` (replaces the legacy `.chatmode.md` primitive)
  - `my-instructions.instructions.md`
  - `my-prompt.prompt.md` (legacy)

- [ ] **Plugin validity** — if the change touches `.github/plugin.json`,
  `.github/mcp.json`, or any skill, `bash .github/eval/checks/plugin-manifest.sh`
  passes. The Agent Plugins root manifest is a **closed** object; only
  `$schema`, `name`, `version`, `description`, `author`, `homepage`,
  `repository`, `license`, `keywords`, and `extensions` are permitted.

- [ ] **Changelog** — entry added to `COPILOT-CHANGELOG.md` under `[Unreleased]`

- [ ] **Ownership** — a specific team or individual is declared as owner in the manifest

### Deprecating assets

1. Add a `### Deprecated` entry in `COPILOT-CHANGELOG.md` with a removal date (minimum 60 days)
2. Add a deprecation notice to the asset file itself (comment at top)
3. Update the manifest entry to include `"deprecated": true, "deprecationDate": "YYYY-MM-DD", "removalDate": "YYYY-MM-DD"`
4. After the grace period, remove the file and manifest entry; log under `### Removed`

### Ownership transfer

1. Update the `owner` field in `.github/copilot-asset-manifest.json`
2. Add a changelog entry noting the transfer
3. Ensure the new owner has reviewed and accepted the asset

## Automated enforcement

The following checks run automatically via `.github/workflows/copilot-eval.yml`:

| Check              | What it validates                                  | Blocking |
| ------------------ | -------------------------------------------------- | -------- |
| `naming.sh`        | Kebab-case file names, correct extensions          | Yes      |
| `frontmatter.sh`   | Required YAML frontmatter fields                   | Yes      |
| `model-refs.sh`    | Model names exist in compatibility matrix          | Yes      |
| `manifest-sync.sh` | Every file in manifest exists; no untracked assets | Yes      |
| `governance.sh`    | Owner, classification, description in manifest     | Yes      |
| `doc-consistency.sh`| Stale references, duplicate guidance, conflicts   | Warn     |
| `deprecation.sh`   | 60-day grace period, expired asset detection       | Yes      |
| `plugin-manifest.sh`| Agent Plugins 1.0 package: closed manifest fields, skill `name` matches its directory, MCP server schema | Yes |

## Keeping the model roster current

Copilot's model roster turns over faster than anything else in this repo. A
retired model in frontmatter is a hard CI failure, not a warning.

- `.github/model-compatibility.json` carries `lastVerified` and `sourceOfTruth`.
  **Re-verify quarterly** against
  <https://docs.github.com/en/copilot/reference/ai-models/supported-models>.
- When a model is retired, move it into that file's `deprecated` block with a
  `replaceWith` value rather than deleting it. `model-refs.sh` then fails with
  a self-explaining message instead of an opaque "not in matrix".
- Update the `slots` block **and** `github.copilot.chat.models` in
  `.vscode/settings.json` together — they mirror each other.
- Prefer raising the reasoning level on the current model over re-pointing a
  slot at a more expensive one.
