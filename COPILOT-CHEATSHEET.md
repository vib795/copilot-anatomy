# GitHub Copilot Multi-Model Setup — Team Cheat-Sheet

> **Who this is for**: Engineers using GitHub Copilot in VS Code with access to multiple
> AI models (OpenAI, Anthropic, Google). This guide explains what every file in the
> `.github/` setup does, when to use it, and which model to reach for.

> **⚠ Schema currency note (May 2026)**
>
> GitHub Copilot's customization schema has evolved since this guide was first
> written. Two changes affect this document:
>
> 1. **Chat modes → Custom Agents.** `.chatmode.md` files have been replaced by
>    `.agent.md` files in `.github/agents/`. Setting `chat.modeFilesLocations`
>    is replaced by `chat.agentFilesLocations`. Custom agents support richer
>    frontmatter (`agents`, `handoffs`, `user-invocable`,
>    `disable-model-invocation`, `target`, `mcp-servers`, `hooks`).
>    **In this repo the migration completed on 2026-05-07** — the
>    `.github/chatmodes/` directory was removed and the 6 persona files
>    were rewritten as Custom Agents.
>
> 2. **Prompt frontmatter `mode:` → `agent:`.** Valid values:
>    `ask | agent | plan | <custom-agent-name>`. Already migrated in this repo.
>
> 3. **`.copilotignore` is unofficial.** Use repo/org **Content Exclusion**
>    (Settings UI + REST API public preview, Feb 2026) for real enforcement.
>
> 4. **Cloud coding-agent MCP is a different schema** from in-IDE MCP — see
>    [§ MCP](#vscodemcp-json) below. Top-level key is `mcpServers` (not
>    `servers`), each server requires a `tools:` allow-list, and the file
>    isn't committed (it's repo-Settings UI).

---

## Table of contents

