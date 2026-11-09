---
name: customer-segmentation
description: Segments customers using RFM scoring, behavioral clustering, or needs-based research, validates the segments, and writes actionable segment profiles. Use when targeting campaigns, designing lifecycle programs, prioritizing markets or personas, or explaining differences in value and retention across the customer base.
---

# Customer Segmentation

A procedure for choosing the right segmentation approach for a decision, building segments from data or research, checking that they are worth acting on, and describing each with the action it implies.

## When to use

- Lifecycle or CRM programs need audiences that behave differently.
- Marketing needs to decide which customer groups to prioritize or message differently.
- Leadership asks why some customers are far more valuable or loyal than others.
- Personas exist but lack data behind them.

Not suitable for tiny customer bases where every account is managed individually, or for decisions that require causal claims about why segments behave differently.

## Inputs

- **Decision** the segmentation will inform (targeting, messaging, product focus, retention). Required; it chooses the method.
- **Customer-level data** — transactions (customer ID, date, amount), product usage events, plan, acquisition source, firmographics for B2B. Pseudonymised IDs are sufficient.
- **Research** — survey responses or interview notes for needs-based segmentation.
- **Analysis period** — a window that covers at least one typical purchase or usage cycle.

## Procedure

1. **Choose the approach from the decision.**
   - *RFM (recency, frequency, monetary)* for transactional businesses deciding who to retain, reactivate, or reward.
   - *Behavioural* (feature usage, engagement patterns, lifecycle stage) for products where usage predicts retention and expansion.
   - *Needs-based* (jobs, priorities, pains from surveys or interviews) for positioning, messaging, and product decisions.
   - *Firmographic or value tiers* for B2B prioritization (size, industry, revenue potential).
   Combinations are common: needs-based segments sized and located with behavioural data.
2. **Prepare data.** Define the customer unit, exclude test and internal accounts, handle refunds and returns, and pick the snapshot date. Exclude sensitive attributes (health, ethnicity, religion, sexual orientation, and similar) and check whether any remaining feature acts as a proxy for them.
3. **Build RFM segments (if chosen).** Compute recency (days since last purchase), frequency (purchases in the window), and monetary value (total or average spend). Score each 1-5 by quintile (frequency often needs custom breakpoints because many customers buy once). Combine into named groups with explicit rules, for example: Champions (R 4-5, F 4-5), Loyal (F 4-5, R 3+), Promising new (R 5, F 1), At risk (R 1-2, F 3+), Hibernating (R 1-2, F 1-2). State the rules so they can be rebuilt in a CRM.
4. **Build behavioural clusters (if chosen).** Select 4-8 standardized features tied to the decision (such as active days per month, core feature adoption, seats used). Start with simple rule-based segments; use clustering (for example k-means on standardized features) only if rules miss structure. Choose the number of clusters by interpretability and stability, not only statistical fit; check stability by re-running on a different time window or a random half of the data.
5. **Build needs-based segments (if chosen).** Code survey or interview responses into needs and priorities, group respondents with similar priority patterns, and then find observable attributes (role, company size, trigger) that predict membership so the segments can be targeted.
6. **Validate.** Check each segment is: measurable (rule or model assigns members), substantial (large enough to justify distinct treatment), distinguishable (behaves differently on the metric that matters), accessible (reachable through channels or product), and actionable (implies a different action). Compare segments on retention, revenue, and conversion to confirm the differences matter.
7. **Profile and act.** For each segment: size, share of revenue, key behaviours, likely needs (marked as inferred unless from research), recommended action, and the metric to watch.
8. **Plan maintenance.** Define how often members are re-scored and how segment movement is tracked, because transitions (for example, Loyal to At risk) are often the best triggers.

## Expected output

```markdown
# Segmentation: <decision> — <data window>
**Method:** RFM / behavioural / needs-based · **Unit:** customer/account · **Snapshot:** <date>

## Segment rules
| Segment | Rule / definition |

## Segment profiles
| Segment | Customers | % revenue | Key behaviours | Needs (source) | Action | Metric |

## Validation
Size, difference on target metric, stability check, caveats.

## Maintenance
Re-scoring cadence, transition triggers.
```

## Constraints and limitations

- Segments describe patterns; they do not explain causes.
- Quintile cut-offs shift as the customer base changes; fixed thresholds are more stable for operations.
- Clusters can be artefacts of feature choice and scaling; prefer interpretable rules.
- Do not use protected or sensitive characteristics for targeting, and check outputs for discriminatory effects in pricing or eligibility decisions.

## Examples

An online coffee retailer with 40,000 customers runs RFM on 12 months of orders. Champions (8% of customers) produce 41% of revenue; At risk (11%) were frequent buyers with no order in 90+ days against a typical reorder cycle of about 30 days. Action: At risk enters a reactivation flow triggered by crossing the recency threshold; Champions get early access rather than discounts. Metric: 60-day reactivation rate versus a holdout.
