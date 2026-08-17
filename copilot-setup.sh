#!/usr/bin/env bash
# =============================================================================
# copilot-setup.sh
# =============================================================================
# GitHub Copilot — Complete Multi-Model Configuration
# Supports: OpenAI (GPT-5.6 Terra, gpt-5.6-sol, claude-haiku-4-5), Anthropic (Claude Sonnet/Opus/Haiku),
#           Google (GPT-5.4, Gemini 3.7 Flash), and more via model picker.
#
# USAGE:  bash copilot-setup.sh [target-directory]
# If no directory is given, writes into the current directory.
#
# WHAT THIS CREATES:
#   .github/copilot-instructions.md   ← Always-on team instructions
#   .github/prompts/                  ← Slash commands (/review, /deploy, etc.)
#   .github/instructions/             ← Auto-loaded rules scoped by file type
#   .github/skills/                   ← Auto-discovered task workflows (SKILL.md)
#   .github/agents/                   ← Chainable specialist agents
#   .github/agents/                   ← VS Code persona agents (formerly chatmodes)
#   .github/workflows/                ← Agent bootstrap + policy hooks
#   .copilotignore                    ← Files excluded from context
#   .vscode/settings.json             ← Model routing + IDE config
#   .vscode/settings.local.json       ← Personal overrides (gitignored)
#   .vscode/mcp.json                  ← Tool servers (MCP)
#   .vscode/extensions.json           ← Recommended extensions
#
# MODEL ROUTING STRATEGY (why each model goes where):
#   gpt-5.6-sol             → Deep reasoning: architecture, trade-off analysis, planning
#   claude-haiku-4-5        → Speed: inline completions, quick fixes, boilerplate
#   gpt-5.6-terra        → General: devops commands, balanced tasks, default fallback
#   claude-sonnet-5 → Code quality: generation, review, docs, tests
#   claude-opus-5   → Thoroughness: security audits, complex review
#   claude-haiku-4-5  → Speed + cost: persona agents needing fast iteration
#   gpt-5.4    → Long context: reading large codebases, entire repos
#   gemini-3.7-flash  → Fast long context: quick analysis of many files
#
# NOTE ON model: IN FRONTMATTER:
#   Setting `model:` in .prompt.md / .agent.md files tells
#   Copilot which model to use when that file is activated. This is the
#   primary per-task routing mechanism. Not all features support it yet —
#   where it doesn't apply, the user's active model picker selection is used.
# =============================================================================

set -euo pipefail
ROOT="${1:-.}"

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║   GitHub Copilot Multi-Model Setup               ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "Writing into: $ROOT"
echo ""

mkdir -p \
  "$ROOT/.github/prompts" \
  "$ROOT/.github/instructions" \
  "$ROOT/.github/skills/helm-upgrade" \
  "$ROOT/.github/skills/debug-eks" \
  "$ROOT/.github/skills/terraform-plan" \
  "$ROOT/.github/skills/incident-triage" \
  "$ROOT/.github/agents" \
  "$ROOT/.github/hooks" \
  "$ROOT/.github/com.github.copilot" \
  "$ROOT/.github/workflows" \
  "$ROOT/.vscode"

# =============================================================================
# SECTION 1: ROOT FILES
# =============================================================================

# ─── .github/copilot-instructions.md ─────────────────────────────────────────
# PURPOSE: The single most important file. Always injected into Copilot's
#          context for every interaction in this repo — inline completions,
#          chat, agents, everything. Think of it as the team constitution.
# WHEN LOADED: Always, automatically.
# WHAT TO PUT HERE: Project overview, language conventions, things that apply
#          to nearly every task. Keep it concise — it eats context budget.
# WHAT TO AVOID: Long specifics that only apply to some tasks (use
#          instructions/ files or skills/ for those instead).
# MODEL: Not applicable — this is context, not a model selector.
# ─────────────────────────────────────────────────────────────────────────────
cat > "$ROOT/.github/copilot-instructions.md" << 'HEREDOC'
# GitHub Copilot — Team Instructions

<!--
  This file is ALWAYS injected into Copilot's context.
  Every model, every mode, every session reads this first.
  Keep it concise. Put task-specific detail in skills/ or prompts/.
-->

## What this project is

A polyglot monorepo: Java/Spring Boot microservices, Go CLI tools, Python scripts,
and Terraform/OpenTofu infrastructure. Services run on EKS, built via Jenkins,
artefacts in JFrog Artifactory.

## Available models in this project

We have access to all major model families. Use the right tool:
- **gpt-5.6-sol** → architecture decisions, complex reasoning, planning
- **claude-haiku-4-5** → fast completions, boilerplate, quick fixes
- **gpt-5.6-terra** → general-purpose, DevOps commands, balanced tasks
- **claude-sonnet-5** → code generation, review, documentation, tests
- **claude-opus-5** → security audits, thorough review, nuanced analysis
- **gpt-5.4** → reading large files or entire codebases (1M token context)
- **gemini-3.7-flash** → fast analysis of many files simultaneously

Use `/review`, `/fix-issue`, `/deploy`, `/architect`, `/security-scan` for
guided workflows. Type `/skills list` to see available skills.

## Code conventions

### Java 17 / Spring Boot 3
- Constructor injection over `@Autowired`. `record` types for DTOs.
- `@ControllerAdvice` + `ProblemDetail` (RFC 9457) for error responses.
- Tests: JUnit 5 + AssertJ. Prefer `@WebMvcTest`/`@DataJpaTest` slices.

### Go
- `fmt.Errorf("context: %w", err)` always. No global state.
- `golangci-lint` must pass. CLIs use `cobra` + `viper`.

### Python
- 3.11+, PEP 723 `uv` shebangs, `pydantic` models, `black` + `ruff`.

### Terraform / OpenTofu
- Tag all resources: `project`, `env`, `owner`. `for_each` over `count`.
- HTTP backend (Bento). Never commit `terraform.tfstate`.

### Kubernetes / Helm
- Resource requests + limits required. Probes required. Secrets via Vault/AWS SM.

