---
name: working-capital-analysis
description: Calculates DSO, DIO, DPO and the cash conversion cycle with consistent day-count conventions, separates seasonality from structural change, quantifies cash tied up or released per day of improvement, and links findings to receivables ageing, inventory, and supplier terms. Use when assessing liquidity, cash release opportunities, or earnings-quality signals.
---

# Working Capital Analysis

Working capital is where profit becomes cash, or fails to. This skill measures how long cash is tied up in receivables and inventory, how much supplier credit offsets it, and what a change of a few days is worth in money. It also catches the patterns that signal trouble: receivables outpacing sales, inventory building ahead of demand, or payables stretched to fund operations.

## When to use

- Liquidity assessment for credit, treasury, or a cash release programme.
- Explaining why operating cash flow diverges from profit.
- Benchmarking working capital efficiency over time or against peers.
- Supplying drivers to a cash forecast.

Not appropriate for: banks and insurers, or project-based businesses where contract assets and liabilities dominate (use contract-specific measures and state the limitation).

## Inputs

- Revenue and cost of goods sold (or cost of sales) per period.
- Trade receivables, inventory, and trade payables at each period end; average balances if available.
- Optional: AR and AP ageing, inventory by category and age, contract payment terms, use of factoring, supply-chain finance, or reverse factoring.

## Procedure

1. **Fix conventions.** Use 365 days for annual data (or the days in the period for interim, for example 91 for a quarter). Prefer average balances; with seasonal businesses, use period-end balances alongside the matching period's flows and state the choice. Use gross receivables before allowance, or net, consistently.
2. **Calculate the metrics.**
   - DSO = trade receivables / revenue × days (use credit sales and exclude VAT/sales-tax mismatches where possible).
   - DIO = inventory / COGS × days.
   - DPO = trade payables / COGS × days (purchases are a better denominator if available).
   - Cash conversion cycle (CCC) = DSO + DIO − DPO.
   - Net working capital as % of revenue = (receivables + inventory − payables) / revenue.
3. **Value one day.** Cash per day of DSO ≈ revenue / days; per day of DIO or DPO ≈ COGS / days. Multiply by the change in days to show cash consumed or released. This is the most persuasive number for management.
4. **Separate seasonality from trend.** Compare the same period year over year and, for monthly data, use trailing twelve months. A rise in DSO at a seasonal peak may be normal; a rise in the same month across years is not.
5. **Diagnose drivers.** For DSO: ageing shifts, customer mix, disputed invoices, billing delays, term changes. For DIO: slow-moving or obsolete stock, safety stock policy, supply disruptions. For DPO: negotiated terms versus late payment. Distinguish improvement from window-dressing: factoring, supply-chain finance, or large period-end supplier payments delayed by a few days all flatter metrics.
6. **Flag earnings-quality signals.** Receivables growing materially faster than revenue, inventory growing faster than COGS, falling inventory provisions as stock ages, and DPO rising sharply alongside falling cash all warrant questions.
7. **Quantify opportunity carefully.** Present cash release ranges from realistic day improvements, with operational and relationship risks (stretching suppliers can breach terms or harm small suppliers and may be regulated).

## Expected output

```markdown
## Working Capital Analysis: <entity> (<periods>)
Conventions: <days, average/closing, denominators>

| Metric | FY-2 | FY-1 | FY0 | Δ days | Cash effect |
| DSO | | | | | |
| DIO | | | | | |
| DPO | | | | | |
| CCC | | | | | |
| NWC % revenue | | | | | |

### Drivers and evidence
### Quality-of-earnings signals
### Cash release opportunities (ranges, risks)
### Caveats
```

## Constraints and limitations

- Analytical support only, not accounting, treasury, or investment advice; actions on customer or supplier terms need sign-off from accountable finance and commercial owners.
- Point-in-time balances can be managed around period ends; note this whenever only year-end data is available.
- Do not recommend paying suppliers beyond agreed terms or contrary to statutory prompt-payment rules.

## Examples

Revenue 365m, COGS 255.5m. Receivables 60m → DSO 60.0 days; inventory 42m → DIO 60.0; payables 28m → DPO 40.0; CCC 80 days. One day of DSO ≈ 1.0m, one day of DIO or DPO ≈ 0.7m. If prior-year DSO was 52 days, the 8-day increase consumed about 8m of cash; ask whether a large customer moved to longer terms or invoices are disputed.
