---
applyTo: "**/{controller,handler,router,api,rest}/**/*.{java,go,py}"
---
<!--
  WHEN LOADED: For files in controller/handler/api directories.
  PURPOSE: Ensures consistent REST API design across all services.
  MODEL: Not set — loaded as context.
-->

# API conventions

## Resource design
- Plural nouns: `/users`, `/orders`. Max two nesting levels.
- Non-CRUD actions: `POST /payments/{id}/refund`.
- Query params for filtering/sorting — never in the path.

## HTTP status codes
| Scenario | Code |
|----------|------|
| Created | 201 + `Location` header |
| Async accepted | 202 |
| Delete success | 204 |
| Validation error | 422 |
| Auth missing | 401 |
| Forbidden | 403 |
| Conflict | 409 |
| Rate limited | 429 + `Retry-After` |

Never return 200 with an error body.

## Error shape (RFC 9457 Problem Details)
```json
{
  "type":     "https://api.example.com/errors/not-found",
  "title":    "Resource not found",
  "status":   404,
  "detail":   "User 'abc-123' does not exist.",
  "instance": "/users/abc-123",
  "traceId":  "4bf92f3577b34da6a3ce929d0e0e4736"
}
```
Always include `traceId` for log correlation.

## IDs and timestamps
- IDs: UUID v4 or ULID. Never expose auto-increment integers publicly.
- Timestamps: ISO 8601 UTC (`"2024-11-01T14:32:00Z"`). Never Unix epoch.

## Versioning
- URL path prefix: `/v1/users`. Breaking changes only bump major.
- Deprecated endpoints: `Deprecation: true` + `Sunset: <date>` response headers.
- 90-day minimum deprecation window before removal.