## Non-negotiables
- No hardcoded credentials. Parameterised SQL only.
- Shell scripts: \`set -euo pipefail\` at top.
- Dockerfiles: multi-stage builds, pinned digest base images, non-root USER.
- Commits: \`<type>(<scope>): <subject>\` — feat/fix/chore/docs/refactor/test/ci/perf.

## Copilot asset governance
- New prompts/skills/agents require a manifest entry in \`.github/copilot-asset-manifest.json\`.
- Model references must exist in \`.github/model-compatibility.json\`.
- Changes to Copilot assets must include a \`COPILOT-CHANGELOG.md\` entry.
- See \`.github/GOVERNANCE.md\` for the full checklist.
HEREDOC

# ─── .copilotignore ───────────────────────────────────────────────────────────
# PURPOSE: Tells Copilot which files to exclude from its context window.
#          Uses the same syntax as .gitignore.
# WHY THIS MATTERS: Copilot pulls file content into context to understand
#          your project. Build artefacts, compiled classes, and secrets
#          waste tokens and can leak sensitive data.
# WHEN LOADED: Automatically, before every context assembly.
# TIP: Keep this aligned with .gitignore. Files excluded here are still
#          accessible on disk — they're just not sent to any AI model.
# ─────────────────────────────────────────────────────────────────────────────
cat > "$ROOT/.copilotignore" << 'HEREDOC'
# .copilotignore
# Excludes files from Copilot's context window.
# Same syntax as .gitignore. Does NOT affect git — files are still tracked.
# Think of this as your AI privacy/efficiency filter.

# ── Build artefacts (large, no signal for code generation) ──────────────────
target/
build/
dist/
out/
*.class
*.jar
*.war
*.ear

# ── Terraform state (sensitive, not useful for code gen) ─────────────────────
**/*.tfstate
**/*.tfstate.backup
**/.terraform/
*.tfplan
*.tfvars
!*.tfvars.example       # ← keep examples (useful for understanding variables)

# ── Secrets and credentials (NEVER send to any AI model) ─────────────────────
**/*.pem
**/*.key
**/*.p12
**/*.jks
**/*.pfx
**/*.env
.env.*
!.env.example
**/secrets/
**/credentials/

# ── Generated code (low signal, high token cost) ─────────────────────────────
**/generated/
**/*_pb2.py             # Python protobuf generated
**/*.pb.go              # Go protobuf generated

# ── Vendor / dependencies (already known by models from training) ─────────────
vendor/
node_modules/

# ── IDE and OS noise ──────────────────────────────────────────────────────────
.idea/
*.iml
.DS_Store
*.swp

# ── Logs (runtime data, not useful for understanding code) ───────────────────
*.log
*.hprof
hs_err_pid*.log

# ── Sensitive test fixtures ───────────────────────────────────────────────────
**/testdata/fixtures/prod-*
**/testdata/snapshots/real-*
HEREDOC

# =============================================================================
# SECTION 2: VS CODE CONFIG
# =============================================================================

# ─── .vscode/settings.json ────────────────────────────────────────────────────
# PURPOSE: Controls how Copilot behaves in VS Code for everyone on the team.
#          This file is COMMITTED — it sets the team defaults.
#
# KEY SETTINGS EXPLAINED:
#   github.copilot.enable        → which file types get inline completions
#   github.copilot.chat.models   → named model slots; referenced by prompt/agent
#                                  frontmatter via the "model:" field
#   codeGeneration.instructions  → optional explicit instruction-file load order
#                                  (modern: instruction files self-scope via
#                                   `applyTo:` and don't need explicit listing)
#   chat.agentFilesLocations     → tells VS Code where Custom Agents live
#   chat.agentSkillsLocations    → tells VS Code where Skills live
#   chat.agent.enabled           → enables the in-IDE agent mode
#
# MODEL ROUTING IN SETTINGS:
#   The named slots below ("fast", "reason", "longctx", etc.) are labels we
#   define here so prompt/agent files can reference them. The actual model
#   string must match what appears in your Copilot model picker.
#   Go to VS Code → Copilot Chat → model dropdown to verify exact names.
# ─────────────────────────────────────────────────────────────────────────────
cat > "$ROOT/.vscode/settings.json" << 'HEREDOC'
{
  // ══════════════════════════════════════════════════════════════════════════
  // GITHUB COPILOT — TEAM SETTINGS
  // This file is committed. Changes affect everyone. Personal overrides
  // go in .vscode/settings.local.json (gitignored).
  // ══════════════════════════════════════════════════════════════════════════

  // Which file types get inline code completions.
  // Set a type to false to disable completions there (e.g. plaintext).
  "github.copilot.enable": {
    "*":           true,
    "plaintext":   false,
    "markdown":    true,
    "scminput":    false,
    "yaml":        true,
    "terraform":   true,
    "dockerfile":  true
  },

  // ── MODEL ROUTING ─────────────────────────────────────────────────────────
  // Named model slots used across prompts, skills, and agents.
  // The string values must match your Copilot model picker exactly.
  // Check: VS Code → Copilot Chat panel → model dropdown → note the exact name.
  //
  // Mirrors the `slots` block in .github/model-compatibility.json — change both
  // together, then run `bash .github/eval/checks/model-refs.sh`.
  //
  // STRATEGY:
  //   "fast"     → claude-haiku-4-5   Speed: inline, boilerplate, trivial fixes
  //   "reason"   → gpt-5.6-sol        Reasoning: architecture, planning, debugging
  //   "code"     → claude-sonnet-5    Code quality: gen, review, tests, docs
  //   "thorough" → claude-opus-5      Thoroughness: security, deep review
  //   "longctx"  → gpt-5.4            Long context: reading entire codebases
  //   "balanced" → gpt-5.6-terra      Balanced: devops, general tasks, good default
  //
  // ROSTER NOTE (verified 2026-08-17): o3, o4-mini, gpt-4.1, gemini-2.5-pro and
  // gemini-2.0-flash have all been retired from Copilot. Claude Sonnet 4.5/4.6
  // and Opus 4.5/4.6 retire 2026-09-01. See the `deprecated` block in
  // .github/model-compatibility.json for the full replacement table.
  "github.copilot.chat.models": {
    "fast":      { "model": "claude-haiku-4-5" },
    "reason":    { "model": "gpt-5.6-sol" },
    "code":      { "model": "claude-sonnet-5" },
    "thorough":  { "model": "claude-opus-5" },
    "longctx":   { "model": "gpt-5.4" },
    "balanced":  { "model": "gpt-5.6-terra" }
  },

  // ── REASONING EFFORT ──────────────────────────────────────────────────────
  // Most 2026 frontier models expose a configurable reasoning level. Raising
  // the level on a mid-tier model is usually cheaper than escalating to a
  // flagship model — try this before switching `code` to `thorough`.
  // Available in VS Code, Copilot CLI, and Copilot cloud agent.
  "github.copilot.chat.reasoningEffort": "medium",

  // ── LONG CONTEXT ──────────────────────────────────────────────────────────
  // The 1M-token context window is a per-model capability (VS Code + CLI only),
  // not a separate model tier. Opting in costs more per request, so leave it
  // off by default and enable per-session when reading a whole repo.
  "github.copilot.chat.largeContext.enabled": false,

  // ── INLINE COMPLETIONS ────────────────────────────────────────────────────
  // The model used for grey-text autocomplete as you type.
  // claude-haiku-4-5 is ideal: fast enough to not interrupt typing, good quality.
  // For slower networks or machines, try mai-code-1.1-flash or gemini-3.7-flash.
  "github.copilot.inlineSuggest.enable": true,
  "github.copilot.inlineSuggest.syntaxMatchingLanguages": [
    "java", "go", "python", "typescript", "terraform",
    "hcl", "yaml", "dockerfile", "shellscript", "groovy"
  ],

  // ── FEATURE FLAGS ─────────────────────────────────────────────────────────
  // Enable Copilot agent mode (the in-IDE agent, not the Copilot cloud agent).
  "chat.agent.enabled": true,
  // Enable hooks declared in .agent.md frontmatter (`hooks:` field).
  "chat.useCustomAgentHooks": true,
  // Allow VS Code to discover MCP servers from other apps (Claude Desktop, etc.).
  "chat.mcp.discovery.enabled": {
    "claude-desktop": true,
    "windsurf": true,
    "cursor-global": true,
    "cursor-workspace": true
  },
  // Inherit chat customizations from parent repos in nested workspace setups.
  "chat.useCustomizationsInParentRepositories": true,
  // Allow custom agents from organization-level locations.
  "github.copilot.chat.organizationCustomAgents.enabled": true,
  // Keeps Copilot responses in English regardless of OS locale.
  "github.copilot.chat.localeOverride": "en",

  // ── ASSET DISCOVERY LOCATIONS ─────────────────────────────────────────────
  // Tell VS Code where to find each asset type. These are the current
  // canonical keys (replacing the older `chat.modeFilesLocations` and the
  // legacy `github.copilot.chat.experimental.chatModes` shim).
  "chat.agentFilesLocations": {
    ".github/agents": true
  },
  // Skills are an open standard shared with other agent tools. VS Code already
  // discovers `.github/skills`, `.claude/skills` and `.agents/skills` by
  // default; listing them keeps discovery explicit for mixed-tool teams.
  "chat.agentSkillsLocations": {
    ".github/skills": true,
    ".claude/skills": true,
    ".agents/skills": true
  },
  // LEGACY: prompt files run only in the Local agent harness. Copilot CLI, the
  // cloud agent, and Agent Plugins express slash commands as skills instead.
  // Keep this while migrating; see COPILOT-CHEATSHEET.md → "Prompts (legacy)".
  "chat.promptFilesLocations": {
    ".github/prompts": true
  },
  // Enables the built-in one-time "Migrate Prompts" action in the
  // AI Customizations overview, which converts prompt files into skills.
  "chat.customizations.promptMigration.enabled": true,
  "chat.instructionsFilesLocations": {
    ".github/instructions": true
  },

  // ── AGENT PLUGINS 1.0 ─────────────────────────────────────────────────────
  // This repo ships as an Agent Plugin (see .github/plugin.json). Registering
  // the plugin root locally lets VS Code load its skills and MCP servers
  // exactly as it would after installing from a marketplace — which is how you
  // test a plugin before publishing it.
  "chat.pluginLocations": {
    ".github": true
  },

  // ── AUTO-LOADED INSTRUCTIONS ───────────────────────────────────────────────
  // Modern: instruction files self-scope via `applyTo:` globs in their own
  // frontmatter, so this explicit list is no longer required. Kept here to
  // pin load order — files listed first are injected first.
  //
  // DEPRECATED (VS Code 1.102+): the sibling instruction-category settings
  //   github.copilot.chat.commitMessageGeneration.instructions
  //   github.copilot.chat.pullRequestDescriptionGeneration.instructions
  //   github.copilot.chat.reviewSelection.instructions
  // were removed. Use `applyTo:` in a single .instructions.md file instead.
  "github.copilot.chat.codeGeneration.instructions": [
    { "file": ".github/instructions/code-style.instructions.md" },
    { "file": ".github/instructions/testing.instructions.md" },
    { "file": ".github/instructions/api-conventions.instructions.md" },
    { "file": ".github/instructions/infrastructure.instructions.md" }
  ],

  // ══════════════════════════════════════════════════════════════════════════
  // EDITOR — TEAM DEFAULTS
  // ══════════════════════════════════════════════════════════════════════════
  "editor.formatOnSave":           true,
  "editor.rulers":                 [100],
  "editor.tabSize":                2,
  "files.trimTrailingWhitespace":  true,
  "files.insertFinalNewline":      true,
  "editor.bracketPairColorization.enabled": true,

  // Language-specific overrides
  "[java]": {
    "editor.tabSize": 4,
    "editor.defaultFormatter": "redhat.java"
  },
  "[go]": {
    "editor.tabSize":  4,
    "editor.defaultFormatter": "golang.go",
    "editor.formatOnSave": true
  },
  "[python]": {
    "editor.tabSize": 4,
    "editor.defaultFormatter": "ms-python.black-formatter"
  },
  "[terraform]": {
    "editor.tabSize": 2,
    "editor.defaultFormatter": "hashicorp.terraform"
  },
  "[yaml]": {
    "editor.tabSize": 2
  },

  // ══════════════════════════════════════════════════════════════════════════
  // LANGUAGE SERVERS
  // ══════════════════════════════════════════════════════════════════════════
  "java.compile.nullAnalysis.mode": "automatic",
  "java.configuration.runtimes": [{ "name": "JavaSE-17", "default": true }],
  "go.lintTool":          "golangci-lint",
  "go.lintOnSave":        "package",
  "go.testFlags":         ["-v", "-race"],
  "go.useLanguageServer": true,
  "python.analysis.typeCheckingMode": "basic",
  "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python",
  "terraform.languageServer.enable": true,

  // ══════════════════════════════════════════════════════════════════════════
  // FILE ASSOCIATIONS
  // ══════════════════════════════════════════════════════════════════════════
  "files.associations": {
    "*.tf":        "terraform",
    "*.tfvars":    "terraform",
    "*.hcl":       "hcl",
    "Jenkinsfile": "groovy"
  }
}
HEREDOC

# ─── .vscode/settings.local.json ─────────────────────────────────────────────
# PURPOSE: Personal machine-specific overrides. Gitignored — never committed.
#          Use this for your own model preferences, local paths, or
#          experimental settings you don't want to inflict on the team.
# HOW TO USE: Copy snippets you want from settings.json and override them.
# ADD TO .gitignore: .vscode/settings.local.json
# ─────────────────────────────────────────────────────────────────────────────
cat > "$ROOT/.vscode/settings.local.json" << 'HEREDOC'
{
  // ══════════════════════════════════════════════════════════════════════════
  // PERSONAL OVERRIDES — DO NOT COMMIT
  // Add this file to .gitignore: .vscode/settings.local.json
  // ══════════════════════════════════════════════════════════════════════════

  // Increase timeout if you're on a slow VPN or using large models like gpt-5.6-sol
  "github.copilot.advanced": {
    "timeout": 45000
  },

  // ── PERSONAL MODEL PREFERENCES ────────────────────────────────────────────
  // Override team model slots with your own preferences.
  // Useful if you have a different subscription tier than teammates.
  // Example: prefer Claude Opus over Sonnet for all code tasks:
  // "github.copilot.chat.models": {
  //   "code": { "model": "claude-opus-5" }
  // },

  // ── LOCAL TOOLCHAIN ───────────────────────────────────────────────────────
  // "java.jdt.ls.java.home": "/usr/local/opt/openjdk@17",
  // "python.defaultInterpreterPath": "/opt/homebrew/bin/python3.11",

  // ── TERMINAL ──────────────────────────────────────────────────────────────
  "terminal.integrated.fontFamily": "MesloLGS NF",
  "terminal.integrated.fontSize": 13,

  // ── EXPERIMENTAL ──────────────────────────────────────────────────────────
  // Enable bleeding-edge Copilot features not yet in team settings
  // "github.copilot.nextEditSuggestions.enabled": true
}
HEREDOC

# ─── .vscode/mcp.json — the "Skills" runtime layer ───────────────────────────
# PURPOSE: Defines MCP (Model Context Protocol) servers — external tools that
#          any AI model can call during agent mode. These are the runtime
#          capabilities: read GitHub issues, query Kubernetes, search Artifactory.
#
# HOW IT WORKS: When Copilot is in agent mode, it can call these tools
#          automatically without being explicitly told to. It decides on its own
#          that "to fix this bug I should check the GitHub issue" and calls the
#          GitHub MCP server.
#
# DIFFERENCE FROM SKILLS: Skills (SKILL.md) are instructions loaded into
#          context. MCP servers are live tool calls that return real data.
#          Together they cover "how to do X" (skill) + "get real data for X" (MCP).
#
# SETUP: Each server needs env vars set in your shell. See "Next steps" at the
#        end of this script for the full list.
# ─────────────────────────────────────────────────────────────────────────────
cat > "$ROOT/.vscode/mcp.json" << 'HEREDOC'
{
  // MCP (Model Context Protocol) Tool Servers
  // These give Copilot agent mode live access to external systems.
  // All models can use these tools — model choice doesn't affect tool access.
  //
  // ACTIVATION: Tools load when Copilot enters agent mode (@ agent in chat).
  // SECURITY: Each tool only has the permissions you grant via API keys/tokens.
  // COST: MCP tool calls count toward premium request usage.

  "servers": {

    // ── GITHUB ────────────────────────────────────────────────────────────
    // Reads issues, PRs, comments, repo structure, workflow runs.
    // Lets Copilot say "let me check the issue for context" automatically.
    // Required env var: GITHUB_TOKEN (personal access token with repo scope)
    "github": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "${env:GITHUB_TOKEN}" }
    },

    // ── FILESYSTEM ────────────────────────────────────────────────────────
    // Reads and writes files within the workspace root.
    // Sandboxed to ${workspaceFolder} — cannot escape the project directory.
    // Useful for agent mode to read files not in its active context.
    "filesystem": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "${workspaceFolder}"]
    },

    // ── KUBERNETES / EKS ─────────────────────────────────────────────────
    // Lists pods, reads logs, checks deployment status, views events.
    // Read-only by default (kubectl get/describe/logs).
    // Required env var: KUBECONFIG (path to your kubeconfig)
    "kubernetes": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-kubernetes"],
      "env": { "KUBECONFIG": "${env:KUBECONFIG}" }
    },

    // ── AWS ───────────────────────────────────────────────────────────────
    // Searches AWS documentation and service references.
    // Useful when writing Terraform or debugging AWS-specific errors.
    // Required env vars: AWS_PROFILE, AWS_REGION
    "aws-docs": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@aws/mcp-server-aws-documentation"],
      "env": {
        "AWS_PROFILE": "${env:AWS_PROFILE}",
        "AWS_REGION":  "us-east-1"
      }
    },

    // ── JFROG ARTIFACTORY ─────────────────────────────────────────────────
    // Searches packages, checks build info, verifies artefact versions.
    // Lets Copilot confirm "does version 2.3.1 exist in Artifactory?"
    // Required env vars: ARTIFACTORY_URL, ARTIFACTORY_TOKEN
    "artifactory": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@jfrog/mcp-server"],
      "env": {
        "JFROG_URL":          "${env:ARTIFACTORY_URL}",
        "JFROG_ACCESS_TOKEN": "${env:ARTIFACTORY_TOKEN}"
      }
    },

    // ── POSTGRES (read-only replica) ──────────────────────────────────────
    // Queries the database schema and runs read-only queries.
    // NEVER point at a production write replica.
    // Required env var: DB_READONLY_URL (postgres connection string)
    "postgres": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": { "POSTGRES_CONNECTION_STRING": "${env:DB_READONLY_URL}" }
    },

    // ── WEB SEARCH ────────────────────────────────────────────────────────
    // Searches the web for documentation, error messages, release notes.
    // Especially useful for "what does this error mean?" questions.
    // Required env var: BRAVE_API_KEY (free tier at brave.com/search/api)
    "brave-search": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": { "BRAVE_API_KEY": "${env:BRAVE_API_KEY}" }
    },

    // ── MEMORY ────────────────────────────────────────────────────────────
    // Persists key facts across Copilot sessions.
    // Copilot can store "the staging DB is postgres-staging.internal" and
    // recall it in future sessions without you repeating it.
    // No required env vars — stores locally.
    "memory": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
HEREDOC

# ─── .vscode/extensions.json ──────────────────────────────────────────────────
# PURPOSE: When a teammate clones this repo, VS Code prompts them to install
#          all "recommended" extensions listed here. This ensures everyone has
#          the same toolchain without manual setup docs.
# HOW: VS Code shows a notification: "This repo recommends extensions. Install?"
# ─────────────────────────────────────────────────────────────────────────────
cat > "$ROOT/.vscode/extensions.json" << 'HEREDOC'
{
  // Recommended extensions — VS Code will prompt teammates to install these.
  // Add extension IDs in the format "publisher.extension-name".
  // Find IDs: right-click any extension in VS Code → "Copy Extension ID".
  "recommendations": [
    // ── GitHub Copilot (required for everything in this setup) ───────────
    "github.copilot",
    "github.copilot-chat",

    // ── Java ─────────────────────────────────────────────────────────────
    "redhat.java",
    "vscjava.vscode-maven",
    "vscjava.vscode-java-test",
    "vscjava.vscode-spring-initializr",

    // ── Go ───────────────────────────────────────────────────────────────
    "golang.go",

    // ── Python ───────────────────────────────────────────────────────────
    "ms-python.python",
    "ms-python.black-formatter",
    "charliermarsh.ruff",

    // ── Infrastructure ────────────────────────────────────────────────────
    "hashicorp.terraform",
    "ms-kubernetes-tools.vscode-kubernetes-tools",
    "tim-koehler.helm-intellisense",
    "ms-azuretools.vscode-docker",

    // ── Data formats ──────────────────────────────────────────────────────
    "redhat.vscode-yaml",
    "tamasfe.even-better-toml",

    // ── Git & quality ─────────────────────────────────────────────────────
    "eamodio.gitlens",
    "mhutchie.git-graph",
    "sonarsource.sonarlint-vscode",
    "streetsidesoftware.code-spell-checker"
  ],

  // Extensions actively discouraged for this repo
  "unwantedRecommendations": []
}
HEREDOC

# =============================================================================
# SECTION 3: PROMPT FILES — Manual slash commands
# =============================================================================
# WHAT THESE ARE: Prompt files create named slash commands you invoke manually.
#   Type /review in Copilot Chat → loads review.prompt.md + runs it.
#   Type /deploy → loads deploy.prompt.md + runs it.
#
# FILE NAMING: Must end in .prompt.md and live in .github/prompts/.
# FRONTMATTER FIELDS:
#   agent:       which chat agent runs the command. One of:
#                  ask    — read-only chat response (no file edits)
#                  agent  — autonomous mode, modifies files directly
#                  plan   — produces a plan only, no edits
#                  <custom-agent-name>  — invokes an agent from .github/agents/
#                NOTE: replaces the deprecated `mode: ask|edit|agent` field.
#   model:       which AI model to use for THIS specific command
#   description: shown in the /command picker list
#
# MODEL ROUTING IN PROMPTS:
#   Each prompt picks the best model for its job.
#   This means /review uses Claude Sonnet while /architect uses gpt-5.6-sol —
#   automatically, without you switching models manually.
# =============================================================================

# ─── review.prompt.md ─────────────────────────────────────────────────────────
# WHY claude-sonnet-5: Best balance of code understanding + natural language
# for expressing review comments. Claude models are trained extensively on
# code review scenarios and follow multi-step instructions reliably.
# ─────────────────────────────────────────────────────────────────────────────
cat > "$ROOT/.github/prompts/review.prompt.md" << 'HEREDOC'
---
agent: ask
model: claude-sonnet-5
description: "Code review: correctness, security, performance, style, tests"
---

<!--
  SLASH COMMAND: /review
  MODEL: claude-sonnet-5 — best for structured multi-step code analysis
  AGENT: ask — read-only, produces a review report without editing files
-->

Review the selected code or active file. Work through these lenses in order
and group findings by lens:

## 1. Correctness
- Logic errors, off-by-one, unchecked nulls, missing error handling
- Java: unclosed resources, missing `@Transactional` rollback rules
- Go: goroutine leaks, missing `defer cancel()`, ignored error returns
- Python: mutable default args, bare `except:`, unvalidated user input

## 2. Security
- SQL/command/log injection risks
- Hardcoded credentials, tokens, or API keys
- Overly broad RBAC/IAM in YAML configs
- Missing authentication or authorisation checks

## 3. Performance
- N+1 queries or missing batch fetching
- Unnecessary allocations in hot paths
- Synchronous blocking calls that should be async

## 4. Style and maintainability
- Follows `.github/copilot-instructions.md` conventions?
- Magic numbers/strings that should be named constants
- Methods over ~40 lines that should be extracted
- Variable names that describe type rather than content

## 5. Tests
- Happy path covered?
- Primary failure/edge case covered?
- Are mocks testing the mock rather than real behaviour?

---
For each finding: **line range → issue in one sentence → concrete fix**.
End with:
- Overall verdict: `LGTM` / `needs minor changes` / `needs major rework`
- Top-priority fix if any changes are needed
HEREDOC

# ─── fix-issue.prompt.md ─────────────────────────────────────────────────────
# WHY claude-sonnet-5: Excellent at following multi-step diagnostic workflows
# and producing minimal targeted edits. Avoids over-engineering the fix.
# agent: agent — autonomous mode that actually modifies files.
# ─────────────────────────────────────────────────────────────────────────────
cat > "$ROOT/.github/prompts/fix-issue.prompt.md" << 'HEREDOC'
---
agent: agent
model: claude-sonnet-5
description: "Diagnose root cause and fix the bug in the active file"
---

<!--
  SLASH COMMAND: /fix-issue
  MODEL: claude-sonnet-5 — reliable at targeted code edits
  AGENT: agent — autonomous mode that modifies files directly
-->

Fix the bug or implement the small feature. Follow these steps exactly:

## Step 1 — State the problem
One sentence. If there's a JIRA/GitHub issue number, acknowledge it.

## Step 2 — Root cause
Trace the execution path. State WHY it fails before writing any code.
Do not skip this — guessing the fix without the root cause leads to regressions.

## Step 3 — Apply the fix
- Minimal change targeting the root cause only.
- Do not refactor unrelated code in the same edit.
- If the fix touches a public API, note callers that may break.
- Add an inline comment where the logic is non-obvious.

## Step 4 — Add or update a test
- Update the existing test if one covers this code path.
- Otherwise add a new test named after the scenario:
  - Java: `shouldReturn404WhenUserNotFound()`
  - Go: table-driven sub-test entry, not a new top-level function
  - Python: `test_raises_not_found_when_user_missing`

## Step 5 — Verification commands
Provide the exact commands to verify the fix:
```bash
# Java
./mvnw test -pl <module> -Dtest=<TestClass>

