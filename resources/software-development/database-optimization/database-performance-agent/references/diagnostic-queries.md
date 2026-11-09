# Read-only diagnostic queries

Starting points for evidence gathering. All statements below only read catalog or statistics views. Verify column names against your engine version's documentation; they change between releases. Run on a replica where possible and set a statement timeout.

## PostgreSQL

Requires the `pg_stat_statements` extension for query statistics (column names shown are for PostgreSQL 13 and later).

```sql
-- Top statements by total execution time
SELECT queryid, calls, round(total_exec_time) AS total_ms,
       round(mean_exec_time::numeric, 2) AS mean_ms, rows,
       left(query, 120) AS query
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;

-- What active sessions are waiting on right now
SELECT wait_event_type, wait_event, state, count(*)
FROM pg_stat_activity
WHERE backend_type = 'client backend'
GROUP BY 1, 2, 3
ORDER BY count(*) DESC;

-- Who is blocking whom
SELECT blocked.pid AS blocked_pid, blocking.pid AS blocking_pid,
       now() - blocking.xact_start AS blocking_xact_age,
       left(blocking.query, 80) AS blocking_query
FROM pg_stat_activity blocked
JOIN LATERAL unnest(pg_blocking_pids(blocked.pid)) AS b(pid) ON true
JOIN pg_stat_activity blocking ON blocking.pid = b.pid;

-- Long or idle-in-transaction sessions
SELECT pid, state, now() - xact_start AS xact_age, left(query, 80)
FROM pg_stat_activity
WHERE xact_start IS NOT NULL
ORDER BY xact_start
LIMIT 20;

-- Tables with heavy sequential scanning
SELECT relname, seq_scan, seq_tup_read, idx_scan, n_live_tup, n_dead_tup,
       last_autovacuum, last_autoanalyze
FROM pg_stat_user_tables
ORDER BY seq_tup_read DESC
LIMIT 20;

-- Indexes never used since statistics reset (check on every replica before dropping)
SELECT schemaname, relname, indexrelname, idx_scan,
       pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY pg_relation_size(indexrelid) DESC;
```

Plan capture: `EXPLAIN (ANALYZE, BUFFERS, VERBOSE) <query>;` on a replica. `EXPLAIN` without ANALYZE does not execute the statement.

## MySQL 8 / InnoDB

```sql
-- Top statement digests by total latency
SELECT digest_text, count_star,
       round(sum_timer_wait / 1e12, 2) AS total_s,
       round(avg_timer_wait / 1e9, 2) AS avg_ms,
       sum_rows_examined, sum_rows_sent
FROM performance_schema.events_statements_summary_by_digest
ORDER BY sum_timer_wait DESC
LIMIT 20;

-- Current lock waits
SELECT * FROM sys.innodb_lock_waits;

-- Long-running transactions
SELECT trx_id, trx_started, trx_state, trx_rows_locked, trx_query
FROM information_schema.innodb_trx
ORDER BY trx_started
LIMIT 20;

-- Unused indexes (sys schema)
SELECT * FROM sys.schema_unused_indexes;
```

A high ratio of `sum_rows_examined` to `sum_rows_sent` is a strong sign of a missing or unusable index. Plan capture: `EXPLAIN FORMAT=TREE <query>;` or `EXPLAIN ANALYZE <query>;` (8.0.18 and later; this executes the query).

## Reading signals

| Signal | Likely meaning |
|---|---|
| Estimated rows off by 10x or more from actual | Stale statistics, correlated columns, or skew; consider extended statistics or `ANALYZE` |
| Sort or hash reported as using disk / temp files | `work_mem` (PG) or `sort_buffer_size` (MySQL) too small for this query, or missing index to provide order |
| Most active sessions in `Lock` / lock waits | Contention; fix transaction scope or lock ordering, not indexes |
| Many sessions `idle in transaction` | Application holding transactions open across slow work |
| Many connections, low CPU, high latency | Pool queuing or connection churn; check pooler |
