# LLM Feature Launch Routine

## Objective
Move one LLM-powered feature from a working prototype to general availability with evidence at every step: a frozen eval baseline, launch criteria agreed before data arrives, staged exposure (internal, shadow, canary, ramp), and pre-agreed rollback triggers. The outcome is a launch record that states what was measured, what thresholds were set, which gates passed, and who approved each one, so a later regression can be compared against a known-good state.

## Trigger
Run this when a feature built on a language model (generation, extraction, classification, agentic tool use) is about to be exposed to users who did not build it. Run it again for any change large enough to alter behavior on real traffic: a new tool, a new data source, or a prompt rewrite. For a model version swap on an already-launched feature, use `model-upgrade-regression-routine` instead. This is a guided human workflow; nothing in it executes on its own.

## Prerequisites
- A named launch owner and a named approver for each gate (often product, engineering, and a trust or safety reviewer for user-facing features).
- An eval set of at least several dozen cases covering core, edge, and adversarial behavior; `eval-test-case-generator-prompt` can draft one.
- Tracing that records, per request: prompt version, model id, input and output tokens, latency, tool calls, and any guardrail verdicts.
- A feature flag or traffic router that can target a percentage of users and revert in minutes without a deploy.
- A cost estimate per request and per month from `token-budget-estimation`.

## Inputs
- Feature spec, system prompt, and tool definitions, with versions pinned.
- Eval set and grading method (deterministic checks plus a calibrated judge where needed).
- Business constraints: latency target, monthly cost ceiling, acceptable failure modes.
- Optional: existing non-LLM baseline (rules engine, human process) to compare against.

## Steps
1. **Write launch criteria before measuring.** In one table, set the threshold for each gate metric: task success rate on the eval set, hard-rule violation count (usually zero tolerance on adversarial cases), p95 latency, cost per request, and an online signal such as thumbs-down rate, escalation rate, or edit distance of accepted drafts. Writing thresholds after seeing results invites rationalizing whatever came out.
2. **Freeze and run the offline baseline.** Pin prompt version, model id, temperature, and tool versions. Run the full eval set at least twice; where the score varies between runs, report the range, not the best run. Read a sample of failures by hand and tag each with a failure category (wrong fact, ignored instruction, bad tool call, format error, unsafe content).
3. **Fix or accept known failures.** For each failure category, decide: fix now, mitigate (guardrail, fallback, UI copy), or accept with a written rationale. Re-run the baseline after any change; record the final version as the launch candidate.
4. **Internal dogfood.** Expose the candidate to employees for a fixed period. Collect free-text feedback and traces, add every surprising input to the eval set, and confirm logging, cost attribution, and the kill switch work end to end, including a timed rollback drill.
5. **Shadow traffic (where the design allows).** Run the candidate on a copy of real inputs without showing outputs to users. Compare against the current path or a human baseline on a reviewed sample. Shadow stages surface input distributions the eval set missed, especially long, multilingual, or malformed inputs, and real token usage.
6. **Canary.** Expose a small slice of real users (1 to 5 percent is a common starting heuristic). Watch the online metrics daily against the thresholds from step 1, review a fixed number of sampled transcripts per day, and watch the latency tail and cost per request on real input lengths.
7. **Ramp.** Increase exposure in steps (for example 5, 25, 50, 100 percent), holding each step long enough to see a full weekly usage cycle if traffic is seasonal. Re-check thresholds at each step; a metric that holds at 5 percent can break when heavier users arrive.
8. **Declare GA and hand over.** Record final metrics, set ongoing monitors with alert thresholds (`ai-observability-analyst-agent` can define them), assign an on-call owner, and schedule the first periodic eval re-run.

## Decision points
- **Offline baseline misses a threshold**: do not start dogfood. Iterate on the prompt or design, or formally renegotiate the threshold with the approver and record why.
- **Any hard-rule violation on adversarial cases**: block the launch until fixed or mitigated by a guardrail that has its own test cases.
- **Shadow outputs worse than the current path on the reviewed sample**: stop and diagnose; do not proceed to canary on the hope that users will not notice.
- **Canary online metric breaches its threshold, or a severity-1 safety incident occurs**: roll back immediately via the flag, then investigate. Rollback is the default, not a judgment call made under pressure.
- **Cost per request exceeds estimate by a wide margin**: pause the ramp; investigate input length distribution, retries, and tool loops before scaling exposure.

## Expected output
A launch record containing: the criteria table with thresholds and actual values per stage; pinned versions of prompt, model, and tools; the failure-category breakdown with fix, mitigate, or accept decisions; dogfood and shadow findings; canary and ramp metrics per step; rollback drill result; monitor definitions and owner; and dated sign-offs per gate.

## Validation checklist
- [ ] Launch thresholds were recorded before the first offline eval run.
- [ ] Eval results report run-to-run variance, not a single best score.
- [ ] Every failure category has a fix, mitigation, or written acceptance.
- [ ] The kill switch was exercised and its rollback time recorded.
- [ ] Canary and ramp metrics were compared against the original thresholds at every step.
- [ ] Monitors, alert thresholds, and an on-call owner exist at GA.

## Human approval
A named approver signs off before each stage advance: dogfood to shadow, shadow to canary, every ramp step, and GA. Accepting a known failure mode, relaxing a threshold, and restarting a ramp after a rollback each require explicit written approval from the launch owner plus the safety or policy reviewer for user-facing features. An agent assisting with this routine may compile metrics and draft the record, but must not flip flags or change traffic allocation itself.
