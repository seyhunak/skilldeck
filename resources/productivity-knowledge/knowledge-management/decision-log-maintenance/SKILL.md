---
name: decision-log-maintenance
description: Records and maintains a decision log - each entry with the decision, context, options considered, rationale, owner, reversibility, status, and a revisit date or trigger - and keeps the log healthy by superseding rather than editing history. Use whenever a team or individual makes a non-trivial choice that others will later need to understand or revisit.
---

# Decision Log Maintenance

Teams forget why they decided things far faster than they forget what they decided. Months later, the decision gets reopened without the original context, or followed long after the assumptions behind it stopped being true. A decision log is a lightweight, append-only register that preserves the reasoning and schedules its own review. For software architecture choices, the more detailed Architecture Decision Record format is usually a better fit; this skill covers the broader set of product, process, people, and business decisions.

## When to use

- A meeting or thread reached a decision that affects other people or will be questioned later.
- A choice rests on assumptions that may change (pricing, vendor, staffing, scope).
- Someone asks "why do we do it this way?" and nobody knows.
- Quarterly or periodic review of past decisions is due.

Not appropriate for trivial, easily reversed choices with no audience, or for formal governance records (board resolutions) that have prescribed formats and approvals.

## Inputs

- The decision source: meeting notes, a thread, a memo, or a person's account. Required.
- The existing log, to assign the next ID and link related entries.
- Who has authority to make the decision, if not obvious.

## Procedure

1. **Test whether it belongs.** Log it if at least one is true: it is costly or slow to reverse, it affects people who were not in the room, it resolves a disagreement, or it depends on assumptions worth re-checking.
2. **State the decision in one sentence** in the active voice, specific enough to be verified: "We will use Vendor A for payroll from 2027-01-01" rather than "Payroll vendor chosen".
3. **Capture context.** The problem or trigger, constraints, and the facts known at the time, with links to evidence. Write it so a newcomer understands it without the meeting.
4. **List options considered** — including "do nothing" — with one line on the main trade-off of each. If only one option was considered, record that honestly.
5. **Record the rationale** — why this option won — and the key assumptions it depends on. Assumptions are what the revisit will test.
6. **Classify reversibility.** Use a two-way-door versus one-way-door distinction: reversible decisions can be made quickly by fewer people; hard-to-reverse ones need more scrutiny. Note the cost or lead time to reverse.
7. **Name the owner and participants.** The owner is the accountable decider; also list who was consulted and who must be informed.
8. **Set a revisit trigger.** A date (for example 6 months out) and/or conditions ("if churn exceeds the target for two consecutive months", "when the contract renewal notice window opens"). Every entry gets at least one.
9. **Set status.** Proposed, accepted, superseded by <ID>, deprecated, or rejected. Never rewrite an accepted entry's content; when a decision changes, add a new entry and mark the old one superseded, linking both ways. Typo fixes and added links are fine.
10. **Maintain the log.** On each review cycle: list entries whose revisit date has passed or whose triggers fired, check each assumption, and record the outcome (reaffirmed, amended via new entry, or reversed). Record reaffirmations too; they show the decision was still sound.

## Expected output

Log entry:

```markdown
## D-024: Use Vendor A for payroll from 2027-01-01
**Status:** accepted · **Date:** 2026-11-09 · **Owner:** Head of People Ops
**Consulted:** Finance, Legal · **Informed:** All managers
**Reversibility:** one-way-ish — 3-month migration and 12-month contract

**Context:** Current provider ends support for our region in March 2027...
**Options considered:**
1. Vendor A — integrates with HRIS; higher per-seat fee
2. Vendor B — cheaper; no API for time tracking
3. Do nothing — not viable after March 2027
**Rationale:** Integration removes manual export...
**Assumptions:** headcount stays under 250 through 2027; Vendor A pricing holds at renewal
**Revisit:** 2027-06-30, or if headcount forecast exceeds 250
**Links:** meeting notes 2026-11-05; vendor comparison sheet; supersedes D-011
```

Index table at the top of the log:

| ID | Decision | Status | Owner | Date | Revisit |
|---|---|---|---|---|---|

Review output: list of due entries, assumption checks, and outcomes.

## Constraints and limitations

- Do not invent rationale or options that were not discussed; record "rationale not recorded" if absent and ask the owner.
- The log records decisions; it does not make them. If authority is unclear, mark the entry proposed.
- Keep entries short (a screen or less); link to longer memos instead of copying them.
- Confidential decisions (personnel, legal) may need a restricted log or a redacted entry.

## Examples

Thread: "OK let's just freeze feature work in December and do bug fixing, Priya agreed, we'll see in January if it helped."

Entry: D-025 "Freeze feature work for December 2026; engineering focuses on bug backlog", status accepted, owner Priya (engineering lead), options: continue features, freeze for two weeks, freeze for the month; rationale: rising bug backlog before peak season (ask for figures); reversibility: two-way door; revisit 2027-01-15 with criterion "open P1/P2 bug count lower than on 2026-12-01".
