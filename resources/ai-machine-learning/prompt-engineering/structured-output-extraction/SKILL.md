---
name: structured-output-extraction
description: Get reliable structured data out of LLMs - extraction schema design with explicit nulls and enums, choosing constrained decoding versus prompt-only formatting, parse and semantic validation, bounded repair retries, and field-level accuracy measurement. Use when model output feeds code, databases, or APIs, or when JSON parsing failures and invented field values appear.
---

# Structured Output Extraction

## When to use
- Extracting fields from documents, emails, transcripts, or forms into JSON.
- Any LLM output consumed by code rather than a person.
- Seeing parse errors, wrong types, or plausible-looking values that are not in the source.

Not for: defining tools an agent calls (see `tool-schema-design`), or verifying free-text answers against sources (see `hallucination-detection`).

## Inputs
- Target data model and the downstream consumer's requirements.
- 20+ sample inputs with hand-labeled expected outputs (more for production gating).
- Provider capabilities: native JSON schema or structured-output mode, tool calling, or plain text only.

## Procedure
1. **Design the schema for extraction, not storage.**
   - Make absence explicit: nullable fields (`"type": ["string", "null"]`) plus an instruction that null means "not stated in the source". This is the single biggest defence against invented values.
   - Use `enum` for categorical fields and include `other` or `unknown` where the world is open.
   - Normalize formats in the schema description (ISO 8601 dates, ISO 4217 currency codes, amounts as strings or integers in minor units to avoid float issues).
   - Keep nesting shallow; use arrays of objects for repeated items (line items, parties).
   - Optionally add an `evidence` or `source_span` field per critical value, quoting the text it came from; it makes review and verification far easier.
2. **Choose the enforcement mechanism, strongest first.** Native schema-constrained output where the provider supports it guarantees syntactic validity for supported keywords; tool or function calling with the schema as parameters is the next option; prompt-only JSON with a schema and example is weakest. Constrained decoding guarantees shape, not correctness.
3. **Write the extraction prompt.** Provide the schema, field definitions with edge-case rules (for example "if two dates appear, use the effective date, not the signature date"), one or two complete examples including a null case, and the source text in a clearly delimited block. Ask for output only, no prose, when not using native modes.
4. **Validate in two layers.**
   - Syntactic: parse, then validate against the JSON Schema (types, required, enums, patterns).
   - Semantic: business rules the schema cannot express, such as totals equal sum of line items, end date after start date, and `evidence` text actually appearing in the source.
5. **Repair with a budget.** On failure, retry once or twice with the validator's error messages appended ("field `currency` must be one of [...]; got `dollars`"). After the budget, route to a fallback: human review queue, partial result with flagged fields, or rejection. Never loop indefinitely, and never "repair" by letting code guess values.
6. **Measure field-level accuracy.** On the labeled set, compute per-field exact match (after normalization), null precision (how often a predicted null is truly absent) and null recall, plus schema-valid rate and repair rate. Aggregate document accuracy hides weak fields.
7. **Monitor in production.** Log validation failure types, repair counts, and null rates per field (without raw sensitive values). Drift in null rates often signals a new input format.

## Expected output
```markdown
## Extraction spec: <document type> v<n>
Enforcement: <native schema | tool call | prompt-only>; model <name/version>
Schema: { ...JSON Schema... }
Semantic rules: total == sum(line_items.amount); end_date > start_date; evidence in source
Repair policy: max 2 retries with validator errors, then human review

| Field | Exact match | Null precision | Null recall | Notes |
|---|---|---|---|---|
| invoice_date | 0.97 | 1.00 | 0.90 | |

Schema-valid first pass <x>%, after repair <y>%, routed to review <z>%
```

## Constraints and limitations
- Schema validity is not truth; always measure field accuracy against labels.
- Provider structured-output modes support different subsets of JSON Schema; check documentation for your provider and version.
- Long documents may exceed context; chunk and merge carefully, deduplicating repeated entities.
- Extract only the fields you need when inputs contain personal data.

## Examples
Invoice extraction produced a `due_date` on 100% of documents although only 70% stated one; the model was inferring "30 days after issue". Making `due_date` nullable, adding a rule "null if not explicitly stated", and an `evidence` field cut invented due dates to near zero on the 150-document labeled set, while exact match on stated dates stayed at 0.96.
