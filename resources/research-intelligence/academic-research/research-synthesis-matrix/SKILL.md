---
name: research-synthesis-matrix
description: Builds a source-by-theme synthesis matrix in which each cell records what one source says about one theme, with a locator and an evidence-strength note, then reads across rows and columns to state consensus, conflict, and gaps. Use when combining roughly five or more sources (papers, reports, interviews, reviews) into a synthesis rather than a source-by-source summary.
---

# Research Synthesis Matrix

## When to use

Use this skill when you have gathered several sources and need to say what they collectively show: literature reviews, market or competitor research with many inputs, customer-feedback analysis across channels, or a policy brief drawing on multiple reports. The matrix prevents the common failure of summarising each source in turn and leaving the reader to do the synthesis.

With fewer than about five sources a simple comparison table is usually enough. The matrix organises evidence; it does not judge source quality, so pair it with a credibility or risk-of-bias assessment.

## Inputs

- The sources, already retrieved, each with a stable id (for example author-year or S1, S2).
- The question the synthesis must answer.
- Optional: a draft list of themes, variables, or outcomes; otherwise derive them.
- Optional: quality grades for each source.

## Procedure

1. **Fix the question and the unit of analysis.** Decide whether rows are sources (typical) or studies, interviews, or products, and whether columns are themes, outcomes, or variables. Write the question at the top of the matrix.
2. **Define columns.** Start with descriptive columns (id, type, date, setting, sample or scope, method, quality grade). Then add theme columns. Derive themes deductively from the question or a framework, and inductively from a first read of three or four sources. Write a one-line definition for each theme so cells stay consistent.
3. **Fill cells with findings, not topics.** Each cell states what the source says about that theme, with direction and magnitude when available ("reduced churn by 12% over six months, n=340"), plus a locator (page, section, figure, timestamp). Use "not addressed" for empty cells; it is different from "found no effect".
4. **Tag evidence strength.** Add a short marker per cell: design or method, sample size, and the source's quality grade. Strong findings from weak sources should be visible as such.
5. **Read across each theme column.** Classify the pattern: consensus (most sources agree, including strong ones), mixed (credible sources disagree), single-source, or gap (few or no sources). For mixed patterns, look for moderators that explain the disagreement: setting, population, time period, method, or definitions.
6. **Read along each source row.** Spot sources that are outliers across many themes, which may indicate a different context or a methodological issue.
7. **Write the synthesis by theme.** For each theme: the overall finding, the strength of support, the sources (by id), explanations for disagreement, and what remains unknown. Keep claims proportional to the evidence.
8. **Check traceability.** Every sentence in the synthesis should map back to cells; delete or flag any claim that does not.

## Expected output

```markdown
**Question:** <question>

| Id | Type/method | Setting | n/scope | Quality | Theme 1: <def> | Theme 2: <def> | Theme 3: <def> |
|---|---|---|---|---|---|---|---|
| S1 | RCT | US hospitals | 412 | Low risk | Positive, +8% (p.6) | Not addressed | Mixed (Table 3) |

## Synthesis by theme
### Theme 1 - <pattern: consensus/mixed/single-source/gap>
Finding · Support (S1, S4, S7) · Disagreement and possible moderators · Unknowns

## Gaps
Themes or populations with little or no evidence.
```

## Constraints and limitations

- Counting sources ("five of seven agree") is vote counting and can mislead; weight by quality, size, and relevance, and say how.
- Themes defined after reading can bend toward the analyst's expectations; record definitions and revisions.
- Large matrices become unreadable in chat; for more than about 20 sources, keep the matrix as a CSV or spreadsheet and present summaries.
- Do not fill cells from memory or general knowledge; every cell needs a locator from a retrieved source.

## Examples

**Question:** What drives adoption of electronic invoicing among small suppliers?
Columns: regulation mandate, buyer pressure, cost savings, IT capability, trust. Seven sources: two surveys, three case studies, one government evaluation, one academic study.
Reading across: regulation mandate shows consensus (five sources, including the government evaluation, report it as the strongest driver where mandates exist); cost savings are mixed (surveys report them, case studies find savings only above a volume threshold, suggesting volume as a moderator); trust is a gap (one case study).
Synthesis states the mandate finding with strong support, presents cost savings conditionally, and lists trust as under-researched.
