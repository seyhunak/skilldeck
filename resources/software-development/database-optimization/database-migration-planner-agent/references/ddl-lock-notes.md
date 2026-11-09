# DDL Lock Notes (PostgreSQL and MySQL/InnoDB)

General guidance for planning. Behaviour changes between versions; always confirm in the official documentation for the exact version and managed service in use, and rehearse on a production-sized copy.

## PostgreSQL

| Operation | Typical behaviour | Safer approach |
|---|---|---|
| `ADD COLUMN` nullable, no default | Brief ACCESS EXCLUSIVE lock, no rewrite | Safe with `lock_timeout` + retry |
| `ADD COLUMN ... DEFAULT <constant>` | No rewrite since PostgreSQL 11 for non-volatile defaults | Volatile defaults (e.g. random) still rewrite |
| `ALTER COLUMN TYPE` | Usually full table rewrite under ACCESS EXCLUSIVE (some binary-compatible changes avoid it) | New column + dual write + backfill + switch |
| `SET NOT NULL` | Full scan under ACCESS EXCLUSIVE | Add `CHECK (col IS NOT NULL) NOT VALID`, `VALIDATE CONSTRAINT`, then `SET NOT NULL` (PostgreSQL 12+ can use the validated check to skip the scan) |
| `ADD FOREIGN KEY` | Validation scan with locks on both tables | `ADD CONSTRAINT ... NOT VALID`, then `VALIDATE CONSTRAINT` (weaker lock) |
| `CREATE INDEX` | Blocks writes for the build | `CREATE INDEX CONCURRENTLY` (cannot run inside a transaction block; failed builds leave an INVALID index to drop) |
| Add unique constraint | Builds index under lock | Build unique index concurrently, then `ADD CONSTRAINT ... USING INDEX` |
| `RENAME COLUMN` | Fast, but breaks old code immediately | Expand/contract with new column or a view |
| `DROP COLUMN` | Fast (marks dropped), but breaks readers | Remove from code and ORM first, then drop |

Lock queueing: an ACCESS EXCLUSIVE request waits behind any open transaction touching the table, and later queries queue behind the request. Use `SET lock_timeout = '<short>'` for migration sessions and retry; check `pg_stat_activity` for long transactions before starting.

## MySQL 8.0 / InnoDB

- Many operations support `ALGORITHM=INSTANT` (for example adding a column in 8.0.12+, with later versions expanding positions) or `ALGORITHM=INPLACE, LOCK=NONE`. Specify the algorithm explicitly so the statement fails instead of silently falling back to a copying rebuild.
- Changing a column type usually requires `ALGORITHM=COPY`, which blocks writes for the duration. Use an online schema change tool (gh-ost, pt-online-schema-change) for large tables.
- Metadata locks: DDL waits for open transactions on the table; queries behind it queue. Set `lock_wait_timeout` low for migration sessions.
- Online DDL on a primary may cause replication lag on replicas applying the same statement; online schema change tools throttle on lag.

## Backfill pattern

```sql
-- Keyset batch; repeat with the last id seen until no rows are updated.
UPDATE target_table
SET new_col = <expression of old_col>
WHERE id > :last_id AND id <= :last_id + :batch
  AND new_col IS NULL;
```

- Commit each batch; sleep or throttle when replica lag or load exceeds a threshold.
- Record progress so the job can resume.
- Idempotent predicate (`new_col IS NULL` or a version check) so reruns are safe.

## Verification query shapes

- Row counts where old and new disagree: `SELECT count(*) FROM t WHERE new_col IS DISTINCT FROM <expr>(old_col);`
- Aggregates per key range to localise mismatches.
- Constraint validation status: invalid constraints or indexes remaining after the run.
