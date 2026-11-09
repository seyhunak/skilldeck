# Decomposition methods for metric changes

Reference for attributing a metric change to components and segments. Use the simplest method that gives shares adding to 100% and state which one was used.

## Multiplicative metrics (Y = A × B × C)

**Log (LMDI-style) decomposition.** For a change from Y0 to Y1:

- Weight `w = (Y1 - Y0) / (ln Y1 - ln Y0)` (if Y1 = Y0, there is nothing to attribute).
- Contribution of A = `w × ln(A1 / A0)`; same for B and C.
- Contributions sum exactly to `Y1 - Y0` and do not depend on ordering.

**Sequential substitution.** Change A first holding B and C at baseline, then B, then C. Simple to explain, but results depend on the order; report the order used, or average over orders when components interact strongly.

Example: revenue = sessions × conversion × AOV. Sessions +5%, conversion −10%, AOV +1% gives revenue roughly −4.5%. Log contributions are proportional to ln(1.05), ln(0.90), ln(1.01): approximately +0.049, −0.105, +0.010. Conversion explains most of the decline.

## Additive metrics (Y = sum of segments)

Contribution of segment i = `Y1_i - Y0_i`. Shares are contributions divided by total change. When segments move in opposite directions, shares can exceed 100% or be negative; present them as signed contributions rather than percentages.

## Rate metrics across segments (rate-mix decomposition)

Overall rate `R = Σ s_i × r_i`, where `s_i` is segment i's share of volume and `r_i` its rate.

- **Rate effect** = `Σ s_i0 × (r_i1 - r_i0)` — what would have changed if mix stayed constant.
- **Mix effect** = `Σ (s_i1 - s_i0) × r_i0` — what changed because volume moved between segments.
- **Interaction** = `Σ (s_i1 - s_i0) × (r_i1 - r_i0)` — usually small; report it, or split it evenly between rate and mix and say so.

The three terms sum to `R1 - R0`. A large mix effect with flat segment rates is the classic Simpson's-paradox pattern.

## Flow metrics (active users, subscribers)

`Active_t = Active_{t-1} + New + Resurrected − Churned`. Attribute changes to each flow. A drop in actives with stable churn and falling new users is an acquisition problem, not a retention problem.

## Practical cautions

- Segments with very small volume produce volatile rates; group them.
- Choose segmentation dimensions that existed and were populated consistently in both periods; a newly tracked dimension creates a fake mix shift.
- Decomposition is accounting, not causation. Pair it with timing evidence and a mechanism before naming a cause.
