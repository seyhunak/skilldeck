---
name: dcf-valuation
description: Builds or reviews a discounted cash flow valuation - unlevered free cash flow forecast, WACC from CAPM, terminal value by Gordon growth and exit multiple with cross-checks, enterprise-to-equity bridge, and sensitivity tables. Use when a task asks for an intrinsic value range or to sanity-check an existing DCF; outputs are analytical, not investment advice.
---

# DCF Valuation

A DCF is a structured way to state assumptions about cash flows and risk. Its value lies in making those assumptions explicit and testable, not in the precision of the answer. This skill produces a transparent valuation range and shows which assumptions move it most.

## When to use

- Estimating an intrinsic value range for a company, business unit, or project with forecastable cash flows.
- Reviewing someone else's DCF for methodological errors.
- Producing sensitivity tables for an investment memo or impairment discussion.

Not appropriate for: early-stage companies with no path to positive cash flow (consider scenario-weighted or venture methods), banks and insurers (use dividend discount or excess-return models), or checking spreadsheet mechanics (use `three-statement-model-review`).

## Inputs

- Historical financials (three to five years) and a forecast or the drivers to build one: revenue growth, margins, tax rate, capex, depreciation, working capital.
- Capital structure: debt, cash, leases, minorities, preferred equity, pensions, share count (diluted, with options and convertibles).
- Market inputs with dates and sources: risk-free rate, equity risk premium, beta (or peer betas), pre-tax cost of debt. If the user cannot supply them, state the values used as placeholders to be confirmed, and never present them as current market data.
- Valuation date and currency; forecast in nominal or real terms consistently.

## Procedure

1. **Build unlevered free cash flow.** UFCF = EBIT × (1 − tax rate) + D&A − capex − Δ net working capital. Forecast five to ten years until the business reaches a steady state. Check that capex exceeds depreciation while the company grows and that working capital scales with revenue.
2. **Estimate the discount rate.** Cost of equity (CAPM) = risk-free rate + β × equity risk premium (+ explicitly justified size or country premium if used). Re-lever peer betas: β_L = β_U × (1 + (1 − t) × D/E) using target capital structure. After-tax cost of debt = pre-tax yield × (1 − t). WACC = E/(D+E) × Ke + D/(D+E) × Kd(1 − t), using market-value weights at the target structure. Match currency and inflation between cash flows and rates.
3. **Calculate terminal value two ways.** Gordon growth: TV = UFCF_(n+1) / (WACC − g), with g at or below long-run nominal GDP growth for the currency (a heuristic ceiling, not a rule). Exit multiple: TV = EBITDA_n × peer EV/EBITDA. Back out the implied multiple from the Gordon TV and the implied growth from the multiple TV; large gaps signal inconsistent assumptions. Also report TV as a share of total EV — above roughly 75% means the valuation rests on the long run.
4. **Discount.** Use mid-year convention if cash flows arrive through the year (discount factor = 1/(1+WACC)^(t−0.5)), and state the choice. Discount TV at the final-year factor consistent with the method.
5. **Bridge to equity.** Equity value = EV − debt − lease liabilities (if UFCF excludes lease payments) − minorities − preferred − pension deficit + cash + non-operating assets. Divide by diluted shares using the treasury stock method for options.
6. **Run sensitivities.** Two-way tables: WACC (±1% in 0.5% steps) × terminal growth (±1%), and WACC × exit multiple. Add an operating sensitivity (margin × growth). Present a value range, not a point.
7. **Sanity-check.** Compare implied EV/EBITDA, EV/revenue, and P/E with trading peers and precedent transactions; reconcile big differences. Confirm ROIC in the terminal year exceeds WACC only if a competitive advantage justifies it.

## Expected output

```markdown
## DCF Valuation: <entity> — valuation date <date>, <currency>
| Year | Revenue | EBIT | Tax | NOPAT | D&A | Capex | ΔNWC | UFCF | Discount factor | PV |

WACC build: Rf, ERP, β (source), Ke, Kd, weights, WACC
Terminal value: Gordon (g) | Exit multiple (x) | implied cross-checks | TV % of EV
EV → equity bridge
Sensitivity tables
Value range and key drivers
Assumptions to confirm (with sources needed)
```

## Constraints and limitations

- Output is analytical support, not investment, fairness-opinion, or accounting advice; investment and transaction decisions require qualified human review and sign-off.
- Never present illustrative market inputs as live data; cite source and date or mark them as assumptions.
- Common errors to avoid: discounting levered cash flows at WACC, double-counting leases, g ≥ WACC, mixing nominal and real figures, and terminal-year capex below depreciation for a growing business.
- Stop and ask when share count, net debt items, or currency are unclear, because they change the per-share answer directly.

## Examples

Year-5 UFCF 50.0m, WACC 9.0%, g 2.5%. TV = 50.0 × 1.025 / (0.090 − 0.025) = 788.5m. If year-5 EBITDA is 80.0m, implied exit multiple = 9.9x; peers trade at 7-8x, so either g is generous or the business deserves a premium — state which assumption you would test first. If PV of TV is 512m and EV is 640m, TV is 80% of EV: flag the dependence on long-run assumptions.