1. [Mental model — the six primitives](#1-mental-model--the-six-primitives)
2. [Model routing — which AI for which task](#2-model-routing--which-ai-for-which-task)
3. [Full folder structure at a glance](#3-full-folder-structure-at-a-glance)
4. [File-by-file reference](#4-file-by-file-reference)
5. [Decision guide — what to use when](#5-decision-guide--what-to-use-when)
6. [How to add your own files](#6-how-to-add-your-own-files)
7. [Admin setup (org/enterprise)](#7-admin-setup-orgenterprise)
8. [Governance and quality gates](#8-governance-and-quality-gates)
9. [Troubleshooting](#9-troubleshooting)

---

## 1. Mental model — the five primitives

Copilot has five customisation primitives. Each solves a different problem:

| Primitive              | Where                            | Trigger                        | Best for                             |
| ---------------------- | -------------------------------- | ------------------------------ | ------------------------------------ |
| **Team instructions**  | `copilot-instructions.md`        | Always, automatically          | Project overview, non-negotiables    |
| **Instructions files** | `instructions/*.instructions.md` | Auto, scoped by `applyTo:` glob| Language/framework conventions       |
| **Prompt files**       | `prompts/*.prompt.md`            | Manual (`/command`)            | Repeatable slash commands            |
| **Skills**             | `skills/*/SKILL.md`              | Auto-discovered by description | Task runbooks (helm, terraform, K8s) |
| **Custom Agents**      | `agents/*.agent.md`              | Agent picker, chained, autonomous | Personas (formerly chatmodes) AND task agents (plan→implement→review) |

> The earlier "Chat modes" primitive (`.chatmode.md`) was deprecated in 2026
> and folded into Custom Agents. Persona agents (architecture, code review,
> security audit, etc.) and task agents now share the same `.agent.md`
> schema. The `.github/chatmodes/` directory was removed in this repo on
> 2026-05-07.

Think of it as layers, innermost to outermost:

```
Always on:   [team instructions] + [instruction files scoped to applyTo: glob]
On demand:   [slash command prompts] ← you type /review
Auto-loaded: [skills] ← Copilot decides based on what you're asking
Interactive: [persona custom agents] ← you pick the persona from the agent picker
Autonomous:  [task custom agents] ← runs a full workflow, can chain via handoffs:
```

---

## 2. Model routing — which AI for which task

> **Core insight**: Different models have different strengths. The setup routes each task
> to the model that performs best for it — automatically, without you switching manually.

### Model strengths

| Model               | Strength                             | Cost tier | Use for                                      |
| ------------------- | ------------------------------------ | --------- | -------------------------------------------- |
| `o3`                | Deep multi-step reasoning            | High      | Architecture, planning, trade-off analysis   |
| `o4-mini`           | Speed                                | Low       | Inline completions, quick fixes, boilerplate |
| `gpt-4.1`           | Balanced, reliable                   | Medium    | DevOps commands, general tasks, good default |
| `claude-sonnet-4-5` | Code quality + instruction following | Medium    | Code gen, review, docs, tests                |
| `claude-opus-4-5`   | Maximum thoroughness                 | High      | Security audit, nuanced analysis             |
| `claude-haiku-4-5`  | Speed + cost                         | Low       | Fast persona agents, light review            |
| `gemini-2.5-pro`    | 1M token context window              | High      | Reading entire codebases, large files        |
| `gemini-2.0-flash`  | Fast long context                    | Medium    | Quick multi-file analysis                    |

### Task → model routing table

| Task                                        | Model               | Why                                           |
| ------------------------------------------- | ------------------- | --------------------------------------------- |
| Typing autocomplete                         | `o4-mini`           | Must be fast enough not to interrupt typing   |
| `/review` — code review                     | `claude-sonnet-4-5` | Best code understanding + natural feedback    |
| `/fix-issue` — bug fix                      | `claude-sonnet-4-5` | Reliable targeted edits, follows instructions |
| `/deploy` — deployment checklist            | `gpt-4.1`           | Fast, structured CLI output                   |
| `/architect` — system design                | `o3`                | Multi-step trade-off reasoning                |
| `/security-scan` — security audit           | `claude-opus-4-5`   | Most thorough, catches subtle issues          |
| `/document` — write docs                    | `claude-sonnet-4-5` | Natural prose + technical accuracy            |
| `/explain-codebase` — understand large code | `gemini-2.5-pro`    | Only model that fits entire service           |
| `/test-gen` — write tests                   | `claude-sonnet-4-5` | Best at realistic, idiomatic tests            |
| Plan agent (planning phase)                 | `o3`                | Systematic planning and risk analysis         |
| Implement agent (coding phase)              | `claude-sonnet-4-5` | Code generation at scale                      |
| Review agent (final review)                 | `claude-opus-4-5`   | Maximum scrutiny before merge                 |
| Code reviewer persona agent                 | `claude-sonnet-4-5` | Balanced speed + quality for back-and-forth   |
| Security auditor persona agent              | `claude-opus-4-5`   | Most thorough for deep sessions               |
| Architect persona agent                     | `o3`                | Extended reasoning conversations              |
| DevOps persona agent                        | `gpt-4.1`           | Fast, reliable for command lookups            |
| Large codebase reader persona agent         | `gemini-2.5-pro`    | 1M token window                               |

### How model selection works

There are three mechanisms, in priority order:

1. **Frontmatter `model:` field** — a prompt or agent file specifies the model explicitly.
   This overrides everything. Example: `model: claude-opus-4-5` in `security-scan.prompt.md`.

2. **Model picker selection** — whatever model you've selected in the VS Code chat panel.
   Used when no frontmatter model is set (skills, instructions, inline completions).

3. **Auto mode** — if you select "Auto" in the picker, Copilot dynamically chooses based
   on availability and your subscription. Gives a 10% premium request discount.

> **Tip**: For everyday work, set your picker to `Auto`. Switch manually to `gemini-2.5-pro`
> only when you need to read large files. The slash commands and custom agents will override
> your picker anyway.

---

## 3. Full folder structure at a glance

```
your-project/
│
├── .github/copilot-instructions.md      ← ALWAYS ON. Team constitution. Short.
├── .copilotignore                        ← Exclude files from AI context. Gitignore syntax.
│
├── .github/
│   │
│   ├── prompts/                          ← SLASH COMMANDS. Type /name to invoke.
│   │   ├── review.prompt.md             →  /review        [claude-sonnet-4-5]
│   │   ├── fix-issue.prompt.md          →  /fix-issue      [claude-sonnet-4-5]
│   │   ├── deploy.prompt.md             →  /deploy         [gpt-4.1]
│   │   ├── architect.prompt.md          →  /architect      [o3]
│   │   ├── security-scan.prompt.md      →  /security-scan  [claude-opus-4-5]
│   │   ├── document.prompt.md           →  /document       [claude-sonnet-4-5]
│   │   ├── explain-codebase.prompt.md   →  /explain-codebase [gemini-2.5-pro]
│   │   ├── test-gen.prompt.md           →  /test-gen       [claude-sonnet-4-5]
│   │   └── [your-command].prompt.md     →  /your-command   [model of choice]
│   │
│   ├── instructions/                     ← AUTO-LOADED by file type. Always on for matches.
│   │   ├── code-style.instructions.md   → *.java *.go *.py *.ts
│   │   ├── testing.instructions.md      → *Test* *_test* test_* files
│   │   ├── api-conventions.instructions.md → controller/ handler/ api/ directories
│   │   └── infrastructure.instructions.md  → *.tf *.yaml Dockerfile
│   │
│   ├── skills/                           ← AUTO-DISCOVERED. Loaded when description matches.
│   │   ├── helm-upgrade/SKILL.md        → triggers on: deploy, upgrade, rollback, helm
│   │   ├── debug-eks/SKILL.md           → triggers on: pod crash, OOMKilled, kubectl
│   │   ├── terraform-plan/SKILL.md      → triggers on: tofu plan, apply, state
│   │   ├── incident-triage/SKILL.md     → triggers on: production incident, alert, postmortem
│   │   └── [your-skill]/SKILL.md        → triggers on: whatever you write in description:
│   │
│   ├── agents/                           ← CUSTOM AGENTS. Two flavors share this dir:
│   │   │                                    (a) TASK AGENTS — chain plan→implement→review
│   │   │                                    (b) PERSONA AGENTS — formerly chatmodes
│   │   ├── plan.agent.md                → model: o3              (task: reasoning)
│   │   ├── implement.agent.md           → model: claude-sonnet-4-5 (task: coding)
│   │   ├── review.agent.md              → model: claude-opus-4-5  (task: thorough review)
│   │   ├── code-reviewer.agent.md       → model: claude-sonnet-4-5 (persona)
│   │   ├── security-auditor.agent.md    → model: claude-opus-4-5  (persona)
│   │   ├── architect.agent.md           → model: o3              (persona)
│   │   ├── devops-assistant.agent.md    → model: gpt-4.1         (persona)
│   │   ├── longcontext-reader.agent.md  → model: gemini-2.5-pro  (persona)
│   │   ├── test-writer.agent.md         → model: claude-sonnet-4-5 (persona)
│   │   └── ... (50+ specialist reviewer agents)
│   │
│   └── workflows/
│       ├── copilot-setup-steps.yml      ← Bootstraps agent toolchain (Java, Go, Python, K8s)
│       └── copilot-hooks.yml            ← Pre/post gates: blocks hardcoded secrets, runs tests
│
└── .vscode/
    ├── settings.json                     ← Team config: model slots, instruction files, IDE
    ├── settings.local.json               ← Personal overrides (GITIGNORED)
    ├── mcp.json                          ← Live tool servers: GitHub, K8s, Artifactory, DB
    └── extensions.json                   ← Prompts teammates to install the right extensions
```

---

## 4. File-by-file reference

### `.github/copilot-instructions.md`

**What it is**: The single most important file. Injected into Copilot's context for
_every_ interaction — inline completions, chat, agents, skill lookups. Think of it as
the team constitution that every model reads before doing anything in your repo.

**When loaded**: Always, automatically.

**What to put here**:

- Project overview (what it is, what languages/frameworks)
- Non-negotiables that apply to everything
- Available models and when to use them (helps models give better advice)
- Commit message format

**What NOT to put here**:

- Long specifics for individual languages (use `instructions/` files instead)
- Task-specific runbooks (use `skills/` instead)
- Anything that only applies to 20% of tasks

**Tip**: Keep it under ~200 lines. It costs context budget on every request.

---

### `.copilotignore`

**What it is**: Tells Copilot which files to exclude from its context window.
Same syntax as `.gitignore`. Does NOT affect git — files are still tracked.

**When loaded**: Before every context assembly.

**What to exclude**:

- Build artefacts (`target/`, `build/`, `*.class`, `*.jar`)
- Terraform state (`*.tfstate`, `.terraform/`)
- Secrets (`*.pem`, `*.key`, `*.jks`, `.env.*`)
- Generated code (protobuf output, generated mocks)
- Dependencies (`vendor/`, `node_modules/`)

**Why it matters**: Context tokens are finite. Sending compiled `.class` files
to a language model wastes tokens and produces worse results. Sending `.jks`
keystores to any external API is a security risk.

---

### `.vscode/settings.json`

**What it is**: Team-wide VS Code + Copilot configuration. Committed to git.
Everyone on the team gets these defaults when they clone the repo.

**Key things it controls**:

- `github.copilot.enable` — which file types get inline completions
- `github.copilot.chat.models` — named model slots used by prompts/agents
- `codeGeneration.instructions` — which instruction files auto-load
- `chat.agentFilesLocations` — where Custom Agents live (replaces the legacy `chat.modeFilesLocations` / `experimental.chatModes`)

**Named model slots** (defined here, referenced in frontmatter):

```json
"fast":      o4-mini           → speed, inline, boilerplate
"reason":    o3                → architecture, planning, trade-offs
"code":      claude-sonnet-4-5 → code quality, review, tests
"thorough":  claude-opus-4-5   → security, deep analysis
"longctx":   gemini-2.5-pro    → reading entire codebases
"balanced":  gpt-4.1           → general tasks, DevOps
```

---

### `.vscode/settings.local.json` _(gitignored)_

**What it is**: Personal overrides that never get committed. Machine-specific
preferences, experimental settings, your own model preferences.

**Add to `.gitignore`**: `.vscode/settings.local.json`

**Common uses**:

- Override a model slot with your personal preference
- Point at a local JDK or Python interpreter
- Increase timeouts when on a slow VPN
- Enable experimental Copilot features you want to test

---

### `.vscode/mcp.json`

**What it is**: Defines MCP (Model Context Protocol) tool servers for the
**in-IDE** Copilot agent. These give agent mode live access to external
systems during task execution.

**How it works**: When you ask Copilot to "fix the bug from issue #42", it can
call the GitHub MCP server to _actually read issue #42_ rather than asking you
to paste it. Tools are called automatically when relevant.

**Schema essentials** (current as of May 2026):

- Top-level keys: `servers` and `inputs`.
- Server `type:` — `stdio` | `http` | `sse` | `streamable-http`.
  Prefer `streamable-http` for new remote servers.
- Per-server optional fields: `env`, `envFile` (dotenv path), `headers`,
  `sandboxEnabled`, `sandbox: { filesystem, network }`, `dev: { watch }`.
- `inputs[]` schema: `{ type: "promptString", id, description, password }`,
  referenced from server config as `${input:id}`.
- Trust is interactive (VS Code asks on first run). No `autoApprove` key.
- Reference: https://code.visualstudio.com/docs/copilot/reference/mcp-configuration

**Servers in this setup**:
| Server | What it does | Env var needed |
|--------|-------------|----------------|
| `context7` | Library/framework docs lookup (streamable-http) | None |
| `github` | Read issues, PRs, workflow runs | `GITHUB_TOKEN` |
| `filesystem` | Read/write project files (sandboxed) | None |
| `kubernetes` | List pods, read logs, check events | `KUBECONFIG` |
| `aws-docs` | Search AWS documentation | `AWS_PROFILE` |
| `artifactory` | Check packages and build info | `ARTIFACTORY_URL`, `ARTIFACTORY_TOKEN` |
| `postgres` | Query DB schema (read-only replica) | `DB_READONLY_URL` |
| `brave-search` | Web search for docs/errors | `BRAVE_API_KEY` |
| `memory` | Persist facts across sessions | None |

**All models can use all tools** — MCP access is not model-specific.

---

### `.github/copilot-mcp-config.json` (cloud coding agent MCP)

**What it is**: MCP configuration for the **GitHub Copilot cloud coding
agent** (the agent that picks up assigned issues on github.com). This is a
**different schema** from `.vscode/mcp.json`:

| Field             | VS Code (`.vscode/mcp.json`) | Cloud agent (`copilot-mcp-config.json`) |
| ----------------- | ---------------------------- | --------------------------------------- |
| Top-level key     | `servers`                    | `mcpServers`                            |
| `tools:` per server | optional (defaults open)   | **required** allow-list (e.g. `["*"]`)  |
| Secrets           | `inputs:` block              | `env:` only, sourced from repo Settings |
| Source of truth   | committed file               | **GitHub.com → Settings → Copilot**     |
| Env-var prefix    | n/a                          | `COPILOT_MCP_*`                         |

The committed file is a reference template — the actual configuration is
applied through the repo's GitHub Settings UI.
Reference: https://docs.github.com/en/copilot/customizing-copilot/extending-copilot-coding-agent-with-mcp

---

### `.vscode/extensions.json`

**What it is**: When a teammate clones the repo, VS Code shows a notification:
_"This repo recommends extensions. Install all?"_. This ensures everyone has the
same toolchain without a setup wiki page.

**Usage**: Just commit the file. VS Code handles the rest.

---

### `prompts/*.prompt.md`

**What they are**: Slash commands. Type `/review` in Copilot Chat → the
`review.prompt.md` template loads and runs with the selected model.

**How the model is selected**: The `model:` field in frontmatter. This overrides
your active model picker. So `/architect` always uses `o3` even if you have
`gpt-4.1` selected in the picker.

**Frontmatter fields**:

```yaml
---
agent: ask # which chat agent runs the command. One of:
           #   ask    — read-only chat response (no file edits)
           #   agent  — autonomous mode, modifies files directly
           #   plan   — produces a plan only, no edits
           #   <custom-agent-name> — invokes an agent from .github/agents/
model: o3 # which model to use for THIS command
description: "..." # shown in the /command picker list
---
```

> **Note**: The `agent:` field replaces the deprecated `mode: ask|edit|agent`
> field. Existing files using `mode:` should migrate (`mode: edit` → `agent: agent`).

**Slash commands in this setup**:
| Command | Model | What it does |
|---------|-------|-------------|
| `/review` | claude-sonnet-4-5 | 5-lens code review (correctness/security/perf/style/tests) |
| `/fix-issue` | claude-sonnet-4-5 | Root-cause diagnosis + targeted fix + test |
| `/deploy` | gpt-4.1 | Full deployment checklist + Helm commands |
| `/architect` | o3 | Trade-off analysis + ADR document |
| `/security-scan` | claude-opus-4-5 | Threat model + OWASP audit |
| `/document` | claude-sonnet-4-5 | Javadoc / GoDoc / docstrings generation |
| `/explain-codebase` | gemini-2.5-pro | Explain large files using 1M token context |
| `/test-gen` | claude-sonnet-4-5 | Generate comprehensive tests |

---

### `instructions/*.instructions.md`

**What they are**: Auto-loaded rules that Copilot injects whenever it generates
code for a matching file type. Unlike `copilot-instructions.md` (always loaded),
these are scoped to specific contexts.

**The `applyTo:` glob**:

```yaml
applyTo: "**/*.{java,go,py}"     ← loads for these file types
applyTo: "**/*Test*.java"         ← loads only for Java test files
applyTo: "**/{controller}/**"     ← loads for files in controller directories
```

**No model set here** — these are context, not commands. The active model reads them.

**Instructions in this setup**:
| File | Scope | Content |
|------|-------|---------|
| `code-style.instructions.md` | Java, Go, Python, TypeScript | Naming, formatting, error handling |
| `testing.instructions.md` | Test files only | JUnit 5, table-driven Go, pytest patterns |
| `api-conventions.instructions.md` | Controller/handler/router dirs | REST design, status codes, error shapes |
| `infrastructure.instructions.md` | Terraform, YAML, Dockerfile | Tagging, probes, multi-stage builds |

**Important**: Instructions are registered in `settings.json` under
`codeGeneration.instructions`. Add new files there to activate them.

---

### `skills/*/SKILL.md`

**What they are**: Task runbooks that Copilot loads automatically when your
request matches the skill's description. Unlike instructions (file-type scoped),
skills are loaded based on what you're _asking_, not which file is open.

**How discovery works**:

1. Copilot reads ONLY `name:` and `description:` from all `SKILL.md` files.
2. If description matches your prompt, the full SKILL.md body is injected.
3. You can also invoke manually: type the skill name in chat.

**The description: field is critical** — it's the only thing Copilot reads to
decide whether the skill is relevant. Write it like search keywords:

```yaml
# Bad — too vague, won't trigger reliably:
description: "Helm deployment skill"

# Good — triggers on natural language:
description: >
  Use when asked to deploy, upgrade, roll back, or release a service to Kubernetes.
  Also triggers for questions about Helm chart values, image tags, or release history.
```

**Full frontmatter (current schema)**:

```yaml
---
name: helm-upgrade                  # required, lowercase/numbers/hyphens, ≤64 chars
description: >                      # required, ≤1024 chars, written as keywords
  Use when asked to deploy, upgrade, or roll back a Kubernetes service via Helm.
argument-hint: "<service-name>"     # optional — shown to the user when invoked
user-invocable: true                # optional — default true; set false for hidden helper skills
disable-model-invocation: false     # optional — default false; true forces user-only invocation
context: inline                     # optional — `inline` (default) or `fork` (isolated subagent)
---
```

**Where skills live**:

```
.github/skills/<name>/SKILL.md     ← project-scoped (committed, everyone uses)
.claude/skills/<name>/SKILL.md     ← same spec, works with both Copilot and Claude Code
~/.copilot/skills/<name>/SKILL.md  ← personal, works across all your projects
```

**Settings key for discovery**: `chat.agentSkillsLocations` in `.vscode/settings.json`.

**Install community skills**: `gh skills install github/awesome-copilot <skill-name>`
(GitHub CLI ≥ 2.90.0).

**Skills in this setup**:
| Skill | Triggers on |
|-------|------------|
| `helm-upgrade` | deploy, upgrade, rollback, helm release, image tag |
| `debug-eks` | pod crash, OOMKilled, ImagePullBackOff, kubectl debug |
| `terraform-plan` | tofu plan, apply infrastructure, state management |
| `incident-triage` | production incident, alert firing, postmortem |

**Adding bundled resources**: Put helper files in the skill folder and reference
them in the SKILL.md:

```
skills/incident-triage/
├── SKILL.md
├── postmortem-template.md      ← referenced from SKILL.md
└── runbook.sh                  ← script Copilot can instruct you to run
```

---

### `agents/*.agent.md`

**What they are**: Autonomous workers that execute multi-step tasks without
step-by-step guidance. Unlike persona agents (you drive the conversation), task agents
take a task and run it — reading files, writing code, running builds, then
handing off to the next agent.

**Key feature — handoffs**: An agent can chain to another agent:

```yaml
handoffs:
  - implement      ← when planning is done, button appears to hand off to implement
```

This creates a Plan → Implement → Review pipeline where each phase uses
the optimal model for that work type.

**Frontmatter fields**:

```yaml
---
name: plan # identifier used in handoffs:
model: o3 # model for this agent's work
tools: # what the agent can do
  - read_file
  - write_file
  - run_terminal_command
handoffs:
  - implement # which agent to hand off to when done
---
```

**Agents in this setup**:
| Agent | Model | Tools | Hands off to |
|-------|-------|-------|-------------|
| `plan` | o3 | Read-only | `implement` |
| `implement` | claude-sonnet-4-5 | Read + Write + Terminal | `review` |
| `review` | claude-opus-4-5 | Read-only | (terminal) |

**When to use task agents vs persona agents** (both live in `agents/`):

- Use a **task agent** (plan/implement/review/specialist reviewer) when you
  want Copilot to execute a complete workflow autonomously
- Use a **persona agent** (architect/code-reviewer/security-auditor/etc.)
  when you want to have a conversation with an expert persona

---

### `agents/*.agent.md` — persona variant

**What they are**: Named conversation modes, each with a defined persona and
model. You pick one from the chat agent dropdown in VS Code. The persona
persists for your entire conversation session.

> Persona agents are the same primitive as task agents (plan/implement/review)
> — both are Custom Agents (`.agent.md`). They differ only in usage pattern:
> personas are interactive, task agents run workflows.
>
> This unification replaces the legacy `.chatmode.md` primitive that was
> deprecated by GitHub Copilot in 2026.

**Key difference from prompts**: Prompts are one-shot commands (`/review` runs
once). Persona agents are persistent for extended back-and-forth.

**Frontmatter fields** (Custom Agent schema):

```yaml
---
name: code-reviewer                 # required, kebab-case
description: "What this persona does — shown in the picker"
model: claude-opus-4-5              # model for all messages in this persona
user-invocable: true                # default true; show in picker
disable-model-invocation: false     # default false; if true, only user can invoke
target: vscode                      # vscode | github-copilot
# Optional: tools[], agents[] (subagents), handoffs[], mcp-servers[], hooks
---
```

**Persona agents in this setup**:
| Agent | Model | Best for |
|-------|-------|---------|
| Code reviewer | claude-sonnet-4-5 | PR review, before pushing |
| Security auditor | claude-opus-4-5 | Auth PRs, new endpoints, security review |
| Architect | o3 | Design sessions, technology decisions |
| DevOps assistant | gpt-4.1 | Deployment issues, infra debugging |
| Large codebase reader | gemini-2.5-pro | Onboarding, understanding legacy code |
| Test writer | claude-sonnet-4-5 | TDD, adding tests to existing code |

**Prerequisite**: `"chat.agentFilesLocations": { ".github/agents": true }` and `"chat.agent.enabled": true` in settings.json.

---

### `workflows/copilot-setup-steps.yml`

**What it is**: A GitHub Actions workflow that bootstraps the environment for
the Copilot _coding agent_ (the autonomous one that works on GitHub issues).

**When it runs**: Automatically before the agent starts any assigned task.

**What it installs**: Java 17, Maven (with Artifactory mirror), Go 1.22,
golangci-lint, Python 3.11, OpenTofu, Helm, kubectl.

**Why this matters**: Without this file, the coding agent would try to generate
code it can't compile or test. With it, the agent has a full toolchain and can
verify its own work.

---

### `workflows/copilot-hooks.yml`

**What it is**: Pre and post-action policy gates that enforce hard rules on
every agent action, regardless of which model or agent triggered it.

**`copilot_pre_action`** — runs BEFORE changes are made:

- Blocks hardcoded credential patterns
- Blocks terraform state commits

**`copilot_post_action`** — runs AFTER changes:

- Runs the test suite
- Runs linters

**Why hooks matter**: Models can make mistakes. Hooks are a safety net that
doesn't rely on model behaviour — they're enforced at the workflow level.

---

## 5. Decision guide — what to use when

### "I want to do something once, right now"

→ Use a **slash command** (`/review`, `/deploy`, `/fix-issue`)

### "I want to have an extended conversation with an expert"

→ Use a **persona agent** (Code reviewer, Architect, Security auditor)

### "I want Copilot to understand how we do X in this project"

→ Add a **skill** (SKILL.md with a good description)

### "I want Copilot to follow rules when writing Java/Python/Go code"

→ Add an **instruction file** with the right `applyTo:` glob

### "I want to run a complete feature from planning to PR"

→ Use the **agent chain**: plan → implement → review

### "I need to read and understand a huge codebase"

→ Use the **Large codebase reader persona agent** (Gemini 2.5 Pro, 1M tokens)

### "I need to find a security vulnerability"

→ Use `/security-scan` or the **Security auditor persona agent** (Claude Opus, most thorough)

### "I'm designing a new system architecture"

→ Use `/architect` or the **Architect persona agent** (o3, best reasoning)

### "I want these rules to apply across ALL my projects"

→ Copy skills to `~/.copilot/skills/` and instructions to `~/.copilot/instructions/`

---

## 6. How to add your own files

### Adding a new slash command

Create `.github/prompts/my-command.prompt.md`:

```markdown
---
agent: ask                   # or: agent (modifies files), plan, or a custom agent name
model: claude-sonnet-4-5     # pick the best model for this task
description: "What /my-command does — shown in the picker"
---

Your prompt instructions here.
Tell Copilot exactly what to do when this command is invoked.
```

The command is immediately available as `/my-command`.

### Adding a new skill

Create `.github/skills/my-skill/SKILL.md`:

```markdown
---
name: my-skill
description: >
  Use when asked to [natural language description of when to trigger this].
  Also triggers for [more trigger phrases].
---

# My skill title

Detailed instructions for Copilot to follow when this skill is loaded.
Include code examples, commands, decision tables — anything useful.
```

The skill auto-discovers when Copilot detects relevance.

### Adding a new persona agent (formerly "chatmode")

Create `.github/agents/my-persona.agent.md`:

```markdown
---
name: my-persona
description: "My persona — what it does — shown in agent picker"
model: o3
user-invocable: true
target: vscode
---

You are [name], a [role] with expertise in [domain].

[Describe the persona's approach, rules, and constraints.]
```

Appears immediately in the VS Code chat agent dropdown.

### Adding an instruction file

Create `.github/instructions/my-rules.instructions.md`:

```markdown
---
applyTo: "**/*.{java,go}"
---

# My rules

[Rules Copilot should follow when generating code for matching files.]
```

Then register it in `.vscode/settings.json`:

```json
"github.copilot.chat.codeGeneration.instructions": [
  { "file": ".github/instructions/my-rules.instructions.md" }
]
```

---

## 7. Admin setup (org/enterprise)

### Enabling multi-model access for the team

1. **GitHub.com** → Your org → Settings → Copilot → Policies
2. Enable "Allow members to use additional AI models"
3. Enable each model family: Anthropic, Google, OpenAI

> If models aren't appearing in VS Code for teammates, this policy is the
> most common reason. Check: VS Code → Copilot Chat → model dropdown →
> "Manage Models" → click "Copilot" (not "Anthropic") to see available models.

### Sharing skills org-wide

Skills can be published as GitHub repos and installed:

```bash
# From the github/awesome-copilot community collection
copilot plugin install my-skill@awesome-copilot
```

Or committed to a central config repo and referenced via
`chat.agentSkillsLocations` in settings.json.

### Premium request usage

Some models cost more than 1× the base request rate. Current multipliers:

- `o3`, `claude-opus-4-5`, `gemini-2.5-pro` → higher multiplier (check GitHub docs)
- `o4-mini`, `claude-haiku-4-5`, `gemini-2.0-flash` → 1× or close
- `gpt-4.1` → check current docs

**Use "Auto" mode** for a 10% discount on premium requests and automatic
model selection based on availability.

---

## 8. Governance and quality gates

### Asset manifest

Every Copilot asset is tracked in `.github/copilot-asset-manifest.json`. This is the
single source of truth for what ships, who owns it, and whether it's generated or
hand-maintained.

**When you add a new asset**, add a corresponding entry to the manifest. The CI
evaluation workflow (`copilot-eval.yml`) will fail if a file exists without a
manifest entry or vice versa.

### Model compatibility matrix

`.github/model-compatibility.json` defines all available models, their capabilities,
named slots (referenced in `settings.json`), and fallback behavior.

**Fallback policy**:

- **Gated workflows** (security scans, eval checks): **fail-closed** — if the
  specified model is unavailable, the workflow blocks rather than silently falling back
- **Advisory workflows** (code review, documentation): **controlled fallback** — may
  use an alternative model, but must report which model was actually used

### Evaluation gates

PRs touching Copilot assets trigger `.github/workflows/copilot-eval.yml`, which runs:

| Check              | What it validates                                       |
| ------------------ | ------------------------------------------------------- |
| `naming.sh`        | Kebab-case file names, correct extensions               |
| `frontmatter.sh`   | Required YAML frontmatter fields per asset type         |
| `model-refs.sh`    | Model names exist in the compatibility matrix           |
| `manifest-sync.sh` | Every manifest path exists on disk; no untracked assets |

All deterministic checks must pass (100%). Rubric-based behavioral checks will be
added in Phase 2 with a ≥80% pass threshold.

### Changelog

All changes to Copilot assets are logged in `COPILOT-CHANGELOG.md` using
[Keep a Changelog](https://keepachangelog.com/) format. Include an entry for every
PR that adds, changes, deprecates, or removes a Copilot asset.

### Governance checklist

See `.github/GOVERNANCE.md` for the full checklist when adding, deprecating, or
transferring ownership of assets. Key rules:

- Every asset must have a declared owner
- Deprecation requires 60-day minimum grace period
- New assets must pass all eval checks before merge

---

## 9. Troubleshooting

### Custom agents not appearing in VS Code

Add to `.vscode/settings.json`:

```json
"chat.agentFilesLocations": { ".github/agents": true },
"chat.agent.enabled": true
```

The older `"github.copilot.chat.experimental.chatModes": true` setting only
matters if you still have `.chatmode.md` files lingering in `.github/chatmodes/`
— in this repo that primitive has been migrated to `.github/agents/*.agent.md`.

Restart VS Code after changing.

### Claude/Gemini not appearing in model picker

1. Go to VS Code → Copilot Chat panel → model dropdown
2. Click **"Manage Models"**
3. Click **"Copilot"** (not "Anthropic" or "Google") in the provider list
4. Check the models you want, click OK

> This is a known UX confusion — you must click "Copilot" as the provider,
> not the individual company names.

### Skills not triggering automatically

The `description:` field must match your natural language. Tips:

- Include both the action ("deploy a service") and the symptoms ("image tag not found")
- List specific keywords people would actually say
- Test by typing `/skills list` to see what's discovered

### Model not being used as set in frontmatter

- Verify the exact model string matches your picker dropdown name
- Some models require the org admin to enable them first (see Admin section)
- Premium models may be rate-limited; try again or switch to a fallback

### MCP tools not working

Check env vars are exported in your shell:

```bash
echo $GITHUB_TOKEN    # should print a value
echo $KUBECONFIG      # should print a path
```

Restart VS Code after setting new env vars — VS Code reads them at startup.

### "Another operation in progress" in Helm

```bash
kubectl get secrets -n <namespace> | grep helm
kubectl delete secret sh.helm.release.v1.<release>.v<n> -n <namespace>
```

---

_Last updated: March 2026. Model IDs and feature availability change — check
[docs.github.com/copilot](https://docs.github.com/en/copilot/reference/ai-models/supported-models)
for the current list._
