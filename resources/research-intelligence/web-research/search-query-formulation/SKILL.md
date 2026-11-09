---
name: search-query-formulation
description: Turns a research question into precise, reproducible search queries and refines them iteratively. Covers concept blocks and synonyms, Boolean AND/OR/NOT, phrase search, exclusion, site:, filetype:, intitle:, date restriction, and database-specific syntax such as controlled vocabulary and field tags. Use when a search returns noise, misses known items, or needs to be documented for a review, landscape, or fact-check.
---

# Search Query Formulation

## When to use

Use this skill whenever finding the right documents matters more than finding any document: research briefs, systematic reviews, patent or regulatory searches, fact-checks, and competitor research. Use it when the first search returns thousands of irrelevant hits, misses a document you know exists, or must be logged so someone else can rerun it.

It is not needed for simple navigational lookups (finding a known homepage). It does not cover judging the results; pair it with `source-credibility-assessment` for that.

## Inputs

- The research question in one sentence.
- Known relevant items ("seeds"), if any, to test recall.
- Target engines or databases and any access limits.
- Time window, languages, geographies, and document types of interest.

## Procedure

1. **Split the question into concepts.** Identify two to four essential concepts. "Effect of four-day work weeks on employee retention in UK firms" becomes: four-day week, retention, UK. Drop words that every relevant document would not contain.
2. **Build synonym blocks.** For each concept list synonyms, spelling variants (UK/US), abbreviations, related technical terms, and, in databases that support it, controlled vocabulary (for example MeSH headings in PubMed, CPC codes in patent databases). Use truncation such as `retain*` only where the engine supports it.
3. **Combine with Boolean logic.** OR within a block, AND between blocks, parentheses to group: `("four-day week" OR "4-day week" OR "compressed workweek") AND (retention OR turnover OR attrition) AND (UK OR "United Kingdom" OR Britain)`. Use NOT sparingly; it silently drops relevant documents that mention the excluded term.
4. **Add precision operators for web engines.** Common examples (support varies by engine; check its help page):
   - Phrase search with quotes: `"compressed workweek"`.
   - Exclude a term with a minus sign: `-recipe`.
   - Restrict to a domain or TLD: `site:gov.uk`, `site:europa.eu`, `site:github.com`.
   - Restrict to file types: `filetype:pdf`, `filetype:xlsx` for datasets and reports.
   - Restrict to titles: `intitle:"annual report"`.
   - Restrict by date with the engine's tools or `before:`/`after:` where supported.
5. **Adapt per source.** Scholarly databases use field tags (title, abstract, keywords), proximity operators, and subject headings; patent databases use classification codes and claims fields; site search on government portals often needs simpler terms. Rewrite the query in each source's syntax rather than pasting one string everywhere.
6. **Test and iterate.** Run the query, check whether seeds appear (recall), and skim the first 20-30 results for relevance (precision). If recall is low, add synonyms or remove a concept block; if precision is low, add a block, use phrase search, or restrict fields. Change one thing at a time so you know what helped.
7. **Use citation and link chasing.** From the best results, follow their references backward and citing documents forward; this finds items no keyword search will.
8. **Log the search.** Record engine, exact query, filters, date run, and approximate hit count for every iteration you keep.

## Expected output

```markdown
**Question:** <one sentence>
**Concept blocks:**
- A: <terms> · B: <terms> · C: <terms>

| # | Source | Query (verbatim) | Filters | Date | Hits | Seeds found | Precision (sample) | Change from previous |
|---|---|---|---|---|---|---|---|---|

**Final queries per source:** ...
**Known gaps:** sources not searched, languages excluded.
```

## Constraints and limitations

- Engines change operator support and ranking without notice; verify operators on the day and keep the log.
- Personalised and localised results mean two people may see different results for the same query.
- Hit counts reported by web engines are estimates.
- Do not use advanced operators to hunt for exposed credentials, private documents, or personal data; that is out of scope regardless of what is technically findable.

## Examples

**Need:** official statistics on heat pump installations in England.
Iteration 1: `heat pump installations England statistics` returns news articles.
Iteration 2: `"heat pump" installations site:gov.uk filetype:xlsx` returns official data tables.
Iteration 3: add `"Boiler Upgrade Scheme"` to find the scheme's monthly statistics series.
Log all three; cite the dataset, not the news coverage.

**Need:** PubMed search on sleep and adolescent academic performance.
`("Sleep"[MeSH] OR sleep*[tiab]) AND ("Adolescent"[MeSH] OR adolescen*[tiab] OR teen*[tiab]) AND ("Academic Performance"[MeSH] OR grades[tiab] OR "academic achievement"[tiab])`, then test that three known seed papers are retrieved.
