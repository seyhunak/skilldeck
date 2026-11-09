---
name: retrieval-quality-metrics
description: Compute and interpret retrieval metrics - recall@k, precision@k, hit rate, MRR, and nDCG - over a labeled query set, with per-segment breakdowns and a sound comparison between two retriever variants. Use when evaluating or changing a search or RAG retriever, building relevance judgments, or explaining what a retrieval score actually means.
---

# Retrieval Quality Metrics

## When to use
- Comparing two retriever configurations (embedding model, chunking, hybrid weights, reranker).
- Establishing a retrieval baseline before shipping or upgrading a RAG system.
- Interpreting metric numbers someone else reported and checking they were computed correctly.

Not for: judging the generated answer (use `hallucination-detection` or `llm-judge-rubric-design`). For fusion and reranker tuning procedures see `hybrid-search-tuning`.

## Inputs
- Query set: ideally 50-300 queries sampled from real traffic, stratified by query type.
- Relevance judgments (qrels): for each query, the document or chunk ids judged relevant, binary or graded (for example 0 = not relevant, 1 = partially, 2 = fully answers).
- Ranked results from each retriever variant: query id, rank, document id, score.
- The k values that matter operationally (usually the number of passages sent to the generator).

## Procedure
1. **Fix the unit of relevance.** Decide whether relevance is judged per chunk or per source document. If chunking changes between variants, judge at document or passage-span level, otherwise the variants are not comparable.
2. **Build qrels deliberately.** Pool the top results from all variants being compared (for example top 10 from each), deduplicate, and label the pool blind to which variant retrieved it. Unjudged documents are treated as non-relevant, which biases against variants that surface new documents; pooling reduces this.
3. **Compute the metrics per query, then average (macro).**
   - Hit rate@k: 1 if any relevant item is in the top k.
   - Recall@k = relevant items in top k / total relevant items for the query.
   - Precision@k = relevant items in top k / k.
   - MRR = mean of 1 / rank of the first relevant item (0 if none in the cutoff).
   - DCG@k = sum over ranks i of (2^rel_i - 1) / log2(i + 1); nDCG@k = DCG@k / ideal DCG@k computed from the qrels sorted by grade.
   Exclude queries with zero relevant documents from recall and nDCG, and report how many were excluded.
4. **Choose the headline metric by use.** For RAG, recall@k at the generator's k is usually primary (did the evidence make it in). MRR matters when only the first result is shown. nDCG fits graded relevance and ranked lists shown to users.
5. **Segment the results.** Break metrics down by query type, document type, language, and query length. Averages hide regressions in small but important segments, such as identifier lookups.
6. **Compare variants with paired statistics.** Because both variants run on the same queries, use per-query differences: a paired bootstrap confidence interval on the mean difference, or a sign or Wilcoxon signed-rank test. Report the interval, not only a p-value. Also count queries that improved, regressed, and tied.
7. **Read the regressions.** Pull every query that regressed and inspect the top results. Check whether the "regression" is a labeling gap (a relevant but unjudged document) and update qrels if so, recording the change.
8. **Version everything.** Store qrels version, query set version, retriever config, and metric code version with each result.

## Expected output
```markdown
## Retrieval evaluation: <variant A> vs <variant B>
Query set v<x> (n=<n>, <m> excluded: no relevant docs) | qrels v<y> | judged at <chunk|document> level

| Metric | A | B | Diff (95% CI) |
|---|---|---|---|
| Recall@5 | | | |
| MRR@10 | | | |
| nDCG@10 | | | |

Per-query: improved <a>, regressed <b>, tied <c>
| Segment | n | Recall@5 A | Recall@5 B |
|---|---|---|---|

Notable regressions (query id, cause): ...
Verdict: <ship | do not ship | inconclusive, need more queries>
```

## Constraints and limitations
- With fewer than about 50 queries, intervals are wide; say "inconclusive" rather than declaring a winner.
- Metrics computed on synthetic queries can diverge from real traffic; label the source of every query.
- Recall depends on qrels completeness; report the judging method alongside the number.
- Do not mix micro and macro averaging across reports.

## Examples
A team reported recall@10 of 0.92 for a new embedding model. Recomputing showed 30% of queries had no relevant documents and had been scored as recall 1.0. Excluding them gave 0.78 versus 0.74 for the old model, with a paired bootstrap interval of roughly -0.01 to +0.09: a plausible but unconfirmed gain, so the team added 100 labeled queries before deciding.
