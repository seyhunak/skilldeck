# Quarterly Access Review Routine

## Objective

Complete a user access review for every in-scope system once per quarter so that inappropriate access is removed promptly and the organisation holds evidence an auditor can test: a complete population, the right reviewers, documented decisions, and verified removals. The routine is run by a human control owner, optionally with an AI assistant applying the `access-review` skill to prepare reviewer packets; it never revokes access automatically.

## Trigger

Start in the first two weeks of each calendar quarter, or on the schedule defined in the organisation's access control standard. Also run an out-of-cycle review for a single system after a reorganisation, an acquisition, a security incident involving that system, or an audit finding. A calendar reminder or ticket is the trigger; nothing here runs on its own.

## Prerequisites

- An access control standard defining review frequency, in-scope systems, dormancy threshold, and removal deadlines.
- A current in-scope system list with a named system owner for each (typically production infrastructure, cloud consoles, source control, CI/CD, identity provider admin roles, databases with customer data, finance and HR systems).
- Read-only export capability for each system, or an owner who can produce exports.
- Access to the HR roster with status, manager, and termination dates.
- A restricted evidence location (for example, a compliance folder with limited access) and a ticketing queue for removals.
- Last quarter's review records.

## Inputs

- Account exports per system with roles, status, created date, and last login.
- HR roster snapshot taken the same day as the exports.
- Role baselines and segregation-of-duties rules, where defined.
- Previous quarter's removal tickets and exceptions with expiry dates.

## Steps

1. **Open the review record.** Create a ticket or tracker for the quarter listing every in-scope system, its owner, its reviewer, and due dates (exports by day 3, reviewer decisions by day 10, removals completed by day 15, evidence packaged by day 20; adjust to your standard). Confirm the system list against the asset inventory so newly added systems are not missed.
2. **Collect exports.** For each system, generate the account export, record who produced it, when, and how (screenshot of the query or report parameters), and save the raw file with its hash in the evidence location. Pull the HR roster on the same day.
3. **Prepare reviewer packets.** Apply the `access-review` skill to each export: match accounts to people, bucket them (active, orphaned, dormant, service, shared, external), list privileged accounts, and flag segregation-of-duties conflicts. Produce one packet per reviewer showing only that reviewer's population, with exceptions highlighted at the top.
4. **Remove obvious orphans promptly.** Accounts belonging to terminated people do not need to wait for the review cycle: raise removal tickets immediately, with system owner approval, and record them.
5. **Send packets to reviewers.** The reviewer is the person's manager or the system owner, never the account holder themselves. Ask reviewers to mark every flagged line Keep, Modify, or Remove, with a reason for each Keep on a flagged account. Do not accept a single "all approved" reply for lists that contain exceptions.
6. **Chase and escalate.** Track responses daily from day 7. Escalate non-responses to the reviewer's manager and the control owner before the due date. Record escalations in the review record.
7. **Execute changes through tickets.** System owners perform the approved removals and modifications. Link each ticket to the decision line. The routine operator does not make access changes personally unless they are the system owner.
8. **Verify.** Take a fresh export after removals and confirm each removed or modified account is gone or changed. Note any that remain and why.
9. **Handle exceptions.** For access kept despite a flag (for example, a dormant break-glass account), record the justification, compensating control, approver, and expiry date.
10. **Package evidence and sign off.** Assemble: system list, exports with hashes, roster snapshot, reviewer packets with decisions, removal tickets, verification exports, exceptions, and a summary. The control owner signs off with date.
11. **Feed improvements back.** Note recurring problems (the same system always late, frequent dormant accounts, missing owners) and raise them as improvement actions for next quarter.

## Decision points

- If a system cannot produce a complete export, then record the limitation, obtain the best available population from the owner, and raise a finding to fix export capability; do not silently skip the system.
- If an account cannot be matched to a person, then treat it as orphaned until the system owner identifies an owner within the review window; if nobody claims it, disable it after approval.
- If a reviewer is also an account holder on the list, then route their own accounts to their manager.
- If a segregation-of-duties conflict cannot be removed, then require a documented compensating control (independent approval, monitoring) and approval from the control owner.
- If removals are not complete by the deadline, then escalate to the system owner's manager and record the delay; it will likely appear as an exception in audit testing.

## Expected output

A quarter's access review package in the evidence location containing the review record, per-system summary (population, exceptions, decisions, removals, verification status), all supporting exports and tickets, an exceptions register with expiry dates, the control owner's sign-off, and a short improvement list.

## Validation checklist

- [ ] Every in-scope system was reviewed, or its omission is documented with a reason and approval.
- [ ] Each export has a recorded source, timestamp, producer, and hash.
- [ ] No account holder reviewed their own access.
- [ ] Every flagged account has an explicit Keep, Modify, or Remove decision with a reason for Keeps.
- [ ] All approved removals were executed through tickets and verified in a fresh export.
- [ ] Exceptions have a justification, compensating control, approver, and expiry.
- [ ] Last quarter's removals and expiring exceptions were checked.
- [ ] Evidence is stored in the restricted location and contains no passwords or credential material.
- [ ] The control owner signed and dated the review.

## Human approval

Every access removal or modification requires approval from the system owner or the person's manager and is executed by an authorised administrator, not by an AI assistant. Exceptions and segregation-of-duties compensating controls require control owner approval. The completed review requires the control owner's sign-off. This routine is guidance, not legal or audit advice; confirm the frequency, scope, and evidence expectations with your compliance lead or auditor.
