---
name: openapi-spec-authoring
description: Writes and lints OpenAPI 3.1 specifications - paths, operations, reusable component schemas (JSON Schema 2020-12), examples, security schemes, and a consistent RFC 9457 problem-details error model. Use when documenting an existing HTTP API, designing a new one contract-first, or cleaning up a spec that fails linting or generates poor client SDKs.
---

# OpenAPI Spec Authoring

A good OpenAPI document is the contract that client generators, mock servers, gateways, and humans all read. This skill produces OpenAPI 3.1 specs that validate, lint cleanly, generate usable SDKs, and describe errors as precisely as successes.

## When to use

- Writing a spec contract-first before implementing an HTTP API.
- Documenting an existing API from routes, handlers, or traffic samples.
- Fixing a spec that fails validation, lints badly, or generates awkward client code.

Not for: judging whether the API design itself is sound across REST/GraphQL/gRPC (`api-design-review-agent`) or reviewing GraphQL SDL (`graphql-schema-review`).

## Inputs

- The operations: methods, paths, request/response bodies, status codes, auth requirements. From code, docs, or a design brief.
- Naming and casing conventions (camelCase vs snake_case properties), pagination style, versioning approach.
- Target tooling, if any: Redocly CLI, Spectral, openapi-generator, a specific gateway — they differ in 3.1 support.

## Procedure

1. **Set up the document skeleton.** `openapi: 3.1.0`, `info` (title, version of the API, description, contact), `servers`, `tags` (one per resource group), `security` default, and `components`. Use 3.1 unless a required tool only supports 3.0; note that 3.1 uses full JSON Schema 2020-12 (`type: [string, "null"]` instead of 3.0's `nullable: true`, `examples` arrays, `const`).

2. **Model schemas once, in `components/schemas`.** One schema per domain concept (`Order`, `OrderLine`, `Money`). Rules:
   - Mark `required` explicitly; everything else is optional by default.
   - Use `readOnly` for server-assigned fields (`id`, `createdAt`) and `writeOnly` for secrets like passwords, instead of separate near-duplicate schemas where possible.
   - Constrain values: `format` (`date-time`, `uuid`, `email`, `uri`), `minLength`/`maxLength`, `minimum`/`maximum`, `pattern`, `enum`. Represent money as a decimal string or integer minor units plus currency, never a float.
   - Decide on `additionalProperties`: `false` for request bodies you validate strictly; leave open on responses so adding fields is non-breaking for clients.
   - Polymorphism: `oneOf` + `discriminator` with `propertyName` and `mapping`; avoid `anyOf` unless overlap is intended.

3. **Write operations.** Each operation gets a unique, verb-first `operationId` (`listOrders`, `createOrder`, `getOrder`) — generators turn these into method names. Add `summary`, `description`, `tags`, parameters (`in: path|query|header`, with schema and `required`), and `requestBody` with `content` media type. Put shared parameters (`PageCursor`, `PageSize`, `IdempotencyKey`) in `components/parameters`.

4. **Specify every response that can happen.** Success codes: `200` for reads, `201` with a `Location` header for creates, `202` for async acceptance, `204` for empty bodies. Errors: `400` (malformed), `401`, `403`, `404`, `409` (conflict/state), `422` (validation, if your convention distinguishes it from 400), `429` with `Retry-After`, `5xx` via `default`. Reuse them through `components/responses`.

5. **Adopt one error model.** Use RFC 9457 problem details (`application/problem+json`): `type` (URI identifying the problem), `title`, `status`, `detail`, `instance`, plus extension members such as `errors: [{pointer, message}]` for field validation. Every error response references this schema.

6. **Add examples that are realistic and valid.** Provide at least one request and one response example per operation (`examples` with named entries), using plausible data. Examples must validate against their schema; linters catch many mismatches.

7. **Describe security.** Define `components/securitySchemes` (`http` bearer, `oauth2` with flows and scopes, `apiKey` in header) and apply them globally or per operation; mark public endpoints with `security: []`.

8. **Lint and validate.** Run `npx @redocly/cli lint openapi.yaml` or `spectral lint openapi.yaml` (Spectral's `spectral:oas` ruleset). Fix: missing `operationId`, unused components, undefined `$ref`s, missing error responses, examples that fail schema. Optionally render docs and generate a client to see whether names read naturally.

9. **Guard compatibility.** For an existing API, diff the new spec against the published one (`oasdiff breaking old.yaml new.yaml`) and treat removed fields, new required request fields, narrowed enums, and changed types as breaking.

## Expected output

```yaml
openapi: 3.1.0
info: {title: Orders API, version: 1.4.0}
paths:
  /orders/{orderId}:
    get:
      operationId: getOrder
      tags: [Orders]
      parameters: [{$ref: '#/components/parameters/OrderId'}]
      responses:
        '200': {description: The order, content: {application/json: {schema: {$ref: '#/components/schemas/Order'}}}}
        '404': {$ref: '#/components/responses/NotFound'}
components:
  schemas: {Order: {...}, Problem: {...}}
  responses: {NotFound: {...}}
```

Followed by a short note listing lint results, assumptions made about behaviour not visible in the source, and any breaking changes detected.

## Constraints and limitations

- Do not invent endpoints, fields, or status codes the implementation does not have; mark inferred behaviour as an assumption for the owner to confirm.
- Never place real credentials or customer data in examples.
- Tool support for 3.1 features varies; if a generator mishandles `type` arrays or `const`, document the workaround rather than downgrading silently.
- A valid spec does not prove the server conforms; recommend contract tests (Schemathesis, Dredd, or Prism validation proxy) to check.

## Examples

**Request:** "Document our `POST /orders` handler; it validates items and returns 201."
**Output highlights:** `createOrder` with `IdempotencyKey` header parameter; `OrderCreate` request schema with `items` `minItems: 1` and `additionalProperties: false`; `201` returning `Order` plus `Location`; `422` returning `Problem` with an `errors` array example pointing at `/items/0/quantity`; a lint run showing zero errors and one warning about a missing `info.license`, left for the owner.
