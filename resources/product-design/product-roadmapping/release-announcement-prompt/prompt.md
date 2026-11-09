# Release Announcement

## Intended task

Convert internal release information (tickets, engineering changelog, PRD summary, or launch brief) into customer-facing release communication: a headline, a short announcement, release-note entries, and an in-app message. The output leads with the user benefit, states clearly who gets the change and when, tells customers whether they need to do anything, and avoids internal jargon and claims the facts do not support. It does not publish anything; a human reviews and posts.

## Required context

- **Change details** — what changed, from tickets, internal changelog, or a launch brief.
- **Audience** — who the customers are and how technical they are.
- **Availability** — plans or tiers, regions, platforms, rollout timing, and whether it is beta.
- **Required actions** — migrations, settings changes, deprecations, breaking changes, with dates.
- **Voice guidelines (optional)** — tone, words to avoid, formatting conventions.
- **Known limitations (optional)** — what it does not do yet.

## Prompt

```text
You are a product marketing writer who writes release communication customers trust. You are precise about availability and required actions and you never overstate what a feature does.

Product: {{PRODUCT_NAME}}
Audience: {{AUDIENCE}}
Internal change details:
{{CHANGE_DETAILS}}
Availability (plans, regions, platforms, timing, beta status): {{AVAILABILITY}}
Required customer actions and deadlines (may be "none"): {{REQUIRED_ACTIONS}}
Known limitations (may be "none"): {{LIMITATIONS}}
Voice and style guidelines (may be "none"): {{VOICE_GUIDELINES}}

Rules:
- Lead with what the customer can now do or what problem is solved, in their language. Mention the feature name second.
- Translate internal terms, ticket IDs, and code names into plain descriptions; never include internal IDs.
- State availability exactly as given. If availability is missing or ambiguous, write [confirm availability] instead of guessing.
- If customers must act, put the action and deadline in the first lines and in its own clearly labelled section.
- Use only facts present in the inputs. Do not add performance numbers, security or compliance claims, or competitive comparisons that are not in the inputs.
- Mention known limitations honestly and briefly.
- No hype words such as "revolutionary", "game-changing", or "seamless". Use concrete verbs.
- Group multiple changes under New, Improved, Fixed, and Changed or Deprecated.

Produce:
1. Three headline options (each under 70 characters).
2. Announcement (120-200 words) for a blog, email, or changelog page.
3. Release-note entries: one or two sentences each, grouped by type.
4. In-app message: title under 40 characters, body under 140 characters, one call-to-action label.
5. A fact-check list: every claim in your copy paired with the input line that supports it, and any item marked [confirm ...].
```

## Variables

| Variable | Description | Required |
|---|---|---|
| `{{PRODUCT_NAME}}` | Product name as customers know it | Yes |
| `{{AUDIENCE}}` | Who reads this and their technical level | Yes |
| `{{CHANGE_DETAILS}}` | Internal description of the changes | Yes |
| `{{AVAILABILITY}}` | Plans, regions, platforms, timing, beta status | Yes |
| `{{REQUIRED_ACTIONS}}` | Customer actions and deadlines, or "none" | Yes |
| `{{LIMITATIONS}}` | Known limitations, or "none" | No |
| `{{VOICE_GUIDELINES}}` | Tone and style rules, or "none" | No |

## Output format

Five labelled Markdown sections: headline options, announcement, grouped release notes, in-app message, and a fact-check table with columns claim, supporting input, and status (supported or needs confirmation). The fact-check table is for the reviewer and is not published.

## Example usage

Product "Ledgerly"; audience "small-business owners, non-technical"; change details "LED-2211 bank feed sync moved to webhook model, sync latency down from 24h batch to near real time for API-connected banks; LED-2240 fixed duplicate transactions when a feed reconnects"; availability "all paid plans, US and Canada, rolling out over two weeks starting 3 March"; required actions "customers with feeds connected before 2024 must reconnect once by 30 April"; limitations "manual-upload banks unchanged".

A good response produces a headline like "Your bank transactions now appear within minutes", puts "Action needed: reconnect older bank feeds by 30 April" near the top, says "rolling out over the next two weeks", mentions that banks using manual upload are not affected, lists the duplicate-transaction fix under Fixed, contains no ticket IDs or mention of webhooks, and its fact-check table ties "within minutes" back to the "near real time" input and flags it as needing confirmation of the exact wording.

## Customization

- Adjust word counts for your channels; keep the action-first rule for anything with a deadline.
- Add a section for a developer audience with API changes and migration snippets if your customers are technical.
- Paste your style guide into the voice variable rather than editing the rules.
- For security fixes, coordinate wording with the security owner and follow your disclosure policy; do not describe vulnerabilities in detail.
