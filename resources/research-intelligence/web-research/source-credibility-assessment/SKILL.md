---
name: source-credibility-assessment
description: Evaluates how much weight a source deserves before a claim from it is used. Applies SIFT lateral reading (Stop, Investigate the source, Find better coverage, Trace to the original), checks fitness with CRAAP criteria (currency, relevance, authority, accuracy, purpose), traces provenance, notes bias and conflicts of interest, and assigns separate grades for source reliability and claim credibility. Use whenever research relies on web pages, reports, social posts, vendor content, or unfamiliar publications.
---

# Source Credibility Assessment

## When to use

Load this skill when an answer, report, or decision is about to rest on a source you have not already vetted: a web article, a statistic in a slide, a vendor white paper, a social media post, a preprint, an unfamiliar journal, or an AI-generated summary. Use it during research (to decide whether to keep reading) and before delivery (to grade the evidence you kept).

It is not a substitute for subject-matter review of complex methods: a statistically subtle paper still needs an expert reader. It also does not decide what is true by itself; it decides how much weight a source can bear.

## Inputs

- The source: URL, document, or citation, and the specific claim you want to use from it.
- The purpose: what decision or deliverable the claim will support, which sets how strict to be.
- Optional: other sources on the same claim, for corroboration.

## Procedure

1. **Stop.** Before reading deeply, note what you already know about the source and what you need from it. If the claim is emotionally charged, surprisingly convenient, or too precise to be plausible, raise the bar.
2. **Investigate the source by reading laterally.** Leave the page and search for the publisher and author elsewhere: who funds or owns the outlet, what it is known for, whether reputable organizations cite it, and whether the author has relevant expertise. Do not judge a site by its own "About" page or design quality.
3. **Find better coverage.** Search for the same claim from independent, established sources. If the best coverage is better than what you have, switch to it. If no independent source mentions a significant claim, that absence is itself evidence.
4. **Trace claims to the original.** Follow links and citations upstream to the original study, dataset, filing, transcript, or official statement. Check that the original says what the secondary source says, with the same numbers, scope, and caveats. Count repeated coverage of one origin as a single source.
5. **Apply CRAAP to the source you will actually cite.**
   - Currency: publication and update dates; whether newer data supersedes it.
   - Relevance: whether it addresses your exact question, population, and geography.
   - Authority: the author's and publisher's expertise and accountability (editorial process, peer review, corrections policy).
   - Accuracy: whether evidence, methods, and data are shown and can be checked.
   - Purpose: inform, sell, persuade, or entertain; disclosed and undisclosed interests.
6. **Note bias and conflicts.** Record sponsorship, vendor authorship, advocacy positions, and selection effects (for example surveys of a vendor's own customers). Bias does not disqualify a source, but it shapes which claims you can rely on.
7. **Grade on two axes.** Source reliability: A (consistently reliable) to E (unreliable), F (cannot judge). Claim credibility: 1 (confirmed independently) to 5 (contradicted), 6 (cannot judge). Keep them separate.
8. **Decide use.** Heuristic: rely on A-B sources with claims at 1-2 for decisions; use C or 3 as supporting context with hedged wording; treat D-E or 4-5 as leads only. Record the reason in one line.

## Expected output

```markdown
| Source | Claim used | Origin traced to | Lateral-reading notes | CRAAP flags | Bias/interest | Grade | Use |
|---|---|---|---|---|---|---|---|
| <title, publisher, date, URL> | "<claim>" | <original doc or "not found"> | <who they are> | Currency: ok; Purpose: vendor | Sponsored by X | B2 | Rely, attribute |
```

Followed by a short note on any claim that changed after tracing (for example "the 40% figure is from a 2019 survey of 200 customers, not industry-wide").

## Constraints and limitations

- Grades are reasoned judgements; record the reason so others can disagree.
- Peer review and reputation reduce error but do not eliminate it; reputable outlets publish corrections.
- Do not bypass paywalls to read an original; record it as not accessed.
- Avoid assessing a source by political alignment alone; assess its evidence and accountability.
- When stakes are high (health, legal, financial, safety), escalate to a qualified human reviewer.

## Examples

**Claim:** "Remote workers are 13% more productive" in a blog post.
Lateral reading shows the blog is a coworking vendor. Tracing leads to a well-known randomised study of call-centre employees at one Chinese travel company. The original measured a specific role and setting. Grade: blog D3, original study A2 for its own population. Use: cite the original with its scope ("in a randomised trial of call-centre staff at one firm"), not the blog's general claim.

**Claim:** A statistic in a slide with no citation. Search finds the same number on many sites, all linking to one market-research press release that does not publish its method. Grade: C3. Use: lead only; seek an independent figure or present it as the firm's estimate.
