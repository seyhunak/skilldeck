# Incremental migration patterns

Patterns commonly used to move capability from a legacy system to a new one while both run. Most plans combine several.

## Interception patterns

| Pattern | How it works | Good for | Watch out for |
|---|---|---|---|
| Strangler fig via routing facade | Reverse proxy or gateway routes selected paths to the new system | Web apps and APIs with clear URL boundaries | Session and auth sharing between old and new |
| Event interception | Capture messages or events the legacy system emits or consumes; route some to the new system | Message-driven systems | Ordering and duplicate delivery |
| UI composition | A shell routes screens to old or new front ends | Large front ends | Visual consistency, navigation state |
| Branch by abstraction | Introduce an interface inside the codebase; implement new behind it; switch | In-place modernization of internals | Abstraction must be removed when done |
| Feature-flagged routing | Per tenant, user, or percentage switching | Gradual exposure and quick rollback | Flag sprawl; plan removal |

## Data patterns

| Pattern | Description | Consistency | Main risk |
|---|---|---|---|
| Read legacy through an anti-corruption layer | New code reads legacy store via a translating adapter | Strong (single source) | Coupling to legacy schema persists |
| Change data capture (CDC) | Stream legacy database changes into the new store | Eventual | Schema changes in legacy break the stream; lag |
| Dual write | Application writes to both stores | Weak unless carefully designed | Partial failures cause divergence; prefer an outbox |
| Transactional outbox | Write the change and an outbox record in one transaction; a relay publishes it | Eventual, reliable | Relay operation and idempotent consumers |
| Bulk migration with cutover | Copy data once in a window, switch ownership | Strong after cutover | Downtime window, rollback after new writes |
| Synchronize back | New system owns data, legacy gets updates for remaining consumers | Eventual | Legacy consumers relying on legacy-specific fields |

Rule of thumb: at any moment, each dataset should have exactly one owner that accepts writes. Phases change the owner explicitly.

## Parity verification

- **Characterization tests** capture legacy outputs for representative inputs before moving logic.
- **Shadow traffic (dark launch)**: send a copy of real requests to the new system, discard its responses, and compare them to legacy responses. Never let shadow requests cause side effects (emails, payments, writes to shared stores).
- **Parallel batch runs**: run old and new jobs on the same inputs and diff outputs; investigate every difference until each is explained or accepted.
- **Business reconciliation**: compare totals, counts, and balances across both stores daily during transition.

## Slice scoring template

Score each 1-3 and discuss rather than sum blindly.

| Slice | Business value | Risk if it fails | Coupling | Data entanglement | Learning value | Notes |
|---|---|---|---|---|---|---|

## When an incremental approach is not the best choice

- The system is small enough to replace within a short, low-risk window.
- A commercial product covers the capability and the organization accepts its process.
- The legacy system is scheduled for retirement with its business line; retaining it until then is cheapest.
- No interception point can be created at acceptable cost; then plan a well-rehearsed cutover with parallel runs instead.
