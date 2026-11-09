---
name: risk-register-construction
description: Construct or improve a risk register for a project, programme, initiative, or partnership - write precise cause-event-consequence risk statements, define likelihood and impact scales, score inherent and residual risk, choose response strategies, assign owners and dated actions, and set review triggers. Use when starting a project or business case, preparing for a steering committee, or when an existing register has become a vague list nobody acts on.
---

# Risk Register Construction

A risk is an uncertain event that, if it occurs, affects objectives. A useful register makes each risk specific enough to act on, scores it consistently, and connects it to an owner and a response. ISO 31000 provides general principles for risk management; this skill applies them at project and initiative level without claiming formal compliance.

## When to use

- At initiation of a project, programme, business case, or partnership.
- Before stage gates, investment committees, or steering meetings.
- When the existing register contains issues (things already happening) mixed with risks, or vague single-word entries.
- Not for enterprise-wide risk appetite frameworks or regulated risk models, which need specialist methods.

## Inputs

- The objectives at risk (scope, timeline, budget, benefits, compliance, reputation).
- Plans, assumptions, dependencies, and constraints.
- Known concerns from the team and stakeholders; lessons from similar past work.
- The organisation's existing scoring scales, if any.

## Procedure

1. **Anchor on objectives.** List the objectives the register protects. Every risk must link to at least one.
2. **Identify risks systematically.** Sweep categories: strategic, commercial, delivery/schedule, technical, people and capacity, third-party and supplier, financial, legal and regulatory, data and security, reputational, and external events. Review each key assumption and dependency: "what if this is false or late?"
3. **Write precise statements.** Use: "Because of <cause>, <event> may occur, leading to <consequence for objective>." Example: "Because the vendor's API is in beta, breaking changes may occur during integration, leading to a 4-8 week slip in go-live." Separate issues (already happening) into an issue log.
4. **Define scales before scoring.** Use 1-5 likelihood (for example 1 = under 10%, 5 = over 70% within the horizon) and 1-5 impact with concrete thresholds per objective (schedule days, cost amount, customers affected, regulatory consequence). Adopt the organisation's scales if they exist. Score = likelihood x impact; treat the bands (for example 15-25 high) as a convention, not science.
5. **Score inherent risk.** Rate likelihood and impact assuming no additional mitigation beyond existing controls; record the rationale in a few words.
6. **Choose a response.** For threats: avoid (change the plan), reduce (lower likelihood or impact), transfer (insurance, contract terms), or accept (with contingency). For opportunities: exploit, enhance, share, or accept. Accepted risks need a stated reason and an owner who agreed.
7. **Define mitigation actions.** Each action has an owner, due date, and expected effect on likelihood or impact. "Monitor closely" is not a mitigation; specify the indicator and threshold.
8. **Score residual risk.** Re-rate assuming actions are completed. If residual stays high, escalate or reconsider the plan.
9. **Assign one owner per risk.** The owner monitors it and ensures actions happen; they need authority over the response.
10. **Set triggers and reviews.** Note early-warning indicators and the review cadence (for example fortnightly for high, monthly for others). Record contingency plans for high-impact risks.
11. **Summarise.** Present a heat map count and the top risks with actions, plus risks that need decisions from sponsors.

## Expected output

```markdown
## Risk Register: <initiative> · Version <n> · <date>
Scales: Likelihood 1-5 (<definitions>) · Impact 1-5 (<definitions by objective>)

| ID | Risk statement (cause → event → consequence) | Objective | Category | L | I | Inherent | Response | Actions (owner, date) | Residual L | Residual I | Residual | Owner | Trigger / indicator | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|

### Heat map summary (residual)
### Top risks and decisions needed from sponsor
### Issue log (items already occurring)
```

## Constraints and limitations

- Scores are subjective; consistency across the register matters more than precision.
- Multiplying ordinal scales is a convention; very-low-likelihood, catastrophic-impact risks need explicit attention regardless of score.
- A register does not capture correlated risks well; note dependencies between risks where they exist.
- Specialist domains (safety, financial risk models, regulatory compliance) require qualified review.

## Examples

**Weak entry:** "Resourcing — high."
**Rewritten:** "Because two of three data engineers are also assigned to the billing migration, analytics pipeline work may be deprioritised in Q2, leading to a delay of the reporting launch beyond the 30 June contract date." L4, I4, inherent 16. Response: reduce. Actions: agree a ring-fenced allocation with the head of data by 15 March (owner: programme manager); identify a contractor option by 22 March. Residual L2, I4 = 8. Trigger: allocation below 1.5 FTE for two consecutive weeks.
