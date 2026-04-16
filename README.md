# Copilot Anatomy

A reference implementation for configuring **GitHub Copilot** across a multi-model,
polyglot team. Includes every customisation primitive — instructions, prompts, skills,
agents, chat modes — plus governance tooling and an interactive visualisation.

> **Live demo →** Open `copilot-anatomy.html` in a browser to explore every file and
> how the pieces fit together.

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
.github/
├── copilot-instructions.md          ← Always-on team instructions
├── copilot-asset-manifest.json      ← Single source of truth for all assets
├── model-compatibility.json         ← Model × primitive compatibility matrix
├── GOVERNANCE.md                    ← Checklist for adding new assets
│
├── instructions/                    ← Auto-loaded rules scoped by file type
│   ├── code-style.instructions.md
│   ├── testing.instructions.md
│   ├── api-conventions.instructions.md
│   └── infrastructure.instructions.md
│
├── prompts/                         ← Slash commands (/review, /deploy, etc.)
│   ├── review.prompt.md
│   ├── fix-issue.prompt.md
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
├── skills/                          ← Auto-discovered task runbooks
│   ├── debug-eks/SKILL.md
│   ├── helm-upgrade/SKILL.md
│   ├── terraform-plan/SKILL.md
│   ├── incident-triage/SKILL.md
│   └── ... (60+ skills)
│
├── chatmodes/                       ← Persona-driven conversation sessions
│   ├── code-reviewer.chatmode.md
│   ├── security-auditor.chatmode.md
│   ├── architect.chatmode.md
│   └── ...
│
├── eval/                            ← Quality gates
│   ├── checks/                         (manifest sync, frontmatter, model refs)
│   └── rubrics/
│
├── hooks/                           ← Session lifecycle hooks
│   └── copilot-hooks.json
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

Each model is routed to tasks that play to its strengths:

| Model | Best for |
|-------|----------|
| **o3** | Architecture decisions, complex reasoning, planning |
| **o4-mini** | Fast completions, boilerplate, quick fixes |
| **gpt-4.1** | General-purpose, DevOps commands, balanced tasks |
| **Claude Sonnet 4.5** | Code generation, review, documentation, tests |
| **Claude Opus 4.5** | Security audits, thorough review, nuanced analysis |
| **Gemini 2.5 Pro** | Reading large files or entire codebases (1M context) |
| **Gemini 2.0 Flash** | Fast analysis of many files simultaneously |

Routing is configured in `.vscode/settings.json` and referenced from prompt/agent frontmatter via `.github/model-compatibility.json`.

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

## The six primitives

| Primitive | Trigger | Location |
|-----------|---------|----------|
| **Team instructions** | Always on | `copilot-instructions.md` |
| **Instruction files** | Auto, by file type | `instructions/*.instructions.md` |
| **Prompt files** | Manual — `/command` | `prompts/*.prompt.md` |
| **Skills** | Auto-discovered | `skills/*/SKILL.md` |
| **Chat modes** | Manual — mode picker | `chatmodes/*.chatmode.md` |
| **Agents** | Manual or chained | `agents/*.agent.md` |

---

## Contributing

1. Fork and create a feature branch
2. Follow the governance checklist in [GOVERNANCE.md](.github/GOVERNANCE.md)
3. Run the eval checks: `bash .github/eval/checks/manifest-sync.sh`
4. Open a PR

---

## License

MIT
