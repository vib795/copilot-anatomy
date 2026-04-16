---
name: incident-triage
description: >
  Use during a production incident, when an alert is firing, a service is down,
  or when writing a postmortem. Provides a structured triage checklist, timeline
  capture format, and postmortem template for this project.
license: MIT
---

# Incident triage — structured response

## Severity levels
| Sev | Definition | Response time |
|-----|-----------|---------------|
| Sev-1 | Production down, data loss risk, SLA breach | Immediate |
| Sev-2 | Degraded production, no data loss | < 30 min |
| Sev-3 | Non-critical feature affected | Next business day |

## Triage checklist (run in order)
1. **Establish impact**: which users/regions affected? What percentage of traffic?
2. **Check dashboards**: Datadog service map → which service shows red?
3. **Check recent deploys**: `helm history <service> -n <namespace>` — did a deploy cause this?
4. **Check logs**: Splunk/Datadog logs filtered to the affected service + last 30 min
5. **Communicate**: post in #incidents with: service, impact, start time, who's investigating

## Common first-response commands
```bash
# Service health
kubectl get pods -n production -l app=<service>
kubectl logs -l app=<service> -n production --tail=200 --since=30m

# Recent changes
helm history <service> -n production
git log --oneline main..HEAD  # recent commits

# Rollback if deploy-caused
helm rollback <service> 0 -n production
```

## Timeline capture (maintain during incident)
```
HH:MM - [event description]
HH:MM - [what was checked / found]
HH:MM - [action taken]
HH:MM - [result of action]
```

## Postmortem template
```markdown
## Incident postmortem: <title>

**Date**: YYYY-MM-DD
**Duration**: HH:MM to HH:MM (X minutes)
**Severity**: Sev-N
**Affected**: <what/who was impacted>

### Timeline
[paste timeline from above]

### Root cause
<What actually caused the incident — not symptoms, the root cause>

### Contributing factors
<What made the root cause possible or worse>

### Resolution
<What fixed it>

### Action items
| Item | Owner | Due date |
|------|-------|----------|
| <preventive action> | @person | YYYY-MM-DD |
```
