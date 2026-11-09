# Debt register guide

## Hotspot scoring

A practical, transparent score: rank files by change count in the window and by complexity, then take the product of their percentile ranks. Files in the top quintile on both are hotspots. This follows the approach popularized by Adam Tornhill's behavioural code analysis; it is a heuristic for directing attention, not a verdict.

Useful history commands (adapt the window and path):

```bash
# Change frequency per file in the last 12 months
git log --since="12 months ago" --name-only --pretty=format: -- src/ \
  | grep -v '^$' | sort | uniq -c | sort -rn | head -50

# Number of distinct authors per file (aggregate before reporting)
git log --since="12 months ago" --pretty=format:'--%an' --name-only -- src/ \
  | awk '/^--/{a=substr($0,3); next} NF{print a"\t"$0}' \
  | sort -u | cut -f2 | sort | uniq -c | sort -rn | head -50
```

Verify the output on a small sample before relying on it; history with merges, renames, or squashes can distort counts (`--follow` works only for single files).

## Interest estimation

Express interest per quarter as a range:

```
interest ≈ (changes to the area per quarter × extra hours per change)
         + (bug and incident hours attributable to the area per quarter)
         + (coordination or onboarding hours caused by the area per quarter)
```

- **Extra hours per change**: ask engineers who recently changed the area how long the change took versus how long it would take in clean code; take the median of several answers and keep the spread.
- **Attributable incident hours**: only count incidents whose postmortem names the area as a contributing factor.
- When none of this is available, rate interest High / Medium / Low with a one-line justification.

## Principal estimation

Break the fix into steps (add tests, refactor, migrate callers, remove old path) and estimate each in engineer-days with low / likely / high values. Wide ranges are honest; narrow ranges without evidence are not.

## Prioritization

| Rule | Use |
|---|---|
| Payback period ≈ principal ÷ interest per quarter | Shorter is better; under a few quarters is usually attractive |
| Risk override | High security, data, or key-person risk can outrank payback |
| Roadmap alignment | Debt in an area scheduled for heavy change pays back sooner; move it up |
| Ride-along first | Prefer paying debt while delivering features in the same code |

## Quadrant reminders

| | Reckless | Prudent |
|---|---|---|
| **Deliberate** | "We don't have time for design" | "Ship now, deal with consequences" (recorded and planned) |
| **Inadvertent** | "What's layering?" | "Now we know how we should have done it" |

Prevention differs: reckless debt calls for standards and review; prudent deliberate debt calls for tracking and scheduled repayment; prudent inadvertent debt is normal learning and calls for periodic refactoring.

## Register field definitions

- **Evidence**: file paths, metrics, incident IDs, or quotes from team input marked as such.
- **Risk**: likelihood × impact of a harmful event, separate from day-to-day interest.
- **Priority**: P1 (next quarter), P2 (this half), P3 (opportunistic), Accept (monitor with a trigger).
