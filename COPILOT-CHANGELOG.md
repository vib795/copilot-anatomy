# Copilot Assets Changelog

All notable changes to Copilot assets (prompts, skills, agents, chatmodes,
instructions, workflows, and configuration) are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- Wave 2 curriculum (10 lab skills + 2 capstone prompts) — "From Individual Proficiency → Delivery-Integrated, Team-Scale AI Execution", imported from the Wave 2 Proposed Curriculum sheet. Ten `wave2-*` skill directories under `.github/skills/` — weeks 1–2 (Advanced Agent Building & Multi-Step Workflows): chaining-agents, context-engineering, guardrails-error-recovery, cross-persona-collaboration, impact-tracking; weeks 3–4 (Delivery Integration & Reusable Assets): embedding-ai-project, reusable-accelerators, team-standards-agent-library, ai-estimation-planning, ai-delivery-playbook. Persona-specific labs carry `ba-track.md` / `dev-track.md` / `qa-track.md` alongside `SKILL.md`.
- `.github/prompts/wave2-capstone-delivery.prompt.md` — weeks 1–2 capstone: end-to-end delivery scenario with chained agents and cross-persona handoffs (`/wave2-capstone-delivery`).
- `.github/prompts/wave2-capstone-accelerator.prompt.md` — weeks 3–4 capstone hackathon: build a governance-clean reusable accelerator, judged on evidence, reusability, governance, and craft (`/wave2-capstone-accelerator`).
- `docs/curriculum/wave-2/README.md` — curriculum map: day-by-day lab → asset table, lab threading, and cohort-run instructions.

- `AGENTS.md` at repo root — cross-tool instruction file recognized by Copilot, Claude Code, Cursor, Aider, and other agents that read `AGENTS.md` alongside `CLAUDE.md` and `GEMINI.md`.
- `.vscode/settings.json` — current canonical chat-customization location keys: `chat.agentFilesLocations`, `chat.agentSkillsLocations`, `chat.promptFilesLocations`, `chat.instructionsFilesLocations`. New flags: `chat.agent.enabled`, `chat.useCustomAgentHooks`, `chat.mcp.discovery.enabled`, `chat.useCustomizationsInParentRepositories`, `github.copilot.chat.organizationCustomAgents.enabled`.
- `.vscode/mcp.json` — examples of the `streamable-http` server type, `envFile`, `dev: { watch }`, and the `sandboxEnabled` / `sandbox` block (filesystem + network rules).
- `.github/hooks/copilot-hooks.json` — entries for the four previously-missing hook events: `userPromptSubmitted`, `preToolUse`, `postToolUse`, `errorOccurred`. The `preToolUse` entry runs the existing destructive-commands / broad-permissions / secret-hygiene policy scripts so a non-zero exit blocks the pending tool call.
- `.github/copilot-mcp-config.json` — header documenting that this file follows the cloud-coding-agent MCP schema (`mcpServers` top-level key, mandatory per-server `tools:` allow-list, `COPILOT_MCP_*` env-var convention, repo-Settings UI as source of truth) versus the in-IDE `.vscode/mcp.json` schema.
- `COPILOT-CHEATSHEET.md` — new "Schema currency note" banner at the top covering the four 2026 schema migrations. New section: `.github/copilot-mcp-config.json` (cloud agent MCP) with a side-by-side schema comparison table. New skills frontmatter reference covering `argument-hint`, `user-invocable`, `disable-model-invocation`, `context`. New `gh skills install` reference.
- Deprecation notice inside each `.github/chatmodes/*.chatmode.md` (6 files) pointing users at the upcoming Custom Agents migration. *(Subsequently removed when the migration completed — see Removed below.)*
- `.github/agents/{architect,code-reviewer,devops-assistant,longcontext-reader,security-auditor,test-writer}.agent.md` — 6 persona Custom Agents migrated from `.github/chatmodes/`. Frontmatter follows the current schema (`name`, `description`, `model`, `user-invocable`, `target`). Bodies preserved verbatim from the original chatmode files.
- `AGENTS.md` (also updated): unified Custom Agents description (persona + task agents share the schema).

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
- `COPILOT-CHEATSHEET.md` — added governance section with manifest, eval, and changelog guidance; migrated `mode:` examples to the new `agent:` field syntax
- `copilot-hooks.yml` — integrated 3 policy check steps in pre-action-checks job
- `copilot-eval.yml` — added governance, doc-consistency, and deprecation validation steps
- `copilot-asset-manifest.json` — added eval-checks (7), policy-checks (3), mcp-profiles entries; expanded agents (53) and skills (64) coverage
- `manifest-sync.sh` — extended to check agents, skills, and eval workflow filesystem↔manifest sync
- Prompt frontmatter — migrated `agent: edit` → `agent: agent` in `fix-issue.prompt.md`, `document.prompt.md`, `test-gen.prompt.md` to match the current Copilot field schema (`ask | agent | plan | <custom-agent-name>`); the deprecated `mode: ask|edit|agent` form is no longer documented. Updated `copilot-setup.sh` heredocs and `copilot-anatomy.html` visualizer accordingly.
- `.github/workflows/copilot-setup-steps.yml` — replaced the non-existent `on: copilot:` trigger with `workflow_dispatch` + paths-filtered `push`/`pull_request`. The cloud coding agent invokes the workflow internally by discovering the required `copilot-setup-steps` job name; the explicit `on:` block now only governs CI self-validation. Added `timeout-minutes: 30` (under the 59-minute coding-agent hard limit).
- `.github/workflows/copilot-hooks.yml` — replaced the non-existent `on: copilot_pre_action` / `copilot_post_action` triggers with real `workflow_dispatch` + `pull_request` triggers (paths-filtered). Renamed jobs to `policy-pre-write` and `policy-post-write` so it's clear this is the CI mirror of the local hook scripts in `.github/hooks/copilot-hooks.json`; the canonical hook mechanism is the `hooks.json` file, not the workflow.
- `.copilotignore` — header note clarifying the file is a community convention, not an official Copilot feature; pointer to the Content Exclusion API (UI + REST API public preview, Feb 2026) for real enforcement.

