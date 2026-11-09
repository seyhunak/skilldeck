# Knowledge Base Audit Rubric

Heuristic thresholds for the curation audit. They are starting points to calibrate with the owning team, not standards.

## Review intervals by content type

| Content type | Suggested review interval | Stale signals beyond age |
|---|---|---|
| Procedures and how-to guides | 6 months | Screenshots of old UI, retired tool names, steps that reference removed commands |
| Reference (settings, contacts, limits) | 3 to 6 months | Named people who left, version numbers behind current |
| Policies | 12 months, or per the policy's own review clause | Superseded policy number, missing effective date |
| Explanations and background | 12 to 24 months | Describes an architecture or org structure that changed |
| Decision records | Never edited for content; status updated | Status still "proposed" long after the decision date |
| Meeting notes | Not reviewed; archive after the decisions and actions are extracted | — |

## Duplicate classification

- **Exact duplicate:** same body text, or differences limited to formatting. Action: keep the page with more inbound links, redirect or archive the other.
- **Divergent copy:** same topic, at least one conflicting fact (a number, a step order, an owner). Action: owner decision required; merge after resolution.
- **Legitimate variant:** same topic for a different audience, product version, or region, and the page says so in its first lines. Action: keep, add cross-links and an explicit scope line.

## Findability checks for a top task

1. Searching the reader's natural phrasing returns the right page in the first five results.
2. The page is reachable from navigation in three clicks or fewer.
3. The answer appears in the first screen of the page, not after background.
4. The title states the task or the thing, not a project codename.

A task failing two or more checks is poorly served even if the page exists.

## Page header template

```markdown
**Owner:** <role, then person> · **Last reviewed:** <date> · **Review every:** <interval>
**Applies to:** <audience / version / region> · **Status:** current | under review | archived
```

## Archive versus delete

Archive keeps the page readable but removes it from navigation and default search. Prefer archive. Recommend deletion only for exact duplicates and empty stubs, and only with owner approval, because links from email, tickets, and code comments often point at old pages.
