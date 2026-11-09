---
name: persona-development
description: Build evidence-based personas from user research by identifying behavioral variables, placing participants on them, and finding clusters of shared goals, behaviors, and contexts. Produces lean personas with an evidence trail, an anti-persona, and stated validity limits. Use when research data exists and a team needs shared, decision-useful user archetypes rather than demographic stereotypes.
---

# Persona Development

A persona is a compact model of a group of users who share goals, behaviors, and context, used to make design decisions. Personas built from evidence change decisions; personas invented in a workshop tend to reflect the team's assumptions and get ignored. This skill follows the behavioral-variable approach associated with Alan Cooper's goal-directed design, combined with lean persona formats.

## When to use

- After a round of qualitative research (ideally 8 or more participants per likely segment) when a team needs shared archetypes.
- When existing personas are demographic profiles that no one uses for decisions.
- When a product serves distinct user types whose needs conflict and the team must decide whom to design for first.

Not for: market segmentation for targeting or sizing (that needs quantitative data and a segmentation approach such as `customer-segmentation`); or when there is no research — in that case produce explicitly labeled proto-personas plus a research plan.

## Inputs

- Research data: interview notes or synthesis, observation logs, survey responses, analytics on behavior. Required.
- Participant metadata such as role, company size, tenure. Recommended.
- The product decisions the personas should inform. Recommended.

## Procedure

1. **List behavioral variables.** From the data, identify dimensions along which participants differ in ways that matter for the product. Typical categories: activities (frequency, volume of work), attitudes (toward risk, technology, control), aptitudes (domain expertise, technical skill), motivations (why they do the task), and skills or context (environment, devices, collaboration). Aim for roughly 8-15 variables expressed as ranges, for example "plans weekly ... reacts daily" or "works alone ... coordinates a team of 10+".
2. **Map participants onto each variable.** Place every participant code on each range based on evidence. Do this per variable, not per person, to avoid forcing people into preconceived groups.
3. **Find clusters.** Look for participants who group together across six to eight variables. A cluster that recurs across many variables suggests a significant behavioral pattern. Most products end up with two to five meaningful clusters.
4. **Check the clusters.** Confirm each is distinct in ways that would lead to different design decisions. Merge clusters that only differ cosmetically. Check for missing variables that would split a cluster.
5. **Define goals for each cluster.** Write end goals (what they want to accomplish), experience goals (how they want to feel), and life goals only where relevant. Goals come from the data, quoted or summarized with participant references.
6. **Write lean personas.** For each cluster: a descriptive name tied to behavior ("The Batch Reconciler") rather than a fictional full name with stock photo; a one-line summary; context; goals; key behaviors; pain points and workarounds; what they need from the product; a representative anonymized quote; and the evidence basis ("based on 5 of 14 participants: P2, P4, P7, P9, P12"). Add demographic details only when research shows they change behavior.
7. **Prioritize.** Designate a primary persona (the one whose needs, if met, satisfy many others without disserving them), secondary personas, and an anti-persona (a group the product deliberately does not design for, and why).
8. **State validity limits.** Record sample size, recruiting bias, date, and which claims would need quantitative validation. Recommend a review trigger such as a new market or a year elapsed.

## Expected output

```markdown
## Personas: <product> · based on <n> participants, <dates>

### Behavioral variables
| Variable | Range | Participant placement summary |

### Persona: <behavioral name> (primary)
- **Summary:** ...
- **Context:** ...
- **Goals:** end — ... · experience — ...
- **Behaviors:** ...
- **Pain points and workarounds:** ...
- **Needs from the product:** ...
- **Quote:** "..." (P7)
- **Evidence basis:** <k of n participants; codes>

### Anti-persona: <name> — why we do not design for them

### Validity and limits
...
```

## Constraints and limitations

- Never fabricate quotes, names of real participants, or attributes not in the data. Use participant codes.
- Avoid stereotypes: do not assign gender, age, ethnicity, or disability unless research shows it shapes behavior relevant to the product, and never as decoration.
- Do not invent precise market percentages for personas; qualitative clusters do not size markets.
- Proto-personas built without research must be labeled as assumptions in the title.

## Examples

Data: 14 interviews with users of an expense tool. Variables include submission frequency (per transaction ... monthly batch), attitude to policy (strict compliance ... gets it done), and role (submitter ... approver).

Cluster A (5 participants): submit monthly in a batch, travel heavily, photograph receipts and lose half of them, and see compliance as friction. Persona: "The Monthly Batcher" — goal: get reimbursed without spending an evening on it; need: capture receipts at the moment of purchase and match them later.

Cluster B (4 participants): finance approvers who review dozens of reports weekly and care about policy exceptions. Persona: "The Exception Hunter".

Anti-persona: corporate travel managers who negotiate rates; they buy travel platforms, not expense tools, and designing for them would bloat the product.