### Deprecated

- None

### Removed

- `.github/chatmodes/` directory (6 `.chatmode.md` files: `architect`, `code-reviewer`, `devops-assistant`, `longcontext-reader`, `security-auditor`, `test-writer`). The chat-modes primitive was deprecated by GitHub Copilot in 2026 and folded into Custom Agents (`.agent.md`). Manifest entries moved from `assets.chatmodes` into `assets.agents` with updated paths and descriptions noting the migration date.
- `github.copilot.chat.experimental.chatModes` setting from `.vscode/settings.json` and from the `copilot-setup.sh` heredoc — replaced by `chat.agentFilesLocations` (canonical) plus `chat.agent.enabled`.
- The `.github/chatmodes` entry inside `chat.agentFilesLocations` (no longer needed after the migration).
- `mkdir "$ROOT/.github/chatmodes"` in `copilot-setup.sh` — generator no longer creates the legacy directory in target repos.
- `chatmode` asset type from `copilot-discover.sh` indexer (folded into `agent`).
- `chatmodes/` folder tile from the `copilot-anatomy.html` visualizer (merged into the `agents/` tile, which now hosts both task and persona agents).

### Fixed

- 49 of 59 `.github/agents/*.agent.md` files had every newline stripped — each file was one single line, with frontmatter keys run together and all body structure (headings, lists, example blocks, tables, code fences) collapsed. Restored proper multi-line formatting; verified whitespace-stripped content is byte-identical to the prior state for every file.
- 14 of those agent files also carried cp437 mojibake from the same encoding accident (`ΓÇö` for em dash, `ΓåÆ` for arrow, garbled emoji, `┬▓` for superscript-2). Reversed deterministically; zero reversible mojibake sequences remain in the repo.
- `copilot-health.sh` — aborted under `set -euo pipefail` because it ran `find` on the removed `.github/chatmodes/` directory (broken since the 2026-05-07 chatmode removal). The chatmode count is now guarded on directory existence; the health dashboard regenerates again.

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
