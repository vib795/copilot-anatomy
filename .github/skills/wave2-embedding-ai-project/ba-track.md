# BA track — a real requirements task through the AI stack

## Suitable tasks

- Refining an epic into sprint-ready stories with acceptance criteria
- Producing a gap analysis between a client brief and the current backlog
- Drafting a process flow or decision table from meeting notes

## Suggested routing

| Task step | Primitive | Asset |
|-----------|-----------|-------|
| Decompose the epic | Agent chain | Your Lab 1 brief→stories→criteria chain |
| Long source documents | Agent | `.github/agents/longcontext-reader.agent.md` + Lab 2 context plan |
| Review the output | Agent | `.github/agents/adversarial-document-reviewer.agent.md` |

## Persona-specific retrospective questions

- Did the agent chain preserve client terminology, or normalize it away?
- How many criteria survived stakeholder review unedited?
- Where did you fall back to manual writing, and was that a prompt problem or
  a missing asset?
