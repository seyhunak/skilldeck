# Experiment validity checks

Use before interpreting any treatment effect. A failed check usually invalidates the readout; fix the cause and rerun rather than adjusting the numbers.

## Sample ratio mismatch (SRM)

Test: chi-square goodness of fit of observed unit counts against designed allocation. For two variants with expected shares p and 1 − p and observed counts n_A, n_B with total N:

`chi2 = (n_A − N·p)² / (N·p) + (n_B − N·(1−p))² / (N·(1−p))`, one degree of freedom.

Many teams treat p < 0.001 as an SRM alarm (a heuristic; it keeps false alarms rare when SRM is checked on every experiment). With large N, even a 50.5/49.5 split can be a strong signal.

Common causes:

- Variant-specific redirects, crashes, or slower load times that lose units before logging.
- Bot filtering or deduplication applied after assignment that affects variants differently.
- Triggering conditions that depend on treatment (for example, counting only users who saw a feature that only exists in treatment).
- Assignment changes mid-experiment (ramping allocation without restarting the analysis window).
- Logging differences between variants (a new code path that emits events differently).

## Randomization and analysis unit

- If randomized by user but analyzed per session or pageview, observations are correlated; use the delta method or aggregate to user level.
- If randomized by cluster (team, region), analyze at cluster level or use cluster-robust standard errors.

## Pre-period balance

Compare the primary metric in the period before exposure across variants. A large imbalance suggests broken randomization or a carryover effect from a previous experiment on the same units.

## Time effects

Plot the daily treatment effect. A large early effect that decays suggests novelty; an effect that grows suggests learning (primacy). Ensure the analysis window covers full weekly cycles so weekday mix is balanced.

## Interference

Treatment can affect control in marketplaces, social products, or shared budgets (for example, ad auctions). If plausible, note that user-level randomization may bias the estimate and consider cluster or switchback designs for the next test.

## Data sanity

- Metric definitions identical across variants, computed from the same pipeline.
- No logging outage confined to one variant (check daily counts per variant).
- Outliers inspected: one extreme account can dominate revenue metrics; use a pre-declared winsorization or a robust method.
