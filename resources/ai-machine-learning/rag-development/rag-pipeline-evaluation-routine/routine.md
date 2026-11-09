# RAG Pipeline Evaluation Routine

## Objective
Produce a dated health report for a production retrieval-augmented generation system that answers four questions: is retrieval still finding the right passages, are answers still faithful to what was retrieved, what are users asking that the corpus cannot answer, and which stage should the team fix first. Each cycle is comparable to the previous one because it reuses the same labeled query set and the same metric definitions, and it adds a fresh production sample so the review tracks how real usage drifts.

## Trigger
Run on a fixed cadence (monthly for high-traffic or fast-changing corpora, quarterly otherwise), and additionally after a change to the embedding model, chunking, index, reranker, or a large corpus import. Also run it when support reports a rise in "the assistant was wrong" complaints. A person leads each cycle; agents can help compute metrics and draft the report but the routine does not run itself.

## Prerequisites
- A labeled query set: questions with the ids of the passages or documents that answer them, versioned. If none exists, the first cycle should build one (`retrieval-quality-metrics` describes labeling and metrics).
- Access to retrieval logs that record query, returned chunk ids with ranks and scores, and the generated answer.
- The ability to rerun retrieval and generation offline against the pinned configuration.
- The previous cycle's report, for trend comparison.
- An owner for the corpus (who can fix stale documents) and an owner for the pipeline.

## Inputs
- Pipeline configuration snapshot: embedding model, chunk size and overlap, top-k, hybrid weights, reranker, generation prompt version, model id.
- Labeled query set version.
- A random sample of recent production queries (for example 100 to 200), with answers and retrieved chunks.
- Corpus metadata: document counts by source, last-updated dates, and changes since last cycle.

## Steps
1. **Snapshot configuration and corpus.** Record every pipeline setting and corpus counts. Diff against last cycle; any change is a candidate explanation for metric movement and should be listed before looking at metrics.
2. **Measure retrieval on the labeled set.** Compute recall@k at the k the generator actually receives, plus MRR or nDCG if ranks matter to your prompt. Break results down by query type or source collection; aggregate numbers hide a collapsed segment.
3. **Measure generation on the labeled set.** For queries where retrieval succeeded, score answer faithfulness (every claim supported by cited passages) and answer correctness against reference answers. Use claim-level checking as in `hallucination-detection`, and calibrate any LLM judge against a small human-labeled slice each cycle.
4. **Attribute failures to a stage.** For each failed query, classify the root cause: not in corpus, in corpus but not retrieved, retrieved but ranked below the cutoff, retrieved but ignored or misread by the generator, or correct passages stale or contradictory. This attribution is the main output; it decides whether the fix is content, chunking, retrieval tuning, or the prompt.
5. **Review the production sample.** Label the fresh sample for the same root causes, and cluster unanswered or abstained questions by topic. New clusters are coverage gaps that the labeled set does not yet represent; add representative queries to the labeled set (as a new version) so future cycles track them.
6. **Check freshness and conflicts.** List the most-retrieved documents whose last-updated date exceeds your staleness threshold, and any pairs of retrieved passages that contradict each other. Send these to the corpus owner rather than tuning retrieval around them.
7. **Compare with the previous cycle.** Put this cycle's metrics next to the last two cycles. Treat small movements on small query sets with caution; with 100 queries, a few points of recall can be noise. Report counts as well as percentages.
8. **Prioritize fixes.** Rank root-cause categories by number of affected queries weighted by business importance. Propose the cheapest fix per category, and name the experiment that would confirm it (for example, test a hybrid weight change with `hybrid-search-tuning` on the labeled set before production).

## Decision points
- **Recall@k drops beyond your alert threshold with no config change**: inspect corpus changes first (deleted or re-chunked sources), then the index build.
- **Retrieval is good but faithfulness falls**: the issue is generation; review prompt changes and model version, and test the grounding prompt on failed cases.
- **Most failures are "not in corpus"**: escalate to content owners; retrieval tuning cannot fix missing knowledge.
- **A proposed fix touches embeddings or chunking**: require a full re-index plan with offline comparison on the labeled set before approval, since it changes every query.
- **The judge disagrees with human labels on more than a small share of the calibration slice**: report judge-based metrics as provisional this cycle.

## Expected output
A cycle report with: configuration snapshot and diff; retrieval metrics by segment with trend versus prior cycles; generation faithfulness and correctness; a root-cause table (category, count, example query ids); coverage-gap clusters from production; stale and conflicting documents for content owners; a ranked fix list with proposed experiments; and the new labeled-set version number.

## Validation checklist
- [ ] Configuration and labeled-set versions are recorded and diffed against the last cycle.
- [ ] Retrieval and generation metrics are reported separately.
- [ ] Every failed query has exactly one primary root-cause category.
- [ ] Production sample findings fed new queries into a new labeled-set version.
- [ ] Trend comparisons include absolute counts and note small-sample uncertainty.
- [ ] Stale or conflicting documents were handed to a named corpus owner.

## Human approval
The pipeline owner approves the fix list and any experiment that changes production retrieval, embeddings, chunking, or the generation prompt. Corpus changes (deleting, rewriting, or re-permissioning documents) require the content owner's approval. Changes to the labeled query set's existing labels, as opposed to added queries, need a second reviewer so that metrics stay comparable across cycles.
