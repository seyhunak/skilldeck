---
name: company-profile-research
description: Builds a sourced company profile from public records - exact legal entity and identifiers, group structure, ownership, leadership, products and customers, financial signals, footprint, and recent news - with the source and date for every field and gaps recorded rather than filled. Use as the base layer for diligence, vendor evaluation, partnership screening, account research, or competitor work.
---

# Company Profile Research

## When to use

Use this skill when you need a reliable factual picture of a company: before a partnership or vendor decision, for account planning, as the first step of due diligence, or to anchor a competitor dossier. It is designed to prevent the most common profile errors: mixing up entities with similar names, copying unsourced revenue or headcount figures from aggregator sites, and presenting stale facts as current.

It does not cover litigation, sanctions screening, or adverse-media investigation in depth (those belong to a full diligence process), and it does not profile private individuals beyond their official corporate roles.

## Inputs

- Company name and website; country of incorporation if known; registration number if available.
- Purpose of the profile, which sets depth.
- Fields required (default: all sections in the output template).

## Procedure

1. **Resolve the entity.** Search the official company register for the jurisdiction (for example Companies House for the UK, state business registries in the US, commercial registers in EU member states) and the GLEIF LEI search where available. Record legal name, registration number, legal form, status, incorporation date, and registered address. If the brand maps to multiple legal entities, list them and identify which one contracts with customers (often stated in website terms of service or invoices).
2. **Map the group.** Identify parent and ultimate parent, main subsidiaries, and persons with significant control or beneficial owners as disclosed in registers or filings. For listed companies use annual reports and securities filings (for example SEC EDGAR for US issuers). Note where ownership is not disclosed.
3. **Record leadership.** List directors and senior executives from official registers and the company's own leadership pages, with appointment dates. Use only official roles and public professional information.
4. **Describe the business.** From the company's website, filings, and documentation, summarise products and services, target customers and segments, business model, named customers (only those publicly disclosed by the company or the customer), and key partners.
5. **Gather financial signals.** For listed companies, take revenue, profit, cash, and debt from the latest filings with period end dates. For private companies, use filed accounts where available, noting filing exemptions that limit detail; otherwise report signals such as funding rounds announced by the company or investors, and label third-party estimates as estimates with their source.
6. **Capture footprint.** Offices and operating countries, headcount as stated in filings or by the company (note date and basis), and key certifications verified with the issuing body where possible.
7. **Scan recent developments.** List material news from the last 12-24 months: leadership changes, funding, acquisitions, layoffs, product launches, regulatory actions, with dates and sources. Prefer the company's own announcements and established press.
8. **Grade and date every field.** Each field gets a source, an as-of date, and a reliability note (official register, company statement, independent press, estimate). Mark unknowns as unknown.

## Expected output

```markdown
# Company Profile: <legal name> - as of <date>

| Field | Value | Source | As of | Reliability |
|---|---|---|---|---|
| Legal name / number / jurisdiction | | | | Official register |
| Status / incorporated | | | | |
| Registered address | | | | |
| Ultimate parent / significant owners | | | | |
| Directors and key executives | | | | |
| Products and segments | | | | |
| Business model | | | | |
| Publicly named customers | | | | |
| Revenue / profit (period) | | | | |
| Funding (if private) | | | | |
| Headcount (basis) | | | | |
| Locations | | | | |
| Certifications | | | | |

## Recent developments
| Date | Event | Source |

## Gaps and caveats
```

## Constraints and limitations

- Register coverage and detail differ greatly by jurisdiction; small private companies may disclose very little.
- Aggregator and data-broker sites often contain outdated or modelled figures; use them only as leads and label them.
- Headcount and revenue claims in marketing materials are self-reported.
- Collect personal data only as it appears in official records and only as needed; no home addresses, family information, or personal social media.
- Never fabricate identifiers, financial figures, or customer names.

## Examples

**Request:** profile "Acme Robotics" before a pilot.
The register shows two entities: Acme Robotics Ltd (UK, active, trading) and Acme Robotics Holdings Inc (Delaware, parent). Website terms name the UK company as the contracting party. The UK entity files small-company accounts with limited detail, so revenue is unknown; the company announced a Series A in a press release (company statement). Two customers are named in public case studies. The profile records the UK entity as the counterparty, the US parent as the ultimate owner, revenue as not disclosed, and flags that the pilot contract should name the correct entity.
