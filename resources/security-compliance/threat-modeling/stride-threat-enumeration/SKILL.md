---
name: stride-threat-enumeration
description: Systematically enumerates STRIDE threats (Spoofing, Tampering, Repudiation, Information disclosure, Denial of service, Elevation of privilege) for every element of a data flow diagram and returns a consistent threat table with preconditions, impact, candidate mitigations, and recorded not-applicable reasoning. Use when a DFD or component list exists and threats must be enumerated completely; not for drawing the DFD from scratch or rating business risk.
---

# STRIDE Threat Enumeration

## When to use

Load this skill when you have a data flow diagram, or a list of external entities, processes, data stores, and data flows with trust boundaries, and you need to enumerate threats without skipping elements or categories. It fits design reviews, threat-model refreshes after a change, and boundary-crossing analysis inside larger architecture reviews.

Do not use it to discover the system's structure (build the DFD first), to rank risk for a business audience (rate afterwards with the organisation's scale), or to find implementation bugs in code (use `owasp-top-10-review`). Apply it only to systems the user owns or is authorised to assess.

## Inputs

- **Element list** with IDs and types: external entity (E), process (P), data store (D), data flow (F). Required.
- **Trust boundaries** and which flows cross them. Required.
- **Data on each flow and store**, ideally with classification labels. Strongly recommended.
- **Known controls** such as authentication method, TLS, signing, WAF, rate limiting. Optional; without them, assume none and say so.

## Procedure

1. **Apply the STRIDE-per-element matrix.** This is the mapping popularised by Microsoft's SDL threat modeling work:

   | Element type | S | T | R | I | D | E |
   |---|---|---|---|---|---|---|
   | External entity | x | | x | | | |
   | Process | x | x | x | x | x | x |
   | Data store | | x | (x) | x | x | |
   | Data flow | | x | | x | x | |

   Repudiation applies to a data store when it holds audit or transaction logs. Produce one row per applicable element-category pair.

2. **Write each threat as a concrete statement.** Use the pattern: *An actor with [precondition] can [action] on [element] resulting in [impact].* Example: "An authenticated tenant user who changes the `account_id` path parameter can read another tenant's invoices from P2 Billing API, disclosing confidential financial data." Avoid generic phrasing like "data could be leaked".

3. **Use the category prompts.** Ask, per element:
   - **Spoofing** — how does this element prove identity? Are tokens validated for issuer, audience, and expiry? Can a caller choose its own identity (header-based user IDs, unauthenticated webhooks)?
   - **Tampering** — can data be modified in transit, at rest, or in a queue? Is integrity checked (TLS, signatures, HMAC on webhooks, database permissions)?
   - **Repudiation** — can an actor deny an action because it is not logged, logs are mutable by the same actor, or logs lack identity and time?
   - **Information disclosure** — what leaks through errors, logs, caches, backups, side channels, over-broad API responses, or misconfigured storage?
   - **Denial of service** — what unbounded input, expensive query, fan-out, or dependency failure exhausts this element?
   - **Elevation of privilege** — can a lower-privileged caller reach admin functions, inject into an interpreter, or escape a sandbox or tenant?

4. **Prioritise boundary crossings.** Every flow crossing a trust boundary must have at least its Tampering and Information disclosure rows filled with concrete threats or a reasoned "mitigated by" note. Processes that receive cross-boundary flows get extra attention for Spoofing and Elevation of privilege.

5. **Record not-applicable decisions.** If a category does not apply, write one line explaining why, for example "R: N/A — stateless proxy, actions logged by P3". This keeps the enumeration auditable and stops reviewers wondering whether a gap was skipped.

6. **Attach candidate mitigations.** For each threat suggest one or two standard controls mapped to the category: authentication and mutual TLS for S; integrity checks and least-privilege writes for T; append-only, centrally collected logs with actor identity for R; encryption, authorisation, and response filtering for I; quotas, timeouts, and back-pressure for D; authorisation checks, input validation, and sandboxing for E.

7. **Validate completeness.** Count rows per element against the matrix; every applicable pair must have a threat or an N/A reason. Check that no threat duplicates another under a different category; merge if so.

## Expected output

A Markdown table:

| ID | Element | STRIDE | Threat statement | Preconditions | Impact | Existing control | Candidate mitigation | Status |
|---|---|---|---|---|---|---|---|---|

followed by an N/A list (`element / category / reason`) and a completeness line such as "14 elements, 41 applicable pairs, 37 threats, 4 N/A". Leave likelihood and rating to the calling workflow unless asked.

## Constraints and limitations

- STRIDE finds classes of threat; it misses business-logic abuse and supply-chain issues unless you add them explicitly.
- Quality depends on the DFD; missing elements produce missing threats. Flag elements that look under-specified.
- Describe threats at design level. Do not write exploit steps, payloads, or attack tooling.
- This is not professional security advice; ratings and mitigation choices need review by the system owner and a qualified security reviewer.

## Examples

Input: E1 Mobile app user, P1 API gateway, P2 Orders service, D1 Orders DB, F1 E1 to P1 (internet boundary, JWT, order data), F2 P1 to P2, F3 P2 to D1.

Extract of output:

| ID | Element | STRIDE | Threat statement | Candidate mitigation |
|---|---|---|---|---|
| T1 | P1 | S | A caller presenting a JWT signed with `alg: none` or an unexpected key is accepted as any user | Pin accepted algorithms and keys; validate `iss`, `aud`, `exp` |
| T2 | F2 | T | A compromised pod in the same namespace can inject requests to P2 bypassing the gateway | Network policy restricting P2 ingress to P1; mTLS between services |
| T3 | P2 | E | A customer can update another customer's order by changing `orderId` because ownership is not checked | Enforce ownership check against token subject in P2 |
| T4 | D1 | R | Order status changes are not attributable because DB writes use a shared service user and no application audit log exists | Application-level audit log with actor ID, shipped off-host |

N/A: `E1 / R — covered by T4 audit log design`.
