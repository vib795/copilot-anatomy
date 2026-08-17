---
name: document
description: Write or update documentation for code — README sections, API reference, docstrings, and inline comments. Use when documenting a module, explaining public interfaces, or refreshing stale or missing docs.
argument-hint: "<file or module>"
---

> **Recommended model:** `claude-sonnet-5` &nbsp;·&nbsp; **Agent mode:** `agent`
>
> Skills are portable across agent clients, so they carry no Copilot-specific
> `model:` field. Set the model via the picker, a custom agent, or the
> slot mapping in `.github/model-compatibility.json`.


<!--
  SLASH COMMAND: /document
  MODEL: claude-sonnet-5 — natural prose + technical accuracy
  AGENT: agent — autonomous mode that updates documentation inline in the file
-->

Generate or update documentation for the selected code.
Apply the appropriate format for the file's language:

**Java** → Javadoc on every public class, method, constructor, and field.
Include `@param`, `@return`, `@throws`. For REST controllers add SpringDoc
`@Operation(summary=...)` and `@ApiResponse`.

**Go** → GoDoc on every exported symbol. First sentence is a headline ending
with the symbol name. Package-level doc in `doc.go`. Example:
```go
// NewUserService creates a UserService backed by the provided repository.
// It returns an error if the repository is nil.
func NewUserService(repo UserRepository) (*UserService, error) {
```

**Python** → Google-style docstrings on all public functions, classes, methods.
```python
def find_by_id(self, user_id: str) -> User:
    """Retrieves a user by their unique identifier.

    Args:
        user_id: The UUID of the user to retrieve.

    Returns:
        The User with the given ID.

    Raises:
        UserNotFoundError: If no user with the given ID exists.
    """
```

**Terraform** → `description` on every `variable` and `output` block.
Generate a `README.md` section in terraform-docs format if missing.

Rules:
- Document the WHAT and WHY — not the HOW (that's the code's job)
- Non-obvious preconditions and side effects always get documented
- Include a usage example where the API is non-trivial
- Never restate the code: `count++ // increment count` is noise
- No version history (that's git's job)
