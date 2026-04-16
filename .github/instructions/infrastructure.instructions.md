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
