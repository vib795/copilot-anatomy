---
applyTo: "**/*{Test,Spec,_test,test_}.{java,go,py}"
---
<!--
  WHEN LOADED: Only for test files — keeps context focused.
  PURPOSE: Enforces testing patterns, prevents common mistakes.
  MODEL: Not set — loaded as context.
-->

# Testing conventions

## Core rules
1. Name tests after the **scenario**, not the method under test.
2. One assertion concept per test (multiple assert lines are fine if same concept).
3. Tests must be **deterministic** — no `Thread.sleep`, no wall-clock time.
4. Mock at integration **boundaries** only (HTTP, database, message bus).
   Prefer real objects everywhere else.

## Java (JUnit 5 + AssertJ)
- `@WebMvcTest`, `@DataJpaTest` slices over `@SpringBootTest`.
- WireMock for external HTTP stubs. `@Testcontainers` for real databases.
- Test builders: `testUser()`, `testOrder()` factory methods, not constructors.

## Go
- Table-driven tests for all non-trivial functions.
- `t.Parallel()` in all table sub-tests. Always run with `-race`.
- `httptest.NewRecorder` + `httptest.NewServer` for HTTP handler tests.

## Python
- `pytest.fixture` for shared setup. No `setUp`/`tearDown`.
- `@pytest.mark.integration` for slow/real-network tests.
- `responses` or `respx` for HTTP mocking, never `unittest.mock.patch` on `requests`.

## Coverage targets
| Layer | Minimum |
|-------|---------|
| Domain / service logic | 90% |
| REST controllers / handlers | 80% |
| Infrastructure adapters | 70% |
| CLI entry points | smoke test |
