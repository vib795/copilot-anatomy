---
name: wave2-impact-tracking
description: >
  Wave 2 curriculum lab (weeks 1-2, days 9-10). Use when documenting time saved,
  quality improvements, and rework reduction from AI-assisted tasks, or building
  a personal AI impact log that rolls up into team metrics. Keywords: AI impact
  tracking, metrics, time saved, impact log, measurement, ROI.
license: MIT
---

# Wave 2 Lab 5 — Measuring What Matters: AI Impact Tracking

**Module:** Advanced Agent Building & Multi-Step Workflows (Weeks 1–2)
**Days:** 9–10 · **Format:** Shared

## Outcome

Document time saved, quality improvements, and rework reduction from
AI-assisted tasks. Create a personal "AI impact log" that becomes a team-level
metric.

## Repo assets used

| Asset | Path | Role in this lab |
|-------|------|------------------|
| Health dashboard | `copilot-health.sh` | The repo's own measurement pattern: JSON canonical + Markdown summary |
| Health report | `.github/health-report.json` | Machine-readable metric shape to imitate |
| Health summary | `.github/HEALTH.md` | Human-readable rollup to imitate |
| Cheatsheet | `COPILOT-CHEATSHEET.md` | Task routing table — your log's task taxonomy |

## Lab steps

1. **Study the dual-output pattern.** Run `bash copilot-health.sh` and compare
   `.github/health-report.json` (canonical, CI-friendly) with `.github/HEALTH.md`
   (readable). Your impact log should follow the same split: structured entries,
   readable rollup.
2. **Define your log schema.** Minimum fields per entry: date, task (use the
   cheatsheet's task taxonomy), assets used, baseline estimate, actual time,
   rework needed (none / minor / major), quality delta, notes.
3. **Backfill from this course.** Log every lab task from days 1–8: chains
   built, contracts written, guardrails added.
4. **Log one week of real work.** Each AI-assisted task gets an entry the same
   day — retrospective logging inflates savings.
5. **Roll up.** Produce a one-page summary: hours saved, rework rate, and the
   two task types where AI helped least (be honest — that finding is the
   valuable one).

## Exit criteria

- A populated impact log with ≥10 entries in a structured, parseable format
- A rollup summary identifying your highest- and lowest-leverage AI task types
- Agreement with your cohort on a shared schema (input to Lab 8 team standards)
