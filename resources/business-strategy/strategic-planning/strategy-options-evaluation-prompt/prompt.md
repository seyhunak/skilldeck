# Strategy Options Evaluation

## Intended task
Compare two to six defined strategic options — for example entering a new market, building versus acquiring a capability, or choosing between product bets — using a weighted multi-criteria evaluation. Use it after options have been generated and before a decision memo is written. The prompt forces criteria and weights to be explicit, screens out options that fail must-have requirements, scores each option with stated evidence, and tests whether the result survives reasonable changes in weights. It complements, rather than replaces, financial analysis such as NPV.

## Required context
- **The decision** and the objective it serves.
- **The options**, each described in a few sentences with any cost, timing, and risk information available.
- **Criteria and weights**, if leadership has agreed them; otherwise the prompt proposes criteria for confirmation.
- **Must-have constraints** (budget ceilings, regulatory requirements, timing limits).
- **Evidence** — data, analyses, or expert views relevant to each option.

## Prompt
```text
You are a strategy analyst facilitating a structured comparison of options for this decision:
{{DECISION}}

Objective the decision must serve: {{OBJECTIVE}}

Options:
{{OPTIONS}}

Criteria and weights (if empty, propose 4-6 criteria with weights summing to 100 and mark them PROPOSED for confirmation):
{{CRITERIA_AND_WEIGHTS}}

Must-have constraints (options failing any of these are screened out before scoring):
{{CONSTRAINTS}}

Evidence and notes:
{{EVIDENCE}}

Instructions:
1. Restate the decision, objective, and each option in one line each. Flag any option that is really a variant of another, or that is not described well enough to score.
2. Screen each option against the must-have constraints. Report pass, fail, or unknown with a reason. Do not score failed options; keep unknowns with a warning.
3. Define a 1-5 scoring scale for each criterion with concrete anchors (what a 1, 3, and 5 look like). Use the same direction for all criteria (5 = best), including cost and risk.
4. Score every remaining option on every criterion. For each score give a one-line justification and an evidence tag: E (evidence supplied), A (assumption), or J (judgement). Never invent data; if information is missing, score with A and say what would confirm it.
5. Compute weighted totals (sum of weight x score / 100) and rank the options.
6. Run sensitivity: (a) change each criterion weight by plus and minus 10 points, redistributing proportionally, and report whether the top option changes; (b) report the smallest score change on a single criterion that would flip first and second place.
7. Identify the two or three assumptions the ranking depends on most, and what evidence would test them.
8. Note important considerations the criteria do not capture (for example reversibility, option value, organisational capacity).
9. Conclude with a recommendation framed as "Based on these criteria and weights, Option X ranks first; the ranking is robust/fragile because ...". Do not present the recommendation as a decision.
```

## Variables
| Variable | Description | Required |
|---|---|---|
| `{{DECISION}}` | The choice being made, with timeframe | Yes |
| `{{OBJECTIVE}}` | The goal the decision serves | Yes |
| `{{OPTIONS}}` | List of options with short descriptions | Yes |
| `{{CRITERIA_AND_WEIGHTS}}` | Agreed criteria and weights, or empty to propose | No |
| `{{CONSTRAINTS}}` | Must-have requirements used as knock-out screens | No |
| `{{EVIDENCE}}` | Data, analyses, and notes for scoring | Yes |

## Output format
```markdown
## Options evaluation: <decision>
### Options and screening
| Option | Summary | Screen result | Reason |
### Scoring scales
| Criterion | Weight | 1 = | 3 = | 5 = |
### Scoring matrix
| Criterion (weight) | Option A | Option B | Option C |
Each cell: score, tag (E/A/J), one-line justification.
| **Weighted total** | | | |
### Sensitivity
### Critical assumptions and how to test them
### Considerations outside the criteria
### Recommendation (for decision-makers)
```

## Example usage
For a mid-sized software company deciding how to enter the Japanese market, `{{OPTIONS}}` lists "direct subsidiary", "reseller partnership", and "acquire a local integrator"; criteria include time to first revenue (25), investment required (20), control of customer relationship (20), execution risk (20), and strategic learning (15); the constraint is "maximum 4m investment in year one". A good response screens out the acquisition as "unknown" on budget because no valuation is given, scores the other two, finds the reseller route ranks first by 0.4 points, and shows that raising the weight of customer-relationship control by 10 points flips the result — making that weight the real debate.

## Customization
- Replace the 1-5 scale with 1-10 for finer distinctions, keeping anchors.
- Add a column for NPV from a separate business case as a criterion or as a tie-breaker.
- For group workshops, run the prompt per participant's weights and compare rankings.
- Keep the evidence tags; they are what make the matrix trustworthy.
