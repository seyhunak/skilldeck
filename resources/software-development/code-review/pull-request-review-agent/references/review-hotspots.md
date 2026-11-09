# Review hotspots by change type

When a diff touches one of these areas, spend proportionally more attention there. Each row lists questions that commonly reveal Blocker or Major issues.

| Change type | Questions to ask |
|---|---|
| Database migration | Does it take a long exclusive lock on a large table? Is it compatible with the code version currently deployed (old code running against new schema during rollout)? Is there a backfill, and is it batched? Can it be rolled back, or is it expand-only? Are new foreign keys indexed? |
| New endpoint or handler | Is authentication required? Is authorization checked against the specific object, not just the role? Is input validated with size limits? Are errors mapped to correct status codes without leaking internals? |
| Money, quantities, rates | Are decimal or integer minor units used instead of floats? Is rounding mode explicit? Are currency and units carried with values? |
| Retries and external calls | Is there a timeout? Are retries bounded with backoff and jitter? Is the operation idempotent, or is there an idempotency key? What happens on partial success? |
| Concurrency and async | Is shared state protected? Are promises/futures awaited and errors handled? Can two requests interleave between a check and an update? Are locks acquired in a consistent order? |
| Caching | What invalidates the entry? Can one user's data be served to another (cache key missing tenant or user)? What is the behaviour on cache outage? |
| Serialization, events, public APIs | Do field renames or type changes break consumers? Are unknown fields tolerated? Is the schema version bumped where required? |
| Configuration and feature flags | Does a changed default alter production behaviour on deploy? Is the risky path behind a flag with a safe default? Is there a plan to remove the flag? |
| Logging and telemetry | Are personal data, tokens, or full request bodies logged? Are log levels sensible? Is a correlation ID propagated? |
| Dependencies | Is the new dependency maintained and licensed compatibly? Is the version pinned via lockfile? Is it necessary, or does the standard library suffice? |
| Authentication and sessions | Are tokens validated (signature, expiry, audience)? Are cookies `Secure`, `HttpOnly`, and `SameSite` as appropriate? Is session fixation or CSRF handled? |
| File and path handling | Can user input traverse directories? Are uploads type- and size-checked and stored outside the web root? |
| Tests | Would the test fail if the change were reverted? Are edge cases from the code's branches covered? Are time, randomness, and network controlled? |
| Deletions | Is removed code truly unused (search for string references, reflection, configuration)? Were tests removed with it, and was that intended? |

## Comment wording pattern

`[Severity] path:line — <issue in one sentence>. Scenario: <inputs or sequence> leads to <bad outcome>. Suggestion: <specific change>.`

Phrase uncertainty as a question: "Is `user_id` guaranteed non-null here? If not, line 42 dereferences it."
