# Feature Launch Routine

## Objective

Take a feature from "engineering is nearly done" to a measured, well-supported launch, with every team that touches the customer prepared and with explicit owners for the go/no-go and rollback decisions. The routine scales by launch tier so that a minor improvement does not get a heavyweight process and a major launch does not get a lightweight one. It ends with a post-launch review that compares results against the success metrics defined before launch.

## Trigger

Begin about four to six weeks before a Tier 1 launch, two to three weeks before Tier 2, and a few days before Tier 3, or when a feature enters final development or beta. This is a human-supervised checklist; an assistant can draft documents and checklists, but people own every decision and every external action.

## Prerequisites

- A launch owner (usually the product manager) with authority to convene the cross-functional group.
- A defined success metric, guardrail metrics, and instrumentation plan (see `product-analytics-instrumentation-agent`).
- A release mechanism that supports staged rollout or a kill switch, such as feature flags (see `feature-flag-rollout-planning`).
- Named contacts in engineering, design, QA, support, marketing, sales or customer success, documentation, and, where relevant, legal, security, and privacy.

## Inputs

- PRD or feature spec, and the final scope.
- Launch tier proposal and target date.
- Beta feedback, known issues list, and test results.
- Pricing or packaging changes, if any.
- Customer segments and regions affected.

## Steps

1. **Tier the launch (T-6 to T-4 weeks for Tier 1).** Classify: Tier 1 — new product or major capability, pricing change, or anything requiring customer action; full cross-functional plan, external announcement, enablement. Tier 2 — meaningful feature for an existing audience; release notes, in-app message, support briefing. Tier 3 — small improvement or fix; release notes only. Record the tier and reasons; tier drives every later step.
2. **Build the launch plan and owner matrix.** List workstreams (engineering readiness, QA, documentation, support enablement, sales enablement, marketing, legal or compliance review, analytics, operations) with owners and due dates. A RACI-style table is sufficient; avoid shared ownership of decisions.
3. **Define go/no-go criteria.** Write them before the review, for example: no open severity-1 or severity-2 defects; performance within agreed budget; accessibility review completed; instrumentation verified in staging; help content published; support briefed; rollback tested; legal and privacy sign-offs recorded where required. Include guardrail thresholds that would trigger a rollback after release (error rate, latency, support contact spike, conversion drop), each with an owner who watches it.
4. **Prepare enablement and content.** Support gets an FAQ, known issues, troubleshooting steps, and escalation path. Sales and success get positioning, eligibility, and pricing answers. Documentation is updated. Draft customer communication with `release-announcement-prompt`; legal or security reviews any claims in their area.
5. **Verify instrumentation and dashboards.** Confirm events fire correctly in staging, a launch dashboard shows the success metric, guardrails, and adoption by segment, and baselines are captured before release.
6. **Hold the go/no-go review (T-2 to T-1 days).** Walk the criteria one by one with evidence. Decision options: go, go with documented exceptions (each with an owner and deadline), or delay. Record the decision and attendees.
7. **Release in stages.** Roll out to internal users, then a small percentage or beta cohort, then broader groups, watching guardrails at each stage. Define hold times between stages in the plan. Publish external communication only after the feature is available to the audience it addresses.
8. **Monitor launch window.** For the first days, the launch owner and engineering on-call review the dashboard at agreed intervals; support reports emerging themes daily. If a rollback threshold is crossed, the named owner decides on rollback or flag-off immediately and informs the group.
9. **Run the post-launch review (typically 2-6 weeks after full rollout).** Compare results to the pre-launch success metric and guardrails, review support volume and themes, collect what went well and what did not, and decide follow-ups: iterate, expand, or retire. Update the launch template with lessons.

## Decision points

- **Tier disputed:** the launch owner decides with marketing; when in doubt about customer-visible risk, choose the higher tier.
- **Any go/no-go criterion unmet:** delay, or go with a documented exception approved by the accountable leader; never silently skip a criterion.
- **Guardrail breach during staged rollout:** pause the rollout at the current stage; resume only after cause is understood.
- **Communication ready before the feature:** hold the announcement; never announce availability that customers cannot see.
- **Pricing, legal, or security claim in copy unverified:** remove the claim or delay publication until the owner signs off.

## Expected output

- Launch plan with tier, workstreams, owners, and dates.
- Go/no-go criteria and the recorded decision.
- Enablement pack for support and sales, and published documentation.
- Customer communication (approved and published by humans).
- Launch dashboard with baselines and guardrails.
- Post-launch review document with results versus targets and follow-ups.

## Validation checklist

- [ ] Launch tier and rationale are recorded.
- [ ] Success and guardrail metrics have baselines captured before release.
- [ ] Every go/no-go criterion has evidence or a documented, approved exception.
- [ ] Rollback or flag-off was tested and has a named decision owner.
- [ ] Support and sales were briefed before customers could see the feature.
- [ ] External claims about pricing, security, privacy, or compliance were signed off by their owners.
- [ ] A post-launch review date is on the calendar.

## Human approval

The launch owner and accountable engineering leader approve the go/no-go decision. Publishing announcements, emailing customers, changing prices, and expanding rollout stages are performed and approved by people. Legal, security, and privacy owners approve any claims or data-handling changes in their areas. Rollback decisions belong to the named owner and must not be delegated to an automated assistant.
