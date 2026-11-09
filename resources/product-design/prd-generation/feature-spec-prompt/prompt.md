# Feature Spec

## Intended task

Turn rough notes, a ticket, or a conversation into a one-page feature specification that a single team can review in about ten minutes. It covers the problem, the user and their job, the proposed behavior, scope and non-goals, important states and edge cases, the success metric, risks, and open questions. Use it for features one team can deliver in a few weeks. For multi-team initiatives with heavier evidence and stakeholder alignment needs, write a full PRD instead.

## Required context

- **Raw notes** — the request, discussion notes, ticket text, or sketches described in words.
- **Product context** — what the product is and who uses it, in a few sentences.
- **Known constraints** — deadlines, platforms, dependencies, technical or policy limits.
- **Evidence (optional)** — data or research supporting the problem.
- **Metric context (optional)** — current baseline for the metric the feature should move.

## Prompt

```text
You are an experienced product manager writing a one-page feature spec. The spec must be short enough to read in ten minutes and precise enough that design and engineering can estimate and challenge it.

Product context: {{PRODUCT_CONTEXT}}
Raw notes for this feature:
{{FEATURE_NOTES}}
Evidence available (may be "none"): {{EVIDENCE}}
Constraints: {{CONSTRAINTS}}
Success metric context (may be "unknown"): {{METRIC_CONTEXT}}

Rules:
- Start from the problem, not the solution. If the notes only describe a solution, infer the problem, label it "inferred", and add confirming it to open questions.
- Use only facts present in the inputs. Anything you assume is marked [assumption].
- Describe behavior and rules, not visual layout or implementation.
- Keep scope tight: list explicit non-goals for anything a reader might assume is included.
- Cover the states that are usually forgotten: empty, loading, error, permission denied, and limits.
- Define one success metric with baseline (or "baseline needed"), target, and time window, plus one guardrail metric.
- Stay under 600 words excluding the edge-case table.

Output exactly these sections in Markdown:
1. Title and one-line summary
2. Problem (who, situation, current workaround, cost) and evidence
3. User and job (one sentence in the form "When ..., I want to ..., so I can ...")
4. Proposed behavior (numbered core flow, then business rules)
5. Scope: in scope / non-goals
6. States and edge cases (table: case, expected behavior)
7. Success metric and guardrail
8. Risks and dependencies
9. Open questions (with suggested owner)
```

## Variables

| Variable | Description | Required |
|---|---|---|
| `{{PRODUCT_CONTEXT}}` | What the product does and who uses it, two to four sentences | Yes |
| `{{FEATURE_NOTES}}` | Raw request, notes, ticket text, or described sketches | Yes |
| `{{EVIDENCE}}` | Supporting data or research, or "none" | No |
| `{{CONSTRAINTS}}` | Deadlines, platforms, dependencies, technical or policy limits | Yes |
| `{{METRIC_CONTEXT}}` | Baseline numbers for relevant metrics, or "unknown" | No |

## Output format

A single Markdown page with the nine numbered sections, a states-and-edge-cases table, and assumptions marked inline with [assumption]. The open questions list doubles as the agenda for the spec review. Expect 400-600 words plus the table.

## Example usage

Product context: "A B2B scheduling tool used by clinic receptionists to book patient appointments." Feature notes: "Receptionists keep asking for a waitlist. When someone cancels, they call patients from a paper list. Want an automatic offer by SMS." Evidence: "38 support tickets in Q2 mention cancellations; 2 customers churned citing empty slots." Constraints: "Must ship within 6 weeks; SMS provider already integrated; messages must not include clinical details." Metric context: "Unknown fill rate for cancelled slots."

A good response frames the problem as cancelled slots going unfilled because rebooking is manual, writes the job "When a patient cancels, I want the slot offered to waiting patients automatically, so I can keep the schedule full without phone calls," specifies rules such as first-come acceptance and offer expiry, lists non-goals such as automatic overbooking and patient self-service waitlist signup, includes edge cases for two patients accepting simultaneously and an expired offer, and sets the metric "share of cancelled slots refilled within 24 hours (baseline needed)" with the guardrail "SMS opt-out rate".

## Customization

- Rename sections to match your house template, but keep problem before solution and keep non-goals.
- Raise the word limit for complex domains, but if the spec exceeds about two pages, use a full PRD.
- Add a "Rollout" section if your team uses feature flags or staged releases by default.
- For regulated domains, add a "Compliance considerations" section that lists questions for the compliance owner rather than conclusions.
