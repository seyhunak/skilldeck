---
name: keyword-research
description: Turns seed topics and keyword tool exports into intent-classified, SERP-clustered, prioritized keyword sets mapped to pages. Use when planning SEO content, deciding which page should target which queries, sizing search demand for a topic, or cleaning up a raw keyword export into an actionable plan.
---

# Keyword Research

A method for going from a handful of seed topics to a short, defensible keyword-to-page map. The output is a set of clusters, each with one target page, a primary query, supporting queries, intent, and a priority score, not a spreadsheet of thousands of rows.

## When to use

- Planning new content or a site section and deciding what to target.
- Mapping existing pages to queries to find gaps and cannibalization.
- Sizing demand for a topic before investing in it.
- Turning a raw export from a keyword tool into decisions.

Not appropriate for paid search bid strategy (search term mining for ads has different economics) or for predicting rankings or traffic precisely.

## Inputs

- **Seeds** — products, problems, audience jobs, and competitor or category terms. Required.
- **Keyword tool export** — query, estimated monthly volume, difficulty, CPC, and SERP features where available. Required for sizing.
- **Search Console query data** for the site, if it exists. Strongly recommended: it shows real demand the site already touches.
- **Site context** — existing pages, topical strengths, conversion paths, and a rough sense of the domain's authority relative to competitors.
- **Market** — country and language; volumes and intent differ across markets.

## Procedure

1. **Expand seeds.** Generate variations with modifiers that express different needs: problem ("how to", "why does"), solution ("tool", "software", "template"), comparison ("vs", "alternative"), commercial ("pricing", "best"), and audience ("for agencies"). Pull related queries and "people also ask" questions from the tool export. Add real phrasing from Search Console, support tickets, and sales calls; it often beats tool suggestions.
2. **Clean the list.** Remove duplicates, misspellings that the tool merges anyway, irrelevant meanings (a homonym in another industry), and branded competitor terms unless comparison pages are planned. Normalize to lowercase.
3. **Classify intent.** Label each query informational, commercial investigation, transactional, or navigational. Confirm intent for important queries by looking at what currently ranks: if the top results are listicles, the searcher wants comparison; if they are product pages, they want to buy; if mixed, intent is fractured and harder to win. Record the dominant result format (guide, list, tool, product page, video).
4. **Cluster by SERP overlap.** Two queries belong together when their top-10 results share several URLs (a common working threshold is 3-4 shared URLs out of 10; treat it as a tunable heuristic). Where SERP data is unavailable, cluster by meaning and intent and mark clusters as unverified. Each cluster becomes one page; splitting a cluster across pages invites cannibalization.
5. **Name each cluster.** Choose the primary query (usually the highest-volume query with the clearest intent) and list supporting queries. Sum the cluster's estimated volume, and note that tool volumes are estimates that can be off substantially for low-volume terms.
6. **Assess difficulty realistically.** Tool difficulty scores are a starting point. Adjust for the site: does it already rank for related queries, do the ranking pages come from much stronger domains, are the results dominated by forums or small sites (often a sign of opportunity), and does the SERP have features (answer boxes, maps, shopping) that reduce organic clicks?
7. **Score business value.** Rate 1-3 how directly the cluster connects to what the business sells: 3 means the searcher could become a customer through this page; 1 means awareness only.
8. **Prioritize.** A simple score: (business value × 2) + demand band (1-3) + winnability (1-3), minus effort (1-3). Show the components so people can argue with them. Prefer clusters where the site already has impressions, because improving an existing page is faster than ranking a new one.
9. **Map to pages.** Assign each cluster to an existing URL (update) or a new page (create). Flag clusters where two existing URLs already compete (consolidation candidates).

## Expected output

```markdown
# Keyword Map: <topic/site> — <market>, <date>

| Cluster | Primary query | Supporting queries | Intent | SERP format | Est. volume (tool) | Difficulty (adj.) | Value | Priority | Target URL | Action |
|---|---|---|---|---|---|---|---|---|---|---|

Notes: data sources and dates; clustering method (SERP overlap or semantic); known caveats.
```

## Constraints and limitations

- Volumes, difficulty, and CPC are third-party estimates; never present them as measured facts.
- SERPs vary by location, device, and personalization; checks are snapshots.
- Zero-volume queries in tools can still drive traffic; do not discard queries that customers demonstrably use.
- Ask the user before targeting competitor brand terms or sensitive topics (health, finance) that may need expert review.

## Examples

Seed: "employee onboarding". Expansion yields "employee onboarding checklist", "onboarding checklist template", "new hire checklist", "employee onboarding software", "best onboarding software for small business", "how to onboard remote employees".

- SERP overlap groups the first three (templates and checklists rank for all three) into cluster A, informational/template intent, target: a downloadable checklist page.
- "employee onboarding software" and "best onboarding software for small business" share listicles and vendor pages: cluster B, commercial investigation, target: a comparison page; value 3.
- "how to onboard remote employees" has guide-format results: cluster C, informational, value 2.

Cluster B scores highest despite higher difficulty because the site already earns impressions for "onboarding software" on its features page; action: rebuild that page to match the list-style intent rather than create a new URL.
