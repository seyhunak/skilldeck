# Weekly Competitive Intelligence Routine

## Objective

Produce a short, reliable weekly digest of what changed at the competitors that matter, triaged by impact, with every item sourced and dated, and with the few important changes routed to a named owner for action. The routine replaces ad hoc "did you see what X did?" messages with a consistent, time-boxed sweep (typically 60-90 minutes) that builds a running history of competitor moves.

## Trigger

Run once a week at a fixed time, for example Monday morning, by the competitive-intelligence owner or an agent working under their supervision. Also run an unscheduled pass when a major competitor event is reported (launch, acquisition, pricing change). This routine is guidance for a human-supervised session; it does not run automatically.

## Prerequisites

- An agreed watchlist of three to eight competitors, prioritised, with the owner who approved it.
- A source list per competitor (see Inputs) and access to last week's snapshot notes or archived copies of key pages.
- A digest template and distribution list approved by the product marketing or strategy lead.
- Familiarity with the `source-credibility-assessment` skill for grading third-party items, and the `competitive-feature-matrix` for recording capability changes.
- Agreement that collection uses public sources only, within site terms.

## Inputs

- Watchlist with tiers: Tier 1 (checked every week in full), Tier 2 (checked every week on headline sources only).
- Per-competitor sources: pricing page, product changelog or release notes, documentation index, blog and newsroom, careers page, status page, app store listings, public filings for listed companies, and the founders' or executives' public posts.
- Category sources: trade press, review sites, community forums, procurement notices.
- Last week's digest and open action items.

## Steps

1. **Set the time box and scope.** Confirm the watchlist and any special focus requested this week (for example "pricing changes before our renewal campaign"). Start a working note with the date.
2. **Check first-party sources for changes.** For each Tier 1 competitor, compare the pricing page, changelog, documentation index, and newsroom with last week's snapshot or archived copy. Record every change with URL, date observed, and a one-line description. For Tier 2, check newsroom and pricing only.
3. **Scan hiring signals.** Review careers pages for new role clusters (for example several enterprise sales roles in a new region, or a new product area). Note counts and locations; treat them as signals of intent, not facts about strategy.
4. **Scan third-party sources.** Search trade press, review sites, forums, and social posts from the past seven days for each competitor. Grade each item with `source-credibility-assessment`; drop rumours that cannot be traced to a credible source, or log them separately as unverified.
5. **Deduplicate and verify.** Merge items describing the same event and, for anything you may mark as high impact, confirm it against a first-party or other credible source.
6. **Triage by impact.** Classify each item:
   - High: changes our win rate, pricing, roadmap, or a live deal within a quarter (for example a price cut in our core segment, a launch of a capability we sell on, an acquisition of a partner).
   - Medium: worth knowing for planning (new region, notable hire, new integration).
   - Low: background (blog posts, minor UI changes).
7. **Update reference material.** Record capability changes in the feature matrix and add notes for battlecard owners; do not edit published battlecards in this routine.
8. **Write the digest.** Lead with high-impact items, each with source, what changed, why it matters (labelled as interpretation), and a suggested owner and action. Keep medium items to one line each and move low items to an appendix or log.
9. **Review open actions.** Update the status of actions raised in previous weeks.
10. **Submit for approval.** Send the draft to the approver; distribute only after approval.

## Decision points

- If a high-impact item affects live deals, alert the sales lead the same day rather than waiting for the digest, after confirming the item with a first-party source.
- If an item cannot be verified, either log it as unverified with its source grade or omit it; never present it as fact.
- If no meaningful changes occurred, send a brief "no material changes" note; do not pad the digest.
- If the same competitor produces high-impact items for three consecutive weeks, propose a full dossier refresh with `competitor-research-agent`.
- If a source requires login, payment, or a fake account to access, skip it and note the gap.

## Expected output

A digest of at most one page:

```markdown
# Competitive Intelligence Digest - week of <date>

## High impact (act this week)
| Competitor | What changed | Source (date) | Why it matters (interpretation) | Owner / action |

## Medium impact
- <Competitor>: <change> [source, date]

## Status of earlier actions
## Unverified signals (do not repeat externally)
## Appendix: low-impact log
```

## Validation checklist

- [ ] Every item has a source link and the date observed.
- [ ] High-impact items were confirmed against a first-party or second credible source.
- [ ] Interpretations are labelled as such and separated from facts.
- [ ] No information was obtained through fake accounts, pretexting, or bypassing access controls.
- [ ] Unverified items are clearly segregated.
- [ ] Owners are named for each high-impact action and last week's actions were updated.
- [ ] The approver signed off before distribution.

## Human approval

The competitive-intelligence owner or product marketing lead approves the digest before it is shared. Changes to battlecards, pricing responses, public comparison pages, or messages to customers require separate approval from their owners; legal review is required before any public comparative claim. Agents may draft but must not distribute the digest or alert sales without explicit human confirmation.
