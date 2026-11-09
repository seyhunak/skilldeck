# Financial Results Commentary

## Intended task

Turn a table of financial results and the drivers your finance team has already validated into management commentary: a headline, line-by-line explanations of material movements, and an outlook paragraph. Use it for monthly management packs, quarterly business reviews, or board finance sections. The prompt writes from numbers and explanations you supply; it does not perform variance analysis (use `budget-variance-analysis-agent` first if drivers are not yet known) and it does not invent reasons for movements.

## Required context

- **Results table**: actual versus comparator (budget, forecast, prior year) for the lines to be discussed, with amounts and percentages, units, and currency.
- **Validated drivers**: the explanation for each material movement, ideally with amounts (for example "price increase +1.2m, volume −0.4m").
- **Audience and length**: executive team, board, lenders, or internal department heads, and a word limit.
- **Materiality threshold** so only meaningful movements get commentary.
- **Outlook facts** (forecast changes, known upcoming events) if the commentary should look forward.

## Prompt

```text
You are a senior FP&A writer preparing results commentary for {{AUDIENCE}}. Write only from the data and drivers provided. Do not invent causes, figures, or forward-looking statements. If a material movement has no driver supplied, write "[driver to be confirmed]" rather than guessing.

Period and basis: {{PERIOD}} compared with {{COMPARATOR}}; currency and unit: {{CURRENCY_UNIT}}.
Materiality: comment on movements above {{MATERIALITY_THRESHOLD}}; group smaller movements into one sentence if relevant.

Results table:
{{RESULTS_TABLE}}

Validated drivers and context:
{{DRIVERS}}

Outlook information (may be empty):
{{OUTLOOK_NOTES}}

Requirements:
- Open with a headline of no more than two sentences covering revenue, profitability, and cash if provided.
- For each material line, follow: what moved (amount and %, favourable/adverse), why (driver with quantification), whether it is timing, one-off, or run-rate, and any action or decision required.
- Use consistent sign language: "favourable/adverse" or "above/below", never both.
- Avoid filler such as "driven by various factors" or "due to higher costs".
- Every number in the commentary must appear in, or be directly computable from, the inputs. Show any computed figure's basis in brackets.
- Keep to {{WORD_LIMIT}} words.
- End with a short list titled "Items to confirm before distribution" listing every placeholder and any figure you computed.
- Add the line: "Draft for finance review; not investment or accounting advice."

Output format: Markdown with sections Headline, Commentary by line, Outlook, Items to confirm before distribution.
```

## Variables

| Variable | Description | Required |
|---|---|---|
| `{{AUDIENCE}}` | Who reads it (for example executive committee, board, lender) | Yes |
| `{{PERIOD}}` | Reporting period, for example "October and YTD FY26" | Yes |
| `{{COMPARATOR}}` | Budget, latest forecast, or prior year | Yes |
| `{{CURRENCY_UNIT}}` | Currency and unit, for example "EUR thousands" | Yes |
| `{{MATERIALITY_THRESHOLD}}` | Threshold for commentary, for example "±5% and ±100k" | Yes |
| `{{RESULTS_TABLE}}` | Pasted table of actuals, comparator, variance | Yes |
| `{{DRIVERS}}` | Validated explanations with amounts | Yes |
| `{{OUTLOOK_NOTES}}` | Forecast changes and known events; may be blank | No |
| `{{WORD_LIMIT}}` | Maximum length | Yes |

## Output format

Markdown with four sections: a two-sentence headline; commentary paragraphs or bullets per material line in the order of the results table; an outlook paragraph only if outlook notes were supplied; and a checklist of items to confirm. Numbers carry units and favourable/adverse labels.

## Example usage

Inputs: audience "executive committee"; period "Q3 FY26"; comparator "budget"; EUR thousands; materiality "±5% and ±150k"; results showing revenue 12,400 vs 12,900 budget, gross margin 41.0% vs 39.5%, opex 3,950 vs 3,700; drivers "Volume −780 (delayed contract start, now signed for Q4); price +280 (list increase from July); opex overspend: 180 recruitment fees (one-off), 70 cloud costs (run-rate)".

A good response opens: "Q3 revenue of 12.4m was 0.5m (3.9%) below budget as a delayed contract start outweighed July price increases; gross margin improved 1.5 points on pricing." Revenue falls below the 5% threshold but above the 150k absolute threshold, so it gets commentary. Opex commentary separates the one-off recruitment fees from run-rate cloud costs and states the run-rate effect is about 70k per quarter (computed, shown in brackets).

## Customization

Change the materiality rule, word limit, and audience freely. Add sections (cash flow, KPIs, segment) by extending the results table and requirements. Keep the instructions forbidding invented drivers and requiring the confirmation list: commentary often goes to boards and lenders, and published or price-sensitive commentary must be approved by qualified finance and, for listed companies, disclosure reviewers before release.
