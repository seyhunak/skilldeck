---
name: secrets-exposure-review
description: Finds hard-coded or leaked credentials in source trees, git history, CI configuration and logs, container images, and config files using manual search patterns plus guidance for established scanners, then drives rotation-first remediation and prevention. Never prints secret values. Use for repository security reviews, pre-open-sourcing checks, or when a leak is suspected.
---

# Secrets Exposure Review

## When to use

Load this skill when:

- Reviewing a repository the user owns or is authorised to assess for committed credentials.
- Preparing to open-source or share a repository, image, or archive.
- A credential leak is suspected or confirmed (public repo, pasted log, departing contractor) and remediation needs sequencing.
- Hardening CI/CD so secrets stop reaching code and logs.

Do not use it to hunt for secrets in systems or repositories the user does not control, and do not use it to validate whether a found credential works by logging in with it.

## Inputs

- **Scope** — repository path, branches, and whether full history is in scope; CI logs, container images, or config bundles if relevant. Required.
- **Known secret stores** — secrets manager, environment configuration approach. Optional; helps classify findings as leaks versus references.
- **Scanner output** — if the user already ran a scanner, its report (with values redacted). Optional.

## Procedure

1. **Decide exposure context first.** Is the repository or artefact public, shared with third parties, or internal only? Public exposure means automated harvesting may already have happened; treat any live credential there as compromised regardless of how briefly it was exposed.
2. **Scan with established tools where available.** Recommend running these locally and reviewing the redacted output:
   - Gitleaks over the working tree and full history, with redaction enabled (`--redact`).
   - TruffleHog over git history. Its verification mode sends found credentials to the provider to test them; that is a use of the credential, so run without verification unless the credential owner approves.
   - The platform's native scanning (for example GitHub secret scanning and push protection) if the user has it.
   Check the installed tool version's documentation for exact flags, as subcommands change between releases.
3. **Search manually for what scanners miss.** Look in: `.env*` files, `config/*.yml`, `settings.py`, `application.properties`, `docker-compose.yml`, Kubernetes manifests (`Secret` objects are only base64-encoded, not encrypted), Terraform state and `*.tfvars`, CI workflow files, Jupyter notebook outputs, test fixtures, mobile app config plists and `strings.xml`, and shell history or scripts. Search for assignment patterns around words such as `password`, `passwd`, `secret`, `token`, `api_key`, `private_key`, `client_secret`, `connection_string`, and `Authorization: Bearer`, and for PEM header lines.
4. **Triage each hit.** Classify as: *Live credential* (real, likely valid), *Revoked or expired* (owner confirms), *Placeholder or test value* (dummy, documented sample, local-only emulator default), or *Reference* (a variable name or secret-manager path, not a value). Record type (cloud key, database password, OAuth client secret, signing key, webhook URL with embedded token), location (file, line, commit, author date), and exposure context. Mask the value in every record, for example by showing only the type and the last four characters if the owner needs to identify which key it is.
5. **Remediate in the right order.**
   1. **Revoke or rotate** the credential at its issuer. Removing it from code does not invalidate it.
   2. **Assess use** — ask the owner to review the issuer's access logs for the credential from the earliest exposure date (hand off to `security-log-analysis` if suspicious use appears).
   3. **Replace in code** with a reference to a secrets manager or injected environment variable.
   4. **Clean history** only after rotation, with `git filter-repo` or BFG Repo-Cleaner, coordinated with all collaborators because it rewrites commits. Forks, clones, CI caches, and package registries may retain copies; history cleaning reduces exposure but never replaces rotation.
6. **Prevent recurrence.** Recommend a pre-commit hook running a scanner, server-side push protection, CI scanning on pull requests, masking of secrets in CI logs, short-lived credentials (OIDC federation from CI to cloud instead of static keys), and `.gitignore` entries for local env files.

## Expected output

| ID | Type | Location (file:line / commit) | Exposure | Classification | Value | Action | Owner | Status |
|---|---|---|---|---|---|---|---|---|
| S1 | Cloud access key | `deploy/ci.yml:14` @ `a1b2c3d` | Public repo since 2026-08-02 | Live | masked (…4F2Q) | Rotate now, review issuer logs | Platform team | Open |

Followed by: remediation sequence per live credential, history-cleaning plan (if needed), and prevention recommendations.

## Constraints and limitations

- Never print, copy, store, test, or use a discovered secret. Report type and location with the value masked.
- Do not run credential verification against providers without the owner's explicit approval.
- History rewrites and rotations are performed by credential and repository owners, after approval.
- Entropy-based detection has false positives (hashes, UUIDs, test vectors) and false negatives (low-entropy passwords); state confidence.
- This is not professional security advice; incidents involving exposed customer data may have notification implications that need legal review.

## Examples

A user asks: "We're about to make our internal SDK repo public. Check it."

Good response outline: confirm the user owns the repository; recommend a Gitleaks scan of full history with redaction; manually review `examples/`, `tests/fixtures/`, and CI files; report three findings: a Slack webhook URL in `examples/notify.py` (live, rotate), a database password in a 2023 commit of `config/dev.yml` (owner says the dev database was decommissioned, classify as revoked after confirmation), and a sample key in the README that matches the provider's documented dummy format (placeholder). Recommend rotation, history cleaning before publication because the repo is not yet public, and push protection.
