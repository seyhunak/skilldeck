---
name: dbt-model-review
description: Reviews dbt models and projects for layering (sources, staging, intermediate, marts), correct ref/source usage, materialization and incremental strategy, tests, documentation, configs, and maintainability. Use on dbt pull requests, when onboarding to a dbt project, or when a model produces suspicious results or runs slowly.
---

# dbt Model Review

dbt turns SQL into a dependency graph with tests and docs. Most dbt defects are not syntax errors; they are layering shortcuts, incremental models that silently drop data, untested grains, and business logic copied between models. This skill reviews one model or a whole project with concrete, file-cited findings.

## When to use

- Reviewing a pull request that adds or changes dbt models, macros, sources, or YAML.
- Auditing an inherited dbt project.
- Diagnosing a dbt model that is slow, expensive, or returns surprising numbers.
- Not for reviewing orchestration outside dbt in depth, or for non-SQL Python models beyond basic structure.

## Inputs

- The model SQL files and associated YAML (`schema.yml` / `_models.yml`, `sources.yml`), `dbt_project.yml`, and relevant macros.
- Optional: `manifest.json` and `run_results.json` for lineage and runtimes.
- Warehouse adapter (Snowflake, BigQuery, Redshift, Databricks, Postgres, DuckDB) because materialization options differ.
- The purpose of the change (for pull requests).

## Procedure

1. **Check layering and naming.** Typical convention: `stg_<source>__<entity>` models are 1:1 with source tables and only rename, cast, and lightly clean; `int_` models combine and reshape; `fct_`/`dim_` (or business-named) marts serve consumers. Flag staging models that join or aggregate, marts that read raw sources directly, and circular-looking cross-layer references. Conventions vary by team; review against the project's own documented convention first.
2. **Check `ref` and `source` usage.** Every raw table must come through `source()` (enables freshness and lineage); every model reference through `ref()`. Hard-coded schema.table names break environments and lineage. Check that sources declare `loaded_at_field` and freshness thresholds for tables that matter.
3. **Check grain and tests.** Every model should state its grain in its description and have `unique` + `not_null` tests on its primary key (or a combination-of-columns uniqueness test via a package such as dbt_utils). Foreign keys into dimensions should have `relationships` tests; enumerations should have `accepted_values`. Consider `severity: warn` with thresholds for known messy sources rather than disabling tests.
4. **Check materialization.** Views for light staging transformations; tables for marts queried often; incremental for large append-heavy facts where full rebuilds are costly; ephemeral sparingly (it hides intermediate results and complicates debugging). A chain of views on top of views can make every dashboard query recompute the whole pipeline.
5. **Check incremental logic carefully.** Is there an `is_incremental()` filter? Does it include a lookback window for late-arriving data (for example, reprocess the last N days rather than `> max(updated_at)`)? Is `unique_key` set so updates merge instead of duplicating? Which strategy is used (`merge`, `delete+insert`, `insert_overwrite`, `append`) and does it suit the adapter and data? How are source deletes handled? Is `on_schema_change` set deliberately? Can the model be rebuilt with `--full-refresh` within an acceptable cost?
6. **Check SQL correctness.** Apply a SQL correctness review: join fan-out, outer join filters, null handling, timezone conversions, and deterministic deduplication (`row_number()` with a tiebreaker).
7. **Check DRY and macros.** Business logic (for example "active customer" or revenue recognition rules) should live in one model or macro, not be pasted into several marts. Macros should be readable; heavy Jinja that obscures SQL is a maintainability cost. Prefer established packages over custom macros for generic utilities.
8. **Check documentation and governance.** Model and key column descriptions present; `meta` owner or group; exposures for important dashboards; contracts (`contract: enforced`) and model versions for public models that other teams depend on, where the dbt version supports them.
9. **Check configuration and performance.** Partitioning and clustering on large tables (adapter-specific), `full_refresh: false` protection on expensive incremental models if appropriate, tags used for scheduling, no `select *` in marts.
10. **Write findings.** Group by severity with file paths and suggested changes; acknowledge what is done well briefly.

## Expected output

```markdown
## dbt review: <model or project> (<adapter>, dbt <version if known>)

**Summary:** …
| # | Severity | File / model | Area | Finding | Suggested change |
|---|---|---|---|---|---|

**Test coverage of reviewed models:** PK x/y · relationships x/y · source freshness x/y
**Incremental models reviewed:** <model - strategy - lookback - verdict>
**Questions for the author:** …
```

Severity: **Blocker** (wrong or lost data), **Major** (likely future incident or large cost), **Minor** (convention, readability).

## Constraints and limitations

- Review only; do not run `dbt run`, `dbt build`, or full refreshes. `dbt parse`, `dbt compile`, or `dbt ls` may be suggested to the user for inspection.
- Feature availability (contracts, versions, microbatch incremental strategy, unit tests) depends on dbt version and adapter; check before recommending.
- Data effects (for example, late-arrival frequency) need data to confirm; label such findings as risks.
- Do not print credentials from `profiles.yml` if encountered.

## Examples

Model `fct_orders` (incremental, Snowflake) uses `where updated_at > (select max(updated_at) from {{ this }})` with no `unique_key`. Findings: Blocker - updated orders are appended again, creating duplicate `order_id` rows; set `unique_key='order_id'` with the merge strategy. Major - no lookback; rows that arrive late with an older `updated_at` are skipped forever; filter on `updated_at > max(updated_at) - interval '3 days'` (window chosen from observed lateness). Major - no `unique` test on `order_id`, so the duplication went undetected. Minor - the model selects from `raw.shop.orders` directly; define a source and a `stg_shop__orders` model.
