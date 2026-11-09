---
name: access-review
description: Performs a user access review for a system or set of systems - reconciles account exports against the HR roster, flags orphaned, dormant, shared, and privileged accounts, checks least privilege against role baselines and segregation-of-duties conflicts, and records reviewer decisions as audit evidence. Use for periodic access certifications, leaver audits, or SoD checks.
---

# Access Review

## When to use

Load this skill when someone needs to certify who has access to a system the organisation owns and whether that access is still appropriate: periodic reviews required by SOC 2, ISO 27001, or SOX controls; checks after a reorganisation or acquisition; a leaver audit; or a segregation-of-duties (SoD) analysis for a finance or production system.

Do not use it to design the IAM model itself (use `security-architecture-review-agent`) or to investigate whether an account was misused (use `security-log-analysis`). For the full quarterly workflow with scheduling and evidence packaging, follow `quarterly-access-review-routine`, which calls this skill.

## Inputs

- **Account export** per system: account ID, display name or email, status, roles or groups, privilege flags, created date, last login. Required.
- **Authoritative roster** from HR: employee or contractor ID, email, status, department, manager, termination date. Required.
- **Role baseline** — which roles each job function should normally hold. Optional but needed for least-privilege judgements.
- **SoD rule set** — pairs of roles or permissions that must not be held together. Optional; examples below.
- **Previous review** — to confirm earlier revocations happened. Optional.

Minimise fields: names, emails, and roles are enough. Never include passwords, hashes, or MFA secrets.

## Procedure

1. **Record scope and population.** System, export date and time, who produced the export, and record counts. Auditors test completeness, so note how the export was generated and keep the raw file (or its hash) as evidence.
2. **Normalise identities.** Match accounts to roster records by a stable key (employee ID, then corporate email). Lowercase emails, strip plus-addressing, and resolve known aliases. Keep a list of unmatched accounts.
3. **Classify every account into one bucket:**
   - **Active-matched** — maps to an active person.
   - **Orphaned** — maps to a terminated person, or to no person at all. High priority: confirm and remove.
   - **Dormant** — no login in a defined window (90 days is a common heuristic; use the organisation's standard). Candidate for removal.
   - **Service or non-human** — must have a named human owner and documented purpose; flag any with interactive login enabled.
   - **Shared or generic** — names like `admin`, `ops`, `test`; must be justified, vaulted, and monitored, or removed.
   - **External** — contractors, vendors, auditors; check an end date exists.
4. **Review privilege.** List every account with administrative, owner, or equivalent rights. Compare each person's roles to their function's baseline; flag excess. Check that administrators use separate privileged accounts where the standard requires it.
5. **Check segregation of duties.** Apply SoD rules; common examples are: create vendor and approve payment; develop code and deploy to production without review; create user accounts and approve access requests; post journal entries and approve them. Report each conflict with the person, both roles, and whether a compensating control (for example, independent approval logged in a workflow tool) exists.
6. **Confirm prior actions.** Check that accounts marked for removal in the previous review are gone; repeated findings are an audit concern.
7. **Prepare the reviewer packet.** Group exceptions by reviewing manager or system owner. Present only the decisions that need judgement, each with a recommended action. Reviewers must actively choose Keep, Modify, or Remove; a blank or bulk-approved list is weak evidence.
8. **Record decisions and follow-through.** Capture reviewer, decision, date, and rationale for keeps on flagged accounts. Track removals to completion and verify with a fresh export.

## Expected output

1. **Summary** — system, population, counts per bucket, privileged account count, SoD conflicts, prior-action status.
2. **Exceptions table:**

| Account | Person / owner | Bucket | Roles | Last login | Issue | Recommended action | Reviewer | Decision | Date |
|---|---|---|---|---|---|---|---|---|---|

3. **SoD conflicts table:** person, conflicting roles, compensating control, recommendation.
4. **Evidence index:** export files with timestamp and hash, roster version, reviewer sign-offs, verification export.

## Constraints and limitations

- Recommend changes only; removals are executed by system owners after approval.
- Last-login data is unreliable for some systems (SSO-fronted apps, API-only access); state the source and its limits.
- Matching by display name alone produces errors; flag low-confidence matches instead of guessing.
- Exports contain personal data: keep outputs internal and minimal. This is not legal or audit advice; the control owner signs off the completed review.

## Examples

Input: GitHub organisation export (212 members) and HR roster.

Output summary: 198 active-matched; 4 orphaned (three leavers from last quarter, one unknown personal account); 6 dormant beyond 90 days; 3 service accounts, one with no documented owner; 1 shared account `deploy-bot` with owner role; 14 organisation owners against a baseline of 4. SoD: two people can both merge to `main` without review and run the production deploy workflow, compensated only partially by branch protection that admins can bypass. Recommended actions: remove the four orphaned accounts today, confirm dormant accounts with managers, assign an owner to the service account and convert `deploy-bot` to a GitHub App with scoped permissions, reduce owners to the baseline, and enable "include administrators" on branch protection.
