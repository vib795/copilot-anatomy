---
applyTo: "**/*.{java,go,py,ts,tsx}"
---
<!--
  WHEN LOADED: Whenever Copilot generates code in Java, Go, Python, TypeScript.
  PURPOSE: Enforces consistent naming, formatting, and error handling.
  MODEL: Not set — loaded as context for whatever model is active.
-->

# Code style conventions

## Naming
Name variables after **what they contain**, not their type.
```java
// Wrong: List<User> userList
// Right: List<User> activeAdmins
```

| Construct | Java | Go | Python |
|-----------|------|----|--------|
| Class/type | `PascalCase` | `PascalCase` | `PascalCase` |
| Method/function | `camelCase` | `camelCase` | `snake_case` |
| Constant | `SCREAMING_SNAKE` | `PascalCase` (exported) | `SCREAMING_SNAKE` |
| Test | `shouldDoXWhenY` | `TestXWhenY/scenario` | `test_x_when_y` |

## Formatting
- 100-character line limit (Java, Python). `gofmt` handles Go automatically.
- Opening braces on the same line. No exceptions.
- One blank line between methods.

## Comments
- Public APIs: Javadoc / GoDoc / docstrings always.
- `TODO(username):` with a linked ticket. Never commit bare `FIXME`.
- Do not comment out dead code — delete it. Git is the undo stack.

## Error handling
- Java: typed checked exceptions for recoverable errors. Never swallow silently.
- Go: `fmt.Errorf("context: %w", err)`. Check every error return.
- Python: specific exception types. Never bare `except:`.
