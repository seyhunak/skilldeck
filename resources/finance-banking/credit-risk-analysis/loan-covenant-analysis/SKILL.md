---
name: loan-covenant-analysis
description: Extracts financial covenants and their contractual definitions from a loan agreement or term sheet, recomputes compliance from financials, measures headroom and break points, and flags definition risks (EBITDA add-backs, equity cures, baskets, test dates). Use for covenant compliance checks, headroom monitoring, or covenant design review.
---

# Loan Covenant Analysis

Covenant compliance is decided by the definitions in the agreement, not by textbook ratios. This skill makes those definitions explicit, recomputes each test on the agreement's own terms, and shows how far performance can fall before a breach.

## When to use

- Preparing or checking a quarterly compliance certificate.
- Monitoring headroom on a borrower or on your own company's facilities.
- Reviewing a term sheet or draft agreement for covenant design weaknesses.
- Feeding covenant tests into a credit memo or cash forecast.

Not appropriate for: general ratio analysis without an agreement (use `financial-ratio-analysis`), or legal interpretation of disputed clauses, which needs counsel.

## Inputs

- The facility agreement or term sheet sections: definitions, financial covenants, testing dates and periods, equity cure, reporting, events of default. Required.
- Financial statements or management accounts for the relevant test periods (often last twelve months). Required.
- Compliance certificates from prior periods, if any. Optional.
- Forecast for forward headroom testing. Optional.

## Procedure

1. **Extract the covenant set.** For each covenant record: name, formula as defined, threshold (and step-downs over time), test frequency and date, measurement period (LTM, quarterly, point-in-time), and clause reference. Common types: maximum leverage (total or senior net debt / EBITDA), minimum interest cover, minimum debt service or fixed charge cover, minimum liquidity or net worth, maximum capex.
2. **Map defined terms.** Trace "Consolidated EBITDA", "Total Net Debt", "Finance Charges" and similar to their definitions. List permitted add-backs (restructuring costs, synergies, non-cash items), caps on them, pro forma adjustments for acquisitions, treatment of leases, and cash netting limits. Note "frozen GAAP" clauses that fix accounting standards at signing.
3. **Recompute compliance.** Build each figure from the financials following the definitions exactly, showing every add-back separately. Compare with the threshold and with any certificate submitted.
4. **Measure headroom.** Headroom % for a maximum covenant = (threshold − actual) / threshold; for a minimum covenant = (actual − threshold) / threshold. Also compute EBITDA cushion: the percentage fall in EBITDA that would cause a breach holding debt constant (for leverage: 1 − actual leverage / maximum leverage). A cushion under about 15-20% is often treated as tight; this is a heuristic, not a rule.
5. **Project forward.** Apply forecasts to upcoming test dates, including threshold step-downs and scheduled amortization. Identify the first date with insufficient headroom.
6. **Assess definition risk.** Flag uncapped add-backs, generous pro forma synergies, unlimited cash netting, equity cure terms (number of cures, whether cure amounts count as EBITDA or reduce debt), springing covenants that only test when a facility is drawn above a percentage, and cross-default triggers.
7. **Report.** Summarize compliance status, headroom, break points, and the questions to raise with the lender or counsel.

## Expected output

```markdown
## Covenant Analysis: <borrower> — <facility>, test date <date>
| Covenant | Definition (clause) | Threshold | Actual | Headroom % | EBITDA cushion | Status |

### Definition walk
Reported EBITDA → each permitted add-back (cap, clause) → Covenant EBITDA
Reported debt → inclusions/exclusions → Covenant Net Debt

### Forward test dates
| Date | Threshold | Projected | Headroom | Comment |

### Definition risks and cure mechanics
### Questions for lender/counsel
```

## Constraints and limitations

- Analytical support only, not legal, credit, or accounting advice. Compliance certificates, waiver requests, and interpretations of disputed definitions need sign-off by qualified finance staff and legal counsel.
- Where the agreement is ambiguous, show both readings and their results; do not choose silently.
- Never alter submitted certificates; report differences.
- Stop and ask if definitions sections are missing, because ratios computed without them may not reflect the contract.

## Examples

Agreement: maximum total net leverage 3.50x stepping to 3.25x from Q2 next year; Covenant EBITDA allows restructuring add-backs capped at 10% of EBITDA. LTM reported EBITDA 20.0m plus 3.0m restructuring add-back, capped at 2.0m → Covenant EBITDA 22.0m. Net debt 70.0m → leverage 3.18x. Headroom = (3.50 − 3.18)/3.50 = 9.1%; EBITDA cushion = 1 − 3.18/3.50 = 9.1%. At the 3.25x step-down with unchanged figures headroom falls to about 2%; flag as tight and list the cure options in the agreement.
