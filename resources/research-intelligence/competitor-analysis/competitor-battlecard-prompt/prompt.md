# Competitor Battlecard

## Intended task

Use this prompt to turn competitor research notes into a one-page battlecard a seller can use during a live deal. The card summarises how the competitor positions itself, where the user's product wins and loses, landmine questions that expose real differences, objection handling, and proof points. It is built only from the notes supplied, so its quality depends on the research behind it; run it after a competitor dossier or feature comparison, not instead of one.

## Required context

- Research notes on the competitor: product, pricing and packaging, positioning, recent moves, with sources and dates where available.
- Your own product's relevant strengths and gaps, stated honestly.
- Win/loss evidence: deals won and lost against this competitor and the reasons recorded.
- The sales segment the card is for (for example mid-market, enterprise, a vertical), since the competitive picture differs by segment.

## Prompt

```text
You are a product marketing manager who writes battlecards sellers trust because they are accurate and fair. Use only the material below. Do not invent facts, prices, customer names, or weaknesses. If something a battlecard normally contains is missing from the notes, write "Not in research" in that place.

Competitor: {{COMPETITOR_NAME}}
Segment this card is for: {{SALES_SEGMENT}}

Competitor research notes (with sources and dates):
{{RESEARCH_NOTES}}

Our product - relevant strengths and known gaps:
{{OUR_PRODUCT_NOTES}}

Win/loss evidence against this competitor:
{{WIN_LOSS_NOTES}}

Write a one-page battlecard with these sections:

1. Snapshot - who they are and how they describe themselves, in two sentences.
2. When we win - three to five situations, each tied to evidence in the notes.
3. When we lose - two to four honest situations where they are the better fit, and what the seller should do (qualify out, reframe, or bring in specialists).
4. Landmine questions - three to five neutral discovery questions the seller can ask the buyer that surface differences that matter to the buyer. No trick questions and no claims about the competitor phrased as questions.
5. Objection handling - for the three most likely objections, a short acknowledge-reframe-evidence response.
6. Proof points - only proof that appears in our notes (customer stories, metrics, certifications), with source.
7. Pricing and packaging notes - only as documented, with date.
8. Do not say - claims sellers must avoid because they are unverified, outdated, or disparaging.
9. Freshness - date of the oldest fact the card relies on and the facts to re-verify before the next update.

Rules: be fair to the competitor; no disparaging language; label inferences as inferences; keep the whole card under 450 words; cite the note or source after each factual claim in square brackets.
```

## Variables

| Variable | Description | Required |
|---|---|---|
| `{{COMPETITOR_NAME}}` | The competitor the card covers | Yes |
| `{{SALES_SEGMENT}}` | The segment or deal type the card targets | Yes |
| `{{RESEARCH_NOTES}}` | Competitor facts with sources and dates | Yes |
| `{{OUR_PRODUCT_NOTES}}` | Our relevant strengths, gaps, and proof | Yes |
| `{{WIN_LOSS_NOTES}}` | Recorded reasons for wins and losses versus this competitor | No |

## Output format

A Markdown battlecard of nine short sections under 450 words, with bracketed source references after factual claims and "Not in research" placeholders where the notes are silent. Bullets, not paragraphs, except the snapshot.

## Example usage

Competitor: a well-known project-management tool. Segment: 50-500 employee agencies. Notes include its published pricing tiers (dated), a documented limit on guest users on lower tiers, and a recent launch of built-in time tracking. Our notes include native resource-planning and two agency case studies. Win/loss notes show losses where buyers wanted one tool for the whole company, and wins where resource planning was a priority.

A good card says we win when agencies plan capacity across clients, lose when the buyer wants a company-wide work hub, suggests asking "How do you decide who is available for a new client project next month?", warns sellers not to claim the competitor "has no time tracking" because the notes show it launched recently, and lists the pricing page date as the item to re-verify.

## Customization

- Change the word limit for printed cards versus CRM-embedded cards.
- Add a "Technical differences" section for sales engineers, sourced the same way.
- For regulated industries, add a line that legal or compliance must approve comparative claims.
- Keep the "Do not say" and fairness rules; removing them is the fastest way to get unusable or risky cards.
