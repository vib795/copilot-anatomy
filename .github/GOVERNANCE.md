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
  - Prompts: `model`, `description`
  - Agents: `description` (model optional). Custom Agents (the persona kind,
    formerly chat modes) additionally take `name`, `user-invocable`, `target`.
  - Skills: `description` field or trigger keywords in first 10 lines of SKILL.md

- [ ] **Model reference** — if `model:` is set, it references a model in `.github/model-compatibility.json`

- [ ] **Naming** — file follows kebab-case convention:
  - `my-prompt.prompt.md`
  - `my-agent.agent.md` (replaces the legacy `.chatmode.md` primitive)
  - `my-instructions.instructions.md`
  - `my-skill/SKILL.md` (directory is kebab-case)

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
