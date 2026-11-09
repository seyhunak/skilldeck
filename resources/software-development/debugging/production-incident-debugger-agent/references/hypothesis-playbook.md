# Hypothesis Playbook

Signatures that help separate common production failure classes. These are heuristics drawn from typical incidents, not rules; confirm each with a discriminating check.

## Change-induced

| Signal | Points toward | Discriminating check |
|---|---|---|
| Step change aligned within minutes of a deploy | Code or config regression | Compare canary vs baseline, or error rate split by build version |
| Errors only on instances with new version during a rolling deploy | Regression in new build | Split errors by host and version label |
| Onset aligned to a flag change, affected cohort matches flag targeting | Flagged code path | Split errors by flag variant; toggle flag off for a small cohort |
| Onset hours after deploy, aligned to TTL or cache expiry | Change whose effect is delayed | Check cache hit ratio and TTL configuration around onset |

## Load and amplification

- **Retry storm:** request rate to a dependency rises faster than inbound traffic; errors and traffic rise together. Check retry counters and client retry policies; look for retries without jitter or budgets.
- **Hot key or hot partition:** one shard, tenant, or key shows saturation while others are idle. Split latency by partition or tenant.
- **Thundering herd:** synchronized spikes after cache flush, restart, or scheduled job. Check alignment to the minute boundary or cron.

## Resource exhaustion

- **Connection pool exhaustion:** latency rises with flat CPU, many requests wait on pool acquisition, database shows fewer active queries than expected. Check pool wait time and active/idle counts.
- **Memory leak:** ramp in RSS or heap across hours, periodic restarts by the orchestrator (OOMKilled), GC time increasing. Plot memory per instance since its start time.
- **File descriptors / ephemeral ports:** errors such as "too many open files" or connect failures under load; check descriptor counts and TIME_WAIT sockets.
- **Disk or quota:** write errors, log volume growth, cloud quota or rate-limit errors from providers.

## Dependency failure

- **Database:** lock waits, replication lag, failover events, slow-query log entries beginning at onset.
- **DNS or certificates:** errors begin at an exact time across many services; certificate expiry dates or resolver changes.
- **Third-party API:** errors confined to calls to one host; check provider status pages only if the user can supply them, and compare latency from multiple regions.

## Data-induced

- A single poison message repeatedly failing in a consumer: retry count climbs for the same message ID; queue depth grows behind it.
- Unexpected payload shape: errors confined to one tenant or client version; parse or null-reference errors at a deserialisation frame.

## Cascades: cause versus symptom

Downstream timeouts, circuit-breaker opens, and queue backlogs are usually effects. Walk upstream in the trace or dependency graph until you reach the first component whose own saturation or error rate changed before its callers did.

## Confidence ladder

1. **Unknown** — no hypothesis explains most symptoms.
2. **Probable** — one hypothesis explains all symptoms and no evidence contradicts it.
3. **Confirmed** — reversing the trigger reversed the symptoms, or the failure was reproduced deliberately.
