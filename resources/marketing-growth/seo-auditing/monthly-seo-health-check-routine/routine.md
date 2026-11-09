# Monthly SEO Health Check Routine

## Objective
Catch search regressions while they are still cheap to fix, and keep a dated record of the site's organic health. Each month, one person reviews the same set of data sources in the same order, compares them with the previous month and the same month last year, logs anything abnormal with evidence, and opens tickets for confirmed issues. The routine takes roughly one to three hours for a small or mid-size site once the first run has set up the log. It is a monitoring pass, not a full audit: when it finds something systemic, it escalates to a full audit instead of trying to solve it inside the check.

## Trigger
Run it in the first week of each calendar month, covering the previous full month. Also run it out of cycle within a few days after a site migration, CMS or template release, robots.txt or redirect change, domain change, or a sudden drop reported by anyone on the team. The routine is guidance for a person (optionally assisted by an AI agent reading exports); nothing in it runs automatically.

## Prerequisites
- Read access to the site's search console property (for example Google Search Console and, if used, Bing Webmaster Tools) and web analytics.
- A site crawler the team is licensed to use, configured with the same settings every month (rendering on or off, user agent, excluded paths).
- The health log from previous months (a spreadsheet or document with one row per check per month).
- A list of priority templates and the top 20-50 landing pages by organic traffic or conversions.
- The release and change log for the month, so changes can be lined up against metric movements.
- A ticketing destination and named owners for engineering and content fixes.

## Inputs
- Search console exports: Performance by page and query for the month, previous month, and same month last year; Page indexing report; Sitemaps status; Core Web Vitals report; Manual actions and Security issues pages.
- Analytics: organic sessions and conversions by landing page for the same periods.
- This month's crawl export, plus last month's for comparison.
- Optional: rank tracking for a fixed keyword set, backlink tool's referring-domain trend.

## Steps
1. **Check for critical alerts first.** Open the Manual actions and Security issues pages and any search console messages. If either shows an issue, stop the routine and escalate immediately; nothing else matters until it is handled.
2. **Review organic performance.** Compare clicks, impressions, CTR, and average position for the month against the previous month and the same month last year (year-over-year removes most seasonality). Split brand and non-brand queries if possible. Record the numbers in the log. Treat moves smaller than normal month-to-month variation for this site as noise; after a few months the log shows what normal looks like.
3. **Find the pages and queries behind any change.** If clicks moved materially, sort pages by absolute change in clicks and look at the top 10 losers and gainers. For each loser, check whether impressions fell (visibility or indexing problem), position fell (ranking change), or only CTR fell (SERP change, title rewrite, new competing feature).
4. **Check indexing coverage.** In the Page indexing report, compare indexed and not-indexed counts with last month, and note any reason whose count grew sharply (for example "Excluded by noindex tag", "Not found (404)", "Page with redirect", "Crawled - currently not indexed", "Alternate page with proper canonical tag"). Use URL inspection on a few examples from any growing reason. Confirm submitted sitemaps were processed without errors and that their URL counts are plausible.
5. **Run and compare the crawl.** Using the `technical-seo-crawl-analysis` skill, compare this crawl with last month's on: total URLs, status-code distribution, new 4xx/5xx URLs and the pages linking to them, new redirect chains, changes in noindex or canonical tags on priority templates, title/H1 changes on top landing pages, and crawl depth of priority templates. Investigate any difference you cannot explain from the change log.
6. **Check page experience.** Review the Core Web Vitals report for changes in the number of poor or needs-improvement URLs by metric and template group. Field data lags by several weeks, so link changes to releases with care.
7. **Spot-check top pages.** For the top 10 landing pages, open each on mobile, confirm it returns 200, is indexable, has the intended title and canonical, and renders its main content. Releases often break exactly these pages.
8. **Check links (optional).** Look for a sharp change in referring domains or many new links from obviously spammy sources; record but do not act on the latter without discussing it.
9. **Log and triage.** For each anomaly, write a row: date, check, observation, evidence (report and example URLs), likely cause, severity (critical: blocks indexing or traffic on priority templates; high: affects many URLs or a top page; medium; low), owner, ticket link, status.
10. **Open tickets and summarize.** Open tickets for confirmed issues with evidence and an acceptance test. Write a short summary (five to ten lines) for stakeholders: headline numbers, what changed and why, issues opened, and items carried over from last month.

## Decision points
- If a manual action or security issue exists, stop and escalate to the site owner and security or SEO lead the same day.
- If non-brand clicks fell beyond normal variation and the drop is concentrated on one template, treat it as a technical or template issue and inspect that template first; if spread across the site with no technical cause, check for a publicly announced search engine update and competitor changes, and consider a full audit with `seo-audit-agent`.
- If indexed pages dropped sharply with a matching growth in "noindex" or "404" reasons, treat it as critical and check the latest release.
- If only CTR fell while position held, review titles and SERP features rather than technical health.
- If the crawl differs from last month but the change log explains it (intended removals, planned redirects), log it as expected and close it.
- If three or more high-severity issues appear in one month, recommend a full audit rather than piecemeal fixes.

## Expected output
An updated health log with this month's metrics and anomaly rows, a set of tickets for confirmed issues (each with evidence, owner, severity, and acceptance test), and a short stakeholder summary that states the overall status (healthy, watch, or action needed), the main changes with likely causes, and items carried over.

## Validation checklist
- [ ] Manual actions and security issues were checked and recorded, even if clear.
- [ ] Metrics were compared month over month and year over year, with brand and non-brand separated where possible.
- [ ] Every anomaly in the log cites a report or export and at least one example URL.
- [ ] Crawl settings matched last month's, so the comparison is valid.
- [ ] Each confirmed issue has a ticket with an owner and an acceptance test.
- [ ] Unexplained changes are marked as open questions rather than assigned a guessed cause.
- [ ] Last month's open items were reviewed and their status updated.

## Human approval
The routine itself is read-only. Any change it leads to (robots.txt, redirects, canonical or noindex rules, sitemap generation, template changes, content removal) must go through the team's normal engineering or content review and be approved by the site owner before release. Disavow files, removal requests, and reconsideration requests are never submitted as part of this routine; they need an explicit decision by the SEO lead and site owner. Stakeholder summaries that attribute a traffic change to a cause should be reviewed by the SEO lead before circulation, since causes are often uncertain.
