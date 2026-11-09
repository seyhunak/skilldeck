---
name: data-profiling
description: Profiles a table or dataset with aggregate queries - volume and freshness, candidate key uniqueness, null and blank rates, cardinality, numeric distributions, categorical frequencies, date ranges, and cross-column consistency - and summarizes red flags. Use before analyzing, modeling, or trusting an unfamiliar or newly ingested source, or as a baseline during a data quality investigation.
---

# Data Profiling

A profile is a short, factual description of what a dataset actually contains, as opposed to what its documentation claims. It catches duplicate keys, sentinel values, truncated loads, and type confusion before they contaminate analysis. This skill uses aggregate SQL (or the dataframe equivalent) and never needs to print individual records.

## When to use

- First contact with a new table, source, or file.
- Before building a model or metric on a table whose grain is undocumented.
- As the baseline step of a data quality investigation, to compare a good period with a bad one.
- Not a substitute for ongoing monitoring; turn the findings into tests afterwards.

## Inputs

- Table or file reference and engine/dialect.
- Expected grain or primary key, if documented.
- Optional: a time column for slicing, and a period of interest.
- Optional: column list to focus on when the table is very wide.

## Procedure

1. **Volume and freshness.** Total rows; rows per day/week over the available range (look for gaps, cliffs, and spikes); min and max of the load or event timestamp; the max loaded timestamp versus now. On large tables, profile a recent partition and a sampled historical one rather than scanning everything, and say so.
2. **Keys and grain.** For the declared or candidate key: `COUNT(*)` versus `COUNT(DISTINCT key)`; null keys; for composite keys, distinct count of the tuple. If duplicates exist, characterize them: exact duplicate rows (load issue) versus same key with different values (versioning or a wrong grain assumption).
3. **Per-column completeness.** Null rate, and for strings also blank (`''`, whitespace) and placeholder rates (`'N/A'`, `'unknown'`, `'null'`, `'0'`). Placeholders are nulls in disguise.
4. **Numeric columns.** Min, max, mean, median, p1/p5/p95/p99, standard deviation, count of zeros and negatives. Look for sentinel values (`-1`, `999999`, `0` where impossible), unit inconsistencies (cents vs. currency units appearing as a bimodal distribution), and long tails that will dominate means.
5. **Categorical columns.** Distinct count, top 10-20 values with frequencies, and the long-tail share. Check case and whitespace variants (`'US'`, `'us'`, `'US '`), unexpected new values, and whether a column documented as an enum is free text.
6. **Date and time columns.** Range, values in the future or before the business existed, default dates (`1970-01-01`, `1900-01-01`), time zone indicators, and distribution by hour (a spike at 00:00 often means a date stored as a timestamp).
7. **Cross-column rules.** Logical consistency: `end >= start`, `total = sum(lines)`, `status = 'shipped'` implies `shipped_at` not null, country matches currency where expected. Choose 3-5 rules that matter for the intended use.
8. **Referential integrity.** For foreign keys, the share of values with no match in the parent table (orphans) and the share of parent rows never referenced.
9. **Summarize red flags.** Rank findings by impact on the intended use and convert the important ones into proposed tests (unique, not null, accepted values, range, relationship, freshness).

## Expected output

```markdown
## Profile: <table> (as of <timestamp>, scope: <full | partition | sample>)
Rows: … · Date range: … · Latest load: … · Declared grain: … · Grain holds: yes/no (details)

| Column | Type | Null % | Distinct | Min / Max or Top values | Flags |
|---|---|---|---|---|---|

### Red flags
1. <finding> - evidence - impact - proposed test

### Volume over time
<short description or small table of rows per period, with gaps noted>
```

## Constraints and limitations

- Aggregate queries only; for personal data columns (emails, names, phone numbers) report counts and patterns, never raw values. Show example values only in masked form (for example `j***@example.com`).
- Sampling can miss rare defects; state the sampling method.
- A profile describes data, it does not judge correctness; validity rules must come from the business.
- On engines that bill by bytes scanned, estimate cost and restrict columns and partitions first.

## Examples

Profiling `raw.payments` (last 90 days) finds: `payment_id` has 0.4% duplicate keys, all exact duplicate rows concentrated on two load dates (likely a connector retry); `amount` is bimodal around 49 and 4,900, suggesting some rows in cents; `currency` has 6 values including `'usd'` and `'USD'`; 2.1% of `customer_id` values have no match in `customers`. Proposed tests: unique `payment_id`, accepted values on uppercase currency, relationship test to customers with a warn threshold, and a range check on `amount` per currency.
