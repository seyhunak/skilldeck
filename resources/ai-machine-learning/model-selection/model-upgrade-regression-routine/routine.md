# Model Upgrade Regression Routine

## Objective
Replace the model behind an already-launched LLM feature (a newer version from the same provider, a cheaper tier, or a different provider) without shipping silent regressions. The routine produces a paired comparison of old and new models on identical inputs, a list of cases that flipped from pass to fail and why, any prompt adjustments needed for the new model, and a reversible rollout. The goal is a decision you can defend with per-case evidence, not an aggregate score that rose by a point.

## Trigger
Run when a provider announces deprecation of the model you use, when a new version promises better quality or lower cost, or when cost or latency pressure suggests moving to a smaller tier. Start early for deprecations: the comparison, re-tuning, and staged rollout typically take longer than expected. Choosing among many candidate models from scratch is a broader exercise for `model-selection-analyst-agent`; this routine assumes one incumbent and one or two challengers. A person runs and signs off on each step.

## Prerequisites
- The feature's current eval set with deterministic checks and any calibrated judge rubric, plus production-derived cases if available.
- Pinned incumbent configuration: exact model id (not an alias that can move), prompt version, temperature, max tokens, tool schemas.
- Access to the challenger model with the same features in use (tool calling, structured output mode, context length).
- Tracing that tags each request with model id, so online metrics can be split by model during rollout.
- A routing flag that can send a percentage of traffic to either model and revert without a deploy.

## Inputs
- Incumbent and challenger model ids and their published pricing and context limits.
- Eval set version and grading configuration.
- Online baseline metrics for the incumbent: success signal, escalation or thumbs-down rate, p50 and p95 latency, tokens per request.
- Deprecation date, if any.

## Steps
1. **Pin and re-baseline the incumbent.** Re-run the eval set on the incumbent today, at least twice, to measure current scores and run-to-run variance. Do not compare against an old report; providers and your own code change over time.
2. **Run the challenger unchanged.** Same prompt, same settings, same cases, at least twice. This shows the cost of a pure swap before any re-tuning hides it.
3. **Diff per case, not per average.** Build a table with each case's result under both models and classify every case: both pass, both fail, improved (fail to pass), regressed (pass to fail), or unstable (flips between runs of the same model). Unstable cases are noise; regressions on stable cases are the signal.
4. **Categorize regressions.** Read every regressed case and tag the cause: format or schema drift, changed refusal behavior (more or less permissive), tool-call differences (wrong tool, extra calls, argument formatting), verbosity or truncation, instruction-following on a specific rule, or factual errors. Format and verbosity changes are common with version changes and are usually fixable in the prompt.
5. **Measure operational deltas.** Compare tokens per request (different tokenizers count the same text differently), cost per request at list prices, p95 latency, and rate limits. A cheaper per-token price can still cost more if the model is more verbose or retries more.
6. **Re-tune for the challenger, then re-run both.** Make targeted prompt changes for the regression categories. Keep the incumbent's prompt unchanged so the comparison stays fair, or if a shared prompt change is needed, re-run the incumbent with it too. Re-run until the diff is stable; record every prompt change.
7. **Shadow or canary.** Send a small share of traffic (or a shadow copy) to the challenger. Split all online metrics by model id. Sample transcripts from both arms and review them blind to the model where possible.
8. **Ramp and retire.** Ramp in steps while the incumbent stays available behind the flag. Keep it available for an agreed period after full rollout (or until the provider's deprecation date) so rollback remains a flag flip.

## Decision points
- **Any regression on a case tagged critical (safety, compliance, money movement)**: block the swap until fixed, regardless of aggregate improvement.
- **Regressions are mostly format drift**: fix with prompt or structured-output mode and continue; `structured-output-extraction` covers schema enforcement.
- **Refusal behavior changed**: review both directions; a model that refuses less may now violate policy, one that refuses more hurts users. Get a policy reviewer's view.
- **Challenger quality is equal but cost or latency is clearly better**: proceed if no critical regressions; record the trade.
- **Unstable cases exceed a meaningful share of the set**: lower temperature for evaluation or increase runs before drawing conclusions.
- **Deprecation date is near and regressions remain**: escalate early with options (accept documented regressions, add guardrails, or pick another challenger) rather than switching under deadline without evidence.

## Expected output
A model upgrade record: pinned configurations for both models; eval scores with variance for incumbent, challenger unchanged, and challenger re-tuned; the per-case flip table with regression categories; operational deltas for tokens, cost, and latency; prompt diff; online metrics by model during canary and ramp; rollback plan and incumbent retirement date; sign-offs.

## Validation checklist
- [ ] Incumbent was re-baselined on the current date with at least two runs.
- [ ] Every regressed stable case was read and categorized by a person.
- [ ] Critical-case regressions were zero or explicitly accepted by the approver.
- [ ] Token, cost, and latency deltas were measured on real input lengths.
- [ ] Online metrics were split by model id throughout rollout.
- [ ] The incumbent stayed available behind the flag until the agreed retirement date.

## Human approval
The feature owner approves moving from offline comparison to canary, each ramp step, and incumbent retirement. Any accepted regression, any change in refusal behavior, and any decision to send production-derived eval data to a new provider require explicit written sign-off, the last one from whoever owns data processing agreements. An assistant may run comparisons and draft the record but must not change routing or retire the incumbent.
