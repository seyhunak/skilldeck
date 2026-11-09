# Research Paper Summary

## Intended task

Use this prompt to produce a structured, critical summary of a single research paper: what question it asks, how it was studied, what it found (with effect sizes and uncertainty as reported), how much the design can support the authors' conclusions, and whether the result applies to the reader's situation. It suits academic, medical, social-science, and computer-science papers, including preprints. It is a reading aid, not a peer review and not a substitute for reading the methods yourself when a decision depends on them.

## Required context

- The paper's full text, or as much as available. If only the abstract is provided, the model must say the appraisal is limited.
- Citation details: authors, year, title, venue, DOI or preprint id, and whether it is peer-reviewed.
- The reader's purpose and context (for example "deciding whether to adopt this retrieval method for legal documents"), so the applicability section is useful.
- Optional: the reader's expertise level, to set how much method jargon to explain.

## Prompt

```text
You are an experienced peer reviewer summarising a paper for a busy reader. Work only from the text provided. Quote numbers exactly as they appear. If a section is missing from the provided text, write "Not provided" rather than reconstructing it. Separate what the authors claim from what the evidence supports.

Citation: {{PAPER_CITATION}}
Reader's purpose and context: {{READER_PURPOSE}}
Reader's expertise: {{READER_EXPERTISE}}

Paper text:
{{PAPER_TEXT}}

Write the summary with these sections:

1. One-sentence takeaway - what the paper shows, at the strength the evidence allows.
2. Research question and motivation - including the gap the authors say they fill.
3. Method - design (for example randomised trial, cohort, case study, benchmark evaluation, simulation), data or sample (size, source, period), key measures, comparison or baseline, analysis approach.
4. Findings - main results with exact figures, effect sizes, confidence intervals or variance, and significance as reported; note any results the abstract emphasises more than the body supports.
5. Validity assessment - internal validity (confounding, bias, leakage, baseline fairness), statistical concerns (multiple comparisons, small samples, missing variance), external validity (who or what the result generalises to), and reproducibility (code, data, preregistration availability).
6. Authors' stated limitations, and important limitations they did not state.
7. What this paper does not show - two to four plausible over-readings to avoid.
8. Relevance to the reader - how the result applies to {{READER_PURPOSE}}, and what would need checking before relying on it.
9. Conflicts of interest and funding, as disclosed.
10. Confidence rating - high, moderate, low, or very low that the main finding holds in the reader's context, with one-sentence justification.

Keep it under 600 words. Use quotation marks only for verbatim text and give the page or section for each quote.
```

## Variables

| Variable | Description | Required |
|---|---|---|
| `{{PAPER_CITATION}}` | Authors, year, title, venue, DOI or preprint id, review status | Yes |
| `{{PAPER_TEXT}}` | Full text or the available sections of the paper | Yes |
| `{{READER_PURPOSE}}` | What the reader wants to use the paper for | Yes |
| `{{READER_EXPERTISE}}` | Novice, practitioner, or specialist; sets jargon level | No |

## Output format

Markdown with ten numbered sections, under 600 words, exact figures preserved, verbatim quotes with locators, "Not provided" where text was missing, and a final confidence rating with justification.

## Example usage

A product team pastes a preprint claiming a new reranking method improves retrieval accuracy by eight points on two benchmarks. Purpose: deciding whether to try it on internal support-ticket search. A good summary reports the exact metric and benchmarks, notes that baselines were run by the authors with default settings while their method was tuned, that no variance across runs is reported, that the benchmarks are web-domain question answering unlike support tickets, and that code is available. It rates confidence as low for the reader's context and suggests a small internal evaluation before adoption.

## Customization

- For clinical papers, ask for risk-of-bias domains from the relevant appraisal tool and absolute risk alongside relative risk.
- For machine-learning papers, add checks for data leakage, compute budget parity, and benchmark contamination.
- Shorten to sections 1, 4, 5, and 10 for a quick triage of many papers.
- Keep the "Not provided" rule; it is the main guard against invented methods or numbers.
