# Discovery Gate Decisions

Date: 2026-04-15
Status: Resolved
Source: docs/brainstorms/2026-04-15-copilot-setup-modernization-requirements.md

## R2 — Evaluation Harness Shape

**Decision**: Two-track shell-based harness under `.github/eval/`.

### Deterministic track

Shell scripts that validate structural correctness with zero flake risk:

- Frontmatter schema validation (required fields: `model`, `description` for prompts/agents/chatmodes)
- File naming conventions (kebab-case, correct extensions)
- Model references match entries in the compatibility matrix
- Skill SKILL.md files have `description` field for auto-discovery
- No orphaned assets (referenced in manifest but file missing, or file exists but not in manifest)

### Rubric track

YAML-defined test definitions for key prompts and skills:

- Each test specifies: input prompt, expected behavior criteria, pass/fail rubric
- Bounded retries: max 3 attempts per rubric test before declaring failure
- Thresholded release gating: deterministic checks must be 100% pass; rubric checks must be ≥80% pass rate across the suite
- Runs in CI via a dedicated `copilot-eval.yml` workflow

### Directory structure

```
.github/eval/
├── checks/              # Deterministic shell scripts
│   ├── frontmatter.sh   # Validate frontmatter schema
│   ├── naming.sh        # Validate file naming conventions
│   ├── model-refs.sh    # Validate model references
│   └── manifest-sync.sh # Validate manifest ↔ filesystem sync
└── rubrics/             # Rubric YAML definitions (Phase 2+)
    └── README.md        # Rubric format spec and examples
```

**Rationale**: Shell-based checks are zero-dependency, fast, and match the repo's existing `set -euo pipefail` convention. Rubric definitions are deferred to individual YAML files so teams can add tests incrementally without modifying CI.

---

## R5 — MCP Tool Profile Mapping

**Decision**: Three profiles derived from current MCP server capabilities.

| Profile       | Servers                                          | Tools                                                                                                                                                   | Default                                    |
| ------------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| **read-only** | `context7`                                       | `["*"]`                                                                                                                                                 | Yes — active by default                    |
| **standard**  | `context7`, `github` (read ops)                  | context7: `["*"]`, github: `["get_issue", "get_file_contents", "list_commits", "search_code", "list_issues", "list_pull_requests", "get_pull_request"]` | No — requires explicit activation          |
| **elevated**  | All (`context7`, `github`, `azure`, `terraform`) | `["*"]` on all servers                                                                                                                                  | No — requires explicit per-task activation |

### Implementation approach

- Define profiles in `.github/copilot-mcp-profiles.json` as named configurations
- Default profile (`read-only`) is loaded by `.vscode/mcp.json`
- Standard and elevated profiles are documented with activation instructions
- `copilot-instructions.md` updated to reference default posture

**Rationale**: context7 is a documentation-only SSE server with no write capability — safe as default. GitHub, Azure, and Terraform servers have write operations that should require explicit elevation.

---

## R6 — False-Positive Thresholds

**Decision**: Per-check thresholds with a two-phase rollout protocol.

| Check                              | Type       | FP Risk | Threshold        | Rollout                      |
| ---------------------------------- | ---------- | ------- | ---------------- | ---------------------------- |
| Hardcoded credentials (regex)      | Pre-action | Medium  | ≤5% over 50 runs | Warn-only burn-in → blocking |
| Terraform state commit             | Pre-action | None    | N/A (binary)     | Immediate blocking           |
| Destructive command patterns (new) | Pre-action | Medium  | ≤5% over 50 runs | Warn-only burn-in → blocking |
| Broad cloud permissions (new)      | Pre-action | High    | ≤3% over 50 runs | Warn-only burn-in → blocking |
| Secret hygiene (new)               | Pre-action | Medium  | ≤5% over 50 runs | Warn-only burn-in → blocking |

### Transition protocol

1. New checks deploy in **warn-only** mode: log findings but `exit 0`
2. Track false-positive count per check over rolling 50-run window
3. When FP rate drops below threshold for consecutive 50 runs, promote to **blocking** (`exit 1`)
4. Document transition date and FP rate at transition in this file

### Burn-in tracking format

Each check records its burn-in state in CI annotations:

```
::notice title=policy-check::check=credential-scan mode=warn-only runs=34/50 fp_rate=2.1%
```

**Rationale**: Binary checks (tfstate) can block immediately. Regex-based checks need burn-in because pattern matching on code content has inherent ambiguity. The 50-run window provides statistical significance without excessive delay.
