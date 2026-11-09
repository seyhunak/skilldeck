# Quality attribute scenario patterns

Use these as starting shapes for the utility tree. Every scenario needs a response measure a person could verify; replace the bracketed values with figures from the stakeholders, never with invented ones.

## Six-part scenario form

| Part | Question it answers | Example |
|---|---|---|
| Source | Who or what causes the stimulus? | Payment provider |
| Stimulus | What happens? | Starts timing out on 30% of calls |
| Artifact | Which part of the system is affected? | Checkout service |
| Environment | Under what conditions? | Normal weekday peak |
| Response | What should the system do? | Degrade to "pay later", keep cart intact |
| Response measure | How do we know it worked? | Checkout success stays above [target]%, no thread pool exhaustion |

## Scenario starters by attribute

| Attribute | Typical stimulus | Typical response measure | Tactics to look for |
|---|---|---|---|
| Availability | Node, zone, or dependency failure | Error budget consumed, recovery time, data loss window (RPO) | Redundancy, health checks, timeouts, circuit breakers, bulkheads, retries with jitter |
| Performance | Load step or burst at [N] requests/s | p95/p99 latency, throughput, queue depth | Caching, batching, async processing, connection pooling, back-pressure |
| Scalability | Data or tenant growth of [x]x | Cost per transaction, latency held flat | Partitioning, stateless services, read replicas, horizontal scaling |
| Modifiability | Add a new payment method / field / tenant type | Files and teams touched, lead time | Encapsulation, stable interfaces, plug-in points, dependency inversion |
| Deployability | Release of one component | Independent deploy, rollback time | Backward-compatible contracts, feature flags, expand/contract migrations |
| Security | Compromised credential or malicious input | Blast radius, detection time | Least privilege, segmentation, input validation, audit logging |
| Observability | Unknown failure in production | Time to localize the faulty component | Correlation IDs, structured logs, traces, RED/USE metrics |
| Cost | Traffic doubles | Spend grows sub-linearly | Autoscaling bounds, tiered storage, right-sizing |
| Data integrity | Duplicate or out-of-order messages | No double charges, eventual consistency within [t] | Idempotency keys, outbox pattern, sequence checks |

## Common tradeoff points

- **Synchronous replication** — durability up, write latency and availability under partition down.
- **Caching** — latency and cost down, staleness and invalidation complexity up.
- **Microservice split** — independent deployability up, operational load, latency, and consistency effort up.
- **Strict schemas between services** — integrity up, evolution speed down unless versioning is disciplined.
- **Aggressive retries** — transient-failure masking up, risk of retry storms and duplicate side effects up.
- **Multi-tenancy in shared tables** — cost down, isolation and noisy-neighbour risk up.

## Fitness function catalogue

| Goal | Check | Example tooling |
|---|---|---|
| Layering holds | Forbidden import rules fail the build | ArchUnit (JVM), import-linter (Python), dependency-cruiser (JS/TS), Go `depguard` |
| No dependency cycles between modules | Cycle detection in CI | Same as above, `madge --circular` |
| Latency budget | Load test asserts p95 under threshold on a fixed profile | k6, Gatling, Locust thresholds |
| Failover works | Scheduled game day or chaos experiment with a pass criterion | Chaos tooling of your platform, manual game day runbook |
| Contracts stay compatible | Schema diff gate on API and event schemas | OpenAPI diff tools, protobuf breaking-change checks, schema registry compatibility mode |
| Cost stays proportional | Budget alert on cost per unit of business volume | Cloud billing alerts plus a business metric |

These tools are examples, not endorsements; confirm current features in their documentation.
