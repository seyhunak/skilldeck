# Release Readiness Routine

## Objective
Decide, on evidence, whether a release candidate should ship now, ship with conditions, or wait. The routine walks the release owner through a fixed set of gates (scope, quality, data, rollback, observability, operations, communication), records each as pass, waived or fail with a link to evidence, and ends with a written go, conditional go, or no-go decision signed off by named people. It is deliberately about readiness, not about writing the notes themselves; release notes come from the `changelog-and-release-notes` skill and staged exposure plans from `feature-flag-rollout-planning`.

## Trigger
Run it for every production release that is not a fully automated continuous deployment, and for any release containing a schema migration, a public API change, a dependency major-version bump, or a change to authentication, billing or data retention. Schedule the review 24-48 hours before the planned release window so there is time to fix a failed gate (a heuristic; adjust to your release cadence). It is a human-led checklist, not an automated pipeline stage.

## Prerequisites
- A frozen release candidate: a tag or commit SHA, build artifact digest, and the list of included changes.
- Access to CI results, the staging environment, monitoring dashboards and the on-call schedule.
- A named release owner, plus approvers agreed in advance (typically engineering lead and, for customer-visible changes, product or support).
- The previous release's rollback notes, if any.

## Inputs
- Required: release candidate identifier, change list (PRs or tickets), CI and test results, migration scripts, deployment plan.
- Optional: performance test results, security scan output, known-issues list, feature flag states, customer communication drafts, support FAQ.

## Steps
1. **Freeze and inventory scope.** Pin the exact SHA and artifact. List every change with its risk class (low: copy or internal refactor; medium: behaviour change behind a flag; high: migration, API contract, auth, billing). Anything merged after the freeze is out unless the owner re-opens the review.
2. **Quality gates.** Confirm the required CI suite passed on the frozen SHA, not on an earlier commit. Record flaky tests that were retried and why that is acceptable. Check open bugs tagged for this release: any severity-1 or severity-2 open item is a fail unless explicitly waived.
3. **Staging verification.** Deploy the same artifact to staging and run the smoke tests and the specific scenarios for high-risk changes. Note any configuration that differs between staging and production; each difference is a risk to name.
4. **Data and migration review.** For each migration: is it backward compatible with the currently running version (expand/contract)? How long does it take on production-sized data, and does it take locks? Is there a tested down-migration or a forward-fix plan? Irreversible data changes need a backup and restore-tested snapshot. The `database-migration-planner-agent` can help analyse these.
5. **Rollback plan.** Write the exact rollback procedure and who executes it: redeploy previous artifact, flip flags off, or forward-fix. State the rollback trigger in measurable terms (for example "error rate above the SLO burn threshold for 10 minutes" or "checkout success drops below baseline"). If rollback is impossible after a certain step, say which step and require extra approval for it.
6. **Observability check.** Confirm dashboards and alerts exist for the new behaviour, that new error paths log something actionable, and that someone knows the baseline values to compare against. Gaps here are often a reason for a conditional go with a watcher assigned.
7. **Operational readiness.** Confirm the deploy window avoids peak traffic and known freezes, the on-call engineer knows the release is happening and has the rollback notes, and dependent teams (data, mobile, partners) are aware of contract changes.
8. **Communication readiness.** Release notes, support briefing, status page plan for user-facing risk, and customer notices for breaking changes. Drafts only at this stage.
9. **Decide.** Hold a short go/no-go review (15 minutes is typical) with the gate table. Each gate is pass, waived (with a named person and a reason) or fail. Record the decision and conditions.
10. **Post-release watch.** Assign someone to watch the agreed metrics for a defined period after deploy and to record the outcome, closing the loop for the next release.

## Decision points
- Any failed gate without a waiver means no-go. Waivers need a named approver and a written reason; the release owner cannot waive their own gates alone.
- If a migration is not backward compatible with the running version, either split it into expand and contract releases or require a maintenance window with explicit approval.
- If the rollback trigger cannot be measured with existing telemetry, the decision is at best a conditional go with a human watcher assigned to manual checks.
- If scope changed after the freeze, restart from step 1 for the new changes.
- If the release falls into a high-traffic period or freeze, default to waiting unless the release fixes an active incident.
- If the release fails in production, follow the rollback plan first and run `incident-postmortem-routine` afterwards.

## Expected output
A release readiness record, stored with the release:

```text
Release: v2.14.0  SHA: 4f2c9a1  Artifact digest: recorded
Owner: <name>   Approvers: <names>   Window: <date/time, timezone>
Gate                 Status   Evidence / note
Scope frozen         PASS     12 PRs, 2 high-risk (migration, auth)
CI on frozen SHA     PASS     run link
Open sev1/sev2       WAIVED   BUG-311 cosmetic sev2, approved by <name>
Migration            PASS     expand-only, 40s on prod-size copy, no long locks
Rollback             PASS     redeploy v2.13.3; trigger: 5xx > 2% for 10 min
Observability        COND     new queue depth alert pending; <name> watches 2h
Comms                PASS     notes + support brief drafted
Decision: CONDITIONAL GO — condition: watcher assigned until alert ships.
```

## Validation checklist
- [ ] Every gate has a status and a link or note pointing to evidence.
- [ ] CI results correspond to the frozen SHA and artifact actually being deployed.
- [ ] Rollback procedure, trigger and executor are written down and the executor has read them.
- [ ] Each migration's compatibility with the running version and its runtime on realistic data are recorded.
- [ ] Every waiver names an approver other than the release owner and gives a reason.
- [ ] A post-release watcher and watch period are assigned.

## Human approval
The go/no-go decision, any waiver, the production deploy itself, irreversible migrations, and customer-facing announcements all require explicit approval from the named humans. An assistant may collect evidence, draft the readiness record and notes, and highlight gaps, but must never trigger a deploy, run a migration, change flag states, or publish communications.
