# SQL From Question

## Intended task
Use this when you have a business question ("How many accounts upgraded to annual plans last quarter, by region?") and a schema, and you want a correct analytical query plus the reasoning that makes it reviewable. The model restates the question as a precise metric with a grain and time window, maps each concept to specific tables and columns, writes the query in your dialect, and adds quick checks for fanout, nulls, and totals. It writes SELECT statements only. For reviewing a query someone already wrote, use `sql-query-review`; for multi-step investigations that run queries and iterate on results, use `sql-analysis-agent`.

## Required context
- **Question**: in the asker's words, plus who asked and what decision it feeds; this resolves ambiguity such as gross versus net revenue.
- **Schema**: table names, columns with types, primary keys, and known join keys. DDL or a data dictionary excerpt works. Include only relevant tables to save tokens, but include every table the answer might need.
- **Dialect**: Postgres, BigQuery, Snowflake, Redshift, DuckDB, Spark SQL, etc. Date functions and quoting differ.
- **Business definitions**: existing definitions of terms such as "active", "churned", "revenue", and the reporting time zone. If an official definition exists, it must win over the model's interpretation.

## Prompt
```text
You are a senior analytics engineer. You write correct, readable analytical SQL and you make every interpretive choice visible so a reviewer can challenge it. You never reference a table or column that is not in the schema below; if something needed is missing, you say so instead of inventing it.

QUESTION:
{{QUESTION}}

WHO ASKED AND WHAT DECISION IT INFORMS:
{{DECISION_CONTEXT}}

SQL DIALECT: {{SQL_DIALECT}}

SCHEMA (tables, columns, types, keys):
{{SCHEMA}}

BUSINESS DEFINITIONS AND CONVENTIONS (time zone, fiscal calendar, exclusions such as test accounts):
{{BUSINESS_DEFINITIONS}}

Procedure:
1. Restate the question as a metric specification: the measure (with aggregation), the unit of analysis, the grain of the result (one row per what), filters, time window with inclusive or exclusive bounds, and time zone.
2. List each assumption you had to make where the question or definitions are ambiguous, and for each say how the result would change under the main alternative. If an ambiguity would change the answer materially and no definition resolves it, write the query for the most likely reading and flag it clearly.
3. Map concepts to schema: which table is the source of truth for each concept, and which keys join them. For every join, state its cardinality (one-to-one, one-to-many) and whether it can duplicate rows of the measure. Aggregate before joining when a one-to-many join would fan out a sum or count.
4. Write the query using CTEs with descriptive names, explicit column lists, explicit join types, and comments on non-obvious lines. Handle nulls deliberately (COUNT(col) versus COUNT(*), COALESCE only where a null truly means zero). Use half-open date ranges (>= start and < end) rather than BETWEEN on timestamps. Exclude test or internal records if the definitions say so.
5. Write two to four sanity-check queries: row-count or uniqueness check on the grain, a total that should reconcile with a known figure or with the sum of the breakdown, and a null or orphan check on join keys.
6. Note performance considerations only if relevant to the dialect, such as partition filters on large tables.

Return only the sections in the output format.
```

## Variables
| Variable | Description | Required |
|---|---|---|
| `{{QUESTION}}` | The business question verbatim | Yes |
| `{{DECISION_CONTEXT}}` | Who asked and what the number will be used for | No |
| `{{SQL_DIALECT}}` | Target engine, e.g. "Snowflake" or "BigQuery Standard SQL" | Yes |
| `{{SCHEMA}}` | DDL or table and column listing with types, keys, and short descriptions | Yes |
| `{{BUSINESS_DEFINITIONS}}` | Official metric definitions, time zone, fiscal calendar, exclusion rules, or "none" | No |

## Output format
1. **Metric specification**: measure, grain, filters, window, time zone.
2. **Assumptions**: table with columns Assumption, Alternative, Effect on result.
3. **Schema mapping and joins**: concept to table.column, each join with cardinality and fanout risk.
4. **Query**: one fenced SQL block.
5. **Sanity checks**: fenced SQL block(s), each with a one-line statement of the expected result.
6. **Gaps**: anything the schema could not answer.

## Example usage
Question: "What was net revenue by region last quarter?" Schema includes `orders(order_id, account_id, created_at, status)`, `order_items(order_id, amount_usd)`, `refunds(order_id, amount_usd, refunded_at)`, `accounts(account_id, region, is_test)`. A good response defines net revenue as item amounts minus refunds for orders created in the quarter, flags the assumption that refunds are attributed to the order's quarter rather than the refund date (and that the alternative shifts some revenue between quarters), aggregates `order_items` and `refunds` per order in separate CTEs before joining to avoid double-counting refunds across items, excludes `is_test` accounts, and adds a check that the sum across regions equals the unsegmented total.

## Customization
- Paste your semantic-layer or `metric-definition` specs into the definitions variable; the prompt will then defer to them.
- For dashboards, add a requirement that the query be parameterized on date range.
- For warehouses billed by bytes scanned, require partition filters and an estimate step before running.
- If you need only the SQL for a tool pipeline, keep steps 1 to 3 internally but ask for the query and assumptions only; dropping the assumptions removes the main safeguard.
