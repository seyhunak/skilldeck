---
name: jobs-to-be-done-analysis
description: Analyze customer research with Jobs-to-be-Done. Writes solution-free job statements (functional, emotional, social), maps the job steps and desired outcomes, and charts the four forces of progress (push, pull, anxiety, habit) behind switching. Use when interviews, switch stories, reviews, or support data need to be turned into a clear statement of what customers are trying to get done and why they choose or reject a product.
---

# Jobs-to-be-Done Analysis

Jobs-to-be-Done (JTBD) treats customers as hiring a product to make progress in a specific circumstance. This skill combines two practical strands of JTBD: job statements and job maps (useful for finding unmet outcomes) and the forces-of-progress model from switch interviews (useful for understanding why people change or stay put). Use them together; keep claims tied to evidence.

## When to use

- Turning interview transcripts or switch stories into job statements and opportunities.
- Explaining why customers adopt, ignore, or churn from a product when feature requests do not.
- Reframing a feature request ("add a Gantt chart") into the progress behind it.
- Comparing competitors, including non-obvious ones such as spreadsheets, agencies, or doing nothing.

Do not use it to build demographic segments or personas as the main deliverable (personas can be built on top of jobs), or when there is no customer evidence at all — in that case, output hypotheses and a research plan instead of findings.

## Inputs

- Research material: interview transcripts or notes, switch timelines, open-ended survey answers, reviews, support or sales notes. Required.
- The product or category under study, and the customer segment. Required.
- Research question, for example "why do teams leave us in month two?". Recommended.

## Procedure

1. **Find the circumstance.** For each participant, identify the situation that triggered the search: what changed, when, and where ("a new finance lead joined and asked for weekly cash reports"). Jobs are defined by circumstance, not by demographics.
2. **Write job statements.** Use the form *verb + object + contextual clarifier*, with no solution, product, or technology in it: "Get an accurate view of weekly cash position before the Monday leadership meeting." Write the main functional job, then related emotional jobs (how they want to feel: "feel confident presenting numbers") and social jobs (how they want to be seen: "be seen as in control of finances"). Test each: would this job have existed fifty years ago in some form? If it only makes sense for one product, it is a solution in disguise.
3. **Map the job steps.** Break the main job into stages that are independent of any solution: define, locate inputs, prepare, confirm, execute, monitor, modify, conclude. Not every job uses every stage; keep the ones the evidence supports.
4. **Extract desired outcomes.** For key steps, write outcome statements in a consistent form: *direction + metric + object + clarifier*, for example "minimize the time it takes to reconcile bank transactions with ledger entries". These describe how customers measure success and are the raw material for opportunities.
5. **Chart the forces of progress.** From switch stories, list evidence for each force: **push** of the current situation (frustration with today), **pull** of the new solution (the imagined better life), **anxiety** about the new solution (will it work, migration risk, cost), and **habit** of the present (comfort, sunk cost, inertia). Switching happens when push plus pull outweigh anxiety plus habit. Weak pull with strong anxiety tells you to reduce risk, not add features.
6. **Rank opportunities.** For each outcome note how important it seems and how poorly current solutions satisfy it, based on evidence frequency and intensity. Important and poorly satisfied outcomes are opportunities. Label the ranking qualitative unless survey data rated importance and satisfaction.
7. **Identify competing solutions.** List everything customers hire for the job today, including manual workarounds and non-consumption, and what each does well.
8. **Validate and label.** Mark each job, outcome, and force as *evidenced* (with participant references) or *hypothesis*. Note contradictions and segments where the job differs.

## Expected output

```markdown
## JTBD Analysis: <segment / product>
**Circumstances observed:** ...
**Main job:** <verb + object + clarifier>
**Emotional jobs:** ... · **Social jobs:** ...

### Job map and desired outcomes
| Job step | Desired outcome statement | Evidence (participants) | Importance | Current satisfaction |

### Forces of progress
| Push | Pull | Anxiety | Habit |
| ... (with participant refs) | ... | ... | ... |

### Competing solutions
| Solution hired today | Strength | Where it fails the job |

### Opportunities (ranked)
1. <outcome> — why it is underserved — evidence strength

### Hypotheses to validate
- ...
```

## Constraints and limitations

- Never invent customer statements or attribute a job to participants who did not express it.
- Job statements must not mention your product, features, or technology.
- Qualitative frequency is not market size; do not convert counts into percentages for small samples.
- If research was not about recent past behavior (for example it asked about hypothetical futures), state that the evidence for forces is weak.

## Examples

Feature request: "Add Slack notifications for overdue invoices."
Circumstance: a small agency owner discovers late payments only when cash runs short at payroll time.
Main job: "Keep incoming cash predictable so payroll is never at risk."
Desired outcome: "Minimize the time between an invoice becoming overdue and the owner knowing about it."
Forces: push — two missed payrolls last year (P2, P5); pull — imagines chasing payments the same day; anxiety — worries automated reminders will annoy clients (P5, P7); habit — checks the bank app manually every Friday.
Implication: notifications address awareness, but the anxiety about client relationships suggests the real opportunity includes tone-controlled reminders the owner approves.
