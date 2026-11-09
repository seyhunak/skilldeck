---
name: on-page-seo-optimization
description: Optimizes one page's on-page SEO - title tag, meta description, heading outline, content coverage, internal links, image attributes, and structured data - for a stated target query. Use when launching a page, improving a page stuck on page two, or fixing low click-through, and you want concrete before/after recommendations.
---

# On-Page SEO Optimization

A page-level method that starts from what the searcher wants and fixes the elements that affect relevance, understanding, and clicks. It produces a before/after table for one URL that a writer or developer can apply directly.

## When to use

- A page ranks in positions roughly 5-20 for its target query and needs a push.
- A page earns impressions but a low click-through rate compared with pages at similar positions on the same site.
- A new page is about to launch.
- A content refresh is planned.

Not for site-wide technical problems such as indexing, canonicals across templates, or crawl budget (use a crawl analysis), and not for choosing what topics to target in the first place (do keyword research first).

## Inputs

- **URL and current HTML or content** (title, meta description, headings, body, internal links, images, existing structured data). Required.
- **Target query and supporting queries** for the page, with intent. Required.
- **Search Console data** for the page: queries, impressions, clicks, CTR, average position. Recommended.
- **Top-ranking competitors** for the target query (URLs or notes on what they cover). Recommended.
- **Site structure** — related pages that could link in or out. Recommended.

## Procedure

1. **Confirm intent and format.** Check that the page type matches what ranks for the target query (guide versus product page versus tool). If it does not, say so: on-page tweaks will not overcome a format mismatch, and the fix is a different page type.
2. **Rewrite the title tag.** Lead with the primary query or its natural phrasing, add a differentiator that earns the click (year for time-sensitive content, format such as "template" or "checklist", audience, or a concrete benefit), and keep the brand at the end if used. Search engines truncate long titles by pixel width; around 50-60 characters is a widely used guideline, not a rule. Search engines may rewrite titles that don't match the page, so keep it honest.
3. **Rewrite the meta description.** It does not directly affect ranking but influences clicks. Summarize what the page gives the reader, include the query naturally, and add a reason to choose this result. Roughly 140-160 characters is a common guideline; descriptions may be rewritten by the search engine.
4. **Fix the heading outline.** One H1 that states the page topic clearly (it can differ from the title). H2s should map to the main subtopics and questions the searcher has, using the supporting queries where they read naturally. Check the hierarchy is logical (no H4 directly under H2 for styling reasons).
5. **Check content coverage.** Compare the page with the questions in the supporting queries and the subtopics covered by top results. List missing subtopics that a reader would expect, and sections that could be cut. Put the direct answer or core value early. Avoid keyword stuffing; repeat the query only where natural.
6. **Add internal links.** Identify 3-5 relevant pages on the site that should link to this page with descriptive anchor text (not "click here"), prioritizing pages with traffic or external links. Add links out from this page to the next logical step in the reader's journey. Check that the page is reachable within a few clicks from the homepage or a hub.
7. **Fix images and media.** Descriptive file names, alt text that describes content images for accessibility (decorative images get empty alt), compressed formats, and explicit dimensions to avoid layout shift.
8. **Propose structured data.** Choose schema.org types that match visible content: Article or BlogPosting, Product with Offer, FAQPage only where a real FAQ exists, HowTo, BreadcrumbList, Organization. Provide JSON-LD. Note that search engines decide which rich results to show and that eligibility rules change, so the user should validate markup with the search engine's current testing tool and documentation.
9. **Check page experience basics.** Mobile layout, intrusive interstitials, and obvious performance issues on the page (oversized hero images, render-blocking embeds). Hand deep performance work to developers.
10. **Prioritize changes.** Mark each change high, medium, or low impact, and give a way to verify (Search Console page-level CTR and position, compared over 4-8 weeks against the prior period, accounting for seasonality).

## Expected output

```markdown
# On-Page Recommendations: <URL>
**Target query:** <q> · **Intent/format:** <...> · **Format match:** yes/no

| Element | Current | Recommended | Reason | Impact |
|---|---|---|---|---|
| Title | | | | |
| Meta description | | | | |
| H1 | | | | |
| H2 outline | | | | |
| Content gaps | | | | |
| Internal links in | | | | |
| Internal links out | | | | |
| Images | | | | |
| Structured data | | (JSON-LD below) | | |

Verification plan: metric, comparison window, date to check.
```

## Constraints and limitations

- Character guidelines are approximations; display depends on pixel width and device.
- Structured data must describe content visible on the page; never mark up reviews, ratings, or FAQs that are not present.
- On-page changes cannot overcome weak authority, poor content quality, or indexing problems.
- Do not fabricate statistics or expert quotes to fill content gaps; mark them as research needed.

## Examples

Page: a "project budget template" page ranking at position 11. Title currently "Templates | Acme". Recommendation: "Project Budget Template (Free Excel & Google Sheets) | Acme". H1 changes from "Our templates" to "Project budget template". Content gap: top results explain how to fill in each column; the page only offers a download button, so add a short how-to section and a worked example. Add links from the "project planning guide" (the site's top-traffic article) with anchor "project budget template". Add BreadcrumbList markup; skip HowTo markup unless the how-to steps are added and visible.
