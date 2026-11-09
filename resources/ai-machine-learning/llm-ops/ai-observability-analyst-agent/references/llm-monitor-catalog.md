# LLM monitor catalog

Choose the monitors that match the system. Thresholds should be expressed relative to an observed baseline (for example "p95 more than 1.5x the trailing 7-day p95 for 15 minutes"); the multipliers below are starting heuristics to tune, not standards.

## Availability and errors

| Monitor | Definition | Suggested starting rule | Alert or dashboard |
|---|---|---|---|
| Provider error rate | Failed model calls / all model calls, by error class | Sustained rise well above baseline for 5-15 min | Alert |
| Rate-limit responses | Count of throttling responses | Any sustained occurrence at normal traffic | Alert |
| Retry rate | Retried calls / all calls | Doubling versus baseline | Dashboard, alert if user latency also rises |
| Fallback activation | Requests served by fallback model | Any activation outside a known incident | Alert (low severity) |
| Tool error rate | Failed tool calls / tool calls, by tool | Rise above baseline per tool | Alert for critical tools |

## Latency

| Monitor | Definition | Note |
|---|---|---|
| Time to first token p95 | From request to first streamed token | The user-perceived latency for chat |
| Total latency p95 / p99 | Full request including tools | Segment by input length bucket |
| Sequential calls per request | Model calls on the critical path | Rising tail signals agent loops |

## Cost and tokens

| Monitor | Definition | Note |
|---|---|---|
| Input tokens per request p50/p95 | Prompt size | Catches context bloat after prompt changes |
| Output tokens per request p95 | Completion size | Catches runaway generations |
| Cached-token share | Cached input tokens / input tokens | Drops indicate a cache-breaking prompt change |
| Spend burn rate | Estimated spend per hour using current prices | Alert when the projected daily spend exceeds budget |
| Tool calls per agent run p95 | Loop depth | Pair with a hard limit in code |

## Quality proxies

| Monitor | Definition | Caveat |
|---|---|---|
| Negative feedback rate | Thumbs-down / responses with feedback | Low and biased sample |
| Regeneration or retry-by-user rate | User asked again or regenerated | Good implicit signal for chat |
| Escalation to human | Handoffs / sessions | Can also rise for business reasons |
| Validation failure rate | Schema or format failures / responses | Deterministic and cheap |
| Guardrail trigger rate | Blocked or modified responses / responses | Spikes can mean attack or false positives |
| Sampled judge score | Calibrated judge on a random sample | Pin the judge version |
| Empty or refusal rate | Responses that refuse or are empty | Rises after model updates |

## Alert hygiene

- Page only on user-impacting symptoms and budget burn; send diagnostics to dashboards.
- Every alert names an owner and a first action.
- Segment alerts by feature so one noisy feature does not mask another.
- Review alert precision monthly and retire alerts nobody acts on.
