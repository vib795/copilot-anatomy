# Copilot Assets Changelog

All notable changes to Copilot assets (prompts, skills, agents, chatmodes,
instructions, workflows, and configuration) are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- Asset manifest (`.github/copilot-asset-manifest.json`) — single source of truth for all Copilot assets with ownership and classification (R1)
- Model compatibility matrix (`.github/model-compatibility.json`) — defines available models, capabilities, slots, and fallback policy (R3)
- Evaluation harness framework (`.github/eval/`) — deterministic checks for frontmatter, naming, model refs, and manifest sync (R2)
- CI evaluation workflow (`.github/workflows/copilot-eval.yml`) — runs deterministic validation on PRs touching Copilot assets (R2)
- Governance checklist (`.github/GOVERNANCE.md`) — required metadata and ownership for new Copilot assets (R7 preview)
- Discovery gate decisions (docs/decisions/2026-04-15-discovery-gate.md) — resolved R2/R5/R6 research items

### Changed

- `copilot-instructions.md` — added governance and model compatibility references
- `COPILOT-CHEATSHEET.md` — added governance section with manifest, eval, and changelog guidance

### Deprecated

- None

### Removed

- None

### Security

- None

---

## Template for future entries

```markdown
## [YYYY-MM-DD]

### Added

- [asset-type] description (Rn reference if applicable)

### Changed

- [asset-type] description of behavioral change

### Deprecated

- [asset-type] description — removal scheduled YYYY-MM-DD (60-day minimum)

### Removed

- [asset-type] description — deprecated on YYYY-MM-DD

### Security

- [asset-type] description of security-relevant change
```
