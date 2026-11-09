# Insight Narrative

## Intended task
Use this after the analysis is done and the numbers are trusted, when you need to communicate them: a write-up for a product review, the summary paragraph above a dashboard, a message to a leadership channel, or the findings section of an experiment readout. The model drafts a narrative that opens with the answer, supports it with the two or three numbers that matter, distinguishes what the data shows from what it suggests, and ends with caveats and a recommended next step. It does not perform the analysis or validate the numbers; to find out why a metric moved, use `metric-anomaly-investigation-agent`, and to check whether a difference is statistically meaningful, use `statistical-significance-testing` first.

## Required context
- **Results**: tables, query output, or summary statistics, with units and time windows. Include comparison baselines (prior period, control group, target).
- **Question and decision**: what was asked and what the reader must decide. A narrative without a decision becomes a tour of the data.
- **Method notes**: how the data was produced (experiment, observational comparison, survey), sample sizes, and any significance or confidence intervals already computed. These govern how strong the language can be.
- **Audience and format**: executive summary, team doc, or chat message, plus length limit.

## Prompt
```text
You are a senior analyst writing up finished results for a decision-maker. Your job is communication, not new analysis. Every number you state must come from the results below, either directly or by simple arithmetic you show. If a figure the story needs is missing, say it is missing; do not estimate it.

QUESTION THAT WAS ASKED AND DECISION IT INFORMS:
{{QUESTION_AND_DECISION}}

AUDIENCE AND FORMAT (including length limit):
{{AUDIENCE_AND_FORMAT}}

RESULTS (tables, outputs, summary statistics, with units and time windows):
{{RESULTS}}

METHOD NOTES (data source, design, sample sizes, significance or intervals, known data issues):
{{METHOD_NOTES}}

Writing rules:
1. Lead with the answer to the question in one or two sentences, including the single most important number with its comparison (versus prior period, control, or target). Use the bottom-line-up-front pattern; no background before the answer.
2. Support it with at most three findings, each stated as a claim followed by the evidence ("Mobile drove most of the decline: mobile sessions fell 18% while desktop was flat"). Prefer absolute and relative changes together when both matter ("from 4.1% to 3.6%, a 0.5-point drop").
3. Match causal language to the method. Randomized experiments may say "caused" within their scope. Observational comparisons must use "associated with", "coincided with", or "is consistent with", and should name the most plausible alternative explanation.
4. Do not report differences the method notes describe as not statistically significant or within noise as if they were real; say they are inconclusive.
5. Include a short caveats section: data quality issues, segments excluded, small samples, and anything that would change the conclusion if wrong.
6. End with a recommendation or next step tied to the decision, and label it as the analyst's recommendation, distinct from findings.
7. Suggest one chart that would best support the lead finding, naming chart type, x and y, and what to highlight.
8. Plain language: define any metric the audience may not know in a clause, avoid jargon, round sensibly, and keep units consistent.
```

## Variables
| Variable | Description | Required |
|---|---|---|
| `{{QUESTION_AND_DECISION}}` | The question asked and the decision the reader faces | Yes |
| `{{AUDIENCE_AND_FORMAT}}` | Reader role, medium, tone, and length limit | Yes |
| `{{RESULTS}}` | The numeric results with units, windows, and baselines | Yes |
| `{{METHOD_NOTES}}` | Study design, sample sizes, significance, data caveats | Yes |

## Output format
- **Headline**: one or two sentences with the answer and key number.
- **What we found**: up to three claim-then-evidence bullets.
- **Caveats**: bullets.
- **Recommendation**: one short paragraph, labeled as recommendation.
- **Suggested chart**: chart type, axes, highlight.
- **Number trace**: a short list mapping each number used to the row or cell in the results it came from, for reviewer verification; omit from the final published version if not needed.

## Example usage
Results: trial-to-paid conversion fell from 12.4% to 10.9% month over month; a breakdown shows trials started from a new paid-social campaign converted at 6.2% versus 12.1% for all other sources; the campaign made up 20% of trials (0.20 x 6.2% + 0.80 x 12.1% reconciles to 10.9%). Method notes: observational, roughly 3,000 trials per month. A good narrative headlines "Conversion fell 1.5 points to 10.9%, and the drop is concentrated in trials from the new paid-social campaign," shows that non-campaign conversion was close to last month, uses "coincided with" rather than "caused," names seasonality as an alternative explanation, and recommends reviewing campaign targeting before cutting spend. The number trace lists each figure's source row.

## Customization
- For chat channels, cap the output at the headline plus two bullets and the recommendation.
- For experiment readouts, add required fields for the primary metric's effect size with interval and guardrail metrics.
- If your organization has a writing standard (for example a fixed memo structure), describe it in the audience variable; the rules above still apply.
- Keep the number trace in drafts even if you remove it before publishing; it is the fastest way for a reviewer to catch a transposed figure.
