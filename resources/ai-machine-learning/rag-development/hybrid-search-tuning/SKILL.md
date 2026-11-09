---
name: hybrid-search-tuning
description: Tune hybrid retrieval that combines BM25 lexical search with vector search - analyzer and BM25 settings, fusion via reciprocal rank fusion or normalized weighted scores, candidate depth, cross-encoder reranking, and parameter sweeps measured on labeled queries with latency checks. Use when vector-only or keyword-only search misses relevant results, or when an existing hybrid setup uses untuned defaults.
---

# Hybrid Search Tuning

## When to use
- Vector search misses exact identifiers, product codes, error messages, names, or rare terms.
- Keyword search misses paraphrases and conceptual queries.
- A hybrid setup exists but its fusion weights or reranker were never measured.

Not for: deciding chunk boundaries (see `chunking-strategy-design`) or choosing a vector database (see `vector-database-evaluation-agent`). This skill depends on `retrieval-quality-metrics` for measurement.

## Inputs
- A labeled query set with relevance judgments, ideally 100+ queries, tagged by query type (identifier lookup, keyword, natural-language question, conceptual).
- Access to both retrievers' ranked results with scores, and to a reranker if one is available.
- Latency budget for the retrieval stage and the final k sent to the generator.

## Procedure
1. **Baseline each retriever alone.** Compute recall@k and MRR or nDCG for BM25-only and vector-only, per query type. Typical pattern: BM25 wins on identifiers and rare terms, vectors win on paraphrase. If one retriever dominates every segment, hybrid may add latency without benefit.
2. **Fix the lexical side first.** Check analyzers: tokenization of codes and hyphenated ids, stemming, stop words, and language handling. Field boosts (title over body) often matter more than BM25 parameters. BM25's k1 (term-frequency saturation, commonly around 1.2) and b (length normalization, commonly 0.75) are reasonable defaults; tune them only after analyzer issues are fixed, and only on the labeled set.
3. **Choose a fusion method.**
   - Reciprocal rank fusion (RRF): score(d) = sum over retrievers of 1 / (k + rank(d)), with k commonly set to 60. It uses ranks only, so it needs no score normalization and is a robust default.
   - Weighted score fusion: score = alpha x norm(vector) + (1 - alpha) x norm(bm25), with min-max or z-score normalization per query. It can outperform RRF when tuned, but it is sensitive to score distributions that shift across queries and index updates.
   Start with RRF; try weighted fusion if per-segment results suggest one retriever should count more.
4. **Set candidate depth.** Retrieve N candidates from each retriever before fusion (for example 50-100 each), so that relevant documents ranked moderately by one retriever can still surface. Measure recall@N of the union; if it is low, no fusion or reranking can recover the missing documents.
5. **Sweep parameters.** Grid over RRF k (for example 10, 30, 60, 100) and per-retriever weights, or alpha in steps of 0.1 for weighted fusion. Evaluate on a tuning split and confirm the chosen setting on a held-out split. Report per-segment results, not just the mean.
6. **Add reranking if it pays.** A cross-encoder reranker scores each query-candidate pair jointly and usually improves top-k precision. Rerank the top M fused candidates (for example 20-100). Measure gain in recall@k and nDCG at the generator's k against added latency and cost; choose M at the knee of that curve.
7. **Apply filters correctly.** Metadata and permission filters must apply to both retrievers before fusion, otherwise one side can leak or crowd out filtered results.
8. **Check latency end to end.** Run both retrievers in parallel; measure p50 and p95 for retrieval, fusion, and reranking separately.
9. **Record the configuration** with the query set and qrels versions, and re-run the evaluation when the embedding model, analyzer, or corpus changes materially.

## Expected output
```markdown
## Hybrid search tuning: <index> (queries v<x>, qrels v<y>)
| Config | Recall@5 | nDCG@10 | Identifier recall@5 | Question recall@5 | p95 latency |
|---|---|---|---|---|---|
| BM25 only | | | | | |
| Vector only | | | | | |
| RRF k=60, N=100 | | | | | |
| RRF + rerank top 50 | | | | | |
Union recall@N: <x>
Chosen config: <fusion, params, N, M>; held-out confirmation: <metric values>
Trade-offs and follow-ups: ...
```

## Constraints and limitations
- Parameter values quoted above are common starting points, not universal optima; the labeled set decides.
- Tuning on few queries overfits; keep a held-out split and report segments with their sizes.
- Reranker gains depend on domain match; a general reranker may underperform on specialized jargon.
- Score-based fusion must be re-checked after re-indexing or model changes because score scales shift.

## Examples
An internal IT knowledge base used vector-only search; queries containing error codes like `0x80070005` had recall@5 of 0.31. Adding BM25 with an analyzer that kept hex codes intact and fusing with RRF (k=60, 50 candidates each) raised error-code recall@5 to 0.84 while question-style queries stayed flat. A reranker over the top 30 added a further gain on questions at an acceptable p95 latency, so both were adopted.
