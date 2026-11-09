# ASVS 4.0.3 Chapter Inspection Guide

A working checklist of where to look in code and configuration for each ASVS 4.0.3 chapter. It summarises intent; always cite the requirement text from the official standard at <https://owasp.org/www-project-application-security-verification-standard/>. If the team uses ASVS 5.0, chapter numbers and requirement identifiers differ; map by topic and cite 5.0 identifiers.

| Chapter | Topic | What to inspect statically | Usually needs dynamic test |
|---|---|---|---|
| V1 | Architecture, design, threat modeling | Existence of a threat model, documented trust boundaries, centralised security controls (one auth middleware, one encoder) | No |
| V2 | Authentication | Password hashing (bcrypt, scrypt, Argon2id, PBKDF2 parameters), breached-password checks, MFA paths, lockout and rate limiting, recovery token entropy and expiry | Rate limiting thresholds, lockout behaviour |
| V3 | Session management | Session ID generation, cookie attributes, rotation on login, invalidation on logout and credential change, idle and absolute timeouts, JWT validation | Actual cookie flags in responses |
| V4 | Access control | Deny-by-default middleware, per-object ownership checks, admin route guards, mass-assignment protection, directory listing | Horizontal and vertical privilege tests |
| V5 | Validation, sanitisation, encoding | Parameterised queries, ORM raw-query escapes, template auto-escaping, deserialisation, XML parser settings, SSRF allow-lists, command execution | Some XSS sinks in client code |
| V6 | Stored cryptography | Algorithms and modes, key storage and rotation, IV and nonce handling, CSPRNG use for tokens | No |
| V7 | Error handling and logging | Security event logging, sensitive data in logs, log injection, generic error responses, debug flags | Error pages in deployed environment |
| V8 | Data protection | Caching headers for sensitive responses, data minimisation, client-side storage of secrets, backups and exports | Browser cache behaviour |
| V9 | Communication | TLS enforcement, certificate verification on outbound calls, HSTS configuration | Deployed TLS configuration |
| V10 | Malicious code | Integrity of build pipeline, unexpected network calls, time bombs, unsigned updates | No |
| V11 | Business logic | Sequential step enforcement, limits on high-value actions, anti-automation | Most items |
| V12 | Files and resources | Upload size and type validation, storage outside web root, path traversal on download, archive extraction limits | Content-type sniffing |
| V13 | API and web services | Schema validation, method and content-type enforcement, GraphQL depth and cost limits, CORS | Live CORS responses |
| V14 | Configuration | Dependency pinning, security headers, build hardening, removal of debug endpoints, default credentials | Deployed headers |

## Status definitions

- **Pass** — evidence in code or configuration satisfies the requirement.
- **Fail** — evidence shows the requirement is not met; produce a finding.
- **Partial** — met on some paths but not others, or enforcement depends on configuration not in scope.
- **Not applicable** — the feature the requirement governs does not exist; state why.
- **Not assessed** — in scope but could not be evaluated; state what is missing.

## Common false positives

- Raw SQL that only concatenates constant identifiers, not user input.
- Missing CSRF tokens on endpoints that only accept bearer tokens in headers, not cookies.
- MD5 used for cache keys or ETags rather than for security decisions.
- Debug flags that are read from configuration whose production value is not in scope; mark Partial and ask.
