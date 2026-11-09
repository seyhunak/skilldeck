---
name: metric-definition
description: Produces an unambiguous metric specification - business question, formula with numerator and denominator, population, time window and attribution, grain, filters and exclusions, deduplication, edge cases, dimensions it can be sliced by, owner, guardrails, and reference SQL. Use when introducing a KPI, reconciling two teams' versions of the same number, or adding a measure to a semantic layer or dashboard.
---

# Metric Definition

A metric name is a promise that everyone computing it gets the same number. That promise breaks on small decisions: which timestamp, which time zone, which accounts, gross or net, distinct users or events. This skill forces each of those decisions into the open and records them in a specification that can be implemented once and reused.

## When to use

- Defining a new KPI or OKR metric.
- Two dashboards or teams report different values for the "same" metric.
- Adding a measure to a semantic layer (dbt Semantic Layer/MetricFlow, LookML, Cube, or similar).
- Before analysis that a decision will rest on, to agree what is being measured.
- Not for documenting individual columns (use a data dictionary entry) or for decomposing a north-star metric into drivers (use a KPI tree).

## Inputs

- The question the metric should answer and the decision it informs.
- Candidate source tables and their grains.
- Existing variants of the metric (queries, dashboard tiles, spreadsheets), if any.
- The owner who has authority to settle definitional choices.

## Procedure

1. **Start from the question.** One sentence: what does a higher or lower value mean, and what decision changes because of it? If no decision changes, question whether the metric is needed.
2. **Choose the metric type.** Count, sum, distinct count, ratio, average, percentile, or derived (combination of other metrics). For ratios, define numerator and denominator separately as their own measures; ratios are recomputed from components at every aggregation level, never averaged.
3. **Define the population.** Which entities are in scope: customers, accounts, workspaces, orders. Explicit exclusions: test and internal accounts, employees, fraud, bots, refunded or cancelled transactions, free tiers. State how each exclusion is identified in the data.
4. **Define time.** The anchoring timestamp (created, paid, shipped, recognized), the business time zone, the window (calendar month, trailing 28 days, cohort age), how incomplete periods are shown, and how late-arriving or restated data is handled (is last month's value allowed to change? until when?).
5. **Define units and money.** Currency and conversion rule (rate at transaction date vs. fixed planning rate), gross vs. net of discounts, taxes, refunds; units for durations.
6. **Define deduplication and identity.** What identifies a unique user or event; how merged accounts, multiple devices, and re-subscriptions are treated.
7. **List edge cases and decide each.** Examples: upgrades mid-period, partial refunds, orders split into shipments, users active in multiple segments, zero-denominator periods (report null, not zero).
8. **Specify dimensions and grain.** The dimensions the metric may be sliced by, and any it must not be (for example, distinct-user metrics are not additive across days or segments). State the finest valid time grain.
9. **Add guardrails and companions.** Name counter-metrics that catch gaming or side effects (for example, pair conversion rate with refund rate, or average handle time with customer satisfaction).
10. **Write reference SQL and a test.** A canonical query or semantic-layer definition, plus a reconciliation check against a known value. Record owner, version, and change log; definition changes create a new version with the date of change.

## Expected output

```markdown
## Metric: <name> (v<version>)
**Question / decision:** …
**Type:** count | sum | distinct count | ratio | …
**Formula:** numerator = … ; denominator = … ; metric = numerator / denominator
**Population and exclusions:** …
**Time:** anchor …, time zone …, window …, incomplete periods …, restatement policy …
**Units / currency:** …
**Identity and dedup:** …
**Edge cases:** | Case | Decision |
**Valid dimensions:** … · **Not additive across:** … · **Finest grain:** …
**Guardrail metrics:** …
**Source(s):** … · **Reference SQL:** <sql code block>
**Owner:** … · **Change log:** …
```

## Constraints and limitations

- The skill surfaces decisions; the metric owner makes them. Mark undecided items as open rather than choosing silently.
- A precise definition cannot fix poor source data; note data quality dependencies.
- Changing a live metric's definition breaks trend comparisons; recommend versioning and, where feasible, restating history.

## Examples

"Monthly Active Workspaces" - ambiguous as written. Specification: distinct `workspace_id` with at least one of {document created, comment posted, file uploaded} by a non-internal member, within the calendar month in UTC; excludes workspaces flagged `is_test` and those on the internal domain; deleted workspaces count in months they were active; current month shown as month-to-date with a marker; not additive across months or plans (a workspace changing plan mid-month appears in both plan slices, so plan totals exceed the overall figure). Guardrail: share of active workspaces with more than one active member.
