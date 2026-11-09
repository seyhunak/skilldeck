---
name: competitive-feature-matrix
description: Builds a like-for-like capability comparison across products using buyer-relevant criteria, defined scoring levels, and a dated evidence link for every cell, with unknowns kept distinct from absent features. Use when product, sales, or marketing needs a comparison grid that will be scrutinised by colleagues, customers, or the competitors themselves.
---

# Competitive Feature Matrix

## When to use

Use this skill to compare two or more products on capabilities: for roadmap gap analysis, sales enablement, comparison pages, analyst briefings, or procurement shortlists. It is designed for situations where a check-mark table would be misleading because capabilities differ in depth, packaging, and maturity.

It does not cover pricing strategy or positioning narrative; those belong in broader competitor research. It is also not suited to public comparison pages without legal or marketing review, since comparative claims carry legal risk in many jurisdictions.

## Inputs

- Products to compare, with versions or editions and the date of comparison.
- The buyer or use case the comparison serves (it decides which capabilities matter).
- Evidence sources: public documentation, pricing pages, release notes, API references, trust pages, review sites, and the user's own trial accounts used under normal terms.
- Optional: internal win/loss notes, flagged as internal evidence.

## Procedure

1. **Anchor on the buyer's evaluation.** List the jobs and requirements the buyer actually evaluates (from RFPs, win/loss notes, sales calls). Capabilities should be phrased at that level ("bulk edit of 10k records") rather than as marketing features ("powerful editing").
2. **Define criteria with levels.** For each capability define what each score means, for example: 0 = not available; 1 = partial or workaround; 2 = available with limits; 3 = full, generally available; plus U = unknown. Write level definitions per criterion where depth varies, such as "SSO: 1 = social login only, 2 = SAML on top tier only, 3 = SAML and SCIM on all paid tiers".
3. **Separate availability from packaging.** Record which tier or add-on includes the capability. A feature that exists only in an enterprise plan is a different competitive fact from one in every plan.
4. **Collect evidence per cell.** For each product and capability, find first-party documentation first. Record URL, date accessed, and any version or plan qualifier. Use third-party evidence (reviews, community posts) for maturity and quality signals, marked as such.
5. **Score conservatively.** Score only what the evidence supports. Marketing pages without documentation get at most a provisional score and a note. Beta, preview, or waitlist features are labelled, not scored as generally available.
6. **Score your own product with the same rules.** Use public documentation for your product too; internal knowledge of unreleased features does not count.
7. **Weight if needed.** If the matrix will drive a decision, assign weights reflecting buyer importance, agreed before scoring, and compute weighted totals. Show unweighted scores alongside.
8. **Review for fairness.** Ask: would the competitor's product manager accept each cell as accurate? Change or caveat any cell you could not defend to them.
9. **Date and maintain.** Stamp the matrix with the evidence date and flag cells older than a set threshold (for example 90 days) for re-verification.

## Expected output

```markdown
**Buyer/use case:** <...> · **Evidence date:** <date> · **Scale:** 0 none, 1 partial, 2 limited, 3 full, U unknown

| Capability (weight) | Level definitions | Us | Competitor A | Competitor B |
|---|---|---|---|---|
| SAML SSO (high) | 1 social only; 2 top tier only; 3 all paid tiers | 3 [1] | 2 Enterprise only [2] | U [-] |

**Evidence:** [1] <title, URL, accessed date> ...
**Notes:** betas, provisional scores, cells needing re-check.
**Summary:** where each product leads, where scores are unknown.
```

## Constraints and limitations

- Feature parity says little about quality, usability, or reliability; add qualitative notes where they matter.
- Documentation may lag or lead the shipped product; trial verification is stronger evidence when available under normal terms.
- Do not create fake accounts, misrepresent identity, or breach terms of service to verify a competitor's feature.
- Public comparative claims should be reviewed by marketing and legal teams before publication.

## Examples

**Use case:** mid-market HR teams choosing an applicant-tracking system.
Capabilities derived from three RFPs: structured interview scorecards, EEO reporting, calendar integration with both major suites, API rate limits, data residency in the EU.
Evidence shows Competitor A has scorecards only on its top plan (score 2, packaging noted), Competitor B documents EU hosting but only as an add-on (2, add-on noted), and neither documents API rate limits (U). The summary reports A's packaging gap as an opening for mid-market deals and lists the API question for a sales-engineer trial.
