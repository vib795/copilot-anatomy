# `com.github.copilot/` — client extension namespace

This directory marks the Copilot-specific extension namespace for the
Agent Plugins 1.0 package rooted at `.github/`.

## Why it is (nearly) empty

Agent Plugins 1.0 standardises exactly two things across every compatible
client — **skills** (`skills/*/SKILL.md`) and **MCP servers** (`mcp.json`).
Anything else is client-specific and must live under a reverse-domain
namespace that the client owns. GitHub's namespace is `com.github.copilot`.

The spec permits that namespace to be expressed **two ways**:

1. as manifest data under `extensions["com.github.copilot"]` in `plugin.json`, or
2. as files inside a top-level `com.github.copilot/` directory.

This repo uses **form 1**, because form 2 would require physically relocating
`agents/`, `instructions/`, and `hooks/` into this directory — and VS Code
discovers those primitives at their canonical `.github/` paths. Moving them
would make the plugin marginally more self-contained and immediately break the
IDE experience, the asset manifest, and every eval check. Portability is not
worth breaking the thing being demonstrated.

So `plugin.json` declares the mapping instead:

```jsonc
"extensions": {
  "com.github.copilot": {
    "agents":            "agents",                     // .github/agents/*.agent.md
    "instructions":      "instructions",               // .github/instructions/*.instructions.md
    "hooks":             "hooks/copilot-hooks.json",
    "mcpProfiles":       "copilot-mcp-profiles.json",
    "defaultMcpProfile": "read-only"
  }
}
```

## What travels, and what doesn't

| Asset | Portable across clients? | Where it lives |
| --- | --- | --- |
| Skills | Yes — spec-standard | `.github/skills/<name>/SKILL.md` |
| MCP servers | Yes — spec-standard | `.github/mcp.json` |
| Custom agents | No — Copilot-specific | `.github/agents/*.agent.md` |
| Instructions | No — Copilot-specific | `.github/instructions/*.instructions.md` |
| Hooks | No — Copilot-specific | `.github/hooks/copilot-hooks.json` |
| Prompt files | No — Local harness only | `.github/prompts/*.prompt.md` (legacy) |

The practical consequence: **anything you want to survive a move to another
agent tool belongs in a skill.** That is the same reason GitHub now recommends
migrating prompt files to skills, and why the ten `/commands` in this repo are
published as skills first and prompt files second.

## Current client behaviour

VS Code currently **ignores** client-extension data and directories in Agent
Plugins 1.0 packages — it loads `skills/` and `mcp.json` and nothing else from
the plugin. The `extensions` block is therefore forward-looking: it documents
intent and is read by this repo's own tooling
(`.github/eval/checks/plugin-manifest.sh`), not yet by the editor.

Re-verify against the spec before relying on it:
<https://agent-plugins.org/specification>
