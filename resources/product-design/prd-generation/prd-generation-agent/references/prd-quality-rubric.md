# PRD Quality Rubric

Score each criterion 0 (absent), 1 (present but weak), or 2 (meets the bar). A draft is ready for review at 16 of 20 or above with no zero on criteria 1, 3, or 6.

| # | Criterion | 2 = meets the bar | Common failure |
|---|---|---|---|
| 1 | Problem framing | Problem is stated without a solution, names who and in what situation, and states the cost of the status quo | "Users need feature X" |
| 2 | Evidence | Each signal has a source and type; strength is graded; numbers come only from inputs | Anecdotes presented as data |
| 3 | Success metric | One primary outcome metric with definition, baseline (or plan to get it), target, and window | "Launch by Q3" or "increase engagement" |
| 4 | Guardrails | At least one metric that must not degrade is named | Optimizing one number at the expense of support load or latency |
| 5 | Target users | Primary segment by situation and job; explicit non-targets | "All users" |
| 6 | Scope boundary | Non-goals list exists and covers likely reviewer assumptions; Musts alone move the primary metric | Scope negotiated during sprints |
| 7 | Requirement quality | Requirements are testable, prioritized, and every Must has acceptance criteria | Untestable adjectives such as "fast", "intuitive" |
| 8 | Altitude | Describes behavior and rules, not pixel layouts or database tables | PRD doubling as a design or tech spec |
| 9 | Risks | Value, usability, feasibility, and viability risks considered, each with a mitigation or test | Only delivery risks listed |
| 10 | Open questions | Assumptions converted to owned questions with dates; blockers marked | Assumptions silently baked into requirements |

## Red flags that override the score

- A metric target with no baseline and no plan to measure one.
- Any customer quote that cannot be traced to supplied research.
- A Must requirement that no reviewer could verify as done.
- Dependencies on another team with no named owner.

## Wording checks

- Replace "should be intuitive" with an observable criterion, for example "a first-time admin completes setup without contacting support in usability testing".
- Replace "fast" with a percentile target, for example "p95 response under 800 ms for lists up to 1,000 rows".
- Replace "support all file types" with the enumerated list and the explicit exclusions.
