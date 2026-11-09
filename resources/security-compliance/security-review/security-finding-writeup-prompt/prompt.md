# Security Finding Write-Up

## Intended task

Convert rough notes about a single vulnerability (from a code review, internal test, scanner result, or bug bounty triage) into a finding that a developer can understand, reproduce safely, and fix, and that a security lead can defend. The prompt produces a title, an explained CVSS vector, affected assets, impact, verification steps at a safe level of detail, remediation, and references. Use it for tickets and assessment reports on systems you own or are authorised to test.

## Required context

- **Raw notes** on the issue: what was observed, where, and how it was found. Mask any secrets, tokens, or personal data before pasting.
- **Affected asset** details: application, endpoint or file, environment, and version or commit.
- **Environment context**: internet-facing or internal, data classification, user roles involved. Severity depends on it.
- **CVSS version** the organisation uses (3.1 or 4.0).
- **Audience**: engineering ticket or formal report, which changes tone and length.

## Prompt

```text
You are a senior application security engineer writing up one security finding for a system the requester owns or is authorised to test. Write for the developer who will fix it and the security lead who will defend its severity. Be precise, neutral, and evidence-based. Do not exaggerate impact, do not speculate beyond the evidence, and mark any assumption with "Assumption:".

Raw notes:
{{FINDING_NOTES}}

Affected asset: {{AFFECTED_ASSET}}
Environment and data context: {{ENVIRONMENT_CONTEXT}}
CVSS version to use: {{CVSS_VERSION}}
Audience: {{AUDIENCE}}
Organisation severity policy (if any): {{SEVERITY_POLICY}}

Requirements:
1. Title: specific, under 12 words, naming the weakness and the location, e.g. "Missing ownership check on GET /invoices/{id} exposes other tenants' invoices".
2. Classify with a CWE ID where one clearly fits; otherwise omit.
3. Severity: give the full CVSS base vector string for the requested version, the score, and one line per metric explaining the choice. If the organisation severity policy adjusts for environment or data sensitivity, apply it and show the adjustment separately from the base score.
4. Description: what is wrong and why, in plain language, 3-6 sentences.
5. Impact: what an attacker could realistically achieve in this environment, with preconditions. No worst-case speculation without evidence.
6. Verification steps: the minimum steps a developer needs to confirm the issue and later confirm the fix. Use placeholder values, keep requests generic, and do not include weaponised payloads, exploit chains, or evasion techniques.
7. Remediation: the specific fix in the asset's technology, any short-term mitigation, and a regression test to add.
8. References: only well-known public references (CWE, OWASP pages, vendor advisories) you are confident exist; otherwise write "References: none added".
9. Never reproduce secrets, tokens, or personal data from the notes; refer to them by type.
10. End with a list of open questions if the notes leave material gaps.
```

## Variables

| Variable | Description | Required |
|---|---|---|
| `{{FINDING_NOTES}}` | Raw notes, scanner output, or reviewer comments about the issue, with secrets masked | Yes |
| `{{AFFECTED_ASSET}}` | Application, endpoint or file path, environment, version or commit | Yes |
| `{{ENVIRONMENT_CONTEXT}}` | Exposure (internet or internal), data classification, roles involved | Yes |
| `{{CVSS_VERSION}}` | `3.1` or `4.0` | Yes |
| `{{AUDIENCE}}` | `engineering ticket` or `formal assessment report` | Yes |
| `{{SEVERITY_POLICY}}` | The organisation's severity mapping or adjustment rules; write `none` if absent | No |

## Output format

Markdown with these headings in order: Title (as a level-2 heading), Summary table (Severity, CVSS vector, CWE, Asset, Status), Description, Impact, Verification steps, Remediation, References, Open questions. Ticket audience: 200-400 words. Report audience: up to 700 words.

## Example usage

Input notes: "Logged in as tenant A user, changed invoice ID in URL to one from tenant B, got 200 with full invoice JSON incl. billing address. API is public, invoices are Confidential."

A good response titles it "Missing ownership check on GET /api/invoices/{id} allows cross-tenant invoice access", maps it to CWE-639, scores CVSS 3.1 `AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:N/A:N` (6.5) with a line per metric, explains impact as read access to other tenants' billing data for any authenticated user, gives two verification steps using two test accounts the requester controls, and recommends enforcing tenant scoping in the data access layer with a regression test that asserts a 404 for foreign IDs.

## Customization

- Swap CVSS for the organisation's own risk matrix by editing requirement 3; keep the per-factor rationale.
- Add a "Business owner" or "SLA due date" field to the summary table if tickets need them.
- For bug bounty triage, add a requirement to state whether the report is a duplicate of a known issue ID.
- Do not remove requirement 6's restriction on payloads or requirement 9's masking rule.
- This is not professional security advice; severities and disclosure decisions need review by a qualified security lead.
