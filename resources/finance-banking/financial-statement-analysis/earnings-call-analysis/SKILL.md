---
name: earnings-call-analysis
description: Analyzes an earnings call transcript and accompanying release to extract guidance changes, KPI disclosures, management tone shifts, hedging language, and Q&A signals (evasions, repeated analyst concerns), then cross-checks claims against the reported numbers. Use after a results release to brief a reader on what changed; not a trading signal.
---

# Earnings Call Analysis

The release tells you the numbers; the call tells you what management wants you to think about them, and the Q&A shows what analysts doubt. This skill turns a transcript into a structured brief of what changed since last quarter, with every point quoted or cited so the reader can check it.

## When to use

- After a company publishes results with a call transcript, to brief a lender, analyst, competitor-watcher, or management team.
- Comparing consecutive calls to track guidance credibility and narrative drift.
- Preparing questions for a management meeting.

Not appropriate for: full financial statement analysis (use `financial-statement-analysis-agent`), valuation (use `dcf-valuation`), or generating buy/sell recommendations, which this skill does not do.

## Inputs

- Current call transcript (prepared remarks and Q&A). Required.
- The earnings release or investor presentation for the same period. Strongly recommended to cross-check figures.
- The previous one or two transcripts and prior guidance. Optional, but required for change detection.
- The reader's focus (credit, competitive intelligence, equity research, internal benchmarking). Optional.

## Procedure

1. **Extract guidance.** Build a table of every forward-looking metric (revenue, margins, EPS, capex, free cash flow, segment targets), with current value or range, prior value, direction (raised, maintained, lowered, introduced, withdrawn), and quote location. Note changes in the guidance basis (constant currency, adjusted measures, excluded items).
2. **Capture KPIs and disclosures.** List operational metrics management discussed. Flag metrics previously reported but now absent, and new metrics introduced — both often signal a changing story.
3. **Reconcile claims to numbers.** Check statements such as "record margins" or "strong cash generation" against the release. Note adjusted versus reported gaps and whether management explains adjustments.
4. **Assess tone and language.** Compare with prior calls: frequency of hedging words (for example "challenging", "headwinds", "uncertain"), confident commitments versus vague phrasing, shifts from specific numbers to qualitative language, and new blame attributions (macro, weather, FX). Treat word counts as weak signals and always pair them with quotes.
5. **Analyze the Q&A.** Group analyst questions by theme; count how many analysts raised each theme. Mark answers as direct, partial, or deflected (answering a different question, deferring to "later this year", or citing confidentiality). Repeated questions on one topic indicate market concern.
6. **Identify risks and positives.** Summarize new risks disclosed, management actions announced (restructuring, buybacks, pricing), and capital allocation shifts.
7. **Write the brief** with citations (speaker and section or timestamp) for every point; separate facts from interpretation.

## Expected output

```markdown
## Earnings Call Brief: <company> <period>
Sources: <transcript, release, prior calls>

### What changed (top five)
### Guidance table
| Metric | Prior | Current | Direction | Basis notes | Source |
### KPI disclosure changes (new / dropped)
### Claims vs reported numbers
### Tone comparison (with quotes)
### Q&A themes
| Theme | # analysts | Answer quality | Key quote |
### Questions to follow up
### Caveats
```

## Constraints and limitations

- Analytical support only, not investment advice or a trading recommendation; investment decisions need a qualified professional's judgement.
- Tone analysis is interpretive and culture- and speaker-dependent; never present it as evidence of misconduct.
- Quote accurately and briefly; do not reconstruct the transcript.
- If the user has non-public information about the company, do not combine it with this analysis for trading purposes; flag the market-abuse risk and stop.

## Examples

Guidance row: "FY gross margin — prior 41-42%, current 'around 40%', lowered; CFO prepared remarks. Basis now excludes a newly acquired unit." Q&A row: "Pricing durability — 4 of 9 analysts asked; CEO answered with volume commentary instead of price (deflected)." Follow-up question: "What share of the margin reduction is from mix versus price concessions?"
