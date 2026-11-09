# Deep Research Brief

## Intended task

Use this prompt at the very start of a research effort, before anyone searches. It turns a loose request ("look into whether we should support passkeys", "what is happening with lithium prices") into a one-page research brief: the decision the research serves, a precise main question, sub-questions, competing hypotheses, a source strategy, evidence standards, the deliverable, and a stop rule. The brief can be handed to a human researcher or to a research agent and used later to judge whether the research answered what was asked.

## Required context

- The raw request in the requester's own words, including any background they gave.
- Who will use the answer and what decision or action depends on it; without this the model will guess and say so.
- Constraints: deadline, effort budget, sources that are off limits or mandatory, confidentiality.
- What is already known, including earlier research or strong opinions in the team, so the plan can test rather than repeat them.

## Prompt

```text
You are a senior research lead. Your job is to scope research, not to answer it. Do not answer the research question from memory; where you are tempted to, turn that knowledge into a hypothesis to be tested.

Raw request:
{{RESEARCH_REQUEST}}

Who will use the answer and for what decision:
{{DECISION_CONTEXT}}

Constraints (deadline, effort, sources, confidentiality):
{{CONSTRAINTS}}

What is already known or believed:
{{EXISTING_KNOWLEDGE}}

Produce a research brief with these sections:

1. Decision and audience - one or two sentences. If the decision is unclear, state your best interpretation and mark it ASSUMPTION.
2. Main research question - one precise, answerable question with scope (time period, geography, population, units).
3. Sub-questions - three to seven, each answerable on its own, ordered so that early answers can change later ones. Mark which are critical to the decision.
4. Hypotheses - at least two competing hypotheses for the main question, including one that would be inconvenient for the requester. For each, the evidence that would support or refute it.
5. Out of scope - what the research will deliberately not cover.
6. Source strategy - for each sub-question, the most authoritative source types (primary data, official records, specifications, peer-reviewed studies, expert interviews, customer data) and example search angles. Name sources to avoid or treat with caution and why.
7. Evidence standards - what counts as sufficient evidence for a conclusion, how sources will be graded, and how conflicting evidence will be handled.
8. Deliverable - format, length, and the sections the final output must contain, including an explicit confidence statement.
9. Stop rule - the conditions under which research ends (question answered at stated confidence, budget exhausted, or a decisive finding), and what to report if it ends early.
10. Risks and open questions for the requester - ambiguities to resolve before starting, at most five.

Keep the brief under 700 words. Use plain language. Mark every assumption you make.
```

## Variables

| Variable | Description | Required |
|---|---|---|
| `{{RESEARCH_REQUEST}}` | The request as originally phrased, with any background | Yes |
| `{{DECISION_CONTEXT}}` | Who uses the answer and which decision depends on it | Yes |
| `{{CONSTRAINTS}}` | Deadline, effort budget, mandatory or forbidden sources, confidentiality | No |
| `{{EXISTING_KNOWLEDGE}}` | Prior research, internal data, and strong beliefs in the team | No |

## Output format

A Markdown document with ten numbered sections matching the prompt, under 700 words. Sub-questions and source strategy work best as a table with columns: sub-question, critical (yes/no), source types, search angles. Assumptions are tagged inline with ASSUMPTION so the requester can confirm them quickly.

## Example usage

Request: "Can you look into passkeys? Product wants to know if we should do it." Decision context: the identity team is choosing next half-year's roadmap; the decision is whether to add passkey sign-in for a consumer fintech app. Constraints: two weeks of one engineer's time; no vendor sales calls.

A good brief asks the main question "Should we offer passkey sign-in to our iOS, Android, and web users by Q3, and as primary or secondary method?"; lists sub-questions on platform support, account recovery, regulatory authentication requirements, user adoption evidence from comparable apps, and implementation effort; offers competing hypotheses ("adoption will be low enough that effort is not justified" versus "passkeys reduce password-reset support contacts materially"); points to platform documentation and standards bodies as primary sources; and sets a stop rule tied to the two-week budget.

## Customization

- Adjust the word limit and the number of sub-questions for quick scans versus multi-week programmes.
- For academic work, replace the main-question format with PICO or PCC and add eligibility criteria.
- For regulated topics, add a section listing which professional reviewers must sign off the final deliverable.
- Keep the instruction not to answer the question; removing it tends to produce a premature answer disguised as a plan.
