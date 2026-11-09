# CI/CD failure signatures

Common log patterns, what they usually mean, and the first check to make. Exact wording varies by tool and version; treat these as starting hypotheses.

| Category | Typical signals in logs | Usual causes | First check |
|---|---|---|---|
| Compile / lint | Compiler errors with file:line, type errors, lint rule IDs | Code change, stricter tool version | Does it fail locally with the same tool version? |
| Deterministic test failure | Same test fails on every run | Real regression, environment-dependent assertion (time zone, locale) | Run the single test locally in the CI image |
| Flaky test | Test passes on re-run; failure location varies | Timing, ordering, shared state, real network calls | Failure rate over recent runs; run in random order or repeated |
| Dependency resolution | `ERESOLVE`, `Could not resolve dependencies`, `No matching distribution`, checksum mismatch | Floating ranges picked a new release, lockfile ignored, package yanked, registry outage | Compare resolved versions in green vs red; is install lockfile-respecting? |
| Cache problems | Cache restored but build fails oddly; cache never hits; "cache size exceeds" | Key not including lockfile hash or OS, restore keys too broad, corrupted cache | Inspect cache key and restore key; test with a fresh key |
| Environment drift | Tool version in setup output differs from last green; "command not found" | Runner image update, unpinned setup action, `latest` base image | Pin tool and image versions; compare printed versions |
| Out of memory | Exit code 137, "Killed", JavaScript heap out of memory, Gradle daemon disappeared | Larger build, parallelism too high, memory leak in tests | Memory settings and parallel worker count; runner memory size |
| Disk full | `No space left on device` | Docker layers, caches, large artefacts accumulating | Disk usage step before failure; prune or larger disk |
| Timeout | Job cancelled after max time; step hangs without output | Deadlock, waiting for input, network hang, slow external service | Last output line before hang; add per-step timeouts |
| Network / external | DNS failures, TLS errors, HTTP 429 or 5xx from registries | Rate limiting, outage, proxy changes | Retry pattern across runs; authenticated registry access; mirrors |
| Permissions | `403`, `Resource not accessible by integration`, `AccessDenied`, `not authorized to perform` | Token scopes, fork restrictions, OIDC trust policy mismatch, branch protection | Which identity ran the step and what it is allowed to do |
| Missing secrets | Empty variables, auth failures only on forks or bot PRs | Secrets withheld from fork or Dependabot workflows by design | Event type and repository of the run |
| Pipeline configuration | Job skipped unexpectedly, YAML parse errors, matrix exclusions | Path filters, `if:` conditions, `needs:` chain, indentation | Render the effective configuration; check conditions against the event |
| Queued forever | Job waiting for a runner | Label mismatch, self-hosted runner offline, concurrency group blocking | Runner labels and availability; concurrency settings |
| Artefacts | Artefact not found in a later job | Earlier job failed or uploaded to a different name or path | The upload step in the producing job |

## Green vs red comparison checklist

- Commit range and changed files (including lockfiles and CI config).
- Runner image name and version printed at job start.
- Tool versions printed by setup steps.
- Base image digests for container jobs.
- Cache keys: which were hit, which missed.
- Event type (push, pull request, fork pull request, schedule, merge queue).
- Environment and secrets available to the job.
- Duration of each step: a sudden change points to the culprit.

## Deterministic build hygiene

- Install from lockfiles in frozen mode.
- Pin third-party actions or plugins to full commit SHAs and update them deliberately.
- Pin container images by digest for release builds.
- Print tool versions at the start of each job.
- Set explicit timeouts on jobs and long steps.
- Upload logs and test reports as artefacts on failure.
