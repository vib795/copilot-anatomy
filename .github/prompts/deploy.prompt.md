---
agent: ask
model: gpt-5.6-terra
description: "Generate deployment checklist and Helm commands for the active service"
---

> [!WARNING]
> **DEPRECATED (2026-08-17) — removal 2026-11-16.** Prompt files run only in the
> Local agent harness. Copilot CLI, the Copilot cloud agent, and Agent Plugins
> express slash commands as **skills**. This command now lives at
> `.github/skills/deploy/SKILL.md`; edit that file, not this one.
> See `.github/GOVERNANCE.md` → "Deprecating an asset".


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
