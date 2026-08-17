# BA track — turning a 100-page requirements document into queryable context

## Exercise

1. Take a long requirements document (real engagement doc or a public RFC).
2. Build a three-tier context plan:
   - **Tier 1 (inject whole):** glossary, scope statement, constraint list.
   - **Tier 2 (chunk by section):** functional requirements, split along the
     document's own heading structure — never mid-requirement.
   - **Tier 3 (summarize-then-reference):** appendices, history, sign-off pages.
3. Ask the same five stakeholder questions against (a) the naive whole-document
   paste and (b) your tiered plan. Score answer accuracy and citation quality.

## Techniques to practice

- **Reference injection:** instead of pasting requirement text, paste the
  requirement IDs plus a one-line summary and instruct the agent to ask for
  full text by ID when needed.
- **Context prioritization:** put constraints and non-goals *before* the
  question — models weight early context more heavily.

## Watch for

- Summaries that silently drop conditional clauses ("unless", "except when") —
  these carry most of a requirement's meaning.
