---
name: commit-message-writing
description: Writes commit messages that follow Conventional Commits, explain why a change was made rather than restating the diff, and splits mixed working-tree changes into atomic, reviewable commits. Use when committing staged changes, cleaning up a branch before review, or setting a team convention that feeds changelog and semver automation.
---

# Commit Message Writing

The diff already says *what* changed. A commit message exists to record *why*, what was considered, and what a future reader (or `git bisect`, `git blame`, and release tooling) needs to know. This skill produces messages that work for humans and for automation.

## When to use

- Writing a message for staged changes.
- Splitting a messy working tree into a sequence of atomic commits before opening a pull request.
- Agreeing a commit convention that will drive changelog generation or version bumps.

Not for: writing release notes or a CHANGELOG from many commits (`changelog-and-release-notes`) or writing a PR body.

## Inputs

- The staged diff (`git diff --staged`) and, if splitting, the unstaged diff (`git diff`).
- The reason for the change: ticket, bug report, conversation, or the user's explanation. If the reason is unknown, ask — do not invent one.
- Repository conventions: look at `git log --oneline -20`, `CONTRIBUTING.md`, and commitlint config (`commitlint.config.*`, `.commitlintrc*`) for allowed types and scopes.

## Procedure

1. **Check atomicity.** One commit = one logical change that builds and passes tests on its own. Signs a split is needed: the summary needs "and"; the diff mixes refactoring with behaviour change; formatting churn hides a fix; unrelated files changed. Split with `git add -p` (hunk selection) or `git add <paths>`, committing refactors and moves before the behaviour change so the behaviour diff stays small. Renames should land in their own commit so history follows them.

2. **Pick the type.** Conventional Commits 1.0.0 format: `type(scope)!: description`. Common types (from the Angular convention, adopted by commitlint's config-conventional): `feat` (new user-facing capability; minor bump), `fix` (bug fix; patch bump), `perf`, `refactor` (no behaviour change), `docs`, `test`, `build`, `ci`, `chore`, `style`, `revert`. Only `feat` and `fix` are defined by the spec itself; the rest are convention, so follow the repo's list.

3. **Choose a scope** matching the codebase's own module or package names (`fix(billing):`), or omit it if the repo does not use scopes. Do not invent scopes per commit.

4. **Write the subject line.** Imperative mood ("add", "fix", "remove" — it should complete "If applied, this commit will..."), lower-case after the colon unless the repo differs, no trailing period, about 50 characters and a hard limit around 72. Be specific: `fix(auth): reject expired refresh tokens` not `fix: bug`.

5. **Write the body when the why is not obvious.** Blank line after subject, wrap at 72 columns. Cover: the problem or motivation (what was wrong, observed symptom), why this approach (and alternatives rejected, briefly), and side effects or risks (migration needed, performance impact, behaviour change). Do not narrate the diff line by line.

6. **Add footers.** `BREAKING CHANGE: <what breaks and how to migrate>` (or `!` after the type/scope) for incompatible changes — this triggers a major bump in semantic-release and similar tools. Issue references per the host's syntax (`Fixes #123`, `Refs PROJ-88`). Trailers like `Co-authored-by:` and `Signed-off-by:` (DCO) when the project requires them.

7. **Review before committing.** Read the message alongside `git diff --staged`: does every claim match the diff? Is anything in the diff unexplained? For a cleanup of existing local commits, use `git commit --fixup` + `git rebase --autosquash` — and never rewrite commits already pushed to a shared branch without the team's agreement.

## Expected output

```text
fix(billing): round tax per line item before summing

Invoices for multi-line orders were off by up to 1 cent per line
because tax was computed on the order total and then allocated back
to lines. Finance reconciles per line, so totals disagreed with the
ledger export.

Compute tax per line with banker's rounding and sum the results.
Rejected: keeping total-level rounding and adjusting the last line,
which hides the discrepancy on single-line refunds.

Fixes #482
```

When splitting, output an ordered plan: commit number, files or hunks, message.

## Constraints and limitations

- Never fabricate motivation, ticket numbers, or co-authors; ask or leave them out.
- Do not run `git commit`, `rebase`, or `push` unless the user asked you to; proposing messages is the default.
- Respect existing repo conventions even when they differ from Conventional Commits.
- Squash-merge workflows mean the PR title becomes the commit subject; apply the same rules to it.

## Examples

**Working tree:** a renamed module, a fixed null check, and a reformatted test file.
**Plan:**
1. `refactor(sync): rename uploader module to transfer` — rename only, no logic change.
2. `style(tests): apply formatter to transfer tests` — formatting only.
3. `fix(sync): skip files deleted during upload` — the null check, with a body explaining the crash seen when a file disappears between scan and upload, and `Fixes #91`.
