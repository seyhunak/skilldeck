# API review coverage checklist

Use to confirm the review touched every area. Not every row applies to every API style.

## Modelling and naming

- Resource names are domain nouns; collections are plural; casing is consistent across paths, fields, query parameters, and enum values.
- Identifiers are opaque strings, stable over time, and not database auto-increment values exposed where enumeration matters.
- Timestamps use RFC 3339 with an explicit offset; durations and sizes carry units in the name or schema description.
- Money is represented as a decimal string or integer minor units plus an ISO 4217 currency code.
- Booleans are named as predicates (`is_active`, `has_children`); avoid negatives such as `not_disabled`.
- Enums are documented as open (clients must tolerate unknown values) or closed.

## REST semantics

| Operation | Method | Success status | Notes |
|---|---|---|---|
| List | GET collection | 200 | Paginated, stable sort |
| Read | GET item | 200 | `ETag` for cacheable or concurrently edited resources |
| Create | POST collection | 201 + `Location` | Idempotency key for side-effecting creates |
| Replace | PUT item | 200 or 204 | Idempotent; `If-Match` for optimistic concurrency |
| Partial update | PATCH item | 200 or 204 | Declare JSON Merge Patch or JSON Patch |
| Delete | DELETE item | 204 | Idempotent; repeated delete returns 204 or 404 consistently |
| Long-running action | POST action | 202 + status resource | Status resource reports progress and result |

## Errors

- Single error schema everywhere (Problem Details for HTTP APIs).
- Stable machine-readable `code` values documented in one list.
- Validation errors identify the field path and constraint violated.
- 4xx vs 5xx boundary is correct: client mistakes never return 500.
- No stack traces, SQL, hostnames, or internal IDs in error bodies.

## Pagination and querying

- Default and maximum page sizes documented.
- Cursor is opaque; clients never construct it.
- Total counts are optional and documented as possibly approximate if expensive.
- Filtering and sorting syntax consistent across collections; unsupported fields rejected with a clear error.

## Evolution

- Versioning strategy and deprecation policy published.
- Additive-only changes within a major version.
- New request fields optional with server defaults.
- Removed fields go through deprecation with a sunset date.
- For protobuf: field numbers never reused; removed fields reserved by number and name.
- For GraphQL: changing a field from nullable to non-null in output is safe, the reverse is breaking; for input arguments the opposite holds.

## Security and limits (contract level)

- Auth scheme and required scopes per operation.
- No secrets or personal data in paths or query strings.
- Rate limits and quota headers documented; 429 with `Retry-After`.
- Request size limits documented; GraphQL depth and complexity limits configured.
- Mass-assignment risk: request schemas exclude server-owned fields such as `id`, `created_at`, `role`.

## Documentation

- Summary and description on every operation.
- Example request, success response, and at least one error response per operation.
- Spec lints clean against the chosen ruleset.
