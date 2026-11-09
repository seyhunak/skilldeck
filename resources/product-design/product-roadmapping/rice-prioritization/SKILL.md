---
name: rice-prioritization
description: Score and rank backlog items with RICE (Reach x Impact x Confidence / Effort) using fixed scales, an evidence note for every input, and a sensitivity check that shows whether the ranking holds. Use when comparing many candidate features or projects against one goal, when a team wants a transparent and repeatable ranking, or when existing RICE scores need auditing.
---

# RICE Prioritization

RICE, popularized by Intercom's product team, ranks work by expected impact per unit of effort: **score = (Reach x Impact x Confidence) / Effort**. Its usefulness comes from forcing each estimate into the open, not from the precision of the result. Treat scores as a structured argument, then apply judgement.

## When to use

- Ranking a list of roughly 5-60 candidates that all serve the same goal.
- Making a prioritization discussion transparent to stakeholders.
- Auditing an existing RICE sheet that produced a surprising ranking.

Not appropriate for: mandatory work (compliance, contractual, security fixes), which should be scheduled outside the scoring; items serving different goals that cannot share an impact scale; or single strategic bets where a business case is needed.

## Inputs

- Candidate list with a short description of each. Required.
- The goal that defines impact (for example "increase trial-to-paid conversion"). Required.
- A time window for reach (usually a quarter). Required.
- Data for reach (analytics, segment sizes), effort estimates from the people doing the work, and any evidence for impact. Recommended.

## Procedure

1. **Fix the scales before scoring.** Agree and write down:
   - **Reach:** number of people or events affected per time window, in real units (customers per quarter, transactions per month). Use the same window for all items.
   - **Impact:** effect on the goal per person reached, on the standard scale 3 = massive, 2 = high, 1 = medium, 0.5 = low, 0.25 = minimal.
   - **Confidence:** 100% = high (data supports reach and impact), 80% = medium (some evidence), 50% = low (mostly intuition). Anything below 50% is a signal to research before scoring.
   - **Effort:** total person-months (or person-weeks) across all disciplines — product, design, engineering, QA — to ship. Use whole or half units; false precision is noise.
2. **Estimate each input with evidence.** Record the source for every number: analytics query, segment size, support ticket counts, sales data, prior experiment, engineering estimate, or "PM judgement". Reach should come from data whenever possible because it is the most measurable input.
3. **Calibrate impact.** Before scoring the list, choose one or two reference items the team agrees on (for example "the saved filters launch was a 1") and score others relative to them. This reduces optimistic inflation.
4. **Apply confidence honestly.** Lower confidence when reach or impact relies on stated intent, a single customer, or an untested assumption. Do not raise confidence because an item is popular internally.
5. **Compute and rank.** Score = Reach x Impact x Confidence / Effort. Show every input and the result in a table so anyone can recompute it.
6. **Run a sensitivity check.** For the top items and those near the capacity cut-off, recompute with the least-certain input at the low end of its plausible range (for example effort doubled or reach halved). Mark items whose rank changes materially as unstable.
7. **Apply judgement and document overrides.** Consider dependencies, strategic fit, and risk balance. If you move an item against its score, write the reason next to it.
8. **Present.** Ranked table, unstable items, overrides, and the inputs that would most change the ranking if better data were gathered.

## Expected output

```markdown
**Goal:** <...> · **Reach window:** <quarter> · **Effort unit:** person-months

| Rank | Item | Reach (source) | Impact (rationale) | Confidence (why) | Effort (source) | RICE | Stable? |
|---|---|---|---|---|---|---|---|

**Overrides:** <item — moved from rank x to y — reason>
**Most valuable data to gather next:** ...
```

A spreadsheet-ready layout is in `examples/rice-scoring-sheet.csv`.

## Constraints and limitations

- Never present an estimate as measured; every input carries its source.
- Do not mix impact scales across different goals; run separate scoring per goal.
- RICE favours small, broad improvements and can under-rank strategic bets or enabling work; call this out when such items are in the list.
- Do not assign effort without input from the people who would do the work; if unavailable, mark effort as a placeholder range.

## Examples

Goal: increase trial-to-paid conversion. Window: one quarter. About 8,000 trials start per quarter.

| Item | Reach | Impact | Confidence | Effort | Score |
|---|---|---|---|---|---|
| Guided setup checklist | 8,000 (all trials, analytics) | 1 | 80% | 2 | 3,200 |
| Slack integration | 2,400 (30% of trials connect Slack, survey) | 0.5 | 50% | 3 | 200 |
| In-app pricing explainer | 3,000 (trials visiting pricing page, analytics) | 0.5 | 80% | 0.5 | 2,400 |

Sensitivity: if the checklist's effort doubles to 4 person-months its score falls to 1,600, below the pricing explainer's 2,400, so the top two swap under a plausible effort range. Both are marked unstable, and a firmer checklist estimate is the most valuable data to gather. The Slack integration stays last under any reasonable change (even at 100% confidence it scores 400).
