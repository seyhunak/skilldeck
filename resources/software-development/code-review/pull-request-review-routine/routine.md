# Pull Request Review Routine

## Objective
Review one pull request so that it ends in an explicit, justified decision (approve, approve with optional suggestions, or request changes) within a predictable time, with comments the author can act on without a meeting. The routine fixes the order of operations: understand intent before reading lines, review the riskiest code first, check the tests as seriously as the code, and separate blocking problems from preferences. The checklist content for each pass comes from the `structured-code-review` skill; this routine is the workflow wrapped around it.

## Trigger
Run it when you are requested as a reviewer, ideally within one working day of the request. It is a guide for a human reviewer, optionally assisted by an AI tool such as `pull-request-review-agent`; it does not run on its own and nothing in it posts or approves automatically.

## Prerequisites
- Read access to the repository, the linked ticket or design doc, and CI results.
- Ability to check out the branch locally if behaviour needs to be exercised.
- The team's review conventions: comment labels, what blocks merge, required approvals, and CODEOWNERS rules.
- A protected block of time. Heuristic: review in sessions of no more than about 60 minutes; attention drops sharply after that and defects get missed.

## Inputs
- Required: the PR link, its description, the diff, CI status.
- Optional: linked issue, design doc or ADR, screenshots or recordings for UI changes, feature flag configuration, migration scripts, and any earlier review rounds.

## Steps
1. **Establish intent (5 minutes).** Read the PR description and the linked issue before the code. Write one sentence: "This PR should make X true without changing Y." If you cannot write it, ask the author for the missing context before reviewing the lines.
2. **Check size and shape.** Note lines changed and files touched. Heuristic: beyond roughly 400 changed lines of non-generated code, review quality falls; ask whether it can be split (refactor first, behaviour change second) before investing time. Confirm the PR does one thing; unrelated changes are a reason to request a split.
3. **Check CI and the obvious.** If required checks fail, comment once and wait rather than reviewing code that will change. Confirm generated files, lockfiles and snapshots changed only where expected.
4. **Map the risk.** Skim the file list and rank files by risk: data model and migrations, authentication and authorization, money and billing, concurrency, public APIs, error handling, then everything else. Review in that order so the important passes get your freshest attention.
5. **Correctness pass.** For each high-risk file, trace the main path and at least two edge paths (empty input, failure of a dependency, retry or duplicate request). Ask: does it meet the intent sentence from step 1? What happens on partial failure? Is anything left in an inconsistent state?
6. **Security and data pass.** Check input validation, authorization at the right layer, injection points (SQL, shell, templates), secrets in code or logs, personal data in logs, and new dependencies (licence, maintenance, known advisories).
7. **Tests pass.** Read the tests as specifications. Would they fail if the change were reverted? Do they cover the edge paths from step 5? Are they deterministic (no sleeps, real clocks or order dependence)? Missing tests for a bug fix is normally blocking.
8. **Design and maintainability pass.** Naming, duplication with existing helpers, abstraction level, comments that explain why, and observability (logs, metrics) for new failure modes. Keep these comments proportionate; most are non-blocking.
9. **Run it when it matters.** For UI changes, migrations or tricky behaviour, check out the branch and exercise the scenario, or ask for evidence (screenshots, query plans, a test run output).
10. **Write comments.** Label every comment (for example issue/blocking, suggestion, question, nitpick, praise). Anchor each to a line, state the impact, and propose a fix. The `code-review-feedback-prompt` can turn rough notes into this form. Batch comments into one review submission rather than many notifications.
11. **Decide and summarise.** Submit with a summary: decision, blocking items in priority order, and what you did not review (for example "did not run the migration locally").

## Decision points
- If any blocking issue exists (incorrect behaviour, security flaw, data loss risk, missing test for a fix, breaking API change without versioning), request changes.
- If only suggestions and nitpicks remain, approve and state they are optional; do not hold a PR hostage to preferences.
- If the PR is too large or mixes concerns, request a split before a line-level review.
- If the design itself is wrong, stop line comments and raise it in one comment or a short call; detailed comments on code that will be rewritten waste both people's time.
- If you lack expertise for a risky area (cryptography, payments, accessibility), say so and request a reviewer who has it, for example via `frontend-accessibility-review-agent` findings for UI.
- If the review stretches past three rounds, switch to a synchronous conversation.

## Expected output
A submitted review containing labelled, line-anchored comments and a summary such as:

```text
Decision: Request changes
Blocking: (1) refund path double-charges on retry, payments/refund.py:L140; (2) no test for the empty-cart case.
Optional: two naming suggestions, one helper reuse.
Not reviewed: migration not executed locally.
```

## Validation checklist
- [ ] The intent sentence was written before reading the diff and the change satisfies it.
- [ ] High-risk files were reviewed first and edge paths were traced, not just the happy path.
- [ ] Tests would fail if the change were reverted, and cover the edge paths.
- [ ] Every comment has a label, a location and a concrete suggestion or question.
- [ ] The summary states the decision, blocking items, and anything not reviewed.
- [ ] No preference-only comment was marked blocking.

## Human approval
Approval, request-changes and merge decisions belong to the human reviewer and the repository's required approvers. An assistant may draft comments and summaries, but posting the review, resolving threads, approving, or merging requires the reviewer's explicit instruction each time. Changes touching security, payments or data deletion should get a second human reviewer even when one approval is technically enough.
