# Value Proposition

## Intended task
Turn customer research and product facts into value proposition statements by way of a value proposition canvas, the customer profile and value map popularized by Strategyzer's Value Proposition Design. The model first fills the customer side (jobs, pains, gains), then maps product capabilities to pain relievers and gain creators, scores the fit, and only then drafts statements in several formats, each traceable to the canvas. Use it when launching a product or feature, entering a new segment, or when existing value propositions read like feature lists.

## Required context
- Research notes about one specific customer segment: interviews, survey answers, support tickets, sales notes. Statements built without customer evidence are guesses, and the model will label them as such.
- A factual description of the product's capabilities, including what it does not do.
- The main alternatives customers use today, so the statements say why this is better than what they would otherwise do.
- Any positioning decisions already made (target customer, market category), so the value proposition stays consistent with them.

## Prompt
```text
You are a product marketer who builds value propositions from customer evidence, using the value proposition canvas (customer profile: jobs, pains, gains; value map: products and services, pain relievers, gain creators).

Customer segment: {{SEGMENT}}
Research evidence (quotes, notes, survey results): {{RESEARCH_EVIDENCE}}
Product capabilities (facts only): {{PRODUCT_CAPABILITIES}}
Current alternatives customers use: {{ALTERNATIVES}}
Positioning constraints (target, category, claims to avoid): {{POSITIONING_CONSTRAINTS}}

Work in this order and show each step:

1. Customer profile. List functional, emotional, and social jobs; pains (obstacles, risks, undesired outcomes); and gains (required, expected, desired, unexpected). For each item, cite the evidence it comes from in brackets, or mark it [ASSUMPTION]. Rank the top three pains and top three gains by how often and how intensely they appear in the evidence.
2. Value map. For each top pain and gain, name the specific capability that addresses it as a pain reliever or gain creator. If nothing in the product addresses it, write "not addressed" rather than stretching a feature.
3. Fit assessment. Score each pain and gain as strong fit, partial fit, or no fit, and explain briefly. Note where the alternative already serves the customer well.
4. Statements. Using only strong-fit items, write:
   a. Two one-sentence value propositions in the form "We help [segment] [achieve job] by [pain reliever/gain creator], unlike [alternative]."
   b. Two headline-style versions of ten words or fewer.
   c. One short paragraph (about 50 words) for a product page.
   Each statement must list the canvas items it relies on.
5. Risks. List the assumptions that, if wrong, would break the value proposition, and propose a quick test for each (customer interview question, landing page test, sales pitch trial).

Do not invent customer quotes, metrics, or outcomes. If the evidence is thin, say so plainly.
```

## Variables
| Variable | Description | Required |
|---|---|---|
| `{{SEGMENT}}` | The single customer segment the value proposition is for | Yes |
| `{{RESEARCH_EVIDENCE}}` | Interview notes, quotes, survey results, support or sales themes | Yes |
| `{{PRODUCT_CAPABILITIES}}` | Factual list of what the product does and does not do | Yes |
| `{{ALTERNATIVES}}` | What the segment uses today instead, including manual workarounds | Yes |
| `{{POSITIONING_CONSTRAINTS}}` | Agreed target, category, and claims to avoid | Optional |

## Output format
Markdown with five numbered sections: customer profile (with evidence citations and ranked top pains and gains), value map, fit assessment table, statements (each tagged with the canvas items it uses), and risks with proposed tests. The statements are hypotheses to validate, not final copy.

## Example usage
Segment: "operations managers at 20-100 person logistics firms". Evidence: twelve interview summaries mentioning hours spent reconciling carrier invoices, fear of overpaying, and frustration with spreadsheet errors. Capabilities: automatic invoice import from major carriers, rate-card matching, discrepancy alerts; no payment processing. Alternatives: spreadsheets and an outsourced audit firm paid a percentage of recoveries.

A good response ranks "hours lost reconciling invoices" and "undetected overcharges" as top pains with interview citations, maps them to import and rate-card matching, marks "paying carriers faster" as not addressed, and drafts: "We help logistics operations managers catch carrier overcharges automatically by matching every invoice to your rate cards, unlike spreadsheets or audit firms that take a cut." It lists the assumption that firms have rate cards in a usable format and proposes asking about it in the next five interviews.

## Customization
Run the prompt once per segment; mixing segments produces vague statements. Change the statement formats in step 4 to match your channel (sales email opener, app store subtitle, investor one-liner). If you already have a positioning canvas, paste it into the constraints so statements align with the chosen category. Keep the evidence-citation requirement in step 1; it is what separates this from feature brainstorming.
