# Rubric Test Definitions

This directory will contain YAML rubric definitions for evaluating prompt/skill quality.
Rubric tests are deferred to Phase 2+ — the deterministic checks in `../checks/` are the
Phase 1 foundation.

## Rubric format (future)

```yaml
# rubrics/review-prompt.yml
name: review-prompt-quality
target: .github/prompts/review.prompt.md
model: claude-sonnet-5
tests:
  - name: identifies-null-check-bug
    input: |
      Review this Java method:
      public String getName(User u) { return u.getName(); }
    criteria:
      - mentions null safety or NullPointerException risk
      - suggests a fix (null check, Optional, or annotation)
    pass_threshold: 2 # must meet all criteria
    max_retries: 3
```

## Adding rubric tests

1. Create a YAML file in this directory following the format above
2. Each test must specify: name, target asset, model, input, criteria, and pass_threshold
3. max_retries defaults to 3 if not specified
4. The evaluation workflow runs rubric tests after all deterministic checks pass
