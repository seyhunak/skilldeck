---
name: kyc-document-review
description: Checks a customer due diligence file against a structured KYC checklist - identity and address evidence, entity documents, beneficial ownership, control persons, source of funds/wealth, screening evidence, and risk-rating rationale - and returns a gap list for a KYC analyst. Use for onboarding QC or periodic review; never approves customers.
---

# KYC Document Review

Most KYC failures found in audits are not exotic: an expired passport, an ownership chart that stops one layer too early, an address proof older than policy allows, or a high-risk rating with no enhanced due diligence on file. This skill checks a customer due diligence (CDD) file systematically and produces a gap list a human analyst can act on. It supports the analyst; it does not decide whether to onboard, retain, or exit a customer.

## When to use

- Quality-checking an onboarding file before the analyst submits it for approval.
- Periodic or trigger-event review of an existing customer file.
- Preparing a remediation backlog after an audit finding.

Not appropriate for: verifying document authenticity (needs trained staff or specialist tools), adjudicating sanctions or PEP screening matches, or transaction monitoring investigations (use `aml-alert-review-agent`).

## Inputs

- The institution's CDD/EDD policy or checklist (document types accepted, validity periods, ownership thresholds, refresh cycles). Strongly recommended; it overrides the defaults below.
- The customer file contents or an index of documents with key fields: type, issuer, dates, names, addresses, ownership percentages.
- Customer type (individual, sole trader, company, partnership, trust, foundation) and jurisdiction.
- Risk rating and the factors behind it.

## Procedure

1. **Establish the standard.** Identify which checklist applies by customer type, risk rating, and jurisdiction. If no policy is supplied, use a generic baseline and label it: for example, many regimes use a 25% ownership threshold for beneficial owners, but some apply lower thresholds for higher risk.
2. **Check identity evidence (individuals and each relevant person).** Document type accepted, legible, unexpired at verification date, name and date of birth consistent across documents, verification method recorded (in person, electronic, certified copy). Note transliteration or name-order differences instead of treating them as mismatches automatically.
3. **Check address evidence.** Accepted type, issued within the policy window (often three months, policy-dependent), name and address match the application.
4. **Check entity documents.** Certificate of incorporation or registry extract, constitutional documents, registered address, list of directors, authorized signatories and mandate, and evidence that the registry check is recent.
5. **Trace ownership and control.** Build or verify the ownership chain to natural persons at or above threshold, multiplying percentages through layers (60% of 50% = 30% indirect). Identify control by other means (voting agreements, board appointment rights). For trusts, record settlor, trustees, protector, and beneficiaries or class. Flag chains that stop at an entity, nominee arrangements, and bearer shares.
6. **Check purpose, activity, and source of funds/wealth.** Confirm stated purpose and expected activity are recorded and plausible for the business. For higher-risk customers, confirm source of wealth and source of funds evidence exists and is corroborated, not merely declared.
7. **Check screening and risk rating.** Evidence that sanctions, PEP, and adverse media screening was run for all relevant parties with dates, that hits were dispositioned by an authorized person, and that the risk rating rationale matches the documented factors (geography, product, channel, ownership complexity). Higher-risk ratings require EDD evidence and the approval level policy prescribes.
8. **Compile the gap list** with severity: critical (missing or expired mandatory evidence, unidentified beneficial owner), major (stale documents, uncorroborated source of funds for high risk), minor (formatting, missing verification notes). Recommend specific remediation documents.

## Expected output

```markdown
## KYC File Review: <customer ref> (<type>, <jurisdiction>, risk <rating>)
Policy applied: <institution policy / generic baseline> · Review date: <>

| Area | Requirement | Evidence on file | Status (met/gap/n.a.) | Severity | Remediation |

### Ownership and control summary
<chain with percentages to natural persons>

### Risk-rating consistency
### Gap summary for analyst
### Items requiring human judgement
```

## Constraints and limitations

- Analytical support only, not legal or regulatory advice. Onboarding, retention, exit, and risk-rating decisions require sign-off by authorized KYC/compliance staff under the institution's policy.
- Requirements vary by jurisdiction and institution; the supplied policy prevails over generic defaults.
- Do not contact the customer, and never draft outreach that mentions any suspicion, alert, or investigation (tipping-off risk). Routine document requests must follow approved templates.
- Data protection: reference documents by type and last four characters of identifiers; do not reproduce full ID numbers, images, or unnecessary personal data. Do not upload files to external services.

## Examples

A private company file shows HoldCo A owning 60% of the customer; HoldCo A is owned 50/50 by two individuals. Each individual holds 30% indirectly, above a 25% threshold, so both are beneficial owners requiring identity verification. The file verifies only one. Gap: "Beneficial owner 2 (30% indirect via HoldCo A) — no identity evidence — critical — obtain ID and address evidence per policy section reference, re-run screening."
