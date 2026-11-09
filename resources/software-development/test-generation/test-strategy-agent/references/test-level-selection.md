# Choosing the test level

Pick the lowest level that can detect the failure mode reliably. Moving a check up a level adds runtime, flakiness exposure, and diagnosis time; moving it down risks missing integration faults. These are heuristics.

| Failure mode type | Lowest reliable level | Why | Typical tools (examples) |
|---|---|---|---|
| Calculation, branching, validation rules | Unit | Pure logic; fast, precise failure location | xUnit-family frameworks, pytest, Jest/Vitest, Go `testing` |
| Invariants over many inputs | Unit with property-based tests | Explores input space beyond chosen examples | Hypothesis, fast-check, jqwik, QuickCheck ports |
| ORM mapping, SQL, migrations, transactions | Integration with a real database | Mocks hide query, constraint, and isolation behaviour | Testcontainers or a disposable database |
| Serialization, framework wiring, HTTP handlers | Component / integration | Faults appear only when the framework runs | In-process test servers |
| Message consumers, retries, idempotency | Integration with a real broker or faithful fake | Ordering and redelivery semantics matter | Containerized brokers |
| Agreement between two services | Consumer-driven contract test | Catches drift without deploying both services | Pact-style contract tooling, schema compatibility checks |
| Third-party API behaviour | Contract test against recorded or sandbox responses, plus monitoring | Cannot control provider uptime in CI | Recorded fixtures with periodic refresh |
| Critical user journey works end to end | End-to-end, few in number | Only level that proves the whole path | Playwright, Cypress, XCUITest, Espresso |
| Visual regressions | Snapshot or visual comparison on components | Cheaper than full-page E2E | Visual diff tooling |
| Accessibility | Automated checks on components plus manual audit | Automation catches only part of WCAG issues | axe-core based tools, manual screen reader passes |
| Performance and capacity | Dedicated load test on a production-like environment | Unit timings do not predict system behaviour | k6, Gatling, Locust |
| Security weaknesses | SAST, dependency scanning, targeted negative tests, periodic pen test | Different techniques find different classes | Platform scanners, manual review |
| Unknown unknowns, UX | Exploratory testing with charters | Humans find what nobody specified | Session-based test management notes |

## Signals a test is at the wrong level

- An end-to-end test asserting a calculation result that a unit test could check.
- A unit test with more than a few mocks that re-implements the code's call sequence.
- Integration tests mocking the very database they exist to verify.
- A contract enforced only by end-to-end tests across two services.

## Deciding whether to automate at all

Automate when the check will run many times, the expected result is stable and objective, and failure would be costly. Prefer exploratory or manual checks for one-off verifications, rapidly changing UI under design, and judgement-heavy quality (copy, look and feel).

## Shape variants

- **Pyramid** — logic-heavy services and libraries.
- **Trophy (integration-weighted)** — thin-logic services where most risk is in wiring and data access, and front ends built from framework components.
- **Honeycomb** — microservices where contract and integration tests dominate.

Justify the chosen shape from the risk register rather than picking one by habit.
