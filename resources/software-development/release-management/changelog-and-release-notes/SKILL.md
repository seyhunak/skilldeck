---
name: changelog-and-release-notes
description: Turns merged changes into a Keep a Changelog-formatted CHANGELOG entry, determines the correct Semantic Versioning bump, and writes user-facing release notes with upgrade instructions for breaking changes. Use when cutting a release, auditing an existing changelog, or setting up a changelog process for a library, API, or app.
---

# Changelog and Release Notes

A changelog is for the people who depend on your software, not a dump of commit subjects. This skill gathers what changed between two versions, decides the version number from the nature of the changes, and writes two artefacts: a precise CHANGELOG entry and readable release notes.

## When to use

- Preparing a release and needing the version number, CHANGELOG entry, and announcement text.
- Auditing a changelog that is missing entries, mislabels breaking changes, or is unreadable.
- Choosing between hand-written changelogs and automation (release-please, semantic-release, changesets, git-cliff).

Not for: writing individual commit messages (`commit-message-writing`) or deciding whether a release is ready to ship (`release-readiness-routine`).

## Inputs

- The previous release tag and the target ref (e.g. `v2.3.1..main`).
- Commits and merged PRs in that range, with labels and linked issues.
- The public surface: what counts as API for this project (exported functions, HTTP endpoints, CLI flags, config keys, file formats, minimum runtime versions).
- Audience: library consumers, API integrators, end users, or operators.

## Procedure

1. **Collect the change set.**
   ```bash
   git describe --tags --abbrev=0
   git log v2.3.1..HEAD --no-merges --format='%h %s'
   git log v2.3.1..HEAD --merges --format='%h %s'
   gh pr list --state merged --search "merged:>2026-09-01" --json number,title,labels
   ```
   Prefer PR titles and descriptions over raw commits when the project squash-merges. Drop noise: CI tweaks, test-only changes, internal refactors with no user effect — unless the audience is contributors.

2. **Classify each change** into Keep a Changelog 1.1.0 categories: **Added** (new features), **Changed** (changes to existing functionality), **Deprecated** (soon-to-be removed), **Removed** (now removed), **Fixed** (bug fixes), **Security** (vulnerabilities). Conventional Commit types map roughly: `feat` → Added or Changed, `fix` → Fixed, `perf` → Changed. Check each item by reading the diff when the title is ambiguous.

3. **Identify breaking changes rigorously.** A change is breaking if a consumer doing something documented and supported must change their code, config, or data to keep working: removed or renamed public symbols, changed signatures or return types, new required parameters, stricter validation, changed defaults, dropped runtime or platform versions, changed wire or file formats. Look for `!` and `BREAKING CHANGE:` footers but do not rely on them alone.

4. **Determine the SemVer bump** (Semantic Versioning 2.0.0): any breaking change → MAJOR; new backward-compatible functionality or a deprecation → MINOR; only backward-compatible fixes → PATCH. For `0.y.z` the spec allows anything to change; most projects bump MINOR for breaking changes in 0.x — state the convention used. Pre-releases: `2.0.0-rc.1`. Applications without a public API may use CalVer instead; follow the project's existing scheme.

5. **Write the CHANGELOG entry.** Newest first; heading `## [2.4.0] - 2026-11-09` with ISO date; keep an `## [Unreleased]` section at the top for ongoing work; each bullet starts with the affected area and describes the effect on the user, with a PR or issue link. Add link references at the bottom (`[2.4.0]: https://github.com/org/repo/compare/v2.3.1...v2.4.0`). Write in plain past or present tense consistently.

6. **Write release notes for humans.** Lead with the two or three changes users care about most, why they matter, and a short example. Then a section "Upgrading" for any breaking change or deprecation: what breaks, how to detect it, the exact migration steps or codemod, and the removal timeline for deprecations. Then the full categorised list or a link to the CHANGELOG. Credit external contributors by handle when the project does so.

7. **Cross-check.** Every merged user-facing PR appears once; no entry describes work that is not in the range; the version number matches the most severe change; links resolve to real tags or compare URLs.

## Expected output

```markdown
## [2.4.0] - 2026-11-09
### Added
- Exports: `exportCsv()` accepts a `delimiter` option. ([#412](https://github.com/org/repo/pull/412))
### Deprecated
- Config: `retryCount` is deprecated in favour of `retry.maxAttempts`; it will be removed in 3.0.0.
### Fixed
- Parser: dates with offsets like `+05:30` no longer shift by one day. ([#405](https://github.com/org/repo/pull/405))
### Security
- Bumped `xml-parser` to 4.2.1 to address an entity-expansion issue.
```

Plus: the chosen version with a one-line justification, the release notes text, and a list of excluded changes with the reason (so reviewers can disagree).

## Constraints and limitations

- Do not describe a security fix in more detail than the project's disclosure policy allows; coordinate with maintainers before publishing exploit details.
- Never publish a release, push a tag, or post notes without explicit approval; produce drafts.
- If the public surface is undefined, say so and ask; the bump depends on it.
- Automated generators are only as good as commit discipline; review their output rather than shipping it verbatim.

## Examples

**Range:** 14 merged PRs. Two add options, eight fix bugs, one renames the CLI flag `--out` to `--output` while keeping `--out` as a hidden alias with a warning, three are CI-only.
**Decision:** MINOR (2.3.1 → 2.4.0). The rename keeps the old flag working, so it is a deprecation, not a break; it goes under Deprecated with a removal note for 3.0.0. CI-only PRs are listed as excluded. Had the alias been dropped, the bump would be 3.0.0 with an Upgrading section.