# Go
go test ./... -run TestTarget -race

# Python
pytest tests/test_target.py -v
```

---
Do not change unrelated files. Do not bump version numbers.
HEREDOC

# ─── deploy.prompt.md ────────────────────────────────────────────────────────
# WHY gpt-5.6-terra: DevOps command generation is a balanced task — needs code
# understanding but not deep reasoning. GPT-5.6 Terra is reliable for structured
# checklists and exact CLI command generation. Also faster than gpt-5.6-sol.
# ─────────────────────────────────────────────────────────────────────────────
cat > "$ROOT/.github/prompts/deploy.prompt.md" << 'HEREDOC'
---
agent: ask
model: gpt-5.6-terra
description: "Generate deployment checklist and Helm commands for the active service"
---

<!--
  SLASH COMMAND: /deploy
  MODEL: gpt-5.6-terra — reliable for structured DevOps checklists and CLI commands
  AGENT: ask — produces output for you to review, does not run commands
-->

Read the active file to identify: service name, version/image tag, and target environment.
Then produce the following — fill all `<placeholders>` from the file context:

## 1. Pre-flight checklist
- [ ] All CI checks green on the release branch
- [ ] Docker image `<registry>/<service>:<version>` exists in Artifactory
- [ ] `values-<env>.yaml` reviewed — resource limits and replica count correct
- [ ] Secrets rotated if this release touches authentication or credentials
- [ ] DB migrations tested against a staging database snapshot (if applicable)
- [ ] On-call engineer notified in #deployments Slack channel

## 2. Dry run (always run this first)
```bash
helm diff upgrade <service> charts/<service> \
  --namespace <namespace> \
  --values charts/<service>/values-<env>.yaml \
  --set image.tag=<version>
```
Review the diff carefully. Stop if any `-/+` (destroy + recreate) lines appear.

## 3. Live deploy
```bash
helm upgrade --install <service> charts/<service> \
  --namespace <namespace> \
  --values charts/<service>/values-<env>.yaml \
  --set image.tag=<version> \
  --atomic \
  --timeout 5m \
  --history-max 5
```
`--atomic` rolls back automatically if health checks fail within 5 minutes.

## 4. Smoke test
```bash
kubectl rollout status deployment/<service> -n <namespace> --timeout=3m
kubectl logs -l app=<service> -n <namespace> --tail=50
curl -sf https://<ingress-host>/actuator/health | jq .status
```

## 5. Rollback (if needed)
```bash
helm history <service> -n <namespace>          # list revisions
helm rollback <service> 0 -n <namespace>       # 0 = previous revision
```

## 6. Post-deploy
- [ ] Error rate and p99 latency unchanged in Datadog
- [ ] Alert rules re-enabled if they were silenced
- [ ] JIRA ticket moved to Done, #releases updated
HEREDOC

# ─── architect.prompt.md ─────────────────────────────────────────────────────
# WHY gpt-5.6-sol: Architecture decisions involve multi-step trade-off reasoning —
# exactly what gpt-5.6-sol was optimised for. It weighs options systematically,
# identifies second-order consequences, and produces structured ADRs.
# ─────────────────────────────────────────────────────────────────────────────
cat > "$ROOT/.github/prompts/architect.prompt.md" << 'HEREDOC'
---
agent: ask
model: gpt-5.6-sol
description: "System design, trade-off analysis, and Architecture Decision Records"
---

<!--
  SLASH COMMAND: /architect
  MODEL: gpt-5.6-sol — best for multi-step reasoning and weighing complex trade-offs
  AGENT: ask — produces design documents for team review
-->

Produce a structured architecture analysis for the described problem.

## Before proposing anything, clarify
1. Expected load / scale constraints
2. Consistency vs availability requirements
3. Team operational maturity (what complexity can be sustained on-call?)
4. Existing infrastructure constraints (what's already running?)

## Output format

### Options considered
For each option (minimum 2, maximum 4):
```
Option N: <name>
  What: <one paragraph describing the approach>
  Optimises for: <what this wins at>
  Trade-offs: <what this costs>
  Operational complexity: Low / Medium / High
  When to choose this: <specific conditions where this is the right call>
