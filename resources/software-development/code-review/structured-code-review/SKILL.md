---
name: structured-code-review
description: Runs a checklist-driven code review of a diff or file set, assigns each finding a severity (blocker, major, minor, nit, question), and words comments so they are specific, actionable, and kind. Use when reviewing a pull request, auditing a module before merge, or calibrating review quality across a team.
---

# Structured Code Review

Unstructured reviews drift toward style nits and miss the defects that matter. This skill imposes an order of attention (intent first, then correctness, then risk, then maintainability, then style), a fixed severity scale, and a comment format that tells the author exactly what to change and why.

## When to use

- Reviewing a pull request or patch, your own or someone else's.
- Reviewing a module before it is promoted (e.g. from experimental to supported).
- Producing review comments that will be posted by a human after checking them.

Not for: deep error-path audits (use `error-handling-review`), quantitative complexity scoring (use `code-complexity-analysis`), or turning existing rough notes into polished comments (use `code-review-feedback-prompt`).

## Inputs

- The diff (preferably unified, with enough context lines) or the files under review. Required.
- The intent: PR description, linked issue, or a one-line goal. If missing, infer it and say that you inferred it.
- Project conventions: linters, style guide, architecture rules. Optional.
- Risk context: does this touch auth, payments, data migrations, public APIs, concurrency? Optional but changes depth.

## Procedure

1. **Understand intent before reading lines.** Summarise in two sentences what the change should do. Check scope: does the diff do only that? Flag unrelated changes and diffs over roughly 400 changed lines as harder to review well; suggest a split if natural seams exist.

2. **Read tests first, then implementation.** Tests reveal what the author believes the behaviour is. Note behaviours the description promises that no test exercises.

3. **Walk the checklist in priority order.** For each item, look for concrete evidence in the diff:
   - **Correctness:** off-by-one and boundary handling, null/empty inputs, wrong operator or inverted condition, unhandled enum cases, timezone and locale assumptions, integer overflow, floating-point money.
   - **Security:** untrusted input reaching SQL, shell, file paths, HTML, or deserialisers; missing authorisation checks on new endpoints; secrets in code or logs; weakened crypto or TLS settings.
   - **Data and state:** migrations that lock large tables or are not backward compatible; transactions too wide or missing; cache invalidation; idempotency of retried operations.
   - **Concurrency:** shared mutable state, check-then-act races, missing locks or awaits, unbounded goroutines/threads/promises.
   - **Errors and resilience:** swallowed exceptions, missing timeouts on network calls, retries without backoff.
   - **API and compatibility:** breaking changes to public signatures, wire formats, config keys, or CLI flags.
   - **Performance:** queries inside loops (N+1), unbounded collections loaded into memory, accidental quadratic work on hot paths.
   - **Tests:** meaningful assertions, failure cases covered, no sleeps or real network in unit tests.
   - **Maintainability:** naming, duplication, function length, dead code, comments that explain why.
   - **Style:** only what the linter does not already enforce.

4. **Assign severity using fixed definitions.**
   - **Blocker** — will cause incorrect behaviour, data loss, a security hole, or an outage; must be fixed before merge.
   - **Major** — likely defect or significant maintainability/performance cost; should be fixed in this PR unless explicitly deferred with a ticket.
   - **Minor** — improvement worth making; author's discretion.
   - **Nit** — cosmetic; never blocks.
   - **Question** — you lack information; ask rather than assert.
   When unsure between two levels, choose the lower one and explain the condition under which it would be higher.

5. **Write each comment in a fixed shape.** Location, severity label, observation (what the code does), impact (why it matters, with a concrete failing input if you can construct one), suggestion (code or approach). Comment on the code, not the author: "this loop re-queries per item" rather than "you forgot". Limit nits; batch them into one comment if there are more than three.

6. **Verify your own claims.** For every blocker or major, trace the path to confirm the defect is reachable. If you cannot, downgrade to a question. Do not cite line numbers you have not seen.

7. **Decide and summarise.** Verdict: approve, approve with minor comments, or request changes (any blocker, or several majors). Include what was done well when it is specific and true.

## Expected output

```markdown
## Review: <PR title or scope>
**Intent (as understood):** <two sentences>  ·  **Verdict:** <Approve | Approve with comments | Request changes>
**Risk areas touched:** <auth, migration, public API, ...>

### Findings
| # | Severity | Location | Finding |
|---|----------|----------|---------|
| 1 | Blocker | `orders/service.py:88` | ... |

### Comments
**[1] Blocker — `orders/service.py:88`**
Observation: ...
Impact: ...
Suggestion:
    <code or approach>

### Not reviewed / assumptions
<files skipped, context missing>
```

## Constraints and limitations

- Review only what you were given; list anything you could not see (generated files, binary assets, unchanged callers).
- Never post comments, approve, or merge on a platform without explicit human instruction.
- Static review cannot prove absence of defects; recommend tests or runtime checks where review alone is insufficient.
- Respect the project's conventions over personal preference; do not mark preferences above Nit.

## Examples

**Diff excerpt:** a new endpoint `DELETE /projects/{id}` that calls `repo.delete(id)` directly.
**Finding:** *Blocker — `routes/projects.py:41`.* Observation: the handler deletes by id without checking that the caller belongs to the project's organisation. Impact: any authenticated user can delete any project by guessing ids (IDOR). Suggestion: load the project scoped to `current_user.org_id` and return 404 when absent, then delete; add a test where a user from another org receives 404.
