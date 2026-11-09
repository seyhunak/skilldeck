---
name: journey-mapping
description: Build a current-state customer journey map for one persona and one scenario, with stages, actions, touchpoints and channels, thoughts, an emotional curve, pain points, moments of truth, and prioritized opportunities, each tied to research evidence. Use when a team needs to see where an end-to-end experience breaks across channels, teams, or time, and turn that into owned improvements.
---

# Journey Mapping

A customer journey map visualizes the experience of a specific person pursuing a specific goal over time and across touchpoints. It is a tool for alignment and for locating opportunities, especially across organizational silos. A map is only as good as its scope and evidence; a generic map of "the customer" doing "everything" produces nothing actionable.

## When to use

- An outcome (activation, renewal, resolution time) is poor and the cause seems to span multiple teams or channels.
- After research, to show stakeholders where the experience breaks.
- Before a service redesign, to agree on the current state.
- To compare how different personas experience the same scenario.

Not for: designing an internal process for efficiency (use value stream mapping such as `value-stream-mapping`), detailed screen-level usability review, or speculative future-state design without a current-state baseline (future-state maps are a follow-up, not a substitute).

## Inputs

- Persona or user segment, and the scenario with a clear start and end ("from noticing a billing error to getting a corrected invoice"). Required.
- Evidence: interview synthesis, support tickets, analytics funnels, diary studies, call recordings notes, reviews. Required.
- Internal knowledge: which teams and systems own each touchpoint. Recommended.

## Procedure

1. **Scope the map.** Write one sentence: persona, scenario, start trigger, end state, and the goal the persona holds. State the business question the map should help answer.
2. **Define stages from the customer's point of view.** Use four to seven stages that describe what the person is trying to do ("realize there is a problem", "find out who can help", "explain the issue", "wait", "receive resolution"), not the company's funnel names.
3. **Fill the lanes stage by stage, from evidence.**
   - *Actions:* what the person does.
   - *Touchpoints and channels:* where interactions happen (email, app, phone, partner, word of mouth).
   - *Thoughts and questions:* in the person's words, using anonymized quotes where available.
   - *Emotions:* a rating per stage (for example -2 to +2) with the evidence for it; this becomes the emotional curve.
   - *Pain points:* specific breakdowns, with frequency or severity indicators from data where available.
   - *Backstage (optional):* teams, systems, and policies behind each touchpoint, to show where silos cause the pain.
4. **Mark moments of truth.** Identify the points that disproportionately shape the person's overall judgement — typically the lowest emotional points, first experiences of value, and moments where they decide to continue or leave.
5. **Mark evidence strength.** Label each cell observed, reported, or assumed. Assumed cells are research questions, not findings.
6. **Derive opportunities.** Turn each significant pain point or moment of truth into a "How might we..." opportunity statement. Note the likely owner team and any metric that would show improvement.
7. **Prioritize.** Rate opportunities by impact on the persona's goal and the business outcome, and by effort or organizational difficulty, as a 2x2 or simple High/Medium/Low. Highlight quick wins and the one or two structural fixes.
8. **Validate.** Review the map with frontline staff (support, sales, success) and, ideally, a few customers; record corrections.

## Expected output

```markdown
## Journey Map: <persona> — <scenario>
**Start:** ... · **End:** ... · **Goal:** ... · **Question this answers:** ...

| Lane | Stage 1: <name> | Stage 2 | Stage 3 | Stage 4 | Stage 5 |
|---|---|---|---|---|---|
| Actions | | | | | |
| Touchpoints | | | | | |
| Thoughts | | | | | |
| Emotion (-2..+2) | | | | | |
| Pain points | | | | | |
| Backstage | | | | | |
| Evidence | observed/reported/assumed | | | | |

**Moments of truth:** ...

### Opportunities
| How might we... | Stage | Owner | Impact | Effort | Metric |
```

A Mermaid `journey` diagram may be added for the emotional curve when the destination renders Mermaid.

## Constraints and limitations

- One persona and one scenario per map; split broader requests.
- Do not invent emotions or quotes; unsupported cells are marked assumed.
- Current-state maps describe reality, including the parts the organization would rather not see.
- A map is a snapshot; date it.

## Examples

Persona: small-business owner. Scenario: from receiving an unexpectedly high invoice to resolution.
Stages: notice the charge → look for an explanation → contact support → wait → get refund or explanation.
Lowest point: "wait" (-2) — three participants described re-explaining the issue to a second agent because the first ticket was not visible to billing (backstage: support and billing use separate systems).
Moment of truth: the first support reply; participants who got a specific answer within a day stayed, two who got a template reply cancelled.
Opportunity: "How might we let billing see the full support conversation so customers explain once?" Owner: support operations. Metric: repeat contacts per billing ticket.
