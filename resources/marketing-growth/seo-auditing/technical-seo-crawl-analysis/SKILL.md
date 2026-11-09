---
name: technical-seo-crawl-analysis
description: Interprets site crawler exports - status codes, indexability, canonicals, redirects, duplicate content, crawl depth, internal links, sitemaps, and hreflang - to find, root-cause, and size technical SEO problems by template. Use after running a crawl with any desktop or cloud crawler and before writing technical SEO tickets.
---

# Technical SEO Crawl Analysis

A method for turning a crawler's thousands of warnings into a short list of root causes, each traced to a template or rule and sized by the important URLs it affects. It is tool-agnostic: column names differ between crawlers, but the concepts are the same.

## When to use

- After a full crawl of a site, especially before or after a migration or major release.
- When Search Console shows indexing exclusions growing and the cause is unclear.
- When preparing technical SEO tickets for engineering.

Not for content or keyword decisions, and not a replacement for search engine data: a crawler shows what it can reach, not what the search engine chose to index.

## Inputs

- **Crawl export** — internal URLs with status code, indexability and reason, canonical, meta robots, X-Robots-Tag, title, H1, word count, crawl depth, inlinks, response time, and content hash or near-duplicate flags. Required.
- **Redirect and chain export**, **sitemap URLs**, **hreflang export** where relevant. Recommended.
- **Crawl configuration** — start URL, user agent, JavaScript rendering on or off, robots.txt respected, URL limits, excluded paths. Required to interpret the results.
- **Traffic or impressions per URL** from analytics or Search Console. Recommended for weighting.

## Procedure

1. **Check the crawl itself.** Confirm the crawl completed, its URL count compared with the expected site size, and whether rendering was on. A crawl that hit its URL limit or got blocked (many 403/429 responses) is incomplete; report it rather than analyze artefacts.
2. **Segment URLs by template.** Use URL patterns (for example /blog/, /product/, /category/, query parameters) to assign each URL to a page type. All further counts are reported per template, because technical problems almost always come from templates or rules, not single pages.
3. **Analyze status codes.** Count 2xx, 3xx, 4xx, and 5xx by template. For 4xx, find which pages link to them (inlinks) and fix the links at source. For 5xx and timeouts, note times and recommend server log review.
4. **Analyze redirects.** Find chains (more than one hop), loops, redirects to non-200 targets, temporary (302/307) redirects used for permanent moves, and internal links pointing at redirected URLs. Recommend updating internal links to final destinations and collapsing chains to a single hop.
5. **Cross-check indexability signals.** For each indexable-intended template, verify consistency: status 200, no noindex in meta robots or X-Robots-Tag, not blocked by robots.txt, self-referencing canonical (or canonical to the intended version), included in the XML sitemap. Flag conflicts such as: canonical pointing to a redirected, 404, or noindex URL; noindexed URLs in the sitemap; robots.txt-blocked URLs that also carry noindex (the noindex cannot be seen); sitemap URLs that are not indexable.
6. **Find duplication.** Use exact-duplicate hashes and near-duplicate flags to find duplicate groups. Common causes: parameter variants, trailing slashes, case differences, HTTP/HTTPS or www/non-www variants, faceted navigation, printer versions. Recommend the consolidation mechanism appropriate to each (redirect, canonical, parameter handling in the application, or noindex), with redirects preferred when the duplicate has no user purpose.
7. **Analyze architecture.** Distribution of crawl depth by template; priority templates deeper than about three or four clicks from the homepage are a common concern (a heuristic). Identify orphan pages (in sitemap or analytics but with zero internal inlinks) and pages reachable only via pagination. Check inlink counts to priority pages.
8. **Check on-page tags at scale.** Missing, duplicate, or templated titles and H1s, empty meta descriptions, and multiple H1s by template. Report counts, not pages.
9. **Check hreflang (if international).** Return-tag errors (A references B but B does not reference A), references to non-200 or non-canonical URLs, invalid language-region codes, and missing self-references.
10. **Check rendering (if JavaScript rendering was used).** Compare raw and rendered titles, canonicals, links, and content length for samples of each template. Content or links that only exist after rendering are a risk worth flagging.
11. **Size and rank.** For each root cause: template, URLs affected, share of those with traffic or impressions, and severity (blocks indexing > wastes crawl or dilutes signals > cosmetic). Write one ticket per root cause, not per URL.

## Expected output

```markdown
# Crawl Analysis: <site> — crawl date <date>
**Crawl config:** <rendering, UA, limits> · **URLs crawled:** <n> · **Completeness:** <ok / issues>

## Template summary
| Template | URLs | 2xx | 3xx | 4xx | 5xx | Indexable | Median depth | Median inlinks |

## Root causes
| # | Issue | Template | URLs affected | With traffic | Severity | Evidence (export/column) | Fix |

## Tickets
### T1 — <title>
Problem · Example URLs (3-5) · Root cause · Fix · Acceptance test (what a re-crawl should show)
```

## Constraints and limitations

- A crawler does not see the search engine's index; confirm indexing with Search Console or similar.
- Rendering in crawlers approximates, but does not equal, search engine rendering.
- Crawl only sites the user owns or is authorized to crawl, at a polite rate.
- Severity is a judgement; traffic-weighting improves it but does not make it precise.

## Examples

A 48,000-URL e-commerce crawl shows 19,000 non-indexable URLs. Segmentation reveals 17,500 are /category/ URLs with ?sort= and ?color= parameters, canonicalized to the clean category URL, but 2,300 of them are listed in the XML sitemap and linked from faceted filters. Root cause: the sitemap generator includes parameter URLs. Fix: exclude parameterized URLs from the sitemap; consider whether high-demand facets (for example "red dresses") deserve indexable landing pages. Acceptance: re-crawl shows zero non-indexable URLs in the sitemap.
