---
name: citation-management
description: Keeps a research deliverable's citations consistent, accurate, and durable. Covers choosing a style, capturing complete metadata, rules for direct quotes versus paraphrase, pinpoint locators, DOIs and persistent identifiers, archiving web sources against link rot, and a final citation audit. Use whenever a report, review, brief, or article will cite sources that readers must be able to check.
---

# Citation Management

## When to use

Use this skill from the first source you collect, not at the end. It applies to research reports, literature reviews, fact-check reports, policy briefs, technical comparisons, and any deliverable whose credibility depends on readers verifying sources. Use the audit step before delivery even if citations were collected by someone else.

It is not a reference-manager tutorial and does not choose sources; pair it with source evaluation and search skills.

## Inputs

- The deliverable and its audience (academic, business, technical, legal-adjacent).
- Any required citation style (APA 7, Chicago, IEEE, Harvard, or an organization's house style).
- The sources: documents, URLs, datasets, interviews, code repositories.

## Procedure

1. **Choose a style and stick to it.** Use the style the venue requires. If none is required, pick a simple consistent format: author or organization, year, title, publisher or venue, identifier or URL, accessed date for web sources. Numbered citations suit technical and business reports; author-date suits academic writing.
2. **Capture metadata at the moment of reading.** Record authors, title, publication or update date, publisher, version (for software and standards), DOI or other persistent identifier, URL, and access date. Copy the exact passage you rely on into your notes with its locator.
3. **Prefer persistent identifiers.** Use DOIs (formatted as `https://doi.org/...`), arXiv ids, ISBNs, standard numbers, case citations, legislative identifiers, or commit hashes and release tags for code. Verify that a DOI resolves to the item you mean.
4. **Archive volatile web sources.** For pages likely to change or disappear (news, company pages, pricing pages, social posts), save a snapshot in a public web archive such as the Internet Archive's Wayback Machine where permitted, and cite both the live URL and the snapshot with its capture date.
5. **Quote versus paraphrase.** Quote directly when exact wording matters (definitions, legal text, contested statements, a person's claim). Keep quotes short, verbatim, and marked with quotation marks; indicate omissions with an ellipsis and additions with square brackets. Paraphrase everything else in genuinely your own words and structure, and still cite it. Never put quotation marks around a paraphrase.
6. **Use pinpoint locators.** Give page numbers, sections, paragraph numbers, table or figure numbers, or timestamps for quotes and specific figures, so readers can find the exact support.
7. **Cite the source you actually read.** If you only saw a claim quoted in a secondary source, cite it as "cited in" or trace and read the original first.
8. **Run a citation audit before delivery.** Check that: every in-text citation has a reference entry and vice versa; every link resolves or has an archive; every quote matches the source verbatim; every cited source actually supports the sentence it is attached to; retracted or superseded sources are flagged; and formatting is consistent.

## Expected output

A reference list in the chosen style, plus an audit table when requested:

```markdown
| Ref | In text? | Link status | Archived | Quote verified | Supports claim? | Issue |
|---|---|---|---|---|---|---|
| [3] | Yes | 404 | Yes (2026-05-02 snapshot) | n/a | Yes | Replace live link with archive |
| [7] | Yes | OK | No | Mismatch: "most" vs "many" | Partly | Fix quote wording |
```

## Constraints and limitations

- Never invent or "complete" metadata such as DOIs, page numbers, or dates; mark missing fields as missing.
- Archiving is not available for every site (some block archivers); record the failure and keep a local note of the content as accessed.
- Copyright limits how much can be quoted; keep quotations brief and purposeful.
- Formatting styles have edge cases; when an official style manual is required, check its current edition.

## Examples

**Problem:** a market report cites "Statista, 2024" for a key figure.
Fix: trace to the original source the aggregator lists, cite that original with title, publisher, year, and table number, and add the aggregator as "via" only if the original is inaccessible.

**Problem:** a quote in a draft reads "AI will replace most analysts". The transcript says "AI will change what most analysts do". Audit marks the quote as inaccurate; the author either quotes correctly or paraphrases accurately.
