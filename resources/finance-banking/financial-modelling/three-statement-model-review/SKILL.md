---
name: three-statement-model-review
description: Reviews the integrity of an integrated financial model (income statement, balance sheet, cash flow) - balance checks, cash and retained earnings roll-forwards, debt and interest circularity, hard-codes, sign errors, and formula consistency - and returns a severity-ranked findings log. Use before a model is relied on for lending, valuation, or budgeting decisions.
---

# Three-Statement Model Review

Spreadsheet models fail quietly: a hard-coded number in a forecast column, a sign flip in working capital, or a circular interest calculation that was "fixed" with a plug. This skill applies a model-audit checklist so integrity issues are found before anyone relies on the outputs. It reviews mechanics and logic, not whether the business assumptions are right.

## When to use

- A model (Excel, Google Sheets, or an export) is about to support a credit decision, valuation, budget, or board paper.
- A model was inherited or heavily edited and nobody is sure it still balances.
- A lender or investor asks for a model review summary.

Not appropriate for: judging whether growth or margin assumptions are reasonable (that is commercial due diligence; use `dcf-valuation` or `financial-statement-analysis-agent` for context), or reviewing non-financial spreadsheets.

## Inputs

- The model file or a faithful export showing formulas, not just values. Values-only exports limit the review to output-level tests; say so.
- Description of the model's purpose, timeline (monthly, quarterly, annual), and key outputs.
- Optional: historical actuals the model should reproduce, and the model owner's list of known issues.

## Procedure

1. **Map the structure.** Identify input, calculation, and output areas; timeline consistency across sheets; units and sign conventions; and named ranges. Note good-practice deviations (inputs scattered in calculation sheets, inconsistent column timelines) as structural findings.
2. **Run the integrity checks:**
   - Balance sheet balances every period (assets − liabilities − equity = 0) without a plug line.
   - Cash on the balance sheet equals closing cash on the cash flow statement every period.
   - Retained earnings roll forward: opening + net income − dividends ± other = closing.
   - Every balance sheet movement appears on the cash flow statement: Δ receivables, inventory, payables, other working capital, PP&E (capex − depreciation − disposals), intangibles, debt draws and repayments, equity issuance. Signs: increase in an asset = cash outflow.
   - Fixed asset and debt schedules roll forward (opening + additions − reductions = closing) and link to the statements.
   - Historical periods tie to reported actuals.
3. **Test the financing logic.** Check interest calculations (average versus opening balance), whether circularity is intentional and controlled by a switch, revolver logic (draws only when cash falls below minimum, repaid when surplus), and minimum cash. Look for iterative-calculation settings that hide errors.
4. **Scan formulas.** Look for hard-coded numbers inside formulas or forecast cells, inconsistent formulas across a row, references to the wrong period (off-by-one columns), external links, error values (#REF!, #DIV/0!), hidden rows or sheets with live logic, and mixed units (thousands versus units).
5. **Stress the mechanics.** Change a key input (for example revenue growth to zero, then to a high value) and confirm outputs move in the expected direction and the balance check still holds. Set an extreme case that forces the revolver to draw and confirm it works.
6. **Classify findings.** Severity: critical (outputs wrong or balance broken), high (likely to cause wrong outputs under plausible inputs), medium (fragile or hard to audit), low (presentation). Give the cell or range reference for each.
7. **Summarize** with an overall integrity verdict limited to mechanics, and a list of fixes in priority order for the model owner.

## Expected output

```markdown
## Model Review: <file name> (<version/date>)
Scope: <sheets reviewed, formulas visible?> · Purpose: <>

### Integrity check results
| Check | Result (pass/fail/not testable) | Periods affected | Reference |

### Findings log
| # | Severity | Sheet!Range | Issue | Effect | Suggested fix |

### Stress test results
### Overall verdict (mechanics only) and caveats
```

## Constraints and limitations

- Analytical support only, not audit, accounting, or investment advice; a formal model audit or decision reliance needs sign-off by qualified professionals.
- Do not edit the user's model unless asked; propose fixes as a list. If editing is requested, work on a copy.
- A "pass" means the tested mechanics hold for tested inputs; it does not validate commercial assumptions or untested scenarios.
- Stop and ask if formulas are not visible, the timeline is ambiguous, or units are unclear.

## Examples

Finding: "Sheet CF!F24:P24 — change in receivables uses closing receivables rather than the movement, so cash is understated by the full AR balance each forecast period; balance check passes only because BS!F58 contains a plug ('Other liabilities' = balancing figure). Severity: critical. Fix: CF!F24 = −(BS!F12 − BS!E12) copied across; remove the plug and re-run the balance check."
