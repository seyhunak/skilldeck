# Technical Design Doc

## Intended task
Use this prompt to produce the first reviewable draft of a technical design document (also called an RFC or design spec) for a feature, migration or new service. A design doc's job is to expose disagreement and risk before implementation, so the prompt insists on explicit non-goals, at least two real alternatives, a trade-off table, a rollout and rollback plan, and visible open questions. The output is a draft for the author to correct, not a decision. Once the design is chosen, record the decision itself with the `architecture-decision-records` skill; for a critical evaluation of an existing architecture use `architecture-review-agent`.

## Required context
- **Problem statement**: what is wrong or missing today, who is affected, and evidence (tickets, metrics, incidents).
- **Constraints**: deadlines, budget, compliance, team skills, technologies that are mandated or off-limits.
- **Current system**: a short description or diagram of the components involved.
- **Scale figures you actually know**: request rates, data volumes, latency targets. Unknown figures should be stated as unknown, not estimated by the model.
- **Candidate approaches** you are already considering, if any.
- **Audience**: who reviews the doc and what they care about.

## Prompt
```text
You are a staff engineer drafting a technical design document for review by peers. The draft must make the decision easy to challenge: explicit scope, real alternatives, honest trade-offs, and visible uncertainty.

Title: {{TITLE}}
Problem and evidence: {{PROBLEM_STATEMENT}}
Current system: {{CURRENT_SYSTEM}}
Constraints: {{CONSTRAINTS}}
Known scale and performance figures: {{SCALE_FIGURES}}
Approaches already under consideration: {{CANDIDATE_APPROACHES}}
Reviewers and their concerns: {{AUDIENCE}}

Rules:
- Use only figures given above. Where a number is needed but missing, write "[NEEDS DATA: what and from where]". Never invent load, cost, latency or headcount figures.
- Mark every assumption inline as "Assumption:" so the author can confirm or delete it.
- Present at least two genuine alternatives besides the proposal, including "do nothing / minimal change" when it is viable. Do not write strawmen.
- Prefer boring, well-understood technology unless a constraint rules it out, and say why when it does.

Write the document with these sections:
1. Summary: three to five sentences a busy reader can stop after.
2. Context and problem: current state, evidence, who is affected, why now.
3. Goals: measurable where possible, each with how success will be checked.
4. Non-goals: plausible things this design deliberately does not do.
5. Proposed design: components, data model changes, API or interface changes, data flow for the main scenario (a numbered sequence), failure modes and how each is handled.
6. Alternatives considered: each with a description, pros, cons, and why it was not chosen.
7. Trade-off table: options as columns; rows for complexity, operational cost, risk, time to deliver, reversibility, and fit with constraints.
8. Cross-cutting concerns: security and privacy, observability, performance, migration and backward compatibility, testing strategy.
9. Rollout and rollback: phases, feature flags, data migration steps, success metrics per phase, and the exact rollback trigger and procedure.
10. Risks and mitigations: table with likelihood, impact, mitigation, owner placeholder.
11. Open questions: each with who can answer it.
12. Milestones: ordered deliverables without calendar dates unless given.
```

## Variables
| Variable | Description | Required |
|---|---|---|
| `{{TITLE}}` | Working title of the design | Yes |
| `{{PROBLEM_STATEMENT}}` | The problem, who it hurts, and evidence | Yes |
| `{{CURRENT_SYSTEM}}` | Components and flows involved today | Yes |
| `{{CONSTRAINTS}}` | Deadlines, compliance, mandated or banned tech, team capacity | Yes |
| `{{SCALE_FIGURES}}` | Known rates, volumes and targets; "unknown" is acceptable | No |
| `{{CANDIDATE_APPROACHES}}` | Options already on the table, or "none yet" | No |
| `{{AUDIENCE}}` | Reviewers and what they will scrutinise | No |

## Output format
A Markdown document with the twelve numbered `##` sections above, in that order, with tables for sections 7 and 10. Assumptions appear inline with the "Assumption:" prefix; missing numbers appear as `[NEEDS DATA: ...]`. Target 1,200-2,500 words; a longer draft usually means the scope is too broad and should be split.

## Example usage
Input: "Move image thumbnail generation out of the request path of a Rails monolith; uploads time out at p99; 40k uploads/day; must stay on AWS; two engineers for one quarter." A good draft proposes an S3 event to a queue to a worker that writes thumbnails back, lists non-goals such as "no video processing" and "no change to the CDN", compares it with "background job in the existing Sidekiq cluster" and "on-the-fly resizing at the CDN edge", and notes that the Sidekiq option wins on time to deliver while the event-driven option wins on isolation. The rollout section dual-writes behind a flag, and open questions include who owns the dead-letter queue.

## Customization
- Map the sections to your company's RFC template; keep goals, non-goals and alternatives even if the template omits them.
- For small changes, request a one-page version with sections 1, 3, 4, 5, 6 and 9 only.
- Add "Cost estimate" as a section if you can supply real pricing inputs.
