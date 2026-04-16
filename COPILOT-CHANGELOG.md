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
- MCP least-privilege profiles (`.github/copilot-mcp-profiles.json`) — three-tier profiles: read-only (default), standard, elevated (R5)
- Policy check: destructive commands (`.github/hooks/scripts/destructive-commands.sh`) — warn-only scan for rm -rf, DROP TABLE, force-push, etc. (R6)
- Policy check: broad permissions (`.github/hooks/scripts/broad-permissions.sh`) — warn-only scan for IAM wildcards, admin policies (R6)
- Policy check: secret hygiene (`.github/hooks/scripts/secret-hygiene.sh`) — warn-only scan for secrets in Dockerfiles, API keys (R6)
- Governance metadata validation (`.github/eval/checks/governance.sh`) — enforces owner, classification, description on all manifest entries (R7)
- Guided onboarding (`copilot-onboarding.sh`) — prerequisite verification, role-based quick starts for developer/reviewer/platform personas (R8)
- Asset discoverability (`copilot-discover.sh`) — task-to-asset mapping with keyword search, interactive menu, and list commands (R9)
- Health dashboard (`copilot-health.sh`) — dual output: JSON canonical (`.github/health-report.json`) and Markdown summary (`.github/HEALTH.md`) (R10)
- Documentation consistency check (`.github/eval/checks/doc-consistency.sh`) — stale references, duplicate guidance, contradictory directives (R11)
- Deprecation lifecycle check (`.github/eval/checks/deprecation.sh`) — 60-day minimum grace period enforcement, expired asset detection (R12)

### Changed

- `copilot-instructions.md` — added governance, model compatibility references, and MCP security posture section
- `COPILOT-CHEATSHEET.md` — added governance section with manifest, eval, and changelog guidance
- `copilot-hooks.yml` — integrated 3 policy check steps in pre-action-checks job
- `copilot-eval.yml` — added governance, doc-consistency, and deprecation validation steps
- `copilot-asset-manifest.json` — added eval-checks (7), policy-checks (3), mcp-profiles entries; expanded agents (53) and skills (64) coverage
- `manifest-sync.sh` — extended to check agents, skills, and eval workflow filesystem↔manifest sync

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
