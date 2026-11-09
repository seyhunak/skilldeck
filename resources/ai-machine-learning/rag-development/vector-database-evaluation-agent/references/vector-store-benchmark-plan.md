# Vector store benchmark plan

A reproducible plan for comparing candidates on the team's own data. Record every setting so the run can be repeated after version upgrades.

## 1. Data preparation

- Sample vectors that represent the production distribution, with real metadata. Use the same embedding model and preprocessing as production.
- Hold out a set of real queries (several hundred to a few thousand). If only documents are available, sample documents as pseudo-queries and say so.
- Compute exact top-k neighbours for every query by brute force, separately for each filter condition being tested. These are the ground truth for recall.
- Define filter conditions at three selectivity levels, for example a filter passing most of the corpus, one passing a moderate share, and one passing a small share. Report the actual pass rates measured on the sample.

## 2. Environment

- Equivalent resources across candidates (vCPU, memory, storage class) or, for managed services, the tier the team would actually buy.
- Client in the same region and network path production would use.
- Warm-up period before measurement; report cold-start behaviour separately if it matters.

## 3. Runs

| Run | What it measures | Procedure |
|---|---|---|
| Build | Index build time, peak memory, final size | Load all sample vectors from empty |
| Recall-latency sweep | Trade-off curve | For each candidate, vary the main search parameter across several values; record recall@k and latency per setting |
| Filtered search | Behaviour under selectivity | Repeat the sweep with each filter level; check result counts reach k |
| Concurrency | Throughput and tail latency | Ramp concurrent clients to expected peak and beyond; record p95/p99 and errors |
| Mixed read/write | Freshness and degradation | Run queries while inserting and updating at the projected rate; measure recall drift and latency |
| Deletes | Correctness and compaction | Delete a share of vectors; confirm they never appear in results; observe compaction effects |
| Restart and restore | Operability | Restart nodes and restore from backup; record time to healthy |

## 4. Reporting rules

- Compare candidates at equal recall, not at defaults.
- Report the number of queries, the k used, and percentile latencies; never only averages.
- Report result-count shortfalls under filters as a failure, even when recall over returned items looks fine.
- Keep raw results so curves can be redrawn.
- Note software versions, index parameters, and hardware for each run.
