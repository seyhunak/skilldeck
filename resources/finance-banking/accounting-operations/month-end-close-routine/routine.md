# Month-End Close Routine

## Objective

Produce an accurate, reviewed set of monthly financial statements on a predictable timetable, with every balance sheet account reconciled, every manual journal supported and approved, material variances explained, and a documented sign-off trail. The routine organizes a human-led close; an AI assistant can prepare checklists, reconciliations, analyses, and commentary drafts, but people post entries and sign off.

## Trigger

Run at each month end, starting on the last business day of the month (day 0) and finishing on the close deadline the controller sets (commonly business day 3 to 8, depending on size and complexity). Also run a lighter version after a system migration or acquisition, when prior close patterns no longer hold. This is guidance for a supervised team, not an automated job.

## Prerequisites

- An agreed close calendar with task owners, reviewers, and day-level deadlines.
- Sub-ledgers (AR, AP, fixed assets, payroll, inventory) with defined cut-off times.
- Access to bank statements, the general ledger, and the reconciliation workspace.
- A materiality policy for reconciliations, accruals, and variance commentary.
- Segregation of duties: preparers and approvers are different people for journals and reconciliations.

## Inputs

- Trial balance and sub-ledger reports at period end.
- Bank and card statements, payment service provider settlement reports.
- Open purchase orders, goods received not invoiced, contract schedules for accruals and prepayments.
- Payroll reports, fixed asset additions and disposals, inventory counts or valuations.
- Prior month's close checklist, open reconciling items, and audit or review points.
- Budget and forecast for variance review.

## Steps

1. **Pre-close (day −3 to 0).** Confirm the calendar, owners, and cut-off reminders. Clear known issues from last month's open-items list. Run preliminary sub-ledger reports to spot unusual items early.
2. **Cut-off and sub-ledger close (day 0 to 1).** Ensure all sales invoices for delivered goods and services are raised, goods received are matched, and payroll is posted. Close AR, AP, inventory, and fixed asset sub-ledgers in the agreed order and lock the period for sub-ledger postings.
3. **Cash and bank (day 1).** Reconcile every bank account to the statement; age and clear reconciling items. The `financial-reconciliation-agent` can prepare draft workpapers; the preparer reviews them.
4. **Accruals, prepayments, and provisions (day 1 to 2).** Book accruals for goods and services received but not invoiced, release prepayments, update provisions (bad debt, inventory obsolescence, warranty, bonuses), and post depreciation and amortization. Each manual journal needs a description, calculation, support, and independent approval.
5. **Intercompany and consolidation (day 2 to 3).** Agree intercompany balances between counterparties, resolve differences, revalue foreign currency balances at the closing rate, and post eliminations.
6. **Balance sheet reconciliations (day 2 to 4).** Reconcile every balance sheet account above the threshold to supporting evidence: sub-ledgers, schedules, third-party confirmations. Record preparer, reviewer, date, and unreconciled items with ages.
7. **Journal entry review (day 3 to 4).** Review the month's manual and post-close journals using the `journal-entry-review` skill criteria; obtain support for selected entries before sign-off.
8. **Flux and variance analysis (day 3 to 5).** Compare the P&L and balance sheet to prior month, prior year, and budget. Investigate movements above threshold; distinguish errors from genuine performance. The `budget-variance-analysis-agent` can draft driver analysis for review.
9. **Reporting pack and commentary (day 4 to 6).** Produce statements, KPIs, and commentary. The `financial-results-commentary-prompt` can draft narrative from validated drivers.
10. **Review and sign-off (deadline day).** Controller reviews reconciliations, significant journals, and variance explanations; the finance lead approves the pack. Lock the period in the general ledger.
11. **Retrospective (within a week).** Record late tasks, recurring adjustments, and audit points; update the calendar and automate repeat manual steps where possible.

## Decision points

- If a bank reconciliation has unexplained differences above threshold at day 2, escalate to the controller before continuing with dependent steps; do not post plugs.
- If a late invoice or event arrives after cut-off, decide with the controller whether it is material enough to adjust in this period or to disclose and adjust next period, and document the rationale.
- If an accrual estimate is judgemental and material, require reviewer approval of the method, not just the amount.
- If flux analysis reveals an error, correct it before sign-off; if it relates to a prior period, consult the controller on correction or restatement treatment.
- If the close will miss the deadline, inform stakeholders with the cause and revised date rather than shortcutting reviews.

## Expected output

- Signed-off monthly financial statements and management reporting pack.
- Completed close checklist with owners, completion times, and reviewer sign-offs.
- Reconciliation set with aged reconciling items and action owners.
- Manual journal log with support and approvals.
- Variance commentary and a retrospective note with improvement actions.

## Validation checklist

- [ ] Trial balance balances and sub-ledgers agree to their GL control accounts.
- [ ] Every bank account and balance sheet account above threshold is reconciled, reviewed, and dated.
- [ ] All manual journals have support, a description, and approval by someone other than the preparer.
- [ ] Intercompany balances agree and eliminations are posted.
- [ ] Variances above threshold have evidence-based explanations.
- [ ] The period is locked after sign-off and the retrospective is recorded.

## Human approval

Posting journals, approving reconciliations, judging estimates and provisions, deciding cut-off treatment, and signing off the statements are human responsibilities of qualified, authorized finance staff. AI-prepared workpapers and drafts are analytical support only, not accounting, audit, or tax advice, and must be reviewed before use. Prior-period corrections and any externally reported figures require controller or CFO approval, and where relevant, auditor consultation.
