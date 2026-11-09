# Patent search notes

Practical reference for building landscape searches. Database syntax changes; check each database's own help pages before relying on a field code.

## Free databases

| Database | Strengths | Notes |
|---|---|---|
| Google Patents | Fast full-text search, CPC filters, family grouping, citation lists | Good for exploration; check family and status data against official sources |
| Espacenet (EPO) | Worldwide coverage, CPC browsing, INPADOC family and legal-status data | Classification search is a strength |
| The Lens | Patents linked to scholarly works, export and analysis features | Useful for linking patents to papers |
| WIPO PATENTSCOPE | PCT applications, multilingual cross-lingual search | Good for international applications |
| USPTO Patent Public Search | Official US full text | Authoritative for US documents |

## Concepts

- **Priority date** — the earliest filing date claimed; use it for trend charts because it is closest to the date of invention.
- **Publication lag** — applications are usually published about 18 months after the priority date, so recent years look artificially low.
- **Patent family** — publications sharing priority claims. Simple families (for example DOCDB) group documents with exactly the same priorities; extended families (for example INPADOC) link through any shared priority. State which you used.
- **Kind codes** — suffixes such as A1 or B2 indicate the publication type and differ by office; for example in the US, A1 is a published application and B1/B2 are granted patents. Check the office's kind-code table rather than assuming.
- **CPC and IPC** — hierarchical classification schemes; CPC is more granular and is used by the EPO and USPTO among others. Codes look like section, class, subclass, group, for example a main group followed by subgroups.

## Building a query

1. Start from seed documents and note the CPC codes most of them share.
2. Write a keyword block for each concept with synonyms and truncation where the database supports it.
3. Combine: (concept A keywords OR concept A codes) AND (concept B keywords OR concept B codes).
4. Restrict keywords to title, abstract, and claims to reduce noise from long descriptions.
5. Check recall on seeds and precision on a random sample; iterate.

## Indicators to use with care

- Forward citations correlate with technological influence but depend on age and examiner practice.
- Family size and number of jurisdictions suggest the applicant's investment, not value.
- Grant rates differ by office and era.

## Where the landscape stops

Infringement, validity, enforceability, claim construction, and freedom-to-operate questions require a registered patent attorney or agent. Collect such questions in the report's counsel section instead of answering them.
