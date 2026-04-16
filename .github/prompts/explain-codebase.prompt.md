---
agent: ask
model: gemini-2.5-pro
description: "Explain a large file, module, or subsystem — uses 1M token context"
---

<!--
  SLASH COMMAND: /explain-codebase
  MODEL: gemini-2.5-pro — 1M token context window, reads entire codebases
  AGENT: ask — produces an explanation document
  BEST FOR: Files > 2000 lines, entire packages, subsystems with many files
  TIP: Select multiple files before running this command for broader analysis
-->

Read all selected files or the active file and produce:

## 1. What this does (2-3 sentences max)
Plain language. No jargon. Suitable for a new engineer's first day.

## 2. How it works — key concepts
Identify the 3-5 most important concepts a reader needs to understand.
For each: name it, explain it in 2-3 sentences, reference the relevant code.

## 3. Data flow / request lifecycle
Trace a typical request or operation from entry point to exit.
Use numbered steps. Reference actual function/class names.

## 4. Key dependencies
What does this code depend on? What depends on it?
List only the non-obvious dependencies — skip obvious standard library use.

## 5. Gotchas and non-obvious behaviour
What would surprise a senior engineer reading this for the first time?
Concurrency concerns, hidden state, surprising error handling, performance cliffs.

## 6. Where to start if I need to change something
Point to the 2-3 files a new contributor should read first.
