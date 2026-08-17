# Copilot Anatomy

A reference implementation for configuring **GitHub Copilot** across a multi-model,
polyglot team. Includes every customisation primitive — `AGENTS.md`, instructions,
skills, custom agents, hooks, MCP, and Agent Plugins 1.0 packaging — plus governance
tooling and an interactive visualisation.

*Verified against GitHub Copilot's documented behaviour on 2026-08-17.*

> **[Live demo →](https://vib795.github.io/copilot-anatomy/)** Explore every file and
> how the pieces fit together — right in your browser.

---

## Quick start

### Option A — Generate into an existing repo

```bash
bash copilot-setup.sh /path/to/your/project
```

This scaffolds the full `.github/` Copilot structure, `.vscode/` settings, and
`.copilotignore` into the target directory. Run it once, then customise.

### Option B — Use as a reference

Browse the files directly. The cheatsheet explains everything:

- [COPILOT-CHEATSHEET.md](COPILOT-CHEATSHEET.md) — Full guide to every primitive
- [copilot-anatomy.html](copilot-anatomy.html) — Interactive folder visualisation

---

## What's inside

```
.github/                             ← also the Agent Plugins 1.0 plugin root
├── copilot-instructions.md          ← Always-on team instructions
├── copilot-asset-manifest.json      ← Single source of truth for all assets
├── model-compatibility.json         ← Model roster, slots, deprecations, fallbacks
├── GOVERNANCE.md                    ← Checklist for adding new assets
├── plugin.json                      ← Agent Plugins 1.0 manifest
├── mcp.json                         ← Portable MCP servers (spec schema)
├── com.github.copilot/              ← Copilot-only extension namespace
│
├── instructions/                    ← Auto-loaded rules scoped by file type
│   ├── code-style.instructions.md
│   ├── testing.instructions.md
│   ├── api-conventions.instructions.md
│   └── infrastructure.instructions.md
│
├── prompts/                         ← LEGACY slash commands — Local harness only
│   ├── review.prompt.md                (deprecated, removal 2026-11-16)
│   ├── fix-issue.prompt.md             each now has a skills/ equivalent
│   ├── deploy.prompt.md
│   ├── architect.prompt.md
│   ├── security-scan.prompt.md
│   └── ...
│
├── agents/                          ← Autonomous multi-step workflows
│   ├── plan.agent.md                   (plan → implement → review chain)
│   ├── implement.agent.md
│   ├── review.agent.md
│   └── ... (50+ specialist reviewers)
│
├── skills/                          ← Auto-discovered runbooks + slash commands
│   ├── debug-eks/SKILL.md              (the portable primitive — prefer these)
│   ├── helm-upgrade/SKILL.md
│   ├── terraform-plan/SKILL.md
│   ├── review/SKILL.md                 ← migrated from review.prompt.md
│   └── ... (84 skills)
│
│   (Persona agents — formerly `.chatmode.md` under chatmodes/ — now live
│    in agents/ above. Chat modes were deprecated by GitHub Copilot in 2026
│    in favor of Custom Agents with a richer frontmatter schema.)
│
├── eval/                            ← Quality gates
│   ├── checks/                         (manifest sync, frontmatter, model refs,
│   │                                    plugin manifest, deprecation lifecycle)
│   └── rubrics/
│
├── hooks/                           ← Lifecycle hooks (14 events available)
│   ├── copilot-hooks.json
│   └── scripts/policy-gate.sh          ← emits permissionDecision allow/ask/deny
│
└── workflows/                       ← CI/bootstrap workflows
    └── copilot-setup-steps.yml

.vscode/
├── settings.json                    ← Model routing + IDE config
├── mcp.json                         ← MCP tool servers
└── extensions.json                  ← Recommended extensions

copilot-anatomy.html                 ← Interactive visualisation
copilot-setup.sh                     ← Generator script
COPILOT-CHEATSHEET.md                ← Comprehensive guide
COPILOT-CHANGELOG.md                 ← Asset change log
.copilotignore                       ← Context exclusion rules
```

---

## Model routing strategy

Each slot is routed to the model that plays to its strengths:

| Slot           | Model                | Best for                                              |
| -------------- | -------------------- | ----------------------------------------------------- |
| **`reason`**   | GPT-5.6 Sol          | Architecture decisions, complex reasoning, planning    |
| **`balanced`** | GPT-5.6 Terra        | General-purpose, DevOps commands, the everyday default |
| **`code`**     | Claude Sonnet 5      | Code generation, review, documentation, tests          |
| **`thorough`** | Claude Opus 5        | Security audits, deep review, nuanced analysis         |
| **`longctx`**  | GPT-5.4              | Reading large files or entire codebases                |
| **`fast`**     | Claude Haiku 4.5     | Inline completions, boilerplate, trivial fixes         |

Routing is configured in `.vscode/settings.json` and referenced from asset
frontmatter via `.github/model-compatibility.json`.

> **Two things changed in 2026 that make the old table misleading.**
>
> **1M context is a capability, not a tier.** Nearly every frontier model now
> offers a 1M-token window in VS Code and Copilot CLI, so `longctx` is a cost
> decision rather than a capability one.
>
> **Reasoning level is a dial.** Models expose configurable reasoning effort.
> Raising it on a mid-tier model is usually cheaper than escalating to a
> flagship — try that before moving a task from `code` to `thorough`.

> **Roster currency (verified 2026-08-17).** `o3`, `o4-mini`, `gpt-4.1`,
> `gemini-2.5-pro`, and `gemini-2.0-flash` have been retired from Copilot
> entirely. Claude Sonnet 4.5/4.6 and Opus 4.5/4.6 retire **2026-09-01**.
> The full replacement table lives in the `deprecated` block of
> `.github/model-compatibility.json`; `model-refs.sh` fails CI on any asset
> still pointing at a retired model.

---

## Governance

Every asset must pass through a checklist before merge:

1. Entry in `copilot-asset-manifest.json` with owner, classification, description
2. Valid frontmatter (model reference, description)
3. Model referenced in `model-compatibility.json`
4. Kebab-case naming convention
5. `COPILOT-CHANGELOG.md` entry

CI eval checks in `.github/eval/checks/` enforce this automatically.
See [GOVERNANCE.md](.github/GOVERNANCE.md) for the full process.

---

## The primitives

| Primitive             | Trigger                            | Location                         | Portable? |
| --------------------- | ---------------------------------- | -------------------------------- | --------- |
| **Team instructions** | Always on                          | `copilot-instructions.md`         | Copilot   |
| **`AGENTS.md`**       | Always on, nearest file wins       | `AGENTS.md` (root or nested)      | **Yes**   |
| **Instruction files** | Auto, by `applyTo:` glob           | `instructions/*.instructions.md`  | Copilot   |
| **Skills**            | Auto-discovered by description, or `/name` | `skills/*/SKILL.md`       | **Yes**   |
| **Custom Agents**     | Agent picker, `handoffs:`, autonomous | `agents/*.agent.md`            | Copilot   |
| **Hooks**             | Lifecycle events (14 of them)      | `hooks/*.json`                    | Copilot   |
| **Agent Plugin**      | Installed from a marketplace       | `plugin.json` + `skills/` + `mcp.json` | **Yes** |
| **Prompt files** ⚠️   | Manual — `/command`                | `prompts/*.prompt.md`             | No — legacy |

> **⚠️ Prompt files are legacy.** They run **only in the Local agent harness**.
> Copilot CLI, the Copilot cloud agent, and Agent Plugins all express slash
> commands as skills, and GitHub ships a one-time *Migrate Prompts* action to
> convert them. The ten commands in this repo are published as skills, with the
> `.prompt.md` originals kept and formally deprecated (removal **2026-11-16**)
> so you can see both shapes side by side.

> **Custom Agents subsume the legacy "chat modes" primitive.** Persona agents
> (formerly `.chatmode.md`) and task agents (plan / implement / review +
> 50+ specialist reviewers) now share the same `.agent.md` schema, with
> richer frontmatter (`agents`, `handoffs`, `user-invocable`,
> `disable-model-invocation`, `target`, `mcp-servers`, `hooks`).

> **"Portable" means it survives a move to another agent tool.** Agent Plugins
> 1.0 standardises exactly two things across clients — skills and MCP servers.
> Everything else is Copilot-specific. If you want a capability to outlive your
> current tool choice, write it as a skill.

---

## Agent Plugins 1.0

Since August 2026, skills and MCP servers can be packaged into a single
installable unit under a vendor-neutral standard backed by GitHub, AWS,
Anysphere, Microsoft, OpenAI, Vercel, and Google. This repo ships as one —
`.github/` **is** the plugin root:

```
.github/                             ← plugin root
├── plugin.json                      ← Agent Plugins 1.0 manifest (closed schema)
├── skills/<name>/SKILL.md           ← portable, spec-standard
├── mcp.json                         ← portable MCP servers
└── com.github.copilot/              ← Copilot-only extension namespace
```

The root manifest is a **closed object** — only `$schema`, `name`, `version`,
`description`, `author`, `homepage`, `repository`, `license`, `keywords`, and
`extensions` are permitted. Putting `hooks` or `mcpServers` at the top level
makes the package invalid, and clients reject it *silently*, so
`.github/eval/checks/plugin-manifest.sh` validates it in CI.

Enterprises govern plugins through `managed-settings.json` — `enabledPlugins`
to force-install or block, `extraKnownMarketplaces` to add sources, and
`strictKnownMarketplaces` to close the gate. See
[`docs/examples/managed-settings.json`](docs/examples/managed-settings.json).

---

## Contributing

1. Fork and create a feature branch
2. Follow the governance checklist in [GOVERNANCE.md](.github/GOVERNANCE.md)
3. Run the eval checks: `bash .github/eval/checks/manifest-sync.sh`
4. Open a PR

---

## License

[MIT](LICENSE)
