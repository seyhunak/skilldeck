---
name: chunking-strategy-design
description: Design how documents are split into retrievable chunks for a RAG system - unit of retrieval, size and overlap, structure-aware boundaries, parent-child layouts, and per-chunk metadata - and validate the choice with a retrieval comparison. Use when building a new index, when answers miss facts that exist in the corpus, or when changing document types or embedding models.
---

# Chunking Strategy Design

## When to use
- Building a new RAG index and deciding how to split source documents.
- Diagnosing retrieval misses where the answer exists in the corpus but the retrieved chunk is cut mid-thought, too broad, or missing its heading context.
- Adding a new document type (tables, code, transcripts, contracts) to an existing index.
- Switching embedding models with a different maximum input length.

Not for: choosing the embedding model itself or tuning fusion and reranking (see `hybrid-search-tuning`). Measuring retrieval quality is covered in depth by `retrieval-quality-metrics`; this skill uses those metrics but does not redefine them.

## Inputs
- A representative sample of documents (20-200, covering every document type in the corpus).
- 30+ real or realistic queries with the passage that answers each (a small labeled set is enough to compare strategies).
- Embedding model input limit in tokens and the generation model's context budget for retrieved text.
- Constraints: index size limits, re-index cost, latency targets.

## Procedure
1. **Profile the corpus.** For each document type record: native structure (headings, sections, list items, table rows, functions, speaker turns), median and p95 length in tokens, and how self-contained a paragraph is. Note boilerplate (headers, footers, navigation) to strip before splitting.
2. **Profile the queries.** Classify the labeled queries as factoid (answer in one sentence), procedural (answer spans steps), comparative or aggregate (answer spans sections), or lookup by identifier. Factoid-heavy workloads favour smaller chunks; procedural and aggregate workloads favour section-sized units or parent-child retrieval.
3. **Choose the unit of retrieval before the size.** Prefer natural boundaries: one section under a heading, one FAQ pair, one table with its caption, one function with its docstring, one speaker turn group. Use recursive splitting (heading, then paragraph, then sentence) only to break units that exceed the size cap. Never split inside a table row, code block, or list item when avoidable.
4. **Set size and overlap as a starting heuristic, then measure.** Common starting points are 200-500 tokens for factoid prose and 500-1,000 for procedural text, with overlap of 0-15% of chunk size. Overlap mainly helps fixed-size splitting; with structure-aware boundaries it often adds duplicates without gains. Treat these as hypotheses, not rules.
5. **Add context to each chunk.** Prepend a short breadcrumb (document title > section path) to the embedded text, and store metadata separately: `doc_id`, `section_path`, `doc_type`, `source_url_or_path`, `updated_at`, `access_scope`, `chunk_index`, `parent_id`. Metadata enables filtering and permission enforcement; the breadcrumb improves embedding of short chunks that lack their subject.
6. **Consider parent-child (small-to-big) retrieval** when queries are factoid but answers need surrounding context: embed small child chunks, retrieve them, and return the parent section to the generator. Cap the parent size to respect the generation budget.
7. **Compare 2-4 candidate strategies** on the labeled queries with recall@k and MRR at the k you will actually pass to the generator. Also record index size (chunk count) and average tokens returned per query, since bigger chunks raise generation cost.
8. **Inspect failures by hand.** For each missed query, look at where the answer landed: split across chunks, diluted in a large chunk, or missing its subject. Adjust boundaries for that document type rather than globally.
9. **Document the decision** per document type, including the version of the splitter so re-indexing is reproducible.

## Expected output
```markdown
## Chunking design: <corpus name>
| Doc type | Unit of retrieval | Max tokens | Overlap | Breadcrumb | Special handling |
|---|---|---|---|---|---|
| Product docs | H2 section | 600 | 0 | Title > H2 > H3 | Tables kept whole with caption |

Metadata schema: doc_id, section_path, doc_type, source, updated_at, access_scope, parent_id
Retrieval mode: <flat | parent-child (child 200 / parent 1200)>

### Evaluation (n=<queries>, k=<k>)
| Strategy | Recall@k | MRR | Chunks | Avg tokens returned |
|---|---|---|---|---|

Decision and rationale: ...
Known failure patterns and follow-ups: ...
```

## Constraints and limitations
- Size and overlap figures above are heuristics; the evaluation result overrides them.
- Small labeled sets give noisy comparisons; treat differences of a few points on 30 queries as inconclusive.
- Never drop `access_scope` metadata: chunking must not let a chunk escape the permissions of its source document.
- Re-chunking requires re-embedding the whole affected corpus; state the cost before recommending it.

## Examples
A support-docs index answered "what is the rate limit for the export API" with a chunk containing only a table of numbers and no API names. Profiling showed tables were split from their headings. The fix: keep each table with its caption and H3 breadcrumb as one chunk, and embed `Export API > Limits` as a prefix. Recall@5 on 40 limit-related queries moved from 0.55 to 0.80 in the team's run, while other doc types were left unchanged.
