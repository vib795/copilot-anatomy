# BA track — packaging the requirements pipeline as shared assets

## What to package

1. **Your Lab 1 chain** (brief → stories → criteria) as three `*.agent.md`
   files with `handoffs:` wired, names prefixed for your team's catalog.
2. **A template library skill** — `skills/<team>-requirements-templates/SKILL.md`
   containing your best story format, criteria format, and decision-table
   template as copy-ready blocks.

## Generalization checklist

- Client and domain nouns replaced with `<placeholders>`
- The artifact contract (Lab 4) embedded in each agent's instructions, not
  assumed
- `description:` fields written as search phrases a teammate would type
  ("turn a brief into user stories", not "BA Agent v2")

## Acceptance test

Hand a teammate only the asset names. They should be able to run
brief → criteria on a sample brief with zero verbal instructions.
