# Credit Application Review Routine

## Objective

Move a commercial credit application from receipt to a committee-ready recommendation package in a consistent, documented way: complete information, verified identity and ownership, analyzed repayment capacity, tested structure and covenants, and a clear record of who reviewed what. The routine guides a credit analyst and approver; an AI assistant may draft analyses, but the credit decision is always made by authorized people under the institution's credit policy.

## Trigger

Run when a new commercial loan, limit increase, renewal, or material amendment request is received, or when a trade-credit limit above the self-approval level is requested. Also run on a triggered review after a covenant breach or rating downgrade. This routine is human-supervised guidance; it does not run automatically.

## Prerequisites

- The institution's credit policy: risk appetite, sector limits, rating scale, approval authorities, required documents, and pricing framework.
- Access to the application, financial information, and internal exposure systems.
- Completed or in-progress KYC for the applicant and related parties.
- Confirmation that the analyst has no conflict of interest with the applicant.

## Inputs

- Application form with requested amount, facility type, tenor, purpose, repayment source, and proposed security.
- Three years of financial statements, latest management accounts, and projections where available.
- Existing debt schedule, bank statements, and AR/AP ageing.
- Collateral documents and valuations; guarantor information.
- Internal data: existing exposure, payment history, prior reviews.

## Steps

1. **Intake and completeness check.** Compare received documents to the policy checklist. Send one consolidated information request rather than piecemeal follow-ups. Log the application date and the date the file became complete.
2. **Policy pre-screen.** Check sector, geography, size, purpose, and product against risk appetite and hard limits. If the request falls outside policy, decide early whether to stop or seek an exception route.
3. **KYC and ownership confirmation.** Confirm customer due diligence is complete and current using the `kyc-document-review` skill as a checklist. Outstanding critical KYC gaps block progress to approval.
4. **Financial spreading and analysis.** Spread statements in the institution's template. Compute ratios with the `financial-ratio-analysis` skill and normalize EBITDA with a documented bridge.
5. **Repayment capacity and stress.** Calculate DSCR, leverage, and interest cover on a pro forma basis including the new facility; run downside scenarios. The `credit-risk-analysis-agent` can draft this section and the 5 Cs assessment for the analyst to review.
6. **Structure, security, and covenants.** Match tenor and amortization to the asset or purpose funded. Assess collateral coverage with policy haircuts. Design or test covenants and headroom with the `loan-covenant-analysis` skill.
7. **Rating and pricing.** Assign the internal rating using the approved methodology and compute risk-adjusted pricing per policy. Record the drivers of the rating.
8. **Memo and recommendation.** Assemble the credit memo: request, borrower, analysis, risks and mitigants, rating, conditions, exceptions, and the analyst's recommendation.
9. **Independent review and approval.** Route to the approver or committee with the correct authority level. Record questions, conditions added, and the decision with date and approvers.
10. **Post-decision.** Communicate the decision through approved channels, document conditions precedent, and set monitoring: covenant test dates, review date, and early-warning indicators.

## Decision points

- If mandatory documents remain missing after the information request deadline, pause the application and inform the relationship owner; do not analyze on incomplete data.
- If the request breaches a hard policy limit, stop unless an approved exception process exists; exceptions must be explicitly labelled and approved at the required authority level.
- If pro forma DSCR falls below the policy minimum in the base case, restructure (amount, tenor, amortization, security) or recommend decline; never adjust assumptions solely to pass the test.
- If key figures conflict between sources, use the more conservative figure and record the conflict.
- If the analyst's recommendation differs from the relationship manager's view, document both positions for the approver.

## Expected output

- A complete credit file with checklist status and dated information requests.
- Financial spread, ratio analysis, and stress results.
- Credit memo with rating, structure, conditions, and recommendation.
- Decision record showing approvers, authority level, conditions, and exceptions.
- Monitoring plan with dates and triggers.

## Validation checklist

- [ ] All policy-required documents are on file or formally waived by the right authority.
- [ ] KYC is complete and current for the borrower, guarantors, and beneficial owners.
- [ ] EBITDA adjustments and stress assumptions are documented and reviewed.
- [ ] The rating follows the approved methodology and its drivers are recorded.
- [ ] Policy exceptions are listed explicitly with approval evidence.
- [ ] The approver had the correct authority for the exposure size and rating.
- [ ] Monitoring dates and covenant tests are scheduled.

## Human approval

Approving, declining, pricing, or granting policy exceptions on credit are decisions for authorized credit officers or committees only. AI-prepared spreads and memo drafts are analytical support, not credit, investment, or legal advice, and must be checked by the analyst before submission. Security documents and guarantees need legal review. Decisions about individuals connected to the applicant must comply with fair lending and data protection requirements, and adverse decisions must be communicated through the institution's approved process.
