---
agent: ask
model: claude-opus-4-5
description: "Comprehensive security audit — threat model, OWASP, CVE patterns"
---

<!--
  SLASH COMMAND: /security-scan
  MODEL: claude-opus-4-5 — most thorough analysis, catches subtle issues
  AGENT: ask — produces a security report, does not edit files
-->

Perform a thorough security audit of the selected code or active file.

## Threat model checklist

Work through each category. Only report findings — skip categories with nothing to flag:

**Authentication & Authorisation**
- Who is allowed to call this? Is the caller verified?
- Does the caller have permission for this specific resource (not just "is logged in")?
- Are there privilege escalation paths?

**Injection**
- SQL injection (raw string concat vs parameterised queries)
- Command injection (`exec.Command`, `Runtime.exec`, `subprocess.run` with user input)
- Log injection (user data interpolated into log messages)
- SSTI / XSS in template rendering

**Secrets & Data Exposure**
- Credentials in code, config, or environment strings that might be logged
- PII in logs, error messages, or API responses
- Insecure serialisation or exposure of internal objects

**Supply Chain**
- Unpinned dependency versions that could be hijacked
- Base images without digest pins
- Third-party scripts loaded from CDNs without integrity checks

**Infrastructure (if applicable)**
- YAML with `privileged: true`, `hostPID`, `runAsRoot`
- S3 `acl = "public-read"` or missing server-side encryption
- IAM policies using `*` resource or `*` action

## Severity ratings
🔴 Critical — remotely exploitable, high impact, low complexity
🟠 High — exploitable, significant data/privilege impact
🟡 Medium — requires specific conditions or limited impact
🔵 Low / Info — defence-in-depth, best practice, hardening

## Per finding
**What**: vulnerability class (e.g. "SQL injection")
**Where**: file:line
**Impact**: what an attacker achieves
**Fix**: concrete code change with example
**Reference**: OWASP / CWE link where applicable
