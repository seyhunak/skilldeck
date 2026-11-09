---
name: owasp-top-10-review
description: Reviews web application or API source code against the OWASP Top 10 risk categories (2021 edition by default, 2025 edition if the team has adopted it) using concrete code patterns per category, false-positive checks, and an evidence-based findings table. Use for a focused secure-code pass over a repository, module, or diff; not for full ASVS audits, infrastructure review, or live testing.
---

# OWASP Top 10 Review

## When to use

Load this skill when an agent needs to check code the user owns or is authorised to assess for the most common web application risk classes: during a security-focused code review, before a release, or as one component of a broader audit. It works on a whole repository, a module, or a pull request diff.

It is not a substitute for a requirement-by-requirement audit (use `application-security-audit-agent`), a dependency inventory triage (use `dependency-vulnerability-triage`), or dynamic testing. The OWASP Top 10 is an awareness document, so passing this review does not mean an application is secure.

## Inputs

- **Code** — files, repository path, or diff. Required.
- **Stack** — language, framework, ORM, template engine, authentication library. Helpful; infer from manifests if not given.
- **Edition** — Top 10:2021 by default. If the team uses the 2025 edition, map findings to its categories and say which edition you used, because category names and order changed between editions.
- **Entry points** — routes or handlers to prioritise. Optional.

## Procedure

1. **Orient.** Identify the framework's built-in protections (ORM parameterisation, template auto-escaping, CSRF middleware) so you look for places that bypass them rather than re-flagging what the framework already handles.
2. **Inspect each 2021 category with concrete signals:**
   - **A01 Broken Access Control** — handlers that load objects by request-supplied ID without checking ownership; admin routes without role guards; authorisation decided in the client; permissive CORS with credentials; path traversal in file paths built from input.
   - **A02 Cryptographic Failures** — MD5, SHA-1, or unsalted hashes for passwords; ECB mode; hard-coded IVs or keys; `Math.random`-style RNG for tokens; TLS verification disabled (`verify=False`, `InsecureSkipVerify: true`, `rejectUnauthorized: false`); sensitive data sent over plain HTTP.
   - **A03 Injection** — SQL or NoSQL built by concatenation or interpolation; shell calls with `shell=True` or string commands containing input; template rendering of raw HTML (`|safe`, `dangerouslySetInnerHTML`, `v-html`, `html_safe`) with user data; LDAP or XPath built from input. Cross-site scripting is in this category in 2021.
   - **A04 Insecure Design** — missing rate limits on authentication, OTP, or costly endpoints; business flows with no step enforcement; trust in client-calculated prices or totals.
   - **A05 Security Misconfiguration** — debug mode on, verbose stack traces returned, default credentials, permissive security headers, XML parsers with external entities enabled, directory listing.
   - **A06 Vulnerable and Outdated Components** — unpinned or end-of-life frameworks visible in manifests; hand off details to `dependency-vulnerability-triage`.
   - **A07 Identification and Authentication Failures** — no brute-force protection, session IDs not rotated at login, long-lived tokens without revocation, JWT accepted without signature or with unvalidated claims, weak password rules.
   - **A08 Software and Data Integrity Failures** — deserialisation of untrusted data (`pickle.loads`, Java native serialisation, `yaml.load` without a safe loader, `BinaryFormatter`); unsigned updates or plugins; CI pipelines that run untrusted pull-request code with secrets.
   - **A09 Security Logging and Monitoring Failures** — no logging of login failures, access denials, or privilege changes; secrets or tokens written to logs; log entries built from unsanitised input.
   - **A10 Server-Side Request Forgery** — server fetches URLs, hostnames, or webhooks supplied by users without an allow-list, scheme restriction, and blocking of internal and metadata address ranges.
3. **Trace before reporting.** For each candidate, follow the data from an entry point to the sink. Report only when user-controlled data reaches the sink without an effective control, or label it *Suspected* with the missing link stated.
4. **Run false-positive checks.** Constant-only concatenation, values already validated against an allow-list, internal-only admin tools behind network controls the user confirms, and hashing used for non-security purposes are common false positives.
5. **Write findings.** Record category, location, data path, impact, fix, and confidence. Fixes should be idiomatic for the stack: the specific parameterised API, the framework's authorisation decorator, the safe loader.

## Expected output

| # | Category | Location | Source -> sink | Impact | Fix | Confidence |
|---|---|---|---|---|---|---|

Then a category summary listing each of A01-A10 as Findings, No issues observed, or Not assessed (with reason), and a short list of positive controls observed.

## Constraints and limitations

- Static pattern review misses issues that depend on runtime configuration and complex business logic; mark them for dynamic testing.
- Describe vulnerable patterns and remediations only; never produce working exploit payloads or bypass strings.
- If you find a credential, report file, line, and type, never the value, and apply `secrets-exposure-review`.
- Review only code the user owns or is authorised to assess. Severity is provisional until a qualified reviewer confirms it; this is not professional security advice.

## Examples

Input: a Flask route.

```python
@app.get("/invoices/<invoice_id>")
@login_required
def get_invoice(invoice_id):
    row = db.execute(f"SELECT * FROM invoices WHERE id = {invoice_id}").fetchone()
    return jsonify(dict(row))
```

Findings:

| # | Category | Location | Source -> sink | Impact | Fix | Confidence |
|---|---|---|---|---|---|---|
| 1 | A03 Injection | `app.py:3` | path param `invoice_id` -> f-string SQL | Arbitrary query against the invoices database | Use a bound parameter: `db.execute("SELECT ... WHERE id = ?", (invoice_id,))` | Confirmed |
| 2 | A01 Broken Access Control | `app.py:3` | path param -> query without owner filter | Any logged-in user can read any invoice | Add `AND customer_id = ?` bound to the session user; return 404 when absent | Confirmed |
