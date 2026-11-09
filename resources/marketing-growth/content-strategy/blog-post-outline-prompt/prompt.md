# Blog Post Outline

## Intended task
Generate a blog post outline aligned with the search intent of a target query. The model classifies intent, matches the format that the results page rewards, identifies what existing results miss, and structures H2/H3 sections around the questions the reader actually has. Use it after you have chosen a target query and before a writer starts drafting, or when refreshing a post whose structure no longer matches what ranks.

## Required context
- The target query and a few supporting queries or "people also ask" questions, so the outline covers the cluster rather than one phrase.
- Notes on the current top results (titles, formats, what they cover and miss). Without these, the model can only guess at the competitive baseline and will say so.
- Who the reader is and what the post should lead them to do, so the outline has a purpose beyond ranking.
- Any product facts, internal data, or angle you want the post to use; the model will not invent data.

## Prompt
```text
You are a senior content strategist who outlines search-driven articles for expert writers.

Create a blog post outline for the target query below. Work in this order:

1. Classify the search intent (informational, commercial investigation, transactional, navigational) and the dominant result format, using the SERP notes. If intent looks mixed, say so and choose the format that best serves the reader described.
2. List the subtopics that most top results cover (table stakes) and the gaps they leave.
3. State the angle: one or two sentences on what will make this post more useful than the current results for this reader. Use the angle or assets provided; do not invent proprietary data.
4. Write the outline:
   - A working title (aim for roughly 60 characters or fewer) and an H1.
   - An introduction plan that answers the query directly within the first few sentences.
   - H2 and H3 headings. Under each heading, one line on the reader question it answers and what the section must include (example, table, screenshot, steps, definition).
   - Mark every place a statistic, quote, or factual claim is needed as [EVIDENCE NEEDED: what kind] instead of inventing it.
   - Two to four internal link slots as [INTERNAL LINK: topic], placed where they help the reader.
   - A conclusion and call to action that fits the funnel stage: {{FUNNEL_STAGE}}.
5. List subtopics deliberately excluded and why (for example, they belong on another page).
6. Suggest an approximate word-count range justified by the depth the topic needs, not by competitor length alone.

Target query: {{TARGET_QUERY}}
Supporting queries and questions: {{SUPPORTING_QUERIES}}
Reader: {{READER}}
Business goal of the post: {{BUSINESS_GOAL}}
SERP notes (top results, formats, coverage, gaps): {{SERP_NOTES}}
Angle or assets available (data, product facts, expert access): {{ANGLE_ASSETS}}
Pages to avoid overlapping with: {{EXISTING_PAGES}}

Do not write the article. Return only the sections described, in Markdown.
```

## Variables
| Variable | Description | Required |
|---|---|---|
| `{{TARGET_QUERY}}` | The primary search query the post targets | Yes |
| `{{SUPPORTING_QUERIES}}` | Related queries and "people also ask" questions in the same cluster | Yes |
| `{{READER}}` | Who searches this and their level of expertise | Yes |
| `{{BUSINESS_GOAL}}` | What the post should lead the reader to do | Yes |
| `{{FUNNEL_STAGE}}` | Awareness, consideration, or decision | Yes |
| `{{SERP_NOTES}}` | Notes on top-ranking results: format, coverage, gaps | Recommended |
| `{{ANGLE_ASSETS}}` | Original data, examples, product facts, or expert access available | Optional |
| `{{EXISTING_PAGES}}` | Your existing pages on adjacent topics, to prevent cannibalization | Optional |

## Output format
Markdown with these parts in order: intent and format classification; table-stakes subtopics and gaps; angle; outline (title, H1, intro plan, H2/H3 headings with purpose lines, evidence markers, internal link slots, conclusion and CTA); exclusions; word-count range with rationale. The outline should be scannable in under two minutes and usable by a writer without further briefing on structure.

## Example usage
Filled values: target query "how to write a project status report"; supporting questions "what should a status report include", "weekly status report template", "status report examples"; reader "first-time project managers at mid-size companies"; business goal "download the status report template"; funnel stage "awareness"; SERP notes "top 5 are listicles of components plus templates; none show a filled-in example for a delayed project"; assets "our template; anonymized example from our PMO".

A good response classifies intent as informational with template expectations, names the gap (no worked example of reporting bad news), sets the angle around "how to report delays honestly", and outlines H2s such as "What a status report must include", "Step by step: writing this week's report", "Worked example: reporting a two-week delay", "Template", and "Common mistakes", with [EVIDENCE NEEDED] markers instead of invented survey statistics.

## Customization
Change the reader and funnel stage freely. Add a house-style line (for example, "use sentence-case headings" or "UK spelling"). For non-English markets, add the language and locale and ask for headings in that language. If you have no SERP notes, keep the variable but write "none available"; the model should then label its table-stakes list as assumed. Keep the instruction not to invent evidence; removing it leads to fabricated statistics.
