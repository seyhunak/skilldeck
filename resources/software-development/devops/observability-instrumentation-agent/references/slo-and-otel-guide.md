# SLO and OpenTelemetry Guide

## Error budget arithmetic

Error budget fraction = 1 − SLO target.

| Target | Budget fraction | Allowed bad time in 30 days |
|---|---|---|
| 99% | 1% | about 7.2 hours |
| 99.5% | 0.5% | about 3.6 hours |
| 99.9% | 0.1% | about 43 minutes |
| 99.95% | 0.05% | about 22 minutes |
| 99.99% | 0.01% | about 4.3 minutes |

For request-based SLIs the budget is a count: budget fraction × valid requests in the window.

## Burn rate

Burn rate = observed error ratio ÷ budget fraction. A burn rate of 1 consumes exactly the budget over the window; a burn rate of 14.4 over one hour consumes 2% of a 30-day budget (14.4 × 1 h ÷ 720 h = 0.02).

Budget consumed by an alert window = burn rate × (alert window ÷ SLO window).

### Multi-window, multi-burn-rate starting point

The Google SRE Workbook's alerting chapter suggests a configuration along these lines for a 30-day SLO; treat it as a starting point to tune.

| Severity | Long window | Short window | Burn rate | Budget consumed in long window |
|---|---|---|---|---|
| Page | 1 h | 5 min | 14.4 | 2% |
| Page | 6 h | 30 min | 6 | 5% |
| Ticket | 3 days | 6 h | 1 | 10% |

The alert fires only when both the long and short window exceed the burn rate: the long window gives significance, the short window makes the alert reset quickly after recovery.

Example rule for a 99.9% SLO: page when the error ratio over 1 h > 14.4 × 0.001 = 1.44% AND over 5 min > 1.44%.

Low-traffic services: a handful of failures can trigger high burn rates. Options include longer windows, synthetic traffic, or aggregating related journeys.

## SLI measurement points

| Vantage | Pros | Cons |
|---|---|---|
| Client / real user monitoring | Closest to experience | Noisy, sampling, device variance |
| Load balancer / edge | Captures failures before the app | Misses semantic errors returned as 200 |
| Server | Rich context | Misses requests that never reached the service |

## OpenTelemetry essentials

- **Signals:** traces, metrics, logs; correlate via trace and span IDs in log records.
- **Resource attributes:** `service.name`, `service.version`, `deployment.environment.name` (older conventions used `deployment.environment`); confirm against the semantic conventions version you pin.
- **Span kinds:** SERVER, CLIENT, PRODUCER, CONSUMER, INTERNAL.
- **Propagation:** W3C Trace Context (`traceparent`, `tracestate` headers); for messaging, inject context into message headers and create consumer spans linked to the producer.
- **Collector:** receivers, processors (batch, memory limiter, attribute redaction, tail sampling), exporters. Tail sampling requires all spans of a trace to reach the same Collector instance.
- **Metric instruments:** Counter, UpDownCounter, Histogram, Gauge (observable or synchronous depending on SDK). Use explicit bucket boundaries near SLO thresholds.

## Cardinality budget

Series count ≈ product of distinct values of each label (per metric, per instance). Example: 20 routes × 5 status classes × 3 methods × 50 pods = 15,000 series for one histogram, multiplied again by bucket count. Remove the pod label where per-instance breakdown is not needed, and never use user IDs, request IDs, raw URLs, or free-text errors as labels.

## Log schema skeleton

```json
{
  "timestamp": "RFC 3339 UTC",
  "severity": "INFO",
  "service": "checkout",
  "version": "build identifier",
  "environment": "prod",
  "trace_id": "hex",
  "span_id": "hex",
  "event": "payment.authorised",
  "attributes": {"order_id": "internal id", "duration_ms": 0}
}
```
