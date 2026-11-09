---
name: graphql-schema-review
description: Reviews a GraphQL schema (SDL) and its resolvers for nullability design, Relay-style connection pagination, input and mutation payload conventions, N+1 resolver patterns and DataLoader batching, query cost limits, and safe evolution via @deprecated. Use when designing a new GraphQL API, reviewing a schema change, or diagnosing slow or fragile GraphQL endpoints.
---

# GraphQL Schema Review

A GraphQL schema is a long-lived public contract that clients query in shapes you do not control. Mistakes in nullability, pagination, and mutation design are expensive to undo, and naive resolvers turn one query into hundreds of database calls. This skill reviews the schema and the resolver layer together.

## When to use

- Designing or reviewing a GraphQL schema or a schema change (SDL diff).
- A GraphQL endpoint is slow, and per-field resolvers are suspected.
- Planning deprecations or federation/subgraph boundaries.

Not for: OpenAPI/REST contracts (`openapi-spec-authoring`), or a cross-protocol API design assessment (`api-design-review-agent`).

## Inputs

- The schema SDL (or introspection result) and, for a change, the diff against production.
- Resolver code for the types under review, and the data-access layer they call.
- Client usage if available: persisted queries, operation logs, field usage from a schema registry.
- Server stack (Apollo Server, GraphQL Yoga, graphql-java, Hot Chocolate, gqlgen, Strawberry) — features differ.

## Procedure

1. **Check naming and shape.** Types in PascalCase, fields and arguments in camelCase, enums values in SCREAMING_SNAKE_CASE. Model the domain, not the database: no `user_id: Int` foreign keys where a `user: User` field belongs. Use custom scalars for meaningful formats (`DateTime`, `URL`, `Email`) with documented serialisation. Every type and non-obvious field has a description.

2. **Review nullability deliberately.** In GraphQL, a resolver error on a non-null field nulls out the nearest nullable parent, so over-using `!` makes one failing field blank an entire response. Guidelines (heuristics, choose per field): IDs and fields that cannot fail independently can be non-null; fields backed by separate services or that may be hidden by authorisation should usually be nullable; lists are typically `[Item!]!` (list always present, no null entries). Arguments: non-null when required. Changing nullable to non-null on an output field is safe for clients; the reverse is breaking — and for inputs the rules invert.

3. **Check pagination.** Unbounded lists (`orders: [Order!]!` on a customer with thousands of orders) are a performance and availability risk. Use the Relay Cursor Connections pattern for growing collections: `orders(first: Int, after: String, last: Int, before: String): OrderConnection!` with `edges { cursor node }`, `pageInfo { hasNextPage hasPreviousPage startCursor endCursor }`, and optionally `nodes` and `totalCount` (only if it is cheap to compute). Enforce a maximum `first`. Cursors should be opaque.

4. **Review mutations.** One mutation per user intent (`cancelOrder`, not `updateOrder(status: CANCELLED)` for everything). Single `input` argument of a dedicated input type (`CancelOrderInput!`), and a dedicated payload type (`CancelOrderPayload`) returning the changed object plus expected, user-facing errors as data (e.g. a `userErrors: [UserError!]!` field or a result union `CancelOrderResult = CancelOrderSuccess | OrderNotCancellable`). Reserve top-level `errors` for unexpected failures. Support idempotency for retried mutations where duplicates matter (client-supplied id or key).

5. **Find N+1 resolver patterns.** A field resolver that queries per parent (`Order.customer` doing `SELECT ... WHERE id = ?` for each of 50 orders) is the classic problem. Fix with DataLoader-style batching and per-request caching: collect keys during one tick, load with `WHERE id = ANY($keys)`, return results in key order (with nulls or errors for missing keys). Create loaders per request to avoid leaking data across users. Check list fields nested inside list fields for multiplicative cost.

6. **Check abuse protection.** Depth limiting, query cost or complexity analysis (assign costs per field and multiply by requested page size), maximum page sizes, timeouts, and — for first-party clients — persisted queries or an operation allow-list. Consider disabling introspection in production only if the API is private; it is not a security boundary on its own.

7. **Check authorisation placement.** Authorisation belongs in the business/data layer or a consistent field-level mechanism, not only on top-level query fields: nested paths (`order { customer { paymentMethods } }`) bypass checks placed only at the root.

8. **Review evolution.** Prefer additive change. Use `@deprecated(reason: "Use fulfilment.status. Removal after 2027-03-01.")` on fields and enum values (and input fields/arguments where the server supports the newer spec), track usage, and remove only when usage reaches zero. Run a schema diff tool (GraphQL Inspector, Apollo `rover graph check`) to classify breaking vs dangerous vs safe changes; adding an enum value is "dangerous" because exhaustive client switches may break.

## Expected output

```markdown
### Scope
<schema version/diff, resolvers reviewed>
### Findings
| # | Severity | Area | Location (Type.field) | Issue | Recommendation |
Areas: naming, nullability, pagination, mutation design, N+1, cost limits, authz, evolution
### Proposed SDL changes
    <SDL>
### Resolver changes
<DataLoader sketch, batched query>
### Breaking-change report
| Change | Classification | Client impact | Mitigation |
```

## Constraints and limitations

- Server and library behaviour (deprecation on input fields, `@oneOf` input support, defer/stream) varies by implementation and spec version; verify against the stack in use.
- Do not label a change safe without checking client usage when a registry or operation logs exist.
- Nullability choices are trade-offs; present the reasoning rather than a blanket rule.
- Performance claims need measurement (resolver tracing, query count per operation).

## Examples

**Schema excerpt:** `type Customer { orders: [Order]! }`, with `Order.items` and `Item.product` each resolved by a per-row SQL query.
**Findings:** unbounded list — replace with `orders(first: Int = 20, after: String): OrderConnection!` capped at 100 (major); nullable list entries `[Order]` should be `[Order!]` unless partial failure is intended (minor); a request for 20 orders with 5 items each issues 1 + 20 + 100 queries — batch `Order.items` and `Item.product` with per-request DataLoaders to make it 3 queries (major, measured by the user with query logging).
