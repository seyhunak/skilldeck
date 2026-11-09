# Investment Memo

## Intended task

Structure analysis you already have into an investment committee memo: thesis, business and market context, financial profile, valuation summary, key risks with mitigants, diligence gaps, and the decision being requested. It suits private equity, venture, corporate development, or credit fund committees. The memo organizes and challenges the supplied material; it is not investment advice, it does not recommend that anyone buy or sell a security, and every factual claim must trace to the inputs.

## Required context

- **Opportunity description**: target, instrument (equity, debt, minority, buyout), size, and terms.
- **Diligence material**: business overview, market notes, customer data, management assessment, financial history and projections.
- **Valuation work**: DCF, multiples, or returns analysis already done (see `dcf-valuation`), with key assumptions.
- **Committee format**: required sections, length, decision type (approval to proceed, final approval), and return hurdles.

## Prompt

```text
You are an experienced investment professional drafting a memo for {{COMMITTEE_NAME}}. Your job is to present the opportunity fairly and rigorously so the committee can decide. You are not giving investment advice and must not state that the investment should be made; present the case for and against and the decision requested.

Opportunity: {{OPPORTUNITY_SUMMARY}}
Decision requested: {{DECISION_REQUESTED}}
Investment criteria and hurdles: {{INVESTMENT_CRITERIA}}

Source material (treat as the only factual basis):
{{SOURCE_MATERIAL}}

Valuation and returns analysis:
{{VALUATION_SUMMARY}}

Instructions:
- Cite the source document or section for every material fact in square brackets.
- Where information is missing, write "Not provided — diligence gap" and list it in the gaps section.
- State the investment thesis as three to five falsifiable statements, each with the evidence for it and what would prove it wrong.
- Include a bear case with at least as much specificity as the base case.
- Show valuation sensitivity to the two assumptions that matter most.
- Rank risks by likelihood and impact, with mitigants and residual risk.
- Do not use promotional language or unsupported superlatives.
- Keep the memo within {{LENGTH_LIMIT}}.
- End with: "Analytical draft for committee deliberation. Not investment, legal, or tax advice; the decision rests with the authorized committee."

Output format (Markdown): 1. Decision requested and summary; 2. Investment thesis; 3. Business and market; 4. Financial profile; 5. Valuation and returns; 6. Base, bull, and bear cases; 7. Key risks and mitigants; 8. Diligence gaps and conditions; 9. Questions for the committee.
```

## Variables

| Variable | Description | Required |
|---|---|---|
| `{{COMMITTEE_NAME}}` | The decision body, for example "Investment Committee" | Yes |
| `{{OPPORTUNITY_SUMMARY}}` | Target, instrument, size, terms | Yes |
| `{{DECISION_REQUESTED}}` | For example "approval to enter exclusivity and spend diligence budget" | Yes |
| `{{INVESTMENT_CRITERIA}}` | Fund mandate, hurdle IRR or MOIC, concentration limits | Yes |
| `{{SOURCE_MATERIAL}}` | Diligence notes, data room extracts, management materials | Yes |
| `{{VALUATION_SUMMARY}}` | Valuation outputs and key assumptions | Yes |
| `{{LENGTH_LIMIT}}` | Page or word limit | Yes |

## Output format

A nine-section Markdown memo as listed in the prompt, with tables for financial profile, valuation sensitivity, and the risk register (risk, likelihood, impact, mitigant, residual). Every material fact carries a bracketed source. The diligence gaps section is a numbered list with an owner placeholder for each gap.

## Example usage

A growth equity team pastes a summary of a B2B software company (ARR, net revenue retention, gross margin, customer concentration notes), a returns model showing base-case MOIC, and the fund's criteria. They request "approval to proceed to confirmatory diligence". A good response frames the thesis as testable claims (for example "net revenue retention above 110% is durable because expansion is driven by seat growth in existing accounts [Cohort analysis, tab 3]"), sets out a bear case where the largest customer churns, shows MOIC sensitivity to exit multiple and growth, and lists missing items such as "no churn data by cohort before 2024 — diligence gap".

## Customization

Adapt section order and names to your committee's template, add mandate-specific sections (ESG screening, portfolio fit), and set the length. For credit committees, swap valuation for debt capacity and recovery analysis. Keep the citation requirement, the bear case, and the closing disclaimer; committee decisions, regulatory obligations, and any public communication about an investment require qualified human review.
