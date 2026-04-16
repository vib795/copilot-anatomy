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
