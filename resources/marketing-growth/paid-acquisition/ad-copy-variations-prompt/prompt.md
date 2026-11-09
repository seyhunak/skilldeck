# Ad Copy Variations

## Intended task
Generate ad copy variations that differ by strategic angle (benefit, proof, objection, urgency, audience call-out) rather than by synonyms, for search or social ad formats. The model works within the character limits and policy notes you supply, counts characters for every line, and flags claims that ad platforms commonly restrict. Use it when building a new ad group or ad set, refreshing fatigued creative, or preparing an angle test.

Ad platforms change their formats, character limits, and advertising policies. This prompt deliberately takes limits as input instead of assuming them: look up the current limits and policies in the platform's own documentation before filling in the variables, and confirm them again before uploading any ad.

## Required context
- The platform and ad format, with the character limits for each field taken from the platform's current documentation.
- The offer, landing page promise, and audience, so ads match the page they lead to.
- Approved claims and proof (from your messaging framework); the model will use only these.
- Keywords or audience targeting, so headlines reflect what people searched for or who they are.
- Policy notes relevant to your industry, and any words or claims your legal team prohibits.

## Prompt
```text
You are a performance copywriter who writes ads for paid search and paid social and designs creative tests.

Write ad copy variations for the platform and format below.

Platform and format: {{PLATFORM_FORMAT}}
Field limits supplied by the user (characters, including spaces): {{FIELD_LIMITS}}
Offer and landing page promise: {{OFFER}}
Audience and targeting (keywords or audience description): {{AUDIENCE_TARGETING}}
Approved claims and proof points (use only these): {{APPROVED_CLAIMS}}
Brand voice notes: {{VOICE_NOTES}}
Policy notes and prohibited words or claims: {{POLICY_NOTES}}
Number of variations per angle: {{VARIATIONS_PER_ANGLE}}

Rules:
1. Create variations across these angles: core benefit, proof or credibility, objection handling, audience call-out, and time or offer relevance (only if a genuine deadline or offer exists in the inputs; never invent urgency or scarcity).
2. Every line must fit its field limit. After each line, show its character count in brackets. If a line exceeds the limit, rewrite it before returning; never return an over-limit line.
3. Use only approved claims. Do not invent statistics, prices, discounts, ratings, awards, or guarantees.
4. For search ads, include the main keyword theme naturally in at least one headline per variation and keep each headline meaningful on its own, since platforms may combine headlines in different orders.
5. Avoid practices commonly restricted by ad policies: excessive capitalization or punctuation, misleading claims, unverifiable superlatives, and claims about personal attributes of the viewer. List any line that might still be sensitive under "Policy flags".
6. Tag each variation with its angle and the single hypothesis it tests.

Return:
- A table per angle: Field | Copy | Character count.
- Policy flags: line, concern, suggested safer alternative.
- A suggested test plan: which two or three angles to test first and why.
- A reminder that limits and policies must be confirmed in the platform's current documentation before upload.
```

## Variables
| Variable | Description | Required |
|---|---|---|
| `{{PLATFORM_FORMAT}}` | The ad platform and format, for example a responsive search ad or a single-image social ad | Yes |
| `{{FIELD_LIMITS}}` | Character limits per field, copied from the platform's current documentation | Yes |
| `{{OFFER}}` | What is offered and what the landing page promises | Yes |
| `{{AUDIENCE_TARGETING}}` | Keywords, keyword themes, or audience definition | Yes |
| `{{APPROVED_CLAIMS}}` | Claims and proof points cleared for use | Yes |
| `{{VOICE_NOTES}}` | Brief brand voice guidance | Optional |
| `{{POLICY_NOTES}}` | Industry policy considerations and prohibited words or claims | Recommended |
| `{{VARIATIONS_PER_ANGLE}}` | How many variations to write for each angle | Optional |

## Output format
One Markdown table per angle with field name, copy, and character count for every line; a policy flags table; a short prioritized test plan; and the closing reminder to confirm current platform limits and policies. Character counts are the model's own count and should be spot-checked with a character counter or the platform's ad preview, since models can miscount.

## Example usage
A project management SaaS fills in: platform "search ad, responsive format"; field limits taken from the platform's help pages that day for headlines and descriptions; offer "14-day free trial, no card required"; targeting "keyword theme: gantt chart software"; approved claims "used by over 3,000 teams (verified internally)", "drag-and-drop timelines", "integrates with Slack and Jira"; policy notes "no 'best' or '#1'".

A good response returns headlines such as "Gantt Chart Software for Teams [30]" under core benefit, "Used by 3,000+ Teams [20]" under proof, and "No Card Needed for the Trial [28]" under objection handling, with counts that fit the supplied limits, no invented discount, and a test plan recommending proof versus objection angles first.

## Customization
Add or remove angles to suit the test you want to run. For social formats, add fields such as primary text and headline with their limits, and ask for a visual concept note per variation. For regulated industries (finance, health, gambling, housing, employment), add the specific policy requirements and route the output to compliance review. Translate by adding a target language and locale, and ask for character counts after translation, because translated copy often runs longer.
