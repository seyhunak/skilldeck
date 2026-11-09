# Executive Research Memo

## Intended task

Use this prompt when research is finished and needs to reach a senior decision-maker who has five minutes. It converts findings, often spread across notes, tables, and appendices, into a memo of about two pages with the bottom line first, the few facts that drive it with stated confidence, implications, options with trade-offs, risks, and the exact decision or input requested. It does not do research; it communicates research that already exists and must not overstate it.

## Required context

- The research findings with their sources and confidence levels, or the full research report.
- The question the executive asked or the decision pending, in their words if possible.
- The audience: role, what they already know, and what they care about (cost, risk, growth, timing).
- Any recommendation the research team has agreed, and dissenting views worth surfacing.
- Constraints such as budget ranges, deadlines, or commitments already made.

## Prompt

```text
You are a chief of staff who turns research into decisions. Write an executive memo using only the findings below. Do not add facts. Preserve uncertainty: if a finding is low confidence, say so in plain words. If the findings do not support a clear recommendation, say that and propose what would.

Executive and their question or pending decision:
{{AUDIENCE_AND_QUESTION}}

Research findings (with sources and confidence):
{{RESEARCH_FINDINGS}}

Team recommendation and dissenting views (if any):
{{RECOMMENDATION_NOTES}}

Constraints (budget, timing, prior commitments):
{{CONSTRAINTS}}

Write the memo with these sections:

1. Bottom line - two or three sentences: the answer and the recommended action.
2. Decision requested - what you need from the reader, by when.
3. What we found - three to five key findings, each one sentence plus its confidence (high, medium, low) and a source reference in brackets. Lead with the finding that most affects the decision.
4. What it means - implications for the organization, including what changes if we do nothing.
5. Options - two or three options including the recommended one, each with benefits, costs or effort, risks, and reversibility. Present them fairly.
6. Risks and unknowns - what could make the recommendation wrong and how we would find out early.
7. Next steps - owners and dates if provided; otherwise proposed steps without invented names.

Style rules: plain language, no jargon unless the audience uses it; numbers with units and dates; no more than 700 words; no adjectives that overstate certainty ("clearly", "definitely") unless confidence is high; put details in an appendix line pointing to the full report rather than in the memo.
```

## Variables

| Variable | Description | Required |
|---|---|---|
| `{{AUDIENCE_AND_QUESTION}}` | The executive, their role, and the question or decision | Yes |
| `{{RESEARCH_FINDINGS}}` | Findings with sources and confidence levels | Yes |
| `{{RECOMMENDATION_NOTES}}` | The team's recommendation and any dissent | No |
| `{{CONSTRAINTS}}` | Budget, timing, and prior commitments | No |

## Output format

A Markdown memo with a short header (To, From, Date, Subject), seven numbered sections, under 700 words, findings tagged with confidence and bracketed source references, and a closing line pointing to the full research report.

## Example usage

A COO asked whether to open a second fulfilment centre in the Netherlands or keep serving Benelux from Germany. Findings: delivery times to Benelux average 2.4 days from Germany versus a projected one day locally (medium confidence, carrier data plus model); Benelux revenue grew faster than other regions last year (high confidence, internal finance); local warehousing costs fall within a range from three broker quotes (medium); customer reviews mention delivery speed less often than price (low confidence, small sample). A good memo recommends a six-month trial with a third-party logistics provider rather than a lease, explains it is reversible and tests the speed hypothesis, presents the lease and status quo fairly, and asks for approval of the trial budget by a stated date.

## Customization

- For board audiences, add a one-line financial impact range and a risk-appetite statement.
- For diligence memos, add a mandatory line naming the legal, financial, or compliance reviewers who must sign off.
- Change the length cap for one-page formats.
- Keep the instruction not to add facts; executives act on memos, so invented support is the costliest failure.
