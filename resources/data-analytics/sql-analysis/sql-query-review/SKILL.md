---
name: sql-query-review
description: Reviews analytical SELECT queries for correctness - join fan-out, null semantics, filter placement on outer joins, window frames, date and timezone boundaries, grain, and aggregation errors - and proposes cheap verification queries. Use before trusting, sharing, or merging any query whose numbers will inform a decision, or when two queries disagree.
---

# SQL Query Review

Analytical queries rarely crash; they return a plausible wrong number. This skill is a correctness review, not a performance review (for speed and EXPLAIN plans, use a query optimization skill). Work through the checklist in order, because early issues (grain, joins) change everything downstream.

## When to use

- Before a query's result goes into a dashboard, deck, model, or decision.
- When reviewing a pull request that changes analytical SQL or a dbt model's logic.
- When two queries for "the same metric" disagree.
- Not for DDL/DML review, security review, or tuning execution time.

## Inputs

- The SQL text and dialect (Postgres, Snowflake, BigQuery, Redshift, Databricks, DuckDB, etc.).
- The intended question or metric definition, in words.
- Table grains and keys, if known (from docs, dbt tests, or profiling). If unknown, the review must include queries to establish them.
- Optional: the query's output and any reference figure it should match.

## Procedure

1. **State the intended output grain.** Write "one row per ___". Compare it with the `GROUP BY` (or lack of one) and the final select list. Any non-aggregated column not in the grain is a bug or a hidden assumption.
2. **Check every join for fan-out.** For each join, establish the cardinality (1:1, 1:N, N:M) from keys. If the right side is not unique on the join key, rows multiply and later `SUM`s inflate. Typical trap: joining orders to order_items and to payments in the same query, then summing order totals. Fix by aggregating each fact to the target grain in its own CTE before joining, or by using `COUNT(DISTINCT)` only when the measure is genuinely a distinct count. Verify with `SELECT key, COUNT(*) ... GROUP BY key HAVING COUNT(*) > 1`.
3. **Check outer join semantics.** A `WHERE` predicate on a column from the optional side of a `LEFT JOIN` turns it into an inner join; move the predicate into the `ON` clause if unmatched rows should survive. Check whether `COALESCE` defaults on unmatched rows are meaningful (0 revenue vs. unknown).
4. **Check null handling.** `COUNT(col)` skips nulls while `COUNT(*)` does not; `AVG` ignores nulls (which may bias it); `col <> 'x'` excludes null rows; `NOT IN (subquery)` returns no rows if the subquery yields any null (prefer `NOT EXISTS`); concatenation and arithmetic with null yield null; nulls in join keys never match.
5. **Check time logic.** Which timestamp anchors the window (created, updated, event, settled)? Is the comparison half-open (`>= start AND < end`) rather than `BETWEEN` on timestamps, which includes midnight of the end day or misses the last day's afternoon on dates? Are timestamps converted to the business time zone before truncation to day/week/month? Are week starts consistent with the business (Monday vs. Sunday, ISO weeks)? Is the current incomplete period excluded or labeled?
6. **Check aggregation and arithmetic.** Integer division (`1/2 = 0` in several engines); averaging pre-computed ratios instead of dividing sums; summing semi-additive balances across time; distinct counts summed across groups (users counted in several groups); currency mixing; rounding before aggregation.
7. **Check window functions.** `PARTITION BY` and `ORDER BY` match intent; ties in `ORDER BY` make `ROW_NUMBER()` dedup non-deterministic (add a tiebreaker); default frames with `ORDER BY` are `RANGE ... CURRENT ROW` in many engines, which treats ties as peers in running totals; `LAG` across partitions; `QUALIFY` support differs by dialect.
8. **Check filters and population.** Test/internal accounts, soft-deleted rows, cancelled or refunded records, duplicates from CDC/replication, and status values: are they handled as the metric definition says? Are hard-coded IDs or dates present?
9. **Check deduplication.** `SELECT DISTINCT` used to hide a fan-out is a smell; find the cause instead. Dedup with `ROW_NUMBER()` needs a deterministic order.
10. **Propose verification queries.** At minimum: a grain check on the output, a total reconciliation against a simpler query or known figure, a bounds check (rates between 0 and 1, subset no larger than parent), and a spot check of two or three entities traced by hand.

## Expected output

```markdown
## SQL review: <query name>
**Intended grain:** one row per … · **Verdict:** Correct | Correct with caveats | Incorrect

| # | Severity | Line/CTE | Issue | Effect on result | Fix |
|---|---|---|---|---|---|

### Verification queries
1. Grain: …
2. Reconciliation: …
3. Bounds: …

### Assumptions to confirm
- …
```

Severity: **Blocker** (result is wrong), **Major** (wrong under plausible data conditions), **Minor** (readability or fragility).

## Constraints and limitations

- Without knowing table grains, conclusions about fan-out are conditional; say so and provide the query to check.
- Dialect semantics differ (null ordering, default window frames, date functions, integer division); confirm against the engine's documentation when it matters.
- Only suggest read-only verification queries.
- Do not rewrite the whole query for style if it is correct; focus on correctness.

## Examples

Query: `SELECT c.region, SUM(o.amount) FROM customers c LEFT JOIN orders o ON o.customer_id = c.id LEFT JOIN support_tickets t ON t.customer_id = c.id WHERE o.created_at BETWEEN '2026-10-01' AND '2026-10-31' GROUP BY 1`

Findings: (1) Blocker - joining tickets (1:N per customer) multiplies each order by the customer's ticket count, inflating `SUM(o.amount)`; tickets are unused, so remove the join. (2) Major - `WHERE o.created_at` on the optional side makes the `LEFT JOIN` inner; acceptable here only if customers without orders should be excluded. (3) Major - `BETWEEN` with a date literal on a timestamp excludes October 31 after midnight; use `>= '2026-10-01' AND < '2026-11-01'` after converting to the business time zone.
