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
