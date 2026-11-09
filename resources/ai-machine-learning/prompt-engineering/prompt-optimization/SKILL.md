---
name: prompt-optimization
description: Improve a prompt systematically against an evaluation set - measured baseline, failure clustering, one-change-at-a-time variants, section ablations, variance checks across repeated runs, held-out confirmation, and a prompt change log. Use when a prompt underperforms, before shipping a prompt change, or when a prompt has grown long and nobody knows which parts matter.
---

# Prompt Optimization

## When to use
- A production prompt has a measurable failure rate you need to reduce.
- A prompt has accumulated instructions over time and you suspect many are dead weight.
- Porting a prompt to a different model and re-tuning it.

Not for: drafting a first system prompt from requirements (use `system-prompt-architect-prompt`) or building the eval set itself (use `golden-dataset-construction`). Without an eval set of some kind, stop and build one first; optimization without measurement is guessing.

## Inputs
- Current prompt, model name and version, and sampling settings.
- Eval set with dev and held-out splits, and a scorer (exact match, programmatic checks, or a calibrated judge).
- Constraints: token budget, latency, safety instructions that must be retained.

## Procedure
1. **Baseline with variance.** Run the current prompt on the dev split. If sampling temperature is above zero, run each case 3-5 times and record mean and spread; otherwise you will mistake noise for improvement. Record cost and latency too.
2. **Cluster failures.** Read every failing output. Group them by cause: misunderstood task, missing domain knowledge, format errors, ignored constraint, wrong tone, over-refusal, under-refusal. Count each cluster. Fix the largest cluster first.
3. **Form a hypothesis per change.** Each variant changes one thing and states the expected effect, for example "adding an explicit rule for partial refunds will fix cluster B (14 cases) without affecting others". Typical levers:
   - Clarify the task and the audience; state what to do, not only what to avoid.
   - Add or replace few-shot examples that cover the failing cluster (diverse, not near-duplicates of eval cases).
   - Restructure: put role and task first, reference material in delimited blocks, and output format last.
   - Specify output format with a schema or template.
   - Ask for brief reasoning before the answer where the task needs multi-step logic and the output allows it.
   - Remove contradictory or stale instructions.
4. **Run and compare per case.** Compare each variant to the baseline on the same cases. Report fixed, broken, and unchanged counts, not only the aggregate. A change that fixes 10 and breaks 6 needs investigation even if the mean rises.
5. **Ablate.** For long prompts, remove one section at a time and re-run. Sections whose removal does not change the score (within run-to-run variance) are candidates for deletion, which saves tokens and reduces conflicts. Keep safety and policy instructions regardless of ablation result unless their owner agrees.
6. **Guard against overfitting.** Stop iterating on dev after a fixed number of rounds or when gains fall within noise. Confirm the final candidate once on the held-out split. If held-out gain is much smaller than dev gain, you overfit; prefer the simpler prompt.
7. **Check side metrics.** Token count, latency, refusal rate, and format validity must not regress beyond agreed limits.
8. **Log the change.** Record each variant, its hypothesis, scores, and decision. Version the prompt in source control alongside the eval set version used.

## Expected output
```markdown
## Prompt optimization: <prompt name> (<model/version>)
Eval: <dataset v>, dev n=<n>, held-out n=<m>, runs per case <r>, scorer <type>
| Variant | Change | Dev score (mean ± sd) | Fixed | Broken | Tokens | Decision |
|---|---|---|---|---|---|---|
| v0 | baseline | 0.72 ± 0.02 | - | - | 1,850 | - |
| v1 | explicit partial-refund rule | 0.78 ± 0.02 | 11 | 2 | 1,910 | keep |

Ablation: removed <sections> with no measurable effect (-<x> tokens)
Held-out: v0 <a> -> final <b>
Remaining failure clusters: ...
```

## Constraints and limitations
- Gains on a small dev set are fragile; report run-to-run variance and per-case changes.
- Prompt gains often do not transfer across models; re-validate after any model change.
- Automated prompt search can exploit judge weaknesses; spot-check winning outputs by hand.
- Never weaken safety, privacy, or policy instructions to gain score without explicit owner approval.

## Examples
A classification prompt scored 0.81 on dev. Failure clustering showed 60% of errors were "billing vs account" confusions. One added decision rule with two contrasting examples raised dev to 0.88 (fixed 19, broke 3). Ablation then removed a 400-token style section with no score change. Held-out confirmed 0.80 to 0.86, and the prompt shipped shorter than it started.
