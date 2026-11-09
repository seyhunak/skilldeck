---
name: data-dictionary-authoring
description: Writes precise data dictionary entries for tables and columns - business definition, grain, type, allowed values, meaning of null, derivation and lineage, owner, freshness, and sensitivity classification - and reviews existing entries for vague or circular wording. Use when documenting a warehouse, dbt project, dataset handoff, or data catalog, or when people misuse a column because its meaning is unclear.
---

# Data Dictionary Authoring

A good dictionary entry lets a new analyst use a column correctly without asking anyone. Most entries fail by restating the column name ("customer_status: the status of the customer"). This skill provides a template, writing rules, and a review checklist to produce definitions that settle questions instead of raising them.

## When to use

- Documenting new tables or models before they are shared.
- Filling `description` fields in dbt YAML or a data catalog.
- Preparing a dataset handoff to another team or vendor.
- Cleaning up documentation after repeated misuse or conflicting interpretations of a column.
- Not for metric definitions that combine columns into KPIs; document those with a metric specification.

## Inputs

- Table name, its source or transformation code, and a profile of its contents (row counts, null rates, distinct values).
- Business context from owners or subject-matter experts.
- Existing documentation, if any, and known points of confusion.
- The organization's sensitivity classification scheme (for example public / internal / confidential / restricted), if one exists.

## Procedure

1. **Write the table entry first.** Include: purpose (what questions it answers), grain sentence ("one row per subscription per calendar day"), primary key, update cadence and freshness expectation, upstream sources, owner (team and a named contact role), status (production, deprecated, experimental), and known caveats (for example "excludes test accounts since 2025-03").
2. **Read the derivation before writing column definitions.** For derived columns, read the SQL or code so the definition describes what the column actually contains, not what someone hoped it contains. Note discrepancies with prior docs.
3. **Write each column definition with the five-part pattern.** (a) What it represents in business terms; (b) how it is derived or where it comes from; (c) unit, currency, time zone, or format; (d) allowed values or valid range; (e) what null means (not applicable, unknown, not yet occurred, or not captured before a date). Keep it to one to three sentences plus structured fields.
4. **Avoid circular and vague wording.** Do not use the column name to define itself. Replace vague words ("recent", "active", "valid", "main") with the rule ("has at least one completed order in the 28 days before the snapshot date").
5. **Document enumerations.** For categorical columns, list each value with its meaning, and say whether the list is closed. If values changed over time, say when.
6. **Document time semantics.** For every timestamp: which event it marks, the time zone, whether it can be updated after creation, and whether it is event time or load time.
7. **Classify sensitivity.** Tag columns containing personal data (direct identifiers such as email, quasi-identifiers such as birth date plus postcode), financial, health, or confidential business data, using the organization's scheme. Note masking or access rules. Never paste real values as examples; use synthetic ones.
8. **Add lineage and relationships.** Foreign keys and the table they reference; upstream source column for staging fields; downstream metrics that depend on the column if known.
9. **Review against the checklist** (below) and with the owner. A definition is not done until the owner agrees it is correct.
10. **Place it where people look.** Prefer documentation stored next to the code (dbt YAML, schema comments) and surfaced in the catalog, over a separate document that drifts.

## Expected output

```markdown
### Table: <schema.table>
**Purpose:** … · **Grain:** one row per … · **Primary key:** …
**Refresh:** … · **Sources:** … · **Owner:** … · **Status:** … · **Caveats:** …

| Column | Type | Definition | Unit / format | Allowed values / range | Null means | Sensitivity | Source / lineage |
|---|---|---|---|---|---|---|---|
```

For dbt, the same content goes in `description` fields, with sensitivity and owner in `meta`.

**Review checklist** (each entry): not circular; states unit and time zone where relevant; null meaning stated; enumerations complete; derivation matches code; sensitivity tagged; owner confirmed.

## Constraints and limitations

- Definitions must be confirmed by the data owner; the author's reading of code can miss business rules applied upstream.
- Documentation drifts; tie entries to code review so changes to logic require changes to docs.
- Do not copy real customer data, secrets, or confidential values into examples.
- When meaning is genuinely unknown, write "Meaning unconfirmed" and list the open question instead of guessing.

## Examples

Weak: `churn_date - the churn date of the customer.`

Strong: `churn_date (DATE, UTC) - the first day on which the account had no active paid subscription after previously having one, derived from subscription end dates in stg_billing__subscriptions; trials ending without conversion are not churn. Null means the account is currently paying or has never paid. Restored accounts keep their most recent churn_date. Sensitivity: internal.`
