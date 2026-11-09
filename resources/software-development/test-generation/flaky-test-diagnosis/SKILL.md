---
name: flaky-test-diagnosis
description: Diagnoses intermittently failing tests by reproducing them under controlled repetition, classifying the cause (async timing, order dependence, shared state, time and randomness, resource leaks, external services, environment), and applying a fix or a tracked quarantine. Use when a test passes and fails without code changes, CI needs reruns to go green, or a team wants a flaky-test policy.
---

# Flaky Test Diagnosis

A flaky test is one that can both pass and fail on the same code. Rerunning until green hides real defects, wastes CI time, and trains people to ignore red builds. This skill reproduces the flake, identifies which family of cause it belongs to, and fixes the cause instead of adding sleeps or retries.

## When to use

- A test fails intermittently locally or in CI with no relevant code change.
- CI has auto-retry enabled and you want to know what it is masking.
- A test passes alone but fails in the full suite, or vice versa.
- Setting up a quarantine and ownership process for flaky tests.

Not for: a deterministic failure (debug it directly, see `stack-trace-analysis`), CI infrastructure and runner problems (`cicd-troubleshooting-agent`), or designing new tests (`unit-test-design`).

## Inputs

- Test name, file, and failure output from several failed runs (messages and traces often differ between flakes of the same test).
- CI history: failure rate, first-seen date, which runners/OS/shards, parallelism settings.
- Test framework and runner options (pytest-xdist, JUnit parallel execution, Jest workers, Go `-race`/`-shuffle`).

## Procedure

1. **Measure it.** Estimate failure rate from CI history and reproduce locally with repetition:
   - pytest: `pytest -x --count=200 path::test` (pytest-repeat) or `pytest -p no:randomly` vs `-p randomly` to test ordering.
   - Go: `go test -run TestName -count=500 -race -shuffle=on ./pkg/...`
   - Jest: `for i in $(seq 200); do npx jest path -t "name" || break; done`
   - JUnit/Gradle: `@RepeatedTest(200)` temporarily, or rerun with `--rerun-tasks`.
   If it never fails locally, reproduce CI conditions: same parallelism, CPU limits (`taskset`, `docker run --cpus=1`), timezone, locale.

2. **Run in isolation vs in suite.** Passes alone but fails in suite → order dependence or shared state. Fails alone too → timing, randomness, or environment within the test itself. Bisect the suite order to find the polluting test (`pytest-randomly` seed replay, `--seed`; Jest `--runInBand`; JUnit `MethodOrderer.Random` with a fixed seed).

3. **Classify the cause.** Common families, with signals:
   - **Async/timing:** fixed `sleep`, assertions before an async operation completes, UI tests not waiting for state, timeouts too tight for a slow runner. Signal: fails more under CPU load.
   - **Order dependence / shared state:** global singletons, module-level caches, environment variables, database rows not cleaned up, static mocks not reset. Signal: depends on test order or parallel worker assignment.
   - **Time:** real clock near midnight, DST, month ends, `now()` compared across two calls, timezone of runner. Signal: fails at specific times or on specific runners.
   - **Randomness:** unseeded random data, UUID ordering, hash/set/map iteration order assumed stable. Signal: varies with seed.
   - **Concurrency in code under test:** genuine races. Signal: `-race`/TSan reports, fails more with parallelism. This is a product bug, not a test bug.
   - **Resource leaks and limits:** ports in use, file handles, temp dirs shared between workers, memory pressure.
   - **External dependencies:** real network, third-party sandboxes, DNS, containers not ready. Signal: errors are connection or 5xx-shaped.
   - **Precision and environment:** floating-point equality, locale-specific formatting, filesystem case sensitivity, OS path separators.

4. **Fix the cause, not the symptom.**
   - Replace sleeps with condition-based waiting (poll with timeout, `await` the promise, Playwright auto-waiting assertions, Awaitility).
   - Inject clock and random sources; freeze time (freezegun, `java.time.Clock`, fake timers); seed randomness and log the seed.
   - Isolate state: fresh fixtures per test, transactions rolled back after each test, unique temp dirs and ports (bind port 0), reset globals in teardown.
   - Sort before comparing unordered collections or assert on sets.
   - Replace real external calls with fakes or recorded responses; keep a separate, clearly labelled contract or integration suite for real dependencies.
   - If the code under test has a race, file and fix the product bug.

5. **Verify the fix statistically.** Rerun with the same repetition count that previously reproduced the flake. With failure rate p, the chance of n clean runs by luck is (1-p)^n; for p = 0.02, 200 clean runs leave about a 1.8% chance the flake is still there. Choose n accordingly and state it.

6. **Quarantine only with ownership.** If a fix cannot land quickly, move the test to a quarantine group that still runs but does not block merges (a marker, tag, or separate job), with an owner, a ticket, and an expiry date. Remove blanket CI retries or make them report retried tests so flakes stay visible.

## Expected output

```markdown
### Test
<id> — observed failure rate <x/y runs, source> — first seen <date/commit>
### Reproduction
<command, conditions, local rate>
### Classification
<family> — evidence: <isolation result, ordering, seed, timing, trace>
### Root cause
<explanation with file:line>
### Fix
<diff or description>
### Verification
<n reruns, result, residual-risk calculation>
### If quarantined
Owner · ticket · expiry · re-enable criterion
```

## Constraints and limitations

- Never "fix" by increasing a sleep or adding a retry decorator without stating that it masks the cause.
- Do not delete or permanently skip a test without the owning team's agreement.
- Some flakes cannot be reproduced locally; say so, and propose instrumentation (extra logging, artefact capture, seed printing) for the next CI failure.
- A low-rate flake in a product race condition may be a real production bug; escalate rather than quarantine.

## Examples

**Symptom:** `test_export_report` fails about 1 in 40 CI runs with `AssertionError: '2026-03-30' != '2026-03-29'`.
**Diagnosis:** passes alone; fails only when run between 23:00 and 01:00 UTC on runners set to a non-UTC zone. The test computes "yesterday" with the real clock while the code uses UTC. Class: time. **Fix:** freeze time at a fixed UTC instant and pass a clock to the exporter. Verified with 300 local runs across five frozen instants straddling midnight and a DST change.
