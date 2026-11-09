---
name: financial-ratio-analysis
description: Computes and interprets a consistent set of liquidity, leverage, coverage, profitability, and efficiency ratios from financial statements, with explicit formulas, period averaging, peer and trend context, and caveats. Use when a task needs a ratio pack for a company or wants to compare periods or peers; not for valuation or covenant testing.
---

# Financial Ratio Analysis

A ratio is only useful when its definition is stated, its inputs are traceable, and it is read against a trend or a relevant peer. This skill standardizes the definitions so that two analysts produce the same numbers, then guides interpretation without overclaiming.

## When to use

- A task needs a standard ratio pack for one company across periods.
- Two or more companies in the same industry must be compared on a like-for-like basis.
- Another workflow (credit memo, statement analysis, investment memo) needs ratio inputs with documented formulas.

Not appropriate for: valuation multiples and DCF (use `dcf-valuation`), covenant compliance where the loan agreement defines terms (use `loan-covenant-analysis`), or banks and insurers, whose balance sheets need sector-specific measures (capital ratios, net interest margin, combined ratio).

## Inputs

- Income statement, balance sheet, and cash flow statement for at least two periods. Three to five gives a trend.
- Reporting framework and whether leases are on balance sheet (IFRS 16 and ASC 842 change EBITDA and debt materially).
- Optional: peer data with the same definitions, industry context, and any adjustments the user wants applied (for example excluding one-off items).

## Procedure

1. **Prepare inputs.** Use the same currency and unit for all periods. For balance-sheet items used with flow items (for example ROE, turnover ratios), use the average of opening and closing balances when both are available; otherwise use closing and say so. Annualize interim flows (multiply quarterly by four or use trailing twelve months, preferably TTM).
2. **Compute the ratio set** using these definitions unless the user specifies others:
   - Liquidity: current ratio = current assets / current liabilities; quick ratio = (cash + short-term investments + receivables) / current liabilities; cash ratio = cash and equivalents / current liabilities.
   - Leverage: debt / equity; net debt / EBITDA where net debt = borrowings + lease liabilities (state inclusion) − cash; debt / capital = debt / (debt + equity).
   - Coverage: interest cover = EBIT / interest expense; EBITDA / interest; fixed-charge cover = (EBITDA − capex) / (interest + scheduled principal) as a simple variant, labelled.
   - Profitability: gross, EBITDA, operating, and net margin (each / revenue); ROA = net income / average total assets; ROE = net income / average equity; ROIC = NOPAT / average invested capital, with NOPAT = EBIT × (1 − effective tax rate) and invested capital = equity + net debt.
   - Efficiency: asset turnover = revenue / average total assets; receivable, inventory, and payable days (delegate detail to `working-capital-analysis`).
   - Cash: CFO / net income; free cash flow = CFO − capex; FCF margin.
3. **Decompose ROE with DuPont.** ROE = net margin × asset turnover × equity multiplier (average assets / average equity). Show which component drove the change between periods; rising ROE from leverage alone is a different story from rising margins.
4. **Read trends and peers.** For each ratio, note the direction and size of change and give one candidate driver from the statements. Compare peers only when definitions and fiscal periods align; otherwise state the mismatch.
5. **Flag anomalies.** Highlight negative equity (makes ROE and D/E meaningless), near-zero denominators, ratios moving opposite to their usual relationship (margins up while cash conversion falls), and the effect of one-off items.
6. **Validate.** Recalculate two ratios from raw inputs as a spot check, confirm units, and make sure every number traces to a statement line.

## Expected output

```markdown
## Ratio Analysis: <company> (<periods>, <currency/unit>)
Basis notes: averaging, TTM, lease treatment, adjustments.

| Category | Ratio | Formula | FY-2 | FY-1 | FY0 | Trend comment |
|---|---|---|---|---|---|---|

### DuPont
| Component | FY-1 | FY0 | Contribution to ΔROE |

### Observations
1. <ratio movement> — <driver from statements> — <question raised>

### Caveats
<data gaps, non-comparable items>
```

## Constraints and limitations

- Ratios are diagnostic, not conclusions. There are no universal "good" values; any reference ranges are industry-dependent heuristics and must be labelled as such.
- This is analytical support, not investment, credit, or accounting advice; decisions relying on these figures need review by a qualified professional.
- Do not mix GAAP and non-GAAP inputs without a reconciliation. Never fill missing inputs with estimates silently; mark them "n/a" or show the assumption.
- Stop and ask if the user's ratio definitions conflict with the standard set and the purpose (for example a covenant test) requires their definition.

## Examples

Input (FY0, closing balances only): revenue 120.0m, net income 6.0m, total assets 100.0m, equity 40.0m, EBIT 10.5m, interest 2.1m, current assets 35.0m, current liabilities 25.0m.

- Net margin 5.0%; asset turnover 1.20x; equity multiplier 2.50x; ROE = 5.0% × 1.20 × 2.50 = 15.0% (closing-balance basis, noted).
- Interest cover = 10.5 / 2.1 = 5.0x. Current ratio = 1.40x.
- Comment: "ROE of 15% relies on 2.5x balance-sheet leverage; compare equity multiplier with peers before treating returns as operational strength."
