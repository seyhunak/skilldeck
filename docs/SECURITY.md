# Security model

The catalog is untrusted content. A manifest passing validation doesn't make a resource safe, which is why every merge also needs human review.

## Reporting a vulnerability

Report privately through [GitHub Security Advisories](https://github.com/seyhunak/skilldeck/security/advisories/new). Please don't open a public issue. We aim to acknowledge reports within 72 hours.

## What contributors may not submit

- executables, binaries, shell scripts, install hooks, or symlinks (`safety.contains_scripts` must be `false`)
- credentials, tokens, private keys, customer records, or personal data
- instructions to bypass platform permissions or security controls, or to produce exploit code or attack payloads
- destructive commands presented as routine steps
- content you have no right to license

## Enforced by the validator (`scripts/validate_catalog.py`)

Allowed file extensions only; limits of 512 KB per file, 2 MB and 60 files per package; no symlinks or executable bits; secret patterns (cloud keys, tokens, private keys); unsafe HTML tags (`<script>`, `<iframe>`, `<object>`, `<embed>`, `<form>`, `<style>`, `<link>`, `<meta>`); links with schemes other than `http(s)` (e.g. `javascript:`, `file:`); leftover template placeholders; compatibility claims capped by the registry; disclaimers in regulated domains. The validator only *parses* YAML and Markdown. It never imports or executes anything from a package.

## Enforced by the app

- Package content is data. Nothing from a package is ever executed, and the app spawns no processes.
- Markdown is rendered by a built-in parser that never interprets HTML. Only `https` links can be opened.
- Every file and every resource is checked against the catalog's SHA-256 when the catalog loads, and resources that don't match are quarantined. Downloaded bundles must match the size and SHA-256 in `latest.json`, and a bundle that fails is discarded while the current catalog stays.
- Install paths come from the compatibility registry, never from the package. Package-relative paths are rejected if they're absolute, contain `..`, `~`, or backslashes, or resolve through a symlink.
- Every install is previewed first. Existing files are never overwritten silently: the user chooses cancel or backup-and-replace (backups go under `~/Library/Application Support/Skilldeck/Backups`). Written files are hash-verified, and a failed install rolls back.
- Uninstall moves files to the Trash and keeps any file the user has modified.
- GitHub logins are validated before any API call. Profile responses are cached and rate limits respected.

## CI

`validate-submission.yml` runs on pull requests with `contents: read`, no secrets, and `persist-credentials: false`. Only the publish job of `release-catalog.yml` gets `contents: write`. It runs in the `catalog-release` environment, which requires approval from the owner or an authorized maintainer and only deploys from protected branches, so the `latest.json` the app trusts can't change without a maintainer's sign-off. `main` is protected: changes need a pull request that passes validation, and force-pushes are blocked. All third-party actions are pinned to full commit SHAs.
