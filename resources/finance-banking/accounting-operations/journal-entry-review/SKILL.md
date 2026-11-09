---
name: journal-entry-review
description: Tests a population of journal entries for completeness and unusual characteristics - manual and post-close entries, weekend or after-hours postings, round amounts, unusual account pairings, seldom-used accounts, self-approved entries, and reversals around period end - and returns risk-scored selections with documentation requests. Use for close review, internal control testing, or audit preparation.
---

# Journal Entry Review

Management override of controls most often shows up in journal entries: a manual entry posted after close by someone who also approved it, to an account pairing nobody normally uses, for a round amount that reverses next month. This skill applies structured journal entry testing so that reviewers spend their time on the entries most likely to matter, with documented criteria. It identifies entries for human follow-up; it does not conclude that any entry is improper.

## When to use

- Controller or finance manager review of manual journals before close sign-off.
- Internal audit or SOX/ICFR control testing of the journal entry process.
- Preparing for an external audit, where auditors will perform similar testing (for example under ISA 240 / AU-C 240 requirements on management override).
- Following up a reconciliation break or suspected misstatement.

Not appropriate for: reconciling two ledgers (use `financial-reconciliation-agent`) or analyzing customer transaction fraud (use `fraud-pattern-investigation-agent`).

## Inputs

- Full journal entry population for the period with: entry ID, line amounts, accounts, posting and effective dates, entry timestamps, source (manual, system, interface), preparer, approver, description, and reversal flags. Required.
- Trial balances at period start and end for completeness testing. Required.
- Chart of accounts with account types, user list with roles, and close calendar. Strongly recommended.
- Materiality or review thresholds from the controller or auditor. Optional.

## Procedure

1. **Test completeness.** Roll forward: opening trial balance + sum of journal activity = closing trial balance for every account. Check that each entry's debits equal credits and look for gaps or duplicates in entry numbering. Do not proceed to selection on an incomplete population.
2. **Profile the population.** Summarize entries and value by source, preparer, day, and account. Identify the manual subset, since automated interface entries are usually tested through system controls.
3. **Apply risk criteria.** Flag entries that meet one or more criteria: manual entries above threshold; posted after period close or on non-business days or outside working hours; round amounts (for example ending in 000) or amounts just below an approval limit; unusual account combinations (revenue debited against cash or suspense; expense credited to equity); seldom-used or recently created accounts; entries by senior staff or users who do not normally post; preparer equals approver or no approval; vague descriptions ("adjustment", "per CFO", blank); entries reversed shortly after period end; and top-side consolidation entries.
4. **Score and select.** Assign a weight per criterion (state the weights, as they are judgemental) and rank entries by combined score and value. Select all high-score entries plus a sample of the remainder so coverage is not purely rules-driven; record the selection rationale.
5. **Request support.** For each selected entry list the documentation needed: business rationale, calculation, source documents, approval evidence, and the effect on financial statement lines.
6. **Evaluate responses.** When support is provided, assess whether it explains the amount, account, period, and approval. Mark entries as supported, supported with exceptions, or unresolved; escalate unresolved ones.
7. **Report control observations.** Summarize patterns such as access conflicts (users who can both post and approve), missing approvals, or weak descriptions, with counts.

## Expected output

```markdown
## Journal Entry Review: <entity> — <period>
Population: <entries, lines, value> · Completeness: <pass/fail with differences>

### Criteria and weights
| Criterion | Weight | Entries flagged |

### Selected entries
| JE ID | Date/time | Preparer/approver | Accounts | Amount | Criteria hit | Score | Support requested |

### Results of follow-up
| JE ID | Status | Notes |

### Control observations
### Limitations of this review
```

## Constraints and limitations

- Analytical support only, not audit, accounting, or legal advice. Flags indicate entries for review, not wrongdoing; conclusions and any disciplinary or reporting steps need qualified human sign-off.
- Never post, reverse, or edit entries; propose corrections for the preparer and approver.
- Refer to users by user ID or role in shared outputs; avoid speculating about individuals' intent.
- Stop if the population fails completeness, because selections would be unreliable.

## Examples

Entry JE-48211 posted Sunday 23:40 on day three after close, preparer = approver (user FIN07), debit Accounts receivable 250,000 / credit Revenue, description "adj", reversed on day six of the next period. Criteria hit: post-close, non-business hours, self-approval, round amount, revenue account, vague description, quick reversal → highest score. Support requested: contract, delivery evidence, rationale for reversal, independent approval.
