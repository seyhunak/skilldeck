# Executive Summary

## Intended task
Turn a long business document — a report, proposal, investigation, strategy paper, or analysis — into a one-page executive summary for a senior reader who will decide or act based on it. The prompt applies the pyramid principle associated with Barbara Minto: lead with the governing thought (the answer), group supporting arguments beneath it, and end with what the reader must do. Use it when the original is too long for its audience, when the key ask is buried, or when a document must be circulated to executives who have not followed the work.

## Required context
- **The full source document**, pasted or attached. The summary can only be as accurate as what is supplied.
- **The reader** — their role and what they care about (a CFO reads for cost and risk; a COO for operational impact).
- **The purpose** — decision, approval, awareness, or input. This determines whether the summary ends with a decision request or next steps.
- **Length limit** — default is about 250-350 words.

## Prompt
```text
You are an experienced chief of staff writing an executive summary for {{READER_ROLE}}.
The purpose of the summary is: {{PURPOSE}}.
Maximum length: {{WORD_LIMIT}} words for the main summary.

Source document:
<<<
{{SOURCE_DOCUMENT}}
>>>

Additional context from the author (may be empty): {{AUTHOR_NOTES}}

Instructions:
1. Identify the single governing message: the main conclusion or recommendation of the document, in one sentence. If the document has no clear conclusion, say so and state the closest supportable one.
2. Write the summary in this order: (a) the answer or recommendation in one or two sentences; (b) the decision or action required from the reader, with any deadline; (c) three to five supporting points, each with the most important evidence or number from the source; (d) key risks or caveats; (e) next steps.
3. Use only facts, figures, and claims that appear in the source. Copy numbers exactly with their units and time periods. Do not add outside information, benchmarks, or opinions.
4. Write for the reader's priorities. Translate technical detail into business consequence (cost, revenue, risk, customers, time).
5. Use plain language and active voice. Avoid jargon and unexplained acronyms. No adjectives that grade results ("excellent", "disappointing") unless the source supports them with data.
6. After the summary, add a section "Gaps and inconsistencies" listing any contradictions, missing evidence for key claims, or numbers that do not reconcile in the source. Write "None found" if there are none.
7. Add a section "What was left out" with one line per important topic omitted for length, so the reader knows where to look in the full document.

Return the output in exactly the format specified below.
```

## Variables
| Variable | Description | Required |
|---|---|---|
| `{{READER_ROLE}}` | Who will read it, e.g. "CFO and executive committee" | Yes |
| `{{PURPOSE}}` | decision / approval / awareness / input, with the decision if known | Yes |
| `{{WORD_LIMIT}}` | Maximum words for the main summary, e.g. 300 | Yes |
| `{{SOURCE_DOCUMENT}}` | Full text of the document to summarise | Yes |
| `{{AUTHOR_NOTES}}` | Optional emphasis or context from the author | No |

## Output format
```markdown
# Executive summary: <document title>
**For:** <reader> · **Purpose:** <purpose> · **Decision needed by:** <date or n/a>

**Bottom line:** <1-2 sentences>

**What we need from you:** <decision/action>

**Why:**
- <supporting point + evidence>
- ...

**Risks and caveats:** ...

**Next steps:** ...

---
**Gaps and inconsistencies:** ...
**What was left out:** ...
```

## Example usage
Fill `{{READER_ROLE}}` with "COO", `{{PURPOSE}}` with "approval of a warehouse slotting redesign pilot", `{{WORD_LIMIT}}` with 300, and paste a 14-page operations analysis. A good response opens: "Bottom line: redesigning pick-face slotting at the Leeds site would cut average pick time by the 18% measured in the March trial, for a one-off cost of 140k; we recommend a 12-week pilot." It then lists the approval needed by 30 April, three supporting points quoting the trial data, a caveat that the trial covered only ambient goods, and a gaps section noting that the cost estimate in section 4 does not match the appendix.

## Customization
- Adjust the order for awareness-only summaries: drop "What we need from you" and keep next steps.
- For board audiences, add a line on governance or compliance implications if the source covers them.
- For very technical sources, add a short glossary limit (maximum three terms) after the summary.
- Keep the instruction to use only source facts; removing it increases the risk of invented content.
