---
name: error-handling-review
description: Audits how code detects, propagates, retries, times out, logs, and surfaces errors - swallowed exceptions, missing timeouts, unsafe retries, lost context, leaky user-facing messages, and partial-failure cleanup. Use when reviewing a service, integration, or pull request for resilience, or after an incident caused by poor failure handling.
---

# Error Handling Review

Most production incidents are not caused by the happy path. They come from a timeout nobody set, a retry that hammered a struggling dependency, an exception caught and ignored, or an error message that leaked internals. This skill traces failure paths deliberately and reports concrete fixes.

## When to use

- Reviewing code that calls networks, databases, queues, filesystems, or third-party SDKs.
- Hardening a service before launch or after an incident traced to error handling.
- Reviewing a pull request that adds retries, background jobs, or new external integrations.

Not for: a general all-aspects review (`structured-code-review`), interpreting a specific crash trace (`stack-trace-analysis`), or diagnosing a live outage (`production-incident-debugger-agent`).

## Inputs

- The code under review, including the call sites of the functions that can fail.
- The language/runtime and error idiom: exceptions (Java, Python, C#, JS), result types (Rust `Result`, Swift `throws`/`Result`, Go `error` values), or promise rejections.
- Operational context: SLAs, which dependencies are critical, existing retry/circuit-breaker libraries, logging and error-tracking setup.

## Procedure

1. **Inventory failure points.** List every operation that can fail: I/O, parsing, external calls, resource acquisition, arithmetic on untrusted input, and assumptions (`list[0]`, unwraps, force casts). For each, note which function handles it and where the error ends up.

2. **Find swallowed and over-broad handling.** Flag:
   - Empty catch blocks, `except: pass`, `catch (e) {}`, `_ = err` in Go, `try?` that discards meaning in Swift.
   - Catching the base type (`Exception`, `Throwable`, `catch (e)`) far from where it can be handled meaningfully.
   - Logging and then continuing as if the operation succeeded.
   - Returning `null`/default values on failure so the caller cannot tell failure from absence.
   Rule of thumb: handle an error where you can do something useful (retry, fall back, translate, report); otherwise propagate it with context.

3. **Check context preservation.** Wrapped errors must keep the cause: `raise X from e` (Python), `new X(msg, cause)` (Java), `fmt.Errorf("charge card: %w", err)` (Go), `Error(msg, { cause })` (JS). Messages should say what was being attempted and with which identifiers, not secrets or full payloads.

4. **Check timeouts on every remote call.** Each HTTP, RPC, database, and queue call needs connect and read/overall timeouts, and they must fit inside the caller's own deadline (propagate deadlines or contexts, e.g. Go `context.Context`, gRPC deadlines). Many clients default to no timeout or very long ones — verify the actual default for the library in use rather than assuming.

5. **Check retries.** Retries are safe only when:
   - The error is transient (timeouts, 429, 502/503/504, connection reset) — not 400/401/403/404/422.
   - The operation is idempotent or carries an idempotency key.
   - They use exponential backoff with jitter, a small attempt cap (commonly 3-5), and honour `Retry-After`.
   - They are not layered: retries in the SDK, the service, and the caller multiply load (3 x 3 x 3 = 27 attempts).
   Look for circuit breakers or load shedding around critical dependencies.

6. **Check partial failure and cleanup.** Resources released on all paths (`finally`, `with`, `defer`, `using`, try-with-resources). Multi-step operations: if step 3 fails, are steps 1-2 compensated or rolled back? Is a message acknowledged only after it is processed? Do background jobs have dead-letter handling?

7. **Check what users and operators see.** User-facing messages: actionable, no stack traces, SQL, file paths, or internal hostnames; consistent error shape (e.g. problem details) with a correlation id. Operators: errors logged once at the boundary with level appropriate to severity, structured fields, and the correlation id — not logged-and-rethrown at every layer.

8. **Rank findings and propose fixes.** Severity by consequence: data loss or corruption, security leak, cascading outage, silent wrong result, poor diagnosability, cosmetic. Provide the corrected code for the top findings.

## Expected output

```markdown
## Error handling review: <scope>
### Failure-point inventory
| Operation | Location | Can fail with | Handled at | Outcome today |
### Findings
| # | Severity | Category | Location | Problem | Fix |
Categories: swallowed, lost-context, no-timeout, unsafe-retry, cleanup, user-leak, logging
### Proposed changes
<code for the highest-severity fixes>
### Open questions
<behaviour that depends on library defaults or ops config you could not see>
```

## Constraints and limitations

- Library defaults change between versions; cite the version you checked or mark the default as unverified.
- Recommend failing fast over silent fallback when correctness matters (payments, inventory, auth).
- Do not add retries to non-idempotent operations without an idempotency mechanism.
- Static review cannot reveal real latency distributions; suggest timeouts derived from observed p99 when metrics exist.

## Examples

```python
def charge(order):
    try:
        return requests.post(PSP_URL, json=order.payload()).json()
    except Exception:
        log.error("charge failed")
        return None
```

**Findings:** no timeout (requests waits indefinitely by default) — high; broad `except Exception` turns PSP declines, network errors, and JSON errors into the same `None` — high, since the caller may treat `None` as "not charged" and retry, double-charging; original exception and order id lost — medium. **Fix:** set `timeout=(3, 10)`, call `raise_for_status()`, catch `requests.Timeout` and connection errors separately, retry only those with an idempotency key header, and raise a domain `PaymentError(order_id=...) from e` otherwise.
