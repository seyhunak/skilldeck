# LLM architecture review checklist

Coverage check for an assessment. Each "no" or "unknown" is a candidate finding; record the evidence either way.

## Model calls
- [ ] Model and version pinned per call site, and the version appears in logs.
- [ ] Timeouts set on every provider call, sized to the latency budget.
- [ ] Retries limited, with exponential backoff and jitter, and only on retryable errors.
- [ ] Overload and rate-limit responses handled distinctly from bad-request errors.
- [ ] A fallback model or degraded mode exists for the critical path, and it has been evaluated.
- [ ] Streaming clients handle mid-stream disconnects without duplicating side effects.

## Inputs and context
- [ ] Every prompt input is labeled trusted or untrusted.
- [ ] Untrusted content is delimited and the system prompt states it is data, not instructions.
- [ ] Context budget is explicit; truncation order is defined and tested with long inputs.
- [ ] Conversation and agent-run length are bounded (turns, tool calls, tokens, wall time).
- [ ] Memory or summaries cannot persist injected instructions across sessions unchecked.

## Outputs
- [ ] Structured outputs are schema-validated; failures are repaired, retried, or rejected deterministically.
- [ ] Rendered output is encoded; external image and link rendering is restricted or allow-listed.
- [ ] Outputs that trigger actions pass through validation and, for consequential actions, human approval.

## Tools and agents
- [ ] Each tool has least-privilege credentials scoped to the requesting user or tenant.
- [ ] Destructive or external-facing tools require confirmation.
- [ ] Tool calls that may be retried are idempotent or deduplicated.
- [ ] Loop limits and cost ceilings exist per agent run.

## Retrieval and data
- [ ] Tenant and permission filters are enforced in the retrieval query, not after generation.
- [ ] Index freshness and re-ingestion are owned and monitored.
- [ ] Caches are keyed so one user's content cannot be served to another.
- [ ] Provider data retention and training-use terms are known and acceptable for the data classes sent.

## Quality assurance
- [ ] An offline eval set exists and covers the main task types and known failure cases.
- [ ] Prompt and model changes are gated by eval results in CI or release review.
- [ ] Online quality signals exist (feedback, judge sampling, task success proxies).

## Operations
- [ ] Traces capture prompt version, model, token counts, latency, tool calls, and errors per request.
- [ ] Sensitive fields are redacted before logs leave the service boundary.
- [ ] A kill switch or feature flag can disable the AI path quickly.
- [ ] A runbook covers provider outage, quality regression after a model update, and cost spike.
