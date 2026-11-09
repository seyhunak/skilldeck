---
name: ab-test-design
description: Designs marketing A/B tests before launch - falsifiable hypothesis, single primary metric with guardrails, minimum detectable effect, sample size and duration, randomization unit, and stopping and decision rules. Use before running any landing page, email, ad, pricing-page, or onboarding test, or to check whether a proposed test is feasible with available traffic.
---

# A/B Test Design

A pre-registration procedure for marketing experiments. It decides, before any traffic is spent, what will be measured, how much data is needed, and what result will lead to which decision. Most of the value is in rejecting tests that cannot produce a trustworthy answer.

## When to use

- Before launching a website, landing page, email, ad creative, or onboarding test.
- When stakeholders want to "test it" and nobody has checked whether traffic supports a test.
- When an experimentation backlog needs feasibility sizing.

Not for analyzing results after the fact (that requires significance testing on the collected data), and not for multi-armed bandits or personalization systems, which optimize differently.

## Inputs

- **Change** — control and variant(s), described concretely. Required.
- **Evidence** behind the change (analytics, research, prior tests). Required for a hypothesis.
- **Baseline** — current conversion rate (or mean and standard deviation for continuous metrics) of the primary metric, and weekly eligible traffic. Required.
- **Business context** — the smallest improvement worth shipping, costs of the change, seasonality, other tests running.
- **Tooling** — the experimentation platform and how it assigns users.

## Procedure

1. **Write the hypothesis.** "Because we observed [evidence], we believe [change] for [audience] will cause [direction] in [primary metric], because [mechanism]." If you cannot fill in the evidence or mechanism, the test is a guess; say so.
2. **Choose one primary metric.** It must be sensitive to the change, measurable within the test window, and aligned with business value. Prefer the closest metric to value that still has enough volume (for example, trial starts rather than paid conversions if paid conversions are too rare). Define it precisely: numerator, denominator, attribution window.
3. **Choose guardrail metrics.** Two or three metrics that must not get worse: for example, refund rate, average order value, lead qualification rate, unsubscribe rate, page load time. Define the tolerated degradation in advance.
4. **Pick the randomization unit.** Usually the user (cookie or logged-in ID), so one person sees one variant. Use account or company level for B2B products where colleagues share an experience. The analysis unit must match the randomization unit.
5. **Set the minimum detectable effect (MDE).** The smallest relative lift that would justify shipping. Too-small MDEs make tests impossibly long.
6. **Calculate sample size.** For a binary metric, a standard approximation for each group at 5% two-sided significance and 80% power is n ≈ 16 × p(1 − p) / δ², where p is the baseline rate and δ is the absolute difference to detect. State that this is an approximation and confirm with the team's calculator or platform.
7. **Convert to duration.** Duration = (n per group × number of groups) / weekly eligible traffic. Round up to whole weeks to cover weekday and weekend behaviour, and run at least one full business cycle (often two weeks is a practical minimum). If the duration exceeds roughly six to eight weeks, redesign: test a bolder change, move to a higher-traffic step, or use a proxy metric, because long tests suffer cookie churn and seasonal drift.
8. **Define stopping rules.** Fix the sample size or duration in advance and do not stop on the first significant reading; repeated peeking inflates false positives. If interim looks are needed, use a sequential method supported by the platform and document it.
9. **Define decision rules.** Before launch, write what each outcome means: significant win on primary and guardrails hold, ship; flat, keep control or ship on cost and qualitative grounds and record the learning; guardrail breach, do not ship. Note that a flat result with a confidence interval spanning the MDE is inconclusive, not proof of no effect.
10. **Plan quality checks.** Sample ratio mismatch check (observed split versus intended split), an A/A test or assignment check if the setup is new, exclusion of internal traffic and bots, and a list of other tests that might interact.

## Expected output

```markdown
# Test Plan: <name>
- Hypothesis: Because ..., we believe ..., because ...
- Variants: Control: ... | Variant B: ...
- Audience and randomization unit: ...
- Primary metric (definition): ...   Baseline: ...
- Guardrails (max tolerated change): ...
- MDE (relative / absolute): ...
- Sample size per group: ... (method, alpha, power)
- Weekly eligible traffic: ...   Planned duration: ... weeks
- Stopping rule: ...
- Decision rules: win / flat / loss / guardrail breach
- QA checks: SRM, internal traffic exclusion, interacting tests
- Feasibility verdict: run / redesign / research instead
```

## Constraints and limitations

- The formula covers a two-group test on a binary metric; continuous metrics need variance estimates, and more variants need a multiple-comparison correction.
- Results generalize only to the tested audience and period.
- Novelty and learning effects can make early results unrepresentative.
- Do not design tests that deceive users (fake scarcity, hidden fees) or that touch pricing, consent, or legal terms without the responsible owner's approval.

## Examples

Pricing page to trial start: baseline 4.0%, MDE 10% relative (δ = 0.004). n ≈ 16 × 0.04 × 0.96 / 0.004² ≈ 38,400 per group. With 20,000 eligible visitors per week and two groups, duration ≈ 3.8 weeks, so plan four full weeks. If traffic were 5,000 per week, duration would be about 15 weeks: redesign by testing a bigger change (MDE 25% gives n ≈ 6,100 per group, about 2.5 weeks, rounded to three) or move the test upstream.
