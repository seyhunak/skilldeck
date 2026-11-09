---
name: feature-flag-rollout-planning
description: Plans the lifecycle of a feature flag - choosing the flag type (release, experiment, ops kill switch, permission), defining targeting and staged percentage rollout with guardrail metrics and stop criteria, documenting the kill-switch procedure, and scheduling flag removal. Use when shipping a risky change behind a flag, designing a progressive rollout, or cleaning up stale flags.
---

# Feature Flag Rollout Planning

Feature flags decouple deploying code from releasing behaviour, but only if the rollout has stages, metrics, and an owner — and if the flag is deleted afterwards. Unplanned flags become permanent configuration nobody understands. This skill produces a rollout plan that a team can execute and audit.

## When to use

- A change is risky enough that you want to expose it gradually and be able to turn it off without a deploy.
- Designing an experiment, beta program, or gradual migration (e.g. new payment provider, new search backend).
- Auditing a codebase with many old flags.

Not for: the go/no-go decision for an entire release (`release-readiness-routine`), A/B test statistics and experiment design in depth, or database schema rollout (`database-migration-planner-agent`), though flags often coordinate with expand/contract migrations.

## Inputs

- The change and what could go wrong (failure modes and blast radius).
- Flag platform in use (LaunchDarkly, Unleash, Flagsmith, ConfigCat, OpenFeature with a provider, or an in-house system) and its targeting capabilities.
- Metrics and dashboards available: error rate, latency, business KPIs, per-cohort breakdown.
- Traffic volume (decides how long each stage must run to see signal) and any regulatory or contractual constraints on exposure.

## Procedure

1. **Choose the flag type, because it sets the expected lifetime.** Using the common taxonomy (Pete Hodgson's categories):
   - **Release toggle** — hides incomplete or risky work; lifetime days to weeks; remove after full rollout.
   - **Experiment toggle** — splits users for measurement; lives for the experiment duration; needs sticky assignment.
   - **Ops toggle / kill switch** — disables a feature or dependency under load or failure; may be long-lived by design, must be documented and tested.
   - **Permission toggle** — entitlements or beta access by account; long-lived, effectively product configuration.
   Do not overload one flag with several purposes.

2. **Define the flag precisely.** Key and name following the repo's naming convention, description, owner (a person and a team), type, default/fallback value when the flag service is unreachable (fail safe: usually the old behaviour), evaluation context (user id, account id, region), and planned removal date.

3. **Design the code path.** Evaluate the flag at one place as close to the entry point as practical, pass the decision down rather than re-evaluating, and keep old and new paths both working until removal. Avoid flag-dependent data written in a form the old path cannot read — if data shapes change, pair with an expand/contract migration. Test both paths in CI.

4. **Choose the rollout unit and stickiness.** Bucket by a stable key (user or account id) so a user's experience does not flip between requests; use account-level bucketing when users in one organisation must see the same behaviour. Hashing on a stable key keeps assignments consistent as the percentage grows.

5. **Plan stages with entry and exit criteria.** A typical progression (adjust to risk and traffic): internal users → named beta accounts → 1% → 5% → 25% → 50% → 100%. For each stage define the minimum soak time (long enough to see enough events — at low traffic, 1% may never produce signal), guardrail metrics with thresholds compared against the control cohort (e.g. error rate not more than X above control, p95 latency within Y ms, checkout conversion not lower beyond noise), and who approves advancing.

6. **Define stop criteria and the kill-switch procedure.** Automatic or manual rollback triggers tied to the guardrails; exact steps to turn the flag off (who, where, expected propagation time of the flag platform); what happens to in-flight work and data created under the new path; communication path. Rehearse the kill switch in a non-production environment before the first external stage.

7. **Plan observability.** Log or tag telemetry with the flag variation so metrics can be split by cohort; ensure dashboards exist before stage one. Record flag changes in an audit trail tied to the incident timeline.

8. **Schedule cleanup.** At 100% and stable for an agreed period, remove the flag: delete the old code path, the flag evaluation, tests for the old path, and the flag definition in the platform — in that order (code first, then the flag). Create the removal ticket when the flag is created. For audits of existing flags, list each flag's age, last change, current serving state (100% one variation = cleanup candidate), and code references (`grep -rn "flag_key"`).

## Expected output

```markdown
## Rollout plan: <feature> — flag `<key>`
Type: release | Owner: <person/team> | Fallback: off (old path) | Removal by: <date>
### Risks and blast radius
### Targeting
Bucketing key: account_id (sticky) · Exclusions: <regulated regions, enterprise tier>
### Stages
| Stage | Audience | Min soak | Guardrails (vs control) | Approver | Status |
### Stop criteria and kill switch
<triggers; who flips; steps; propagation; data handling>
### Observability
<dashboards, cohort tagging>
### Cleanup
<ticket, steps, definition-of-done>
```

## Constraints and limitations

- Thresholds and soak times here are starting points; set them from the service's real baselines and traffic.
- Do not change flag states in any environment on the user's behalf without explicit instruction; produce the plan and commands.
- A flag does not make an irreversible change reversible: data migrations, emails sent, and external API calls stay done.
- Percentage rollouts on low-traffic features may not yield statistically meaningful comparisons; say so and lean on qualitative beta feedback.

## Examples

**Change:** replace the tax calculation service used at checkout.
**Plan sketch:** release toggle `checkout-tax-v2`, owner payments team, fallback old service. Shadow mode first (compute both, serve old, log mismatches) for a week; then internal accounts; then 1% of accounts bucketed by account id for 48 hours; advance only if mismatch rate stays under the agreed tolerance and checkout error rate is within noise of control. Kill switch: payments on-call flips the flag off; propagation within the platform's documented streaming delay; orders already priced with v2 keep their computed tax. Removal ticket due two weeks after 100%.
