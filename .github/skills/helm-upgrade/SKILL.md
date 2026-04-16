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
