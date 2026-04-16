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

- **o3** → architecture decisions, complex reasoning, planning
- **o4-mini** → fast completions, boilerplate, quick fixes
- **gpt-4.1** → general-purpose, DevOps commands, balanced tasks
- **claude-sonnet-4-5** → code generation, review, documentation, tests
- **claude-opus-4-5** → security audits, thorough review, nuanced analysis
- **gemini-2.5-pro** → reading large files or entire codebases (1M token context)
- **gemini-2.0-flash** → fast analysis of many files simultaneously

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
- Shell scripts: `set -euo pipefail` at top.
- Dockerfiles: multi-stage builds, pinned digest base images, non-root USER.
- Commits: `<type>(<scope>): <subject>` — feat/fix/chore/docs/refactor/test/ci/perf.

## Copilot asset governance

- New prompts/skills/agents/chatmodes require a manifest entry in `.github/copilot-asset-manifest.json`.
- Model references must exist in `.github/model-compatibility.json`.
- Changes to Copilot assets must include a `COPILOT-CHANGELOG.md` entry.
- See `.github/GOVERNANCE.md` for the full checklist.

## MCP tool security posture

- Default profile is **read-only** (context7 only). See `.github/copilot-mcp-profiles.json`.
- **Standard** profile adds GitHub read operations — activate explicitly for context gathering.
- **Elevated** profile enables all servers including write operations — required for deployments, PR creation, and infrastructure changes.
- Never run with elevated profile unless the task requires write operations.