```

### Recommendation
State the recommended option and the exact conditions under which you'd
switch to an alternative.

### ADR (Architecture Decision Record)
```markdown
## ADR-NNN: <Title>

**Status**: Proposed | Accepted | Deprecated | Superseded by ADR-NNN

**Context**
<What problem are we solving? What constraints exist? What happens if we do nothing?>

**Decision**
<What are we doing?>

**Consequences**
Positive: <what gets better>
Negative: <what gets harder or more expensive>
Risks: <what could go wrong>

**Alternatives considered**
<What else did we look at and why did we reject it?>
```

---
Do not recommend complexity the team isn't ready to operate on a pager.
HEREDOC

# ─── security-scan.prompt.md ─────────────────────────────────────────────────
# WHY claude-opus-5: Security review requires the most thorough analysis —
# Claude Opus is the most capable Claude model and consistently outperforms
# on nuanced reasoning about attack vectors and subtle vulnerabilities.
# ─────────────────────────────────────────────────────────────────────────────
cat > "$ROOT/.github/prompts/security-scan.prompt.md" << 'HEREDOC'
---
agent: ask
model: claude-opus-5
description: "Comprehensive security audit — threat model, OWASP, CVE patterns"
---

<!--
  SLASH COMMAND: /security-scan
  MODEL: claude-opus-5 — most thorough analysis, catches subtle issues
  AGENT: ask — produces a security report, does not edit files
-->

Perform a thorough security audit of the selected code or active file.

## Threat model checklist

Work through each category. Only report findings — skip categories with nothing to flag:

**Authentication & Authorisation**
- Who is allowed to call this? Is the caller verified?
- Does the caller have permission for this specific resource (not just "is logged in")?
- Are there privilege escalation paths?

**Injection**
- SQL injection (raw string concat vs parameterised queries)
- Command injection (`exec.Command`, `Runtime.exec`, `subprocess.run` with user input)
- Log injection (user data interpolated into log messages)
- SSTI / XSS in template rendering

**Secrets & Data Exposure**
- Credentials in code, config, or environment strings that might be logged
- PII in logs, error messages, or API responses
- Insecure serialisation or exposure of internal objects

**Supply Chain**
- Unpinned dependency versions that could be hijacked
- Base images without digest pins
- Third-party scripts loaded from CDNs without integrity checks

**Infrastructure (if applicable)**
- YAML with `privileged: true`, `hostPID`, `runAsRoot`
- S3 `acl = "public-read"` or missing server-side encryption
- IAM policies using `*` resource or `*` action

## Severity ratings
🔴 Critical — remotely exploitable, high impact, low complexity
🟠 High — exploitable, significant data/privilege impact
🟡 Medium — requires specific conditions or limited impact
🔵 Low / Info — defence-in-depth, best practice, hardening

## Per finding
**What**: vulnerability class (e.g. "SQL injection")
**Where**: file:line
**Impact**: what an attacker achieves
**Fix**: concrete code change with example
**Reference**: OWASP / CWE link where applicable
HEREDOC

# ─── document.prompt.md ──────────────────────────────────────────────────────
# WHY claude-sonnet-5: Documentation writing requires clear, natural prose
# alongside accurate technical understanding. Claude Sonnet excels at both —
# it produces documentation that humans actually want to read.
# ─────────────────────────────────────────────────────────────────────────────
cat > "$ROOT/.github/prompts/document.prompt.md" << 'HEREDOC'
---
agent: agent
model: claude-sonnet-5
description: "Generate or update documentation for the selected code"
---

<!--
  SLASH COMMAND: /document
  MODEL: claude-sonnet-5 — natural prose + technical accuracy
  AGENT: agent — autonomous mode that updates documentation inline in the file
-->

Generate or update documentation for the selected code.
Apply the appropriate format for the file's language:

**Java** → Javadoc on every public class, method, constructor, and field.
Include `@param`, `@return`, `@throws`. For REST controllers add SpringDoc
`@Operation(summary=...)` and `@ApiResponse`.

**Go** → GoDoc on every exported symbol. First sentence is a headline ending
with the symbol name. Package-level doc in `doc.go`. Example:
```go
// NewUserService creates a UserService backed by the provided repository.
// It returns an error if the repository is nil.
func NewUserService(repo UserRepository) (*UserService, error) {
```

**Python** → Google-style docstrings on all public functions, classes, methods.
```python
def find_by_id(self, user_id: str) -> User:
    """Retrieves a user by their unique identifier.

    Args:
        user_id: The UUID of the user to retrieve.

    Returns:
        The User with the given ID.

    Raises:
        UserNotFoundError: If no user with the given ID exists.
    """
```

**Terraform** → `description` on every `variable` and `output` block.
Generate a `README.md` section in terraform-docs format if missing.

---
Rules:
- Document the WHAT and WHY — not the HOW (that's the code's job)
- Non-obvious preconditions and side effects always get documented
- Include a usage example where the API is non-trivial
- Never restate the code: `count++ // increment count` is noise
- No version history (that's git's job)
HEREDOC

# ─── explain-codebase.prompt.md ──────────────────────────────────────────────
# WHY gpt-5.4: This command is specifically for understanding large
# files or entire subsystems. GPT-5.4 has a 1M token context window —
# it can read your entire service in one shot. No other model comes close.
# ─────────────────────────────────────────────────────────────────────────────
cat > "$ROOT/.github/prompts/explain-codebase.prompt.md" << 'HEREDOC'
---
agent: ask
model: gpt-5.4
description: "Explain a large file, module, or subsystem — uses 1M token context"
---

<!--
  SLASH COMMAND: /explain-codebase
  MODEL: gpt-5.4 — 1M token context window, reads entire codebases
  AGENT: ask — produces an explanation document
  BEST FOR: Files > 2000 lines, entire packages, subsystems with many files
  TIP: Select multiple files before running this command for broader analysis
-->

Read all selected files or the active file and produce:

## 1. What this does (2-3 sentences max)
Plain language. No jargon. Suitable for a new engineer's first day.

## 2. How it works — key concepts
Identify the 3-5 most important concepts a reader needs to understand.
For each: name it, explain it in 2-3 sentences, reference the relevant code.

## 3. Data flow / request lifecycle
Trace a typical request or operation from entry point to exit.
Use numbered steps. Reference actual function/class names.

## 4. Key dependencies
What does this code depend on? What depends on it?
List only the non-obvious dependencies — skip obvious standard library use.

## 5. Gotchas and non-obvious behaviour
What would surprise a senior engineer reading this for the first time?
Concurrency concerns, hidden state, surprising error handling, performance cliffs.

## 6. Where to start if I need to change something
Point to the 2-3 files a new contributor should read first.
HEREDOC

# ─── test-gen.prompt.md ──────────────────────────────────────────────────────
# WHY claude-sonnet-5: Claude is consistently ranked best at generating
# tests that follow conventions. It produces realistic scenarios rather than
# trivial ones, and respects the testing patterns in the instructions files.
# ─────────────────────────────────────────────────────────────────────────────
cat > "$ROOT/.github/prompts/test-gen.prompt.md" << 'HEREDOC'
---
agent: agent
model: claude-sonnet-5
description: "Generate tests for the selected code following project conventions"
---

<!--
  SLASH COMMAND: /test-gen
  MODEL: claude-sonnet-5 — produces realistic, convention-following tests
  AGENT: agent — autonomous mode that adds test files or test cases
-->

Generate tests for the selected code. Follow `.github/instructions/testing.instructions.md`.

## What to produce

1. **Happy path test** — the normal case with valid inputs
2. **Boundary / edge cases** — empty input, max values, type boundaries
3. **Primary failure path** — the most likely error scenario
4. **At least one integration-adjacent test** — real repository / real HTTP

## Naming conventions
- Java: `shouldDescribeScenario()` e.g. `shouldReturn404WhenUserNotFound()`
- Go: `TestFunctionName/scenario_description` table-driven sub-test
- Python: `test_describes_scenario` e.g. `test_raises_not_found_when_user_missing`

## What NOT to do
- Do not test implementation details (private methods, internal state)
- Do not write tests that only test mocks
- Do not use `Thread.sleep` or real clocks — use fixed time sources
- Do not generate trivial tests: `assert user != null` alone is not a test
HEREDOC

# =============================================================================
# SECTION 4: INSTRUCTIONS FILES — Auto-loaded rules
# =============================================================================
# WHAT THESE ARE: Unlike copilot-instructions.md (always on for everything),
#   instruction files are scoped to specific file types via the applyTo: glob.
#   They're automatically loaded by Copilot when you open a matching file.
#
# FILE NAMING: Must end in .instructions.md and live in .github/instructions/.
# FRONTMATTER: applyTo: "glob pattern" scopes the file.
#   applyTo: "**/*.java"         → only for Java files
#   applyTo: "**/*Test*.java"    → only for Java test files
#   applyTo: "**"                → all files (use sparingly)
#
# WHEN LOADED: When Copilot generates code or edits for a matching file.
#   Also loaded for chat if you have a matching file open/selected.
#
# MODEL: Not set here — these are context, not commands. The model is
#   determined by whatever command or persona agent is active.
#
# REGISTERED IN: .vscode/settings.json → codeGeneration.instructions
# =============================================================================

cat > "$ROOT/.github/instructions/code-style.instructions.md" << 'HEREDOC'
---
applyTo: "**/*.{java,go,py,ts,tsx}"
---
<!--
  WHEN LOADED: Whenever Copilot generates code in Java, Go, Python, TypeScript.
  PURPOSE: Enforces consistent naming, formatting, and error handling.
  MODEL: Not set — loaded as context for whatever model is active.
-->

# Code style conventions

## Naming
Name variables after **what they contain**, not their type.
```java
// Wrong: List<User> userList
// Right: List<User> activeAdmins
```

| Construct | Java | Go | Python |
|-----------|------|----|--------|
| Class/type | `PascalCase` | `PascalCase` | `PascalCase` |
| Method/function | `camelCase` | `camelCase` | `snake_case` |
| Constant | `SCREAMING_SNAKE` | `PascalCase` (exported) | `SCREAMING_SNAKE` |
| Test | `shouldDoXWhenY` | `TestXWhenY/scenario` | `test_x_when_y` |

## Formatting
- 100-character line limit (Java, Python). `gofmt` handles Go automatically.
- Opening braces on the same line. No exceptions.
- One blank line between methods.

## Comments
- Public APIs: Javadoc / GoDoc / docstrings always.
- `TODO(username):` with a linked ticket. Never commit bare `FIXME`.
- Do not comment out dead code — delete it. Git is the undo stack.

## Error handling
- Java: typed checked exceptions for recoverable errors. Never swallow silently.
- Go: `fmt.Errorf("context: %w", err)`. Check every error return.
- Python: specific exception types. Never bare `except:`.
HEREDOC

cat > "$ROOT/.github/instructions/testing.instructions.md" << 'HEREDOC'
---
applyTo: "**/*{Test,Spec,_test,test_}.{java,go,py}"
---
<!--
  WHEN LOADED: Only for test files — keeps context focused.
  PURPOSE: Enforces testing patterns, prevents common mistakes.
  MODEL: Not set — loaded as context.
-->

# Testing conventions

## Core rules
1. Name tests after the **scenario**, not the method under test.
2. One assertion concept per test (multiple assert lines are fine if same concept).
3. Tests must be **deterministic** — no `Thread.sleep`, no wall-clock time.
4. Mock at integration **boundaries** only (HTTP, database, message bus).
   Prefer real objects everywhere else.

## Java (JUnit 5 + AssertJ)
- `@WebMvcTest`, `@DataJpaTest` slices over `@SpringBootTest`.
- WireMock for external HTTP stubs. `@Testcontainers` for real databases.
- Test builders: `testUser()`, `testOrder()` factory methods, not constructors.

## Go
- Table-driven tests for all non-trivial functions.
- `t.Parallel()` in all table sub-tests. Always run with `-race`.
- `httptest.NewRecorder` + `httptest.NewServer` for HTTP handler tests.

## Python
- `pytest.fixture` for shared setup. No `setUp`/`tearDown`.
- `@pytest.mark.integration` for slow/real-network tests.
- `responses` or `respx` for HTTP mocking, never `unittest.mock.patch` on `requests`.

## Coverage targets
| Layer | Minimum |
|-------|---------|
| Domain / service logic | 90% |
| REST controllers / handlers | 80% |
| Infrastructure adapters | 70% |
| CLI entry points | smoke test |
HEREDOC

cat > "$ROOT/.github/instructions/api-conventions.instructions.md" << 'HEREDOC'
---
applyTo: "**/{controller,handler,router,api,rest}/**/*.{java,go,py}"
---
<!--
  WHEN LOADED: For files in controller/handler/api directories.
  PURPOSE: Ensures consistent REST API design across all services.
  MODEL: Not set — loaded as context.
-->

# API conventions

## Resource design
- Plural nouns: `/users`, `/orders`. Max two nesting levels.
- Non-CRUD actions: `POST /payments/{id}/refund`.
- Query params for filtering/sorting — never in the path.

## HTTP status codes
| Scenario | Code |
|----------|------|
| Created | 201 + `Location` header |
| Async accepted | 202 |
| Delete success | 204 |
| Validation error | 422 |
| Auth missing | 401 |
| Forbidden | 403 |
| Conflict | 409 |
| Rate limited | 429 + `Retry-After` |

Never return 200 with an error body.

## Error shape (RFC 9457 Problem Details)
```json
{
  "type":     "https://api.example.com/errors/not-found",
  "title":    "Resource not found",
  "status":   404,
  "detail":   "User 'abc-123' does not exist.",
  "instance": "/users/abc-123",
  "traceId":  "4bf92f3577b34da6a3ce929d0e0e4736"
}
```
Always include `traceId` for log correlation.

## IDs and timestamps
- IDs: UUID v4 or ULID. Never expose auto-increment integers publicly.
- Timestamps: ISO 8601 UTC (`"2024-11-01T14:32:00Z"`). Never Unix epoch.

## Versioning
- URL path prefix: `/v1/users`. Breaking changes only bump major.
- Deprecated endpoints: `Deprecation: true` + `Sunset: <date>` response headers.
- 90-day minimum deprecation window before removal.
HEREDOC

cat > "$ROOT/.github/instructions/infrastructure.instructions.md" << 'HEREDOC'
---
applyTo: "**/*.{tf,tfvars,yml,yaml,Dockerfile}"
---
<!--
  WHEN LOADED: For Terraform, YAML, and Dockerfile files.
  PURPOSE: Enforces secure-by-default infrastructure patterns.
  MODEL: Not set — loaded as context.
-->

# Infrastructure conventions

## Terraform / OpenTofu
- Tag all resources: `project`, `env`, `owner`.
- `for_each` over `count`. HTTP backend — never commit `terraform.tfstate`.
- Every `variable` and `output` must have a `description`.
- Always `plan` and share the plan file before `apply` in production.

## Kubernetes / Helm
- `resources.requests` and `resources.limits` required on every container.
- Liveness and readiness probes required on all long-running containers.
- Secrets via External Secrets Operator (Vault / AWS SM). Never in `values.yaml`.
- Image tags: never `latest` in production charts. Always pin versions.

## Dockerfiles
- Multi-stage builds: builder compiles, final stage is minimal/distroless.
- Pin base image digests: `FROM eclipse-temurin:17-jre@sha256:abc...`
- Final stage: `USER 1001` — never run as root.
- No secrets in `ENV` or `ARG` — mount at runtime via secrets manager.

## GitHub Actions
- Pin action versions to full commit SHAs, not tags.
- Secrets via `${{ secrets.NAME }}` only. Never `echo $SECRET` in run steps.
- Set `retention-days` on all artefact uploads.
HEREDOC

# =============================================================================
# SECTION 5: SKILLS — Auto-discovered task workflows
# =============================================================================
# WHAT THESE ARE: SKILL.md files are the "how to do X in this project"
#   knowledge base. Unlike instructions (always loaded for matching files),
#   skills are loaded on demand when Copilot detects relevance.
#
# HOW DISCOVERY WORKS:
#   1. Copilot reads ONLY the name: and description: fields from all SKILL.md files.
#   2. If the description matches what you're asking, the full SKILL.md body is
#      injected into context automatically.
#   3. You can also invoke manually: type the skill name or /skill-name in chat.
#
# KEY INSIGHT: The description: field is the trigger. Write it to match the
#   natural language someone would use when they need this skill.
#   Bad:  "Helm skill for upgrading releases"
#   Good: "Use when asked to deploy, upgrade, rollback, or release a service"
#
# LOCATION OPTIONS:
#   .github/skills/<name>/SKILL.md    ← project-scoped (committed)
#   .claude/skills/<name>/SKILL.md    ← also works (shared with Claude Code)
#   ~/.copilot/skills/<name>/SKILL.md ← personal, works across all projects
#
# MODEL: Not set in SKILL.md — skills are context, not commands.
#   The active model (or persona agent's model) processes the skill's instructions.
# =============================================================================

# ─── helm-upgrade/SKILL.md ────────────────────────────────────────────────────
# TRIGGER PHRASES: "deploy", "upgrade", "helm release", "rollback service",
#                  "chart values", "image tag", "release history"
# ─────────────────────────────────────────────────────────────────────────────
cat > "$ROOT/.github/skills/helm-upgrade/SKILL.md" << 'HEREDOC'
---
name: helm-upgrade
description: >
  Use when asked to deploy, upgrade, roll back, or release a service to Kubernetes.
  Also triggers for questions about Helm chart values, image tags, release history,
  or when a deployment is failing or stuck.
license: MIT
---

# Helm upgrade — project runbook

## Pre-flight (always run these first)
```bash
# 1. Confirm cluster and namespace
kubectl config current-context
kubectl get namespace <namespace>

# 2. Diff before applying (requires helm-diff plugin)
helm diff upgrade <release> charts/<service> \
  --namespace <namespace> \
  --values charts/<service>/values-<env>.yaml \
  --set image.tag=<new-tag>
```
Stop if any `-/+` (destroy + recreate) lines appear — they are disruptive.

## Upgrade
```bash
helm upgrade --install <release> charts/<service> \
  --namespace <namespace> \
  --values charts/<service>/values-<env>.yaml \
  --set image.tag=<new-tag> \
  --atomic --timeout 5m --history-max 5
```
`--atomic` auto-rolls-back on health check failure.

## Smoke test
```bash
kubectl rollout status deployment/<release> -n <namespace> --timeout=3m
curl -sf https://<ingress-host>/actuator/health | jq .status
```

## Rollback
```bash
helm history <release> -n <namespace>          # list revisions
helm rollback <release> 0 -n <namespace>       # 0 = previous revision
```

## Failure patterns
| Symptom | Cause | Fix |
|---------|-------|-----|
| `ImagePullBackOff` | Wrong tag or missing Artifactory creds | `kubectl describe pod` → check events |
| Pod stuck `Pending` | Insufficient node resources | Check requests vs node capacity |
| Readiness probe failing | App not healthy at startup | Check logs, raise `initialDelaySeconds` |
| `another operation in progress` | Previous release stuck | Check and delete stuck Helm secret |

## Values file locations
```
charts/<service>/values.yaml           ← defaults
charts/<service>/values-dev.yaml       ← DEV overrides
charts/<service>/values-staging.yaml   ← staging
charts/<service>/values-prod.yaml      ← prod (PR required)
```
HEREDOC

# ─── debug-eks/SKILL.md ───────────────────────────────────────────────────────
# TRIGGER PHRASES: "pod crashing", "OOMKilled", "ImagePullBackOff", "pod pending",
#                  "check kubernetes", "debug deployment", "pod not starting"
# ─────────────────────────────────────────────────────────────────────────────
cat > "$ROOT/.github/skills/debug-eks/SKILL.md" << 'HEREDOC'
---
name: debug-eks
description: >
  Use when a pod is crashing, not starting, or behaving unexpectedly in Kubernetes/EKS.
  Also triggers for OOMKilled, ImagePullBackOff, CrashLoopBackOff, Pending pods,
  or any kubectl debugging questions.
license: MIT
---

# EKS debugging — triage order

Always follow this sequence. Don't jump to solutions before triage.

## Step 1 — Pod status
```bash
kubectl get pods -n <namespace> -l app=<service>
kubectl describe pod <pod-name> -n <namespace>
# ↑ Read the Events: section at the bottom — this is where the error lives.
```

## Step 2 — Logs
```bash
kubectl logs <pod-name> -n <namespace> --tail=200
kubectl logs <pod-name> -n <namespace> --previous --tail=200  # if crashed
kubectl logs -l app=<service> -n <namespace> --tail=100       # all pods
```

## Step 3 — Events
```bash
kubectl get events -n <namespace> --sort-by='.lastTimestamp' | tail -20
```

## Common failures

### CrashLoopBackOff
App crashes on startup. Check previous logs first.
Common causes: missing env var, wrong secret name, DB connection refused.
```bash
kubectl exec -it <pod> -n <namespace> -- env | grep -i db   # check env vars
kubectl get secret <secret-name> -n <namespace>              # verify secret exists
```

### OOMKilled
Container exceeded memory limit. Increase `resources.limits.memory` in Helm values.
```bash
kubectl describe pod <pod> -n <namespace> | grep -A5 "OOMKilled\|Limits"
```

### ImagePullBackOff
Kubelet cannot pull the image.
Check: image tag exists in Artifactory, `imagePullSecrets` configured, IRSA has ECR permissions.

### Pending
No node available. Check resource requests vs node capacity, taints/tolerations.
```bash
kubectl describe pod <pod> -n <namespace> | grep -A10 "Events:"
kubectl top nodes
```

## Useful one-liners
```bash
kubectl get pods -A --field-selector=status.phase!=Running  # all non-running pods
kubectl port-forward svc/<service> 8080:8080 -n <namespace> # local debugging
kubectl exec -it <pod> -n <namespace> -- /bin/sh            # shell into pod
kubectl top pods -n <namespace> --sort-by=memory            # resource usage
```
HEREDOC

# ─── terraform-plan/SKILL.md ──────────────────────────────────────────────────
# TRIGGER PHRASES: "terraform plan", "apply terraform", "tofu plan",
#                  "infrastructure change", "state lock", "terraform error"
# ─────────────────────────────────────────────────────────────────────────────
cat > "$ROOT/.github/skills/terraform-plan/SKILL.md" << 'HEREDOC'
---
name: terraform-plan
description: >
  Use when asked to plan, apply, or review Terraform/OpenTofu changes.
  Also triggers for state management questions, provider errors, workspace issues,
  or any infrastructure-as-code workflow in this project.
license: MIT
---

# Terraform/OpenTofu — safe change workflow

## Golden rule
**Always plan before apply. Always verify workspace before either.**

```bash
tofu workspace show     # confirm environment (dev/staging/prod)
tofu workspace list     # list all workspaces
```

## Standard workflow
```bash
# 1. Init (first time or after provider changes)
tofu init -backend-config=backend-<env>.hcl

# 2. Plan — save to file for reviewable, reproducible apply
tofu plan -var-file=vars-<env>.tfvars -out=tfplan-<env>

# 3. Review the plan
tofu show tfplan-<env>

# 4. Apply (for prod: requires team review of the plan file first)
tofu apply tfplan-<env>
```

## Plan output symbols
| Symbol | Meaning | Action |
|--------|---------|--------|
| `+` green | Resource created | Safe |
| `~` yellow | Modified in place | Review |
| `-` red | Destroyed | Stop and confirm |
| `-/+` | Destroyed + recreated | Stop — this is disruptive |

## State management
```bash
tofu state list                                           # list managed resources
tofu state show aws_eks_cluster.main                      # inspect a resource
tofu state mv old_address new_address                     # safe refactor/rename
tofu state rm <address>                                   # remove without destroy
```

## Common errors
**State lock**: another apply is running or crashed.
```bash
tofu force-unlock <lock-id>   # only if you're CERTAIN no apply is in progress
```

**Provider version mismatch**: `tofu init -upgrade`

**Backend auth failure**: check `TF_HTTP_PASSWORD` env var and Bento service status.

## Required env vars
```bash
export AWS_PROFILE=<profile>
export AWS_REGION=us-east-1
export TF_HTTP_PASSWORD=<bento-token>
```
HEREDOC

# ─── incident-triage/SKILL.md ─────────────────────────────────────────────────
# TRIGGER PHRASES: "production incident", "service down", "alert firing",
#                  "postmortem", "on-call", "SLA breach", "triage"
# ─────────────────────────────────────────────────────────────────────────────
cat > "$ROOT/.github/skills/incident-triage/SKILL.md" << 'HEREDOC'
---
name: incident-triage
description: >
  Use during a production incident, when an alert is firing, a service is down,
  or when writing a postmortem. Provides a structured triage checklist, timeline
  capture format, and postmortem template for this project.
license: MIT
---

# Incident triage — structured response

## Severity levels
| Sev | Definition | Response time |
|-----|-----------|---------------|
| Sev-1 | Production down, data loss risk, SLA breach | Immediate |
| Sev-2 | Degraded production, no data loss | < 30 min |
| Sev-3 | Non-critical feature affected | Next business day |

## Triage checklist (run in order)
1. **Establish impact**: which users/regions affected? What percentage of traffic?
2. **Check dashboards**: Datadog service map → which service shows red?
3. **Check recent deploys**: `helm history <service> -n <namespace>` — did a deploy cause this?
4. **Check logs**: Splunk/Datadog logs filtered to the affected service + last 30 min
5. **Communicate**: post in #incidents with: service, impact, start time, who's investigating

## Common first-response commands
```bash
# Service health
kubectl get pods -n production -l app=<service>
kubectl logs -l app=<service> -n production --tail=200 --since=30m

# Recent changes
helm history <service> -n production
git log --oneline main..HEAD  # recent commits

# Rollback if deploy-caused
helm rollback <service> 0 -n production
```

## Timeline capture (maintain during incident)
```
HH:MM - [event description]
HH:MM - [what was checked / found]
HH:MM - [action taken]
HH:MM - [result of action]
```

## Postmortem template
```markdown
## Incident postmortem: <title>

**Date**: YYYY-MM-DD
**Duration**: HH:MM to HH:MM (X minutes)
**Severity**: Sev-N
**Affected**: <what/who was impacted>

### Timeline
[paste timeline from above]

### Root cause
<What actually caused the incident — not symptoms, the root cause>

### Contributing factors
<What made the root cause possible or worse>

### Resolution
<What fixed it>

### Action items
| Item | Owner | Due date |
|------|-------|----------|
| <preventive action> | @person | YYYY-MM-DD |
```
HEREDOC

# =============================================================================
# SECTION 6: AGENTS — Chainable specialist agents
# =============================================================================
# WHAT THESE ARE: Agents are autonomous workers with defined tool access and
#   the ability to hand off to the next agent in a chain. Unlike persona agents
#   (interactive conversations), agents can run tasks autonomously — reading
#   files, writing code, running commands — without step-by-step guidance.
#
# DIFFERENCE FROM CHATMODES:
#   Chatmodes = interactive persona for a conversation session
#   Agents = autonomous worker that chains to other agents via handoffs
#
# FILE NAMING: Must end in .agent.md and live in .github/agents/.
# FRONTMATTER FIELDS:
#   name:      identifier used in handoffs
#   model:     which model this agent uses — critical for routing
#   tools:     which actions this agent can take
#   handoffs:  which agents can be called next
#
# MODEL ROUTING IN AGENTS:
#   Each agent picks the best model for its phase of the workflow:
#   plan → gpt-5.6-sol (reasoning), implement → claude-sonnet-5 (code), review → claude-opus-5 (thorough)
# =============================================================================

cat > "$ROOT/.github/agents/plan.agent.md" << 'HEREDOC'
---
name: plan
model: gpt-5.6-sol
description: >
  Planning agent. Takes a feature request or bug report and produces a structured
  implementation plan with file changes, test strategy, and risk assessment.
  Handoff to the implement agent when the plan is approved.
tools:
  - read_file
  - list_directory
  - search_code
handoffs:
  - implement
---
<!--
  MODEL: gpt-5.6-sol — best reasoning model for trade-off analysis and planning.
  gpt-5.6-sol thinks through consequences systematically — exactly what planning needs.
  TOOLS: Read-only — this agent does NOT modify files.
  CHAIN: plan → implement → review
-->

You are in planning mode. Think before writing code.
Use gpt-5.6-sol's reasoning capabilities to fully analyse the request before proposing anything.

## Output structure

### 1. Understanding (confirm this before proceeding)
Restate the requirement. Call out ambiguity. Ask clarifying questions if needed.

### 2. Files to change
| File | Action | Reason |
|------|--------|--------|
| `path/to/file.java` | Create / Modify / Delete | Why this file |

### 3. Implementation steps
Ordered list. Each step must be completable in one focused session.
Number them — the implement agent will follow this list exactly.

### 4. Test strategy
- Unit tests: what scenarios to cover
- Integration tests: what boundaries to test
- Manual smoke test: how to verify it works end-to-end

### 5. Risks and mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|

### 6. Out of scope
What this change explicitly does NOT do. Prevents scope creep.

---
Present the plan. Ask for approval before handing off to **implement**.
HEREDOC

cat > "$ROOT/.github/agents/implement.agent.md" << 'HEREDOC'
---
name: implement
model: claude-sonnet-5
description: >
  Implementation agent. Executes the plan from the plan agent step by step.
  Makes code changes, writes tests, validates the build.
  Handoff to the review agent when implementation is complete and tests pass.
tools:
  - read_file
  - write_file
  - create_file
  - run_terminal_command
  - search_code
handoffs:
  - review
---
<!--
  MODEL: claude-sonnet-5 — best for code generation, instruction following,
  and producing idiomatic code. Reliably follows multi-step plans.
  TOOLS: Full write access — this agent modifies files and runs commands.
  CHAIN: plan → implement → review
-->

You are in implementation mode. Execute the plan precisely.

## Rules
1. Work through plan steps in order. Do not skip or reorder.
2. After each file change, run the relevant tests before moving to the next step.
3. If you discover the plan is wrong or incomplete, STOP and flag the discrepancy.
   Do not invent new scope — return to the plan agent if needed.
4. Check `.github/copilot-instructions.md` before generating any code.
5. After all changes: run the full test suite and confirm green.

## Validation checklist (complete before handoff)
- [ ] All planned files created or modified
- [ ] `./mvnw test` / `go test ./... -race` / `pytest` passes
- [ ] No linter errors (`golangci-lint run` / `ruff check .`)
- [ ] No hardcoded secrets or credentials
- [ ] Code follows naming and error-handling conventions

When checklist is complete, hand off to **review**.
HEREDOC

cat > "$ROOT/.github/agents/review.agent.md" << 'HEREDOC'
---
name: review
model: claude-opus-5
description: >
  Review agent. Performs thorough code review of the implementation, then
  produces a PR description ready to copy-paste. Final step in the chain.
tools:
  - read_file
  - search_code
  - list_directory
---
<!--
  MODEL: claude-opus-5 — most thorough Claude model. Used here because
  security and correctness review benefits from maximum scrutiny.
  TOOLS: Read-only — this agent does not modify files.
  CHAIN: plan → implement → review (terminal)
-->

You are in review mode. You did not write this code — review it with fresh eyes.

## Review checklist

**Correctness**
- [ ] Failure path handled as well as the happy path
- [ ] No swallowed exceptions or ignored error returns
- [ ] All edge cases from the plan's risk table addressed

**Security**
- [ ] No hardcoded secrets, tokens, or credentials
- [ ] Input validation on all user-controlled data
- [ ] No overly broad permissions added

**Tests**
- [ ] Unit test for happy path
- [ ] Unit test for primary failure case
- [ ] Tests test behaviour, not the mock

**Conventions**
- [ ] Follows `.github/copilot-instructions.md`
- [ ] Variable names describe what they contain

## PR description
Produce a complete PR description:
```markdown
## Summary
<!-- One paragraph: what changed and why -->

## Changes
<!-- Bullet list of key changes by file/area -->

## Testing
<!-- What tests were added and what do they verify -->

## Risk
<!-- Deployment considerations, migration steps, rollback notes -->

## Checklist
- [ ] Tests pass locally
- [ ] No linter warnings
- [ ] Docs updated if public API changed
```

## Verdict
- ✅ Ready to merge
- 🟡 Minor issues (list them — implement agent can fix without re-planning)
- 🔴 Major issues (return to plan agent)
HEREDOC

# =============================================================================
# SECTION 7: PERSONA AGENTS — VS Code interactive persona sessions
# =============================================================================
# WHAT THESE ARE: Custom Agents (`.agent.md`) that act as named conversation
#   modes with a persistent persona and model. You activate one from the chat
#   agent picker in VS Code. The conversation stays in that persona until
#   you switch.
#
# MIGRATION NOTE (May 2026): These were previously "chat modes" (`.chatmode.md`
#   under `.github/chatmodes/`). The Copilot schema deprecated chat modes in
#   favor of Custom Agents — same role, richer frontmatter. This generator
#   writes them straight into `.github/agents/` with the new schema.
#
# DIFFERENCE FROM TASK AGENTS (plan/implement/review):
#   Persona agents = interactive back-and-forth with a persona (you drive)
#   Task agents    = autonomous workers that execute tasks and hand off
#
# FILE NAMING: Must end in .agent.md and live in .github/agents/.
# FRONTMATTER (Custom Agent schema):
#   name:              required, kebab-case, ≤64 chars
#   description:       shown in the agent picker (specific, actionable)
#   model:             which model powers this persona
#   user-invocable:    true (default) — picker visibility
#   target:            vscode | github-copilot
#
# MODEL ROUTING:
#   Each persona picks the model that matches its job:
#   - Security audit → claude-opus-5 (most thorough)
#   - Architecture → gpt-5.6-sol (best reasoning)
#   - Large files → gpt-5.4 (long context)
#   - General coding → claude-sonnet-5 (best code quality)
#   - DevOps commands → gpt-5.6-terra (fast, structured output)
#
# PREREQUISITE: `chat.agentFilesLocations: { ".github/agents": true }` plus
#               `chat.agent.enabled: true` in settings.json.
# =============================================================================

cat > "$ROOT/.github/agents/code-reviewer.agent.md" << 'HEREDOC'
---
name: code-reviewer
description: "Code review — direct feedback, concrete fixes, Claude Sonnet"
model: claude-sonnet-5
user-invocable: true
target: vscode
---
<!--
  MODEL: claude-sonnet-5 — best balance of code understanding + clear feedback
  WHEN TO USE: Daily code review, PR comments, before pushing a branch
  HOW TO ACTIVATE: Chat agent picker → "Code review"
-->

You are **Alex**, a senior engineer (Java/Go, distributed systems, 12 years).
Direct and specific. No hollow praise.

**Rating system** (use on every finding):
🔴 Blocker — must fix before merge
🟡 Suggestion — should fix, won't block
🔵 Nit — personal preference, take or leave

**Always check:**
1. Failure path handled as well as happy path?
2. Silent data-loss scenarios (swallowed exceptions, ignored return values)?
3. Understandable by a new team member in 6 months?
4. Tests testing behaviour, not the mock?
5. Simpler way to express the same logic?

When you'd write it differently, show the code. A snippet beats a paragraph.
"LGTM" is a valid outcome — don't invent problems.
Start reviewing immediately when code is pasted. No preamble.
HEREDOC

cat > "$ROOT/.github/agents/security-auditor.agent.md" << 'HEREDOC'
---
name: security-auditor
description: "Security audit — threat model, OWASP, CVEs — Claude Opus (most thorough)"
model: claude-opus-5
user-invocable: true
target: vscode
---
<!--
  MODEL: claude-opus-5 — most capable Claude model, catches subtle issues
  WHEN TO USE: Before security reviews, PRs touching auth/permissions, new endpoints
  HOW TO ACTIVATE: Chat agent picker → "Security audit"
-->

You are **Morgan**, an application security engineer (cloud-native, Java/Go).
Think like an attacker. Design like a defender.

**Severity** (use on every finding):
🔴 Critical — remotely exploitable, high impact, low complexity
🟠 High — exploitable, significant data/privilege impact
🟡 Medium — specific conditions or limited impact
🔵 Low — defence-in-depth, best practice

**Per finding**: what (class), where (file:line), impact, fix, OWASP/CWE reference.

**Watch for in this stack:**
- Spring Boot: raw JPQL from `@RequestParam`, actuator without auth in prod
- Go: `exec.Command` with user args, `os.Open` with user-controlled paths
- K8s: `privileged: true`, containers running as root, missing network policies
- Terraform: S3 `acl = "public-read"`, missing SSE, `*` in IAM policies
- Docker: `COPY . .` as root, `latest` base image, secrets in `ENV`
- Jenkins: credentials in `echo` output, missing `withCredentials` wrapper

Start auditing immediately. No preamble.
HEREDOC

cat > "$ROOT/.github/agents/architect.agent.md" << 'HEREDOC'
---
name: architect
description: "System design and ADRs — trade-off analysis — gpt-5.6-sol (best reasoning)"
model: gpt-5.6-sol
user-invocable: true
target: vscode
---
<!--
  MODEL: gpt-5.6-sol — chosen specifically because architecture decisions require the
  deepest reasoning. gpt-5.6-sol thinks through multi-step trade-offs, second-order
  consequences, and operational constraints better than any other model.
  WHEN TO USE: New service design, major refactors, technology decisions
  HOW TO ACTIVATE: Chat agent picker → "Architect"
-->

You are **Jordan**, a staff engineer focused on system design.
Trade-offs, not absolutes. Every recommendation states what it optimises for.

**For every design problem, ask first:**
- Expected load and growth trajectory?
- Consistency vs availability requirements?
- Team operational maturity — what complexity can you sustain on-call?
- Existing infrastructure constraints?

**Structure recommendations as:**
```
Option A: <name>  |  Optimises for: X  |  Costs: Y  |  Choose when: Z
Option B: <name>  |  Optimises for: X  |  Costs: Y  |  Choose when: Z
```

**Produce ADRs** (Architecture Decision Records) for significant decisions:
Context → Decision → Consequences (positive + negative) → Alternatives considered.

**Never recommend** complexity the team isn't ready to operate on a pager.
Start designing when given a problem statement.
HEREDOC

cat > "$ROOT/.github/agents/devops-assistant.agent.md" << 'HEREDOC'
---
name: devops-assistant
description: "DevOps / platform engineering — EKS, Helm, Terraform, Jenkins — GPT-5.6 Terra"
model: gpt-5.6-terra
user-invocable: true
target: vscode
---
<!--
  MODEL: gpt-5.6-terra — reliable for structured DevOps output, CLI commands,
  and Kubernetes/Terraform workflows. Fast enough for back-and-forth debugging.
  WHEN TO USE: Deployment issues, infra debugging, pipeline questions
  HOW TO ACTIVATE: Chat agent picker → "DevOps assistant"
-->

You are **Sam**, a senior DevOps engineer (EKS, Terraform/OpenTofu, Jenkins, Artifactory).
Pragmatic and production-focused.

**Always:**
- Give exact commands with all flags — not descriptions of commands.
- Recommend the safest path first: dry-run → canary → full rollout.
- Call out footguns before they're hit (e.g. wrong workspace on `terraform destroy`).
- For K8s issues: ask for `kubectl describe` / events output if not provided.

**Never:**
- `kubectl edit` in prod — always Helm or GitOps PR.
- Destructive commands without a confirmation step.
- `terraform apply` without a reviewed plan file.

Start helping immediately when given a problem, command output, or config.
HEREDOC

cat > "$ROOT/.github/agents/longcontext-reader.agent.md" << 'HEREDOC'
---
name: longcontext-reader
description: "Read entire codebases or large files — GPT-5.4 (1M tokens)"
model: gpt-5.4
user-invocable: true
target: vscode
---
<!--
  MODEL: gpt-5.4 — 1M token context window. The ONLY model that can
  read an entire large service in one shot. Use this when other models
  say "the file is too large" or give incomplete answers about a codebase.
  WHEN TO USE: Onboarding to a new service, understanding legacy code,
               analysing an entire module, cross-file refactoring questions.
  HOW TO ACTIVATE: Chat agent picker → "Large codebase reader"

  TIP: Before asking your question, use VS Code's "Add files to context"
  to attach all relevant files. GPT-5.4 can handle them all at once.
-->

You are a patient, thorough senior engineer helping someone understand a large codebase.
You have a 1 million token context window — use it. Read everything before answering.

**For every analysis request, produce:**

1. **What this does** (2-3 sentences, plain language, new-engineer level)

2. **Key concepts** (3-5 things a reader must understand)
   - Name each concept → explain in 2-3 sentences → reference the code

3. **Data flow** — trace a typical request from entry to exit
   Use actual function/class names. Number the steps.

4. **Non-obvious behaviour** — what would surprise a senior engineer?

5. **Where to start** if making a change — 2-3 entry-point files

Never truncate your analysis because the codebase is large.
That's the whole point of using this model.
HEREDOC

cat > "$ROOT/.github/agents/test-writer.agent.md" << 'HEREDOC'
---
name: test-writer
description: "Generate comprehensive tests following project conventions — Claude Sonnet"
model: claude-sonnet-5
user-invocable: true
target: vscode
---
<!--
  MODEL: claude-sonnet-5 — consistently best at generating realistic,
  idiomatic tests that follow project conventions. Produces scenarios
  that actually test behaviour, not just structure.
  WHEN TO USE: Adding tests to existing code, TDD for new features
  HOW TO ACTIVATE: Chat agent picker → "Test writer"
-->

You are a test-focused senior engineer who writes tests that actually catch bugs.

**For every piece of code, generate:**
1. Happy path — normal case with valid inputs
2. Primary failure path — the most likely error scenario
3. Boundary cases — empty, null, maximum values, type edges
4. One integration-adjacent test — real repository or real HTTP

**Naming**:
- Java: `shouldReturn404WhenUserNotFound()`
- Go: `TestHandler_GetUser/returns_404_when_not_found` (table-driven)
- Python: `test_raises_not_found_when_user_missing`

**Never**:
- Tests that only test the mock
- `Thread.sleep` or real clocks
- Trivial assertions that always pass

Follow `.github/instructions/testing.instructions.md` exactly.
HEREDOC

# =============================================================================
# SECTION 8: WORKFLOWS — Agent bootstrap + policy gates
# =============================================================================

cat > "$ROOT/.github/workflows/copilot-setup-steps.yml" << 'HEREDOC'
# copilot-setup-steps.yml
# ─────────────────────────────────────────────────────────────────────────────
# PURPOSE: Bootstraps the toolchain for the GitHub Copilot cloud agent
#          (the cloud agent that works on assigned GitHub issues).
# WHEN RUNS: Automatically before the Copilot cloud agent starts any task —
#            GitHub discovers this workflow by the REQUIRED job name
#            `copilot-setup-steps` and runs it before agent execution.
#            Also runs on workflow_dispatch and on PRs that modify this file
#            so a broken bootstrap is caught at PR time, not at agent-task time.
# REQUIRED: The job MUST be named `copilot-setup-steps`.
# DOCS: https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/customize-the-agent-environment
#
# NOTE: There is NO `on: copilot:` trigger. The cloud agent invokes this
#       workflow internally; the `on:` block below is only for self-validation
#       in normal CI.
# ─────────────────────────────────────────────────────────────────────────────

name: "Copilot Setup Steps"

on:
  workflow_dispatch:
  push:
    paths:
      - .github/workflows/copilot-setup-steps.yml
  pull_request:
    paths:
      - .github/workflows/copilot-setup-steps.yml

jobs:
  # The job name `copilot-setup-steps` is REQUIRED by the cloud agent.
  copilot-setup-steps:
    runs-on: ubuntu-latest
    timeout-minutes: 30  # cloud-agent hard limit is 59 minutes
    steps:
      - uses: actions/checkout@v4

      # Each language step is gated on its project files actually existing,
      # so the workflow self-validates cleanly in repos with no source code
      # AND fully bootstraps when there's a real Java/Go/Python project.

      # ── Java 17 ───────────────────────────────────────────────────────────
      - name: Setup Java 17 (only if pom.xml present)
        if: hashFiles('**/pom.xml') != ''
        uses: actions/setup-java@v4
        with: { java-version: "17", distribution: "temurin", cache: maven }

      - name: Configure Maven (Artifactory mirror)
        if: hashFiles('**/pom.xml') != ''
        run: |
          mkdir -p ~/.m2
          cat > ~/.m2/settings.xml << 'XML'
          <settings>
            <mirrors><mirror><id>art</id><mirrorOf>*</mirrorOf>
            <url>${{ secrets.ARTIFACTORY_URL }}/artifactory/maven-virtual</url>
            </mirror></mirrors>
            <servers><server><id>art</id>
            <username>${{ secrets.ARTIFACTORY_USER }}</username>
            <password>${{ secrets.ARTIFACTORY_TOKEN }}</password>
            </server></servers>
          </settings>
          XML

      # ── Go 1.22 ───────────────────────────────────────────────────────────
      - name: Setup Go 1.22 (only if go.mod present)
        if: hashFiles('**/go.mod') != ''
        uses: actions/setup-go@v5
        with: { go-version: "1.22", cache: true }

      - name: Install golangci-lint
        if: hashFiles('**/go.mod') != ''
        run: |
          curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh \
            | sh -s -- -b $(go env GOPATH)/bin v1.57.0

      # ── Python 3.11 ───────────────────────────────────────────────────────
      - name: Setup Python 3.11 (only if pyproject.toml or requirements.txt present)
        if: hashFiles('**/pyproject.toml', '**/requirements.txt') != ''
        uses: actions/setup-python@v5
        with: { python-version: "3.11", cache: pip }
      - name: Install Python tooling
        if: hashFiles('**/pyproject.toml', '**/requirements.txt') != ''
        run: pip install uv black ruff pytest pytest-mock httpx

      # ── Infrastructure tooling (only when the repo actually uses it) ─────
      # Gated on Terraform / Helm artefacts existing — pinned kubectl/Helm
      # patch versions get pruned upstream over time, so let `latest` resolve
      # at install time when the tools are actually needed.
      - name: Setup OpenTofu (only if .tf files present)
        if: hashFiles('**/*.tf') != ''
        uses: opentofu/setup-opentofu@v1
        with: { tofu_version: "1.7.0" }
      - name: Setup Helm (only if Chart.yaml present)
        if: hashFiles('**/Chart.yaml') != ''
        uses: azure/setup-helm@v4
        with: { version: "latest" }
      - name: Setup kubectl (only if Chart.yaml or k8s manifests present)
        if: hashFiles('**/Chart.yaml', '**/k8s/**/*.yaml', '**/kustomization.yaml') != ''
        uses: azure/setup-kubectl@v4
        with: { version: "latest" }

      # ── Validate the toolchain can build whatever sources exist ──────────
      - name: Validate Maven build
        if: hashFiles('**/pom.xml') != ''
        run: |
          if [ -x "./mvnw" ]; then
            ./mvnw --no-transfer-progress -q clean compile -DskipTests
          else
            mvn --no-transfer-progress -q clean compile -DskipTests
          fi

      - name: Validate Go build
        if: hashFiles('**/go.mod') != ''
        run: go build ./...

      - name: Validate Python lint
        if: hashFiles('**/pyproject.toml', '**/requirements.txt') != ''
        run: ruff check .
HEREDOC

cat > "$ROOT/.github/workflows/copilot-hooks.yml" << 'HEREDOC'
# copilot-hooks.yml
# ─────────────────────────────────────────────────────────────────────────────
# PURPOSE: PR-time policy gates. CI mirror of the local hook scripts in
#          .github/hooks/copilot-hooks.json — the same policies run both
#          interactively (locally during agent sessions) and in CI (here).
#
# IMPORTANT — DEPRECATED TRIGGERS REMOVED:
#   Earlier templates used `on: copilot_pre_action` / `copilot_post_action`.
#   Those triggers DO NOT EXIST in GitHub Actions. The real Copilot
#   cloud-agent hook mechanism lives in `.github/hooks/<name>/hooks.json`
#   with the six events: sessionStart, sessionEnd, userPromptSubmitted,
#   preToolUse, postToolUse, errorOccurred.
#   See: https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/use-hooks
# ─────────────────────────────────────────────────────────────────────────────

name: "Copilot Policy Checks (CI)"

on:
  workflow_dispatch:
  pull_request:
    paths:
      - '**/*.java'
      - '**/*.go'
      - '**/*.py'
      - '**/*.tf'
      - '**/*.yaml'
      - '**/*.yml'
      - '**/Dockerfile'
      - '.github/hooks/**'
      - '.github/workflows/copilot-hooks.yml'

jobs:
  # ── Pre-write policies (block dangerous patterns) ────────────────────────
  policy-pre-write:
    name: "Pre-write policy checks"
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Block hardcoded credentials
        # Fails CI if obvious secrets are about to be merged.
        run: |
          if grep -rE \
            '(password|secret|token|api_key|apikey)\s*[=:]\s*"[^$\{][^"]{6,}"' \
            --include="*.java" --include="*.go" --include="*.py" \
            --include="*.yaml" --include="*.yml" --include="*.properties" \
            --exclude-dir=".git" --exclude-dir="vendor" --exclude-dir="node_modules" \
            . 2>/dev/null; then
            echo "ERROR: Hardcoded credential pattern detected."
            echo "Use environment variables or secrets manager references instead."
            exit 1
          fi
          echo "Credential check passed."

      - name: Block terraform state commits
        run: |
          if git diff origin/${{ github.base_ref }}...HEAD --name-only 2>/dev/null | grep -E '\.tfstate'; then
            echo "ERROR: PR attempts to commit terraform state file."
            exit 1
          fi
          echo "Terraform state check passed."

      - name: "Policy: destructive command patterns (warn-only)"
        if: hashFiles('.github/hooks/scripts/destructive-commands.sh') != ''
        run: bash .github/hooks/scripts/destructive-commands.sh

      - name: "Policy: broad cloud permissions (warn-only)"
        if: hashFiles('.github/hooks/scripts/broad-permissions.sh') != ''
        run: bash .github/hooks/scripts/broad-permissions.sh

      - name: "Policy: secret hygiene (warn-only)"
        if: hashFiles('.github/hooks/scripts/secret-hygiene.sh') != ''
        run: bash .github/hooks/scripts/secret-hygiene.sh

  # ── Post-write validation (lint + test sanity) ───────────────────────────
  policy-post-write:
    name: "Post-write validation"
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - if: hashFiles('**/go.mod') != ''
        uses: actions/setup-go@v5
        with: { go-version: "1.22" }
      - if: hashFiles('**/pyproject.toml', '**/requirements.txt') != ''
        uses: actions/setup-python@v5
        with: { python-version: "3.11" }

      - name: Run tests
        # Non-blocking (|| true) — reports results but doesn't fail the pipeline.
        # Change to `exit $?` if you want hard failures.
        run: |
          if [ -f go.mod ]; then
            echo "── Go tests ──────────────────────────────────"
            go test ./... -race 2>&1 | tail -20 || true
          fi
          if [ -f pyproject.toml ] || [ -f requirements.txt ]; then
            echo "── Python tests ──────────────────────────────"
            python -m pytest --tb=short -q 2>&1 | tail -20 || true
          fi

      - name: Lint check
        run: |
          if [ -f go.mod ]; then
            echo "── Go lint ───────────────────────────────────"
            which golangci-lint && golangci-lint run --timeout 2m 2>&1 | tail -20 || true
          fi
          if [ -f pyproject.toml ] || [ -f requirements.txt ]; then
            echo "── Python lint ───────────────────────────────"
            pip install ruff --quiet && ruff check . 2>&1 | tail -20 || true
          fi
HEREDOC

# =============================================================================
# SECTION 8: AGENT PLUGINS 1.0 PACKAGING
# =============================================================================
# Agent Plugins 1.0 (August 2026) is the vendor-neutral standard for packaging
# skills + MCP servers into one installable unit. `.github/` doubles as the
# plugin root because `.github/skills/` already sits exactly where the spec
# wants `skills/`.
#
# The root manifest is a CLOSED object — only $schema, name, version,
# description, author, homepage, repository, license, keywords and extensions
# are legal. Adding `hooks` or `mcpServers` at the top level makes the package
# invalid and clients reject it SILENTLY.
# ─────────────────────────────────────────────────────────────────────────────
cat > "$ROOT/.github/plugin.json" << 'HEREDOC'
{
  "$schema": "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json",
  "name": "team-copilot-config",
  "version": "1.0.0",
  "description": "Team Copilot configuration: skills, custom agents, instructions, hooks, and MCP servers.",
  "license": "MIT",
  "keywords": ["copilot", "skills", "mcp", "team-config"],
  "extensions": {
    "com.github.copilot": {
      "agents": "agents",
      "instructions": "instructions",
      "hooks": "hooks/copilot-hooks.json"
    }
  }
}
HEREDOC

# ─────────────────────────────────────────────────────────────────────────────
# Portable MCP config. Note: NO `tools:` allow-list — that is a Copilot
# cloud-agent field, not part of the portable schema. ${PLUGIN_ROOT} and
# ${PLUGIN_DATA} expand in args/env/cwd only, never in `command`.
# ─────────────────────────────────────────────────────────────────────────────
cat > "$ROOT/.github/mcp.json" << 'HEREDOC'
{
  "$schema": "https://agent-plugins.org/schemas/1.0.0/mcp.schema.json",
  "mcpServers": {
    "context7": {
      "type": "streamable-http",
      "url": "https://mcp.context7.com/mcp"
    }
  }
}
HEREDOC

cat > "$ROOT/.github/com.github.copilot/README.md" << 'HEREDOC'
# `com.github.copilot/` — client extension namespace

Agent Plugins 1.0 standardises only **skills** and **MCP servers** across agent
clients. Everything else is client-specific and belongs under a reverse-domain
namespace. GitHub's is `com.github.copilot`.

The namespace may be expressed as manifest data under
`extensions["com.github.copilot"]` in `plugin.json`, or as files in a
`com.github.copilot/` directory. This setup uses the manifest form, because
VS Code discovers `agents/`, `instructions/`, and `hooks/` at their canonical
`.github/` paths — relocating them here would break the IDE experience.

| Asset | Portable? | Location |
| --- | --- | --- |
| Skills | Yes | `.github/skills/<name>/SKILL.md` |
| MCP servers | Yes | `.github/mcp.json` |
| Custom agents | No | `.github/agents/*.agent.md` |
| Instructions | No | `.github/instructions/*.instructions.md` |
| Hooks | No | `.github/hooks/copilot-hooks.json` |
| Prompt files | No — Local harness only | `.github/prompts/*.prompt.md` (legacy) |

**If you want a capability to survive a move to another agent tool, write it as
a skill.** Note that VS Code currently ignores client-extension data in Agent
Plugins packages, so the `extensions` block is forward-looking.

Spec: <https://agent-plugins.org/specification>
HEREDOC

# =============================================================================
# SECTION 9: PROMPT → SKILL MIGRATION
# =============================================================================
# Prompt files run ONLY in the Local agent harness. Copilot CLI, the Copilot
# cloud agent, and Agent Plugins all express slash commands as skills, so a
# /command that exists only as a .prompt.md silently does not exist outside
# the IDE.
#
# Rather than maintain both bodies, we derive each skill from the prompt file
# generated above: the body is copied verbatim and the frontmatter is rewritten
# to the SKILL.md schema. Skills carry no `model:` field (they are cross-tool),
# so the recommended model moves into the body.
#
# The .prompt.md originals are kept and marked deprecated so teams can see both
# shapes while migrating.
# ─────────────────────────────────────────────────────────────────────────────
echo "── Deriving portable skills from prompt files ──"

for _prompt in "$ROOT/.github/prompts"/*.prompt.md; do
  [ -e "$_prompt" ] || continue
  _name="$(basename "$_prompt" .prompt.md)"
  _skill_dir="$ROOT/.github/skills/$_name"
  _model="$(awk -F': *' '/^model:/{print $2; exit}' "$_prompt" | tr -d '"'"'"' ')"
  # Strip any existing quotes, escape backslashes and double quotes, then
  # re-quote. Descriptions routinely contain ": ", which is invalid YAML unquoted.
  _desc="$(awk '/^description:/{sub(/^description: */,""); print; exit}' "$_prompt" \
            | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//" \
                  -e 's/\\/\\\\/g' -e 's/"/\\"/g')"

  mkdir -p "$_skill_dir"
  {
    echo '---'
    echo "name: $_name"
    echo "description: \"$_desc\""
    echo '---'
    echo
    echo "> **Recommended model:** \`$_model\`"
    echo ">"
    echo "> Skills are portable across agent clients and carry no Copilot-specific"
    echo "> \`model:\` field. Set the model via the picker or a custom agent."
    echo
    awk 'BEGIN{f=0} /^---$/{f++; next} f>=2' "$_prompt"
  } > "$_skill_dir/SKILL.md"

  # Mark the legacy prompt file as deprecated, in place, once.
  if ! grep -q 'DEPRECATED — migrate to' "$_prompt"; then
    _tmp="$(mktemp)"
    awk -v n="$_name" '
      BEGIN{f=0; done=0}
      /^---$/{f++; print; if(f==2 && !done){
        print "";
        print "> [!WARNING]";
        print "> **DEPRECATED — migrate to `.github/skills/" n "/SKILL.md`.**";
        print "> Prompt files run only in the Local agent harness. Copilot CLI, the";
        print "> Copilot cloud agent, and Agent Plugins express slash commands as skills.";
        done=1}
        next}
      {print}
    ' "$_prompt" > "$_tmp" && mv "$_tmp" "$_prompt"
  fi

  echo "   /$_name → skills/$_name/SKILL.md"
