---
name: market-sizing
description: Estimates total addressable market (TAM), serviceable addressable market (SAM), and serviceable obtainable market (SOM) using independent top-down and bottom-up builds, explicit sourced or labelled assumptions, low/base/high ranges, and a reconciliation of the two methods. Use when a business case, pitch, market-entry plan, or board deck needs a market size that can survive scrutiny, or when checking someone else's figure.
---

# Market Sizing

## When to use

Use this skill when a decision depends on how large a market is or could become: entering a segment, prioritising geographies, building a business case, writing an investment memo, or challenging a headline figure. It works for B2B and B2C, products and services.

It does not produce forecasts of the company's revenue, valuations, or investment advice. For the qualitative structure of the market (segments, value chain, drivers) use a broader market research process; this skill supplies the numbers.

## Inputs

- Market definition: product or problem, customer type, geography, year, currency.
- The offer: price point and pricing unit (per seat, per site, per transaction).
- Available data: statistics, filings, analyst figures, internal data (customers, conversion, pricing).
- Purpose and audience, which set the precision needed.

## Procedure

1. **Define the boundary precisely.** State what is in and out, the unit (annual revenue, spend, units), currency, and base year. Define the three layers for this case:
   - TAM: annual spend if every potential customer for this problem in the defined scope bought a solution.
   - SAM: the part of TAM your offer can actually serve given product, segment, channel, language, and regulatory reach.
   - SOM: the part of SAM you can realistically win in a stated period (typically three to five years), given competition and go-to-market capacity.
2. **Build top-down.** Start from a broad published figure (industry spend, category revenue, government statistics) and narrow with filters that each have a source: share in your geography, share in your segment, share relevant to your use case. Record each filter as sourced or assumed.
3. **Build bottom-up.** Multiply countable units by value: number of target customers (from business registers, census data, industry databases) × adoption or fit rate × annual value per customer (from your pricing or comparable products). For SOM, multiply SAM by an achievable share justified by comparable companies' trajectories, sales capacity (reps × quota × ramp), or funnel math.
4. **Optionally build a value-theory estimate.** For new categories with no spend yet, estimate the cost of the problem being solved or the budget being displaced, then apply a capture rate. Label it as the least certain method.
5. **Express ranges.** For each method compute low, base, and high using plausible ranges for the two or three most uncertain inputs. Identify which inputs move the result most (simple one-at-a-time sensitivity).
6. **Reconcile.** Compare top-down and bottom-up. If they differ by more than about a factor of two (a heuristic), find the cause: mismatched definitions, overstated adoption, wrong price, or a top-down figure that includes adjacent categories. Adjust or explain; do not average blindly.
7. **Sanity-check.** Compare SOM against revenues of existing players, implied market share, and the customer count it implies. A SOM requiring more customers than your sales team could ever close is wrong.
8. **Document the assumptions register** so anyone can change an input and see the effect.

## Expected output

```markdown
**Definition:** <scope, unit, currency, base year>

| Layer | Method | Low | Base | High | Key drivers |
|---|---|---|---|---|---|
| TAM | Top-down | | | | |
| TAM | Bottom-up | | | | |
| SAM | Bottom-up | | | | |
| SOM (year N) | Capacity/share | | | | |

**Bottom-up build (base):** <units> × <fit rate> × <annual value> = <result>
**Reconciliation:** <why methods differ and which is preferred>
**Sensitivity:** <top inputs and their effect>

| # | Assumption | Value (low/base/high) | Source or "assumed" | Confidence |
|---|---|---|---|---|
```

## Constraints and limitations

- A market size is a model; present ranges and the method, not a single precise number.
- Analyst figures often lack published methods and use broader definitions; never use one as TAM without checking its scope.
- Avoid the "1% of a huge market" fallacy: SOM must come from a capacity or comparable-company argument, not an arbitrary percentage.
- Keep currency and year consistent; state any conversions and inflation adjustments.
- Never invent statistics; when an input is unknown, label it as an assumption with a range.

## Examples

**Case:** scheduling software for independent physiotherapy clinics in the UK, priced at £1,200 per clinic per year.
Bottom-up TAM: about N clinics (from the professional body's register or business register counts; sourced) × £1,200 = TAM. SAM: exclude clinics already locked into hospital-group systems (assumed 20-35%) and those without online booking demand. SOM over three years: two sales reps closing 15-25 clinics per month each, minus churn, gives a capacity ceiling to compare with SAM.
Top-down cross-check: published UK practice-management software spend × physiotherapy share. If the top-down is five times the bottom-up, inspect whether it includes hospital systems, which the definition excluded.
