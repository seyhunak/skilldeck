---
name: data-classification
description: Designs a data classification scheme or applies an existing one - defines levels with clear criteria, classifies datasets and fields by confidentiality, integrity, and regulatory triggers (personal, special category, payment card, health, credentials), and produces a handling matrix for storage, transfer, sharing, retention, and disposal. Use when building a scheme, classifying a schema or data inventory, or deciding how a dataset must be handled.
---

# Data Classification

## When to use

Load this skill when:

- An organisation needs its first classification scheme or wants to simplify one nobody follows.
- A team must classify a database schema, data warehouse, file share, or new dataset.
- Another workflow (threat model, DPIA, vendor assessment) needs consistent sensitivity labels.
- Someone asks "can I put this data in tool X?" and the answer depends on its class.

Do not use it to decide lawful basis or necessity under privacy law (use `privacy-impact-assessment-agent`) or to write the overarching policy document (use `security-policy-writing`, which can embed the scheme this skill produces).

## Inputs

- **Data to classify** — schema, field list, dataset description, or data inventory. Use column names, types, and masked or synthetic samples; never real records. Required for classification work.
- **Existing scheme** — if one exists, apply it rather than inventing a new one. Optional.
- **Regulatory context** — jurisdictions, sector (health, payments, public sector), contracts with handling clauses. Optional but important.
- **Business context** — what the data is used for and who owns it. Optional.

## Procedure

1. **Define or adopt a scheme.** Four levels work for most organisations; more levels reduce consistency. A default:
   - **Public** — approved for public release; disclosure causes no harm.
   - **Internal** — routine business data; disclosure causes minor harm or embarrassment.
   - **Confidential** — disclosure would cause significant harm to the organisation, customers, or individuals: most personal data, customer data, contracts, non-public financials, source code.
   - **Restricted** — disclosure would cause severe harm or trigger regulatory consequences: special category personal data, payment card data in PCI DSS scope, government identifiers, authentication secrets and keys, health records, data under strict contractual terms.
   Name the data owner role responsible for each dataset's classification.
2. **Apply classification criteria.** For each dataset or field, assess:
   - **Confidentiality impact** if disclosed.
   - **Integrity impact** if altered (some public data, such as published prices, still needs integrity protection; record this separately from the label).
   - **Regulatory triggers**: personal data (any information relating to an identified or identifiable person); special category data under GDPR Article 9 (health, biometric for identification, genetic, racial or ethnic origin, political opinions, religious beliefs, trade union membership, sex life or orientation); payment card data (PAN, and sensitive authentication data which must not be stored after authorisation); credentials and keys; children's data.
   - **Aggregation**: combinations can raise the class (name plus date of birth plus postcode is more sensitive than any one field).
   Take the highest applicable level; the dataset inherits its most sensitive field unless fields are separated.
3. **Classify field by field** for schemas. Flag free-text fields (notes, comments, attachments) as at least Confidential because they routinely contain unexpected personal data.
4. **Build the handling matrix.** For each level define rules for: storage locations allowed, encryption at rest and in transit, access approval, sharing externally, use in non-production environments (masked or synthetic only for Confidential and above), use in AI or third-party tools, printing and email, retention, and disposal method.
5. **Label and propagate.** Recommend how labels are applied: database column comments or catalogue tags, document labels, storage bucket tags. Derived datasets inherit the highest class of their inputs unless de-identified and reviewed.
6. **Validate.** Spot-check classifications with the data owner, list fields where you were unsure, and record decisions about borderline cases so they are applied consistently.

## Expected output

1. **Scheme** (if designing): levels, definitions, examples, owner roles.
2. **Classification register:**

| Dataset / table | Field | Data type | Personal? | Regulatory trigger | Class | Rationale | Confidence |
|---|---|---|---|---|---|---|---|

3. **Handling matrix:**

| Rule | Public | Internal | Confidential | Restricted |
|---|---|---|---|---|

4. **Open questions** for the data owner.

## Constraints and limitations

- Classify from schemas and masked samples; never reproduce sensitive values in the output.
- Whether data is personal or special category can depend on context and jurisdiction; mark uncertain cases for privacy counsel.
- A scheme only works if it is short and enforced by tooling; resist adding levels.
- This is not legal advice. Final classification of regulated data and the scheme itself require approval by the data owner and, where regulations apply, legal or privacy counsel.

## Examples

Input: `customers` table with `id`, `email`, `full_name`, `date_of_birth`, `postcode`, `marketing_opt_in`, `support_notes`, `card_last4`, `password_hash`.

| Field | Class | Rationale |
|---|---|---|
| `id` | Internal | Internal identifier; personal only in combination |
| `email`, `full_name` | Confidential | Direct identifiers |
| `date_of_birth`, `postcode` | Confidential | Quasi-identifiers; raise re-identification risk in combination |
| `marketing_opt_in` | Confidential | Consent record; integrity matters for compliance |
| `support_notes` | Confidential (review for Restricted) | Free text may contain health or other special category data |
| `card_last4` | Confidential | Truncated PAN; not full cardholder data but keep restricted access |
| `password_hash` | Restricted | Authentication secret material |

Dataset class: Restricted, driven by `password_hash`. Recommendation: move credentials to a separate store so the customer table can be handled as Confidential.
