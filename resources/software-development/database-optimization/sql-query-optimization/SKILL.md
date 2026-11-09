---
name: sql-query-optimization
description: Diagnoses and rewrites slow SQL by reading EXPLAIN / EXPLAIN ANALYZE plans (PostgreSQL, MySQL, SQL Server, SQLite), fixing non-sargable predicates, bad join strategies, misestimates, pagination, and N+1 query patterns. Use when a specific query or endpoint is slow and you have the SQL, the plan, or ORM code that generates it.
---

# SQL Query Optimization

Most slow queries fail for a handful of reasons: the planner cannot use an index, it misestimates row counts, it reads far more rows than it returns, or the application issues the query hundreds of times. This skill works from evidence — the actual plan — to a rewrite and a measured comparison.

## When to use

- A query, report, or endpoint is slow and you can obtain the SQL and its plan.
- ORM code is suspected of generating inefficient SQL or N+1 patterns.
- Reviewing SQL in a pull request for performance risk.

Not for: designing a new index strategy across a whole schema (`database-index-design`), lock contention and connection pool problems across a system (`database-performance-agent`), or schema changes in production (`database-migration-planner-agent`).

## Inputs

- The SQL text with representative parameter values (not just placeholders).
- The engine and version, e.g. PostgreSQL 16, MySQL 8.0.
- The plan: `EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)` on PostgreSQL; `EXPLAIN ANALYZE` (8.0.18+) or `EXPLAIN FORMAT=TREE` on MySQL; actual execution plan in SQL Server; `EXPLAIN QUERY PLAN` on SQLite.
- Table sizes, existing indexes (`\d table` / `SHOW INDEX FROM t`), and how often the query runs.

## Procedure

1. **Get a real plan safely.** `EXPLAIN ANALYZE` executes the statement. For `UPDATE`/`DELETE`/`INSERT`, wrap it in `BEGIN; ... ROLLBACK;` and run it against a replica or staging copy, never casually on production primary.

2. **Read the plan bottom-up and find where time goes.** In PostgreSQL, each node shows `actual time=first..last rows=N loops=L`; total node time is roughly `last x loops`. Locate the node with the largest exclusive time. Note:
   - **Estimate vs actual rows.** A ratio worse than about 10x usually means stale statistics, correlated columns, or a non-sargable predicate. Fix with `ANALYZE`, extended statistics (`CREATE STATISTICS ... (dependencies)`), or a rewrite.
   - **Rows Removed by Filter** large relative to rows returned: the index is not selective for this predicate, or no index covers it.
   - **Seq Scan** on a large table returning a small fraction of rows: a missing or unusable index.
   - **Nested Loop** with a high-`loops` inner side doing scans: consider a hash join (often caused by a misestimate) or an index on the inner join key.
   - **Sort** with `external merge Disk:` or **Hash** with `Batches > 1`: `work_mem` too small for this query, or sort could be avoided by an index matching `ORDER BY`.
   - **Buffers: shared read** high vs **hit**: cold cache; time the query warm before drawing conclusions.
   In MySQL, check `type` (`ALL` = full scan), `key`, `rows`, `filtered`, and `Extra` (`Using filesort`, `Using temporary`).

3. **Make predicates sargable.** An index on `col` cannot be used for range seeks when the column is wrapped or coerced:
   - `WHERE date(created_at) = '2026-01-05'` → `WHERE created_at >= '2026-01-05' AND created_at < '2026-01-06'`
   - `WHERE lower(email) = $1` → store normalised data or add an expression index on `lower(email)`
   - `WHERE amount + 10 > 100` → `WHERE amount > 90`
   - Implicit casts (`varchar_col = 123`) and leading wildcards (`LIKE '%abc'`) defeat B-tree indexes; use matching types, and trigram or full-text indexes for substring search.
   - `OR` across different columns often blocks index use; try `UNION ALL` of two indexed queries (watch for duplicates).

4. **Reduce rows early and read less.** Select only needed columns (enables index-only scans). Replace `IN (SELECT ...)` / `NOT IN` with `EXISTS` / `NOT EXISTS` where nulls or planner behaviour make it slower (`NOT IN` with a nullable subquery is also a correctness bug). Push filters into subqueries and CTEs; in PostgreSQL 12+, CTEs are inlined unless `MATERIALIZED`. Avoid `SELECT DISTINCT` used to hide a join fan-out — fix the join.

5. **Fix pagination.** `OFFSET 100000 LIMIT 50` reads and discards 100,000 rows. Use keyset pagination: `WHERE (created_at, id) < ($last_created_at, $last_id) ORDER BY created_at DESC, id DESC LIMIT 50`, backed by an index on `(created_at, id)`.

6. **Eliminate N+1 at the application layer.** Symptom: one query for a list, then one per row (visible as many identical statements in logs or APM). Fixes: eager loading (`select_related`/`prefetch_related` in Django, `includes` in Rails, `JOIN FETCH` or entity graphs in JPA), or one batched `WHERE id = ANY($1)` / `IN (...)` query.

7. **Propose an index only when the plan justifies it,** and state its write cost. Hand index design questions with many competing queries to `database-index-design`.

8. **Measure before and after.** Run each version several times warm, compare median execution time, rows read (buffers), and plan shape. Confirm the rewrite returns identical results (compare `EXCEPT` both ways or row counts plus checksums).

## Expected output

```markdown
### Diagnosis
Engine/version: ... · Runs: <freq> · Baseline: <median ms>, <buffers/rows read>
Bottleneck node: <node, why>
Root cause: <non-sargable predicate | misestimate | missing index | N+1 | pagination | ...>
### Rewrite
    <SQL>
### Supporting changes
<index, statistics, ORM change — with write-cost note>
### Evidence
| Version | Median time | Rows/buffers read | Plan shape |
### Correctness check
<how equivalence was verified>
### Risks
```

## Constraints and limitations

- Never run `EXPLAIN ANALYZE` on writes outside a rolled-back transaction, and prefer non-production copies with production-like data volume; small dev databases produce different plans.
- Planner hints and forced join orders are a last resort; they freeze today's data distribution into code.
- Report measured numbers only; label estimates as estimates.
- Behaviour differs across engines and versions; state which one your advice applies to.

## Examples

**Query:** `SELECT * FROM orders WHERE customer_id = 42 AND date(created_at) >= '2026-10-01' ORDER BY created_at DESC LIMIT 20;`
**Plan:** Seq Scan on orders (rows removed by filter: 4.1M), Sort.
**Fix:** rewrite to `created_at >= '2026-10-01'`, select needed columns, add `(customer_id, created_at DESC)` if absent. New plan: Index Scan with no Sort; baseline vs new medians recorded from the user's own runs.
