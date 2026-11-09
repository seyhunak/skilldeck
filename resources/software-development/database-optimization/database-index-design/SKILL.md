---
name: database-index-design
description: Designs relational database indexes from the actual query workload - composite column ordering (equality, sort, range), covering and INCLUDE indexes, partial and expression indexes, redundancy removal, and the write, storage, and lock cost of each index. Use when adding indexes for new queries, rationalising an over-indexed table, or reviewing index changes in a migration.
---

# Database Index Design

An index is a trade: faster reads for specific query shapes in exchange for slower writes, more storage, more memory pressure, and longer maintenance. This skill designs the smallest set of indexes that serves the workload, using the B-tree rules that decide whether an index is usable at all.

## When to use

- New queries or features need index support.
- A table has accumulated many overlapping indexes and writes are slowing.
- Reviewing a migration that adds or drops indexes.

Not for: rewriting a single slow query (`sql-query-optimization`), planning the production rollout of schema changes (`database-migration-planner-agent`), or document stores with their own index models (e.g. MongoDB-specific tooling).

## Inputs

- The queries that matter: SQL text with typical parameters, frequency, and latency target. Best source: `pg_stat_statements` (PostgreSQL), Performance Schema digest tables or the slow log (MySQL), Query Store (SQL Server).
- Table definitions, row counts, and value distributions for filtered columns (how selective is `status = 'open'`?).
- Existing indexes and their usage: `pg_stat_user_indexes.idx_scan` (PostgreSQL), `sys.schema_unused_indexes` (MySQL sys schema), `sys.dm_db_index_usage_stats` (SQL Server).
- Write rate on the table and engine/version.

## Procedure

1. **Group queries by access pattern.** For each important query write its shape: equality predicates, range predicates, `ORDER BY`, `GROUP BY`, selected columns, `LIMIT`. Several queries often share one index.

2. **Order composite columns with the ESR rule (a heuristic).** **E**quality columns first, then **S**ort columns (matching `ORDER BY` direction), then **R**ange columns. A B-tree can seek on a left prefix of its columns; after the first range predicate, later columns can only filter, not seek. Example: `WHERE tenant_id = ? AND status = ? AND created_at > ? ORDER BY created_at` → `(tenant_id, status, created_at)`. Among equality columns, order matters less for seeking; put the column also used alone by other queries first so one index serves both.

3. **Cover hot queries when it pays off.** If a frequent query reads few columns, include them so the engine can answer from the index alone (index-only scan in PostgreSQL — dependent on the visibility map being current — or "Using index" in MySQL). PostgreSQL 11+ and SQL Server support `INCLUDE (col)` for non-key payload columns; in MySQL InnoDB, secondary indexes implicitly contain the primary key. Do not cover wide columns; index size grows with them.

4. **Use partial and expression indexes for skewed or computed predicates.**
   - Partial (PostgreSQL, SQLite; SQL Server "filtered"): `CREATE INDEX ... ON jobs (run_at) WHERE status = 'pending'` when queries always target a small subset. The query's predicate must imply the index predicate.
   - Expression/functional: `CREATE INDEX ON users (lower(email))` to support `WHERE lower(email) = ?` (MySQL 8.0.13+ functional key parts; or generated columns).
   - Unique partial indexes enforce rules like "one active subscription per user".

5. **Pick the right index type.** B-tree for equality, range, and sort (the default). PostgreSQL alternatives: GIN for `jsonb` containment, arrays, and full-text; GiST/SP-GiST for geometric and range types and exclusion constraints; BRIN for very large, naturally ordered append-only tables (timestamps); hash for equality only. Trigram GIN (`pg_trgm`) for `LIKE '%term%'`.

6. **Remove redundancy.** An index on `(a)` is redundant with `(a, b)` for most purposes (unless it is unique or much smaller and hot). Duplicates with identical columns are pure cost. Indexes with zero scans since the last statistics reset are candidates for removal — check the stats window covers month-end jobs and replicas (usage counters are per server).

7. **Account for costs.** Each index adds work to every `INSERT`, to `UPDATE`s that change indexed columns (and in PostgreSQL can prevent HOT updates), and to `DELETE`s; it consumes storage and buffer cache. Prefer one well-designed composite over several single-column indexes. Check foreign keys: unindexed FK columns make parent deletes and joins slow (PostgreSQL does not index FKs automatically; MySQL InnoDB does).

8. **Plan safe creation.** Build without blocking writes: `CREATE INDEX CONCURRENTLY` (PostgreSQL; cannot run inside a transaction, leaves an INVALID index on failure that must be dropped), `ALGORITHM=INPLACE, LOCK=NONE` (MySQL InnoDB online DDL), `ONLINE = ON` (SQL Server, edition-dependent). Estimate build time and disk on a production-sized copy.

9. **Verify with plans.** Run `EXPLAIN` for each target query before and after (on realistic data) and confirm the index is chosen and the plan improves. Then monitor usage counters after release.

## Expected output

```markdown
### Workload
| Query id | Shape (eq / sort / range / cols) | Calls/day | Current p95 | Target |
### Proposed indexes
| Index DDL | Serves queries | Why this column order | Est. size | Write cost note |
### Indexes to drop
| Index | Reason (redundant/unused) | Evidence (stats window) |
### Rollout
<online creation command, order, rollback>
### Verification
<EXPLAIN before/after per query>
```

## Constraints and limitations

- Do not drop indexes based on usage stats from a short window, a single replica, or without checking unique/constraint roles.
- Size and timing estimates must be labelled as estimates; measure on a copy for large tables.
- The planner may ignore an index for low-selectivity predicates or small tables; that is often correct.
- Engine features and syntax differ; state which engine and version the DDL targets.

## Examples

**Queries:** (1) `WHERE account_id = ? AND state = 'open' ORDER BY due_at LIMIT 50` — 40k calls/day; (2) `WHERE account_id = ? AND due_at < now()` — nightly.
**Existing:** `(account_id)`, `(state)`, `(due_at)`.
**Design (PostgreSQL):** `CREATE INDEX CONCURRENTLY invoices_open_due ON invoices (account_id, due_at) WHERE state = 'open';` serves query 1 with no sort; add `(account_id, due_at)` without the predicate only if query 2 needs closed invoices too. Drop `(state)` if its scan counter is zero over a full billing cycle; `(account_id)` becomes redundant once the composite exists.
