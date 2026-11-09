---
name: git-history-forensics
description: Mines a git repository's history with concrete git log commands to find churn hotspots, code ownership and bus-factor risk, change coupling between files, and activity trends. Use when assessing an unfamiliar codebase, prioritising refactoring or review effort, estimating knowledge-loss risk, or explaining why a file keeps breaking. Read-only; requires a local clone with history.
---

# Git History Forensics

Version history is behavioural data about a codebase: where people actually spend effort, who holds the knowledge, and which files change together even though no import links them. This skill turns `git log` output into three evidence-backed signals — **churn hotspots**, **ownership/bus factor**, and **change coupling** — that complement static analysis.

## When to use

- Surveying a new repository and deciding where to read first or where risk concentrates.
- Prioritising refactoring: hotspots = high churn x high complexity (Adam Tornhill's "code as a crime scene" approach).
- Estimating knowledge-loss risk before someone leaves or a team is reorganised.
- Finding hidden dependencies: files that always change together across module boundaries.
- Investigating a regression window (pair with `git bisect`).

Do not use it on shallow clones (`git rev-parse --is-shallow-repository` returns `true`) without first running `git fetch --unshallow`, and do not treat it as a performance review of individuals — commit counts measure activity, not contribution quality.

## Inputs

- A local clone with full history (required). Note the default branch and HEAD commit.
- Analysis window (default: last 12 months; use `--since`). Older history is useful for ownership, misleading for churn.
- Paths to exclude: lockfiles, generated code, vendored dirs, snapshots, migrations if auto-generated.
- Optional: a `.mailmap` or a list of author aliases to merge identities.

## Procedure

1. **Check the history is trustworthy.** Confirm full depth, count commits, and look for distortions:
   ```bash
   git rev-parse --is-shallow-repository
   git rev-list --count HEAD
   git log --since="12 months ago" --format='%an' | sort | uniq -c | sort -rn | head
   git log --diff-filter=R --summary --since="12 months ago" | grep -c rename
   ```
   Large one-off commits (formatter runs, license headers, mass renames) inflate churn; find them with `git log --since="12 months ago" --shortstat --format='%h %s' | paste - - - | sort -t, -k2 -rn | head` and add their hashes to an exclusion list. If authors appear under several names, rely on `.mailmap` (`%aN` honours it).

2. **Churn hotspots (change frequency).** Count commits touching each file, excluding merges and noise:
   ```bash
   git log --since="12 months ago" --no-merges --format= --name-only -- . \
     ':(exclude)*.lock' ':(exclude)package-lock.json' ':(exclude)vendor/*' \
     | grep -v '^$' | sort | uniq -c | sort -rn | head -30
   ```
   For lines added/removed per file (code churn rather than commit count):
   ```bash
   git log --since="12 months ago" --no-merges --numstat --format= \
     | awk '$1 != "-" {a[$3]+=$1; d[$3]+=$2} END {for (f in a) print a[f]+d[f], a[f], d[f], f}' \
     | sort -rn | head -30
   ```
   Then intersect with size or complexity (e.g. `wc -l`, or output from `code-complexity-analysis`). A file in the top decile of both is a hotspot; a high-churn trivial file (config, changelog) is not.

3. **Ownership and bus factor.** Per file or directory, find the share of commits and surviving lines by author:
   ```bash
   git log --no-merges --format='%aN' -- src/billing/ | sort | uniq -c | sort -rn
   git blame --line-porcelain -w -M -C src/billing/invoice.py \
     | grep '^author ' | sort | uniq -c | sort -rn
   git shortlog -sn --no-merges --since="12 months ago" -- src/billing/
   ```
   Heuristic flags: one author owning more than 75-80% of a hotspot's recent commits is a knowledge silo; a directory whose main author has made no commits in 6+ months is "orphaned". Bus factor for a component is the smallest number of authors whose departure removes more than half its recent knowledge — report it as an estimate.

4. **Change coupling (temporal coupling).** Find file pairs that co-occur in commits:
   ```bash
   git log --since="12 months ago" --no-merges --format='--%h' --name-only \
     | awk '/^--/ {if (n>1 && n<30) for(i=1;i<=n;i++) for(j=i+1;j<=n;j++) print f[i]" | "f[j]; n=0; next}
            NF {f[++n]=$0}
            END {if (n>1 && n<30) for(i=1;i<=n;i++) for(j=i+1;j<=n;j++) print f[i]" | "f[j]}' \
     | sort | uniq -c | sort -rn | head -30
   ```
   Commits touching 30+ files are skipped as noise. Compute degree of coupling as `shared commits / min(commits(A), commits(B))`; treat pairs with at least ~5 shared commits and degree above ~50% as meaningful. Coupling across module or service boundaries (API handler and a client in another package; code and a test fixture elsewhere) is the interesting finding; a source file coupled to its own unit test is expected.

5. **Trends and age.** Monthly commit volume and last-touched dates show where activity is moving and what is stale:
   ```bash
   git log --no-merges --since="24 months ago" --format='%ad' --date=format:'%Y-%m' | sort | uniq -c
   git ls-files -z src | xargs -0 -I{} git log -1 --format='%ad {}' --date=short -- {} | sort | head -20
   ```

6. **Targeted archaeology.** For a specific file or bug: `git log --follow -p -- path` (history through renames), `git log -S 'symbol' --oneline` (when a string appeared/vanished), `git log -L :functionName:path` (function-level history), and `git bisect start BAD GOOD` with a test command to find the introducing commit.

7. **Interpret and report.** Combine signals; never present a raw count without context. State the window, exclusions, and caveats (squash merges hide authorship; rebases rewrite dates; monorepo-wide refactors distort coupling).

## Expected output

```markdown
## Git history findings — <repo> @ <short-hash>, window <since>..<until>
Exclusions: <paths, commit hashes>; identity merging: <mailmap yes/no>

### Hotspots (churn x size)
| File | Commits | Lines changed | LOC | Note |
### Ownership and bus factor
| Component | Top author share | Active authors (12m) | Bus factor (est.) | Flag |
### Change coupling
| File A | File B | Shared commits | Degree | Crosses boundary? |
### Trends
<one paragraph: activity direction, stale areas>
### Caveats
<squash merges, mass commits, shallow history, etc.>
```

## Constraints and limitations

- Read-only: never rewrite history, push, or run `git gc`/`filter-repo` during analysis.
- Commit counts are proxies. Squash-merge workflows collapse many authors into one; pair-programmed commits credit one person. Say so.
- Do not rank or judge individual engineers; report ownership at component level unless the user explicitly asks about knowledge transfer.
- `git blame` cost is high on large files; sample hotspots rather than blaming the whole repo.
- Thresholds above are heuristics to start a conversation, not standards.

## Examples

**Request:** "Where should we focus refactoring in this service?"
**Result sketch:** `orders/pricing.py` — 94 commits in 12 months (top 1%), 1,800 LOC, 81% of commits by one author, coupled at 68% with `api/serializers/order.py` in another package. Recommendation: treat as the first refactoring target, pair a second engineer on it, and investigate why serializer changes ride along with every pricing change (likely a leaked data shape).