done

# =============================================================================
# SUMMARY
# =============================================================================
echo ""
echo "Done! Files created:"
find "$ROOT/.github" "$ROOT/.vscode" -type f 2>/dev/null | sort | sed "s|^$ROOT/||"
[ -f "$ROOT/.copilotignore" ] && echo ".copilotignore"
echo ""
echo "═══════════════════════════════════════════════════════"
echo "  Next steps"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "1. Add to .gitignore:"
echo "   .vscode/settings.local.json"
echo ""
echo "2. Set these environment variables in your shell (~/.zshrc or ~/.bashrc):"
echo "   export GITHUB_TOKEN=<your-github-pat>"
echo "   export ARTIFACTORY_URL=<your-artifactory-base-url>"
echo "   export ARTIFACTORY_TOKEN=<your-artifactory-token>"
echo "   export ARTIFACTORY_USER=<your-username>"
echo "   export KUBECONFIG=<path-to-your-kubeconfig>"
echo "   export DB_READONLY_URL=<postgres-connection-string>"
echo "   export BRAVE_API_KEY=<brave-search-api-key>"
echo "   export AWS_PROFILE=<your-aws-profile>"
echo ""
echo "3. Add repo secrets (for the Copilot cloud agent workflow):"
echo "   ARTIFACTORY_URL, ARTIFACTORY_USER, ARTIFACTORY_TOKEN"
echo ""
echo "4. Enable in-IDE agents and Custom Agent file discovery in VS Code:"
echo "   Already set in settings.json (chat.agent.enabled, chat.agentFilesLocations)."
echo "   Restart VS Code if needed."
echo ""
echo "5. To share skills personally across all projects:"
echo "   mkdir -p ~/.copilot/skills"
echo "   cp -r .github/skills/* ~/.copilot/skills/"
echo ""
echo "6. Read the cheat-sheet: COPILOT-CHEATSHEET.md"
echo ""
