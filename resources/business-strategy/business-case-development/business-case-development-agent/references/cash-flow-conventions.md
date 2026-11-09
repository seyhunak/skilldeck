# Cash-flow conventions for business cases

Use these conventions consistently and state them in the case header. Agreeing them with finance up front prevents most review comments.

## Timing
- **Year 0** holds up-front investment that occurs at decision time; it is not discounted.
- **Year-end convention:** each annual flow is discounted by (1 + r)^t. Simple and standard.
- **Mid-year convention:** discount by (1 + r)^(t - 0.5) when flows arrive evenly during the year. It raises NPV slightly; never mix conventions within one comparison.

## Nominal vs. real
- Nominal cash flows (including expected inflation and price escalators) must be discounted at a nominal rate.
- Real cash flows (today's prices) must be discounted at a real rate. Approximation: real = (1 + nominal) / (1 + inflation) - 1.

## Metrics
- **NPV** = sum over t of CF_t / (1 + r)^t, using incremental flows versus the baseline.
- **IRR** is the rate at which NPV = 0. It can be misleading with non-conventional flows (sign changes more than once) or when comparing options of very different scale; prefer NPV for ranking mutually exclusive options.
- **Simple payback** is the time until cumulative undiscounted incremental flows turn positive. **Discounted payback** uses discounted flows and is always later.
- **TCO** totals all one-off and recurring costs over the horizon, without benefits.

## Incrementality checklist
- Exclude sunk costs already spent.
- Include opportunity cost of assets or people redirected to the initiative.
- Count a released cost only if a budget line actually falls (headcount not backfilled, contract terminated).
- Include terminal or residual value only if there is a realistic basis, and show NPV with and without it.
- Do not include financing costs (interest) in flows when discounting at WACC; the rate already reflects them.

## Sensitivity layout
List each assumption with its low, base, and high values and the resulting NPV. Sort by the size of the NPV swing. The top three rows are where validation effort should go before approval.
