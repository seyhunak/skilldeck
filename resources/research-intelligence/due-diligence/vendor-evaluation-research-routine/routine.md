# Vendor Evaluation Research Routine

## Objective

Take a shortlist of vendors for a defined need to a documented, defensible recommendation that a budget owner can approve or challenge. The routine fixes requirements and weights before vendor contact, gathers evidence the same way for every vendor, verifies claims through demos, documentation, and references, screens for company and security risk, and ends with a scored comparison and a decision memo. It is a research and evaluation workflow; contracting and purchasing stay with procurement and the budget owner.

## Trigger

Run when a team needs to choose among roughly two to six vendors for a software product, service, or supplier relationship of material cost or risk, or when a major renewal is up and alternatives should be compared. This routine is guidance for a human-supervised process, not an automated job.

## Prerequisites

- A named budget owner (decision-maker) and an evaluation lead.
- A clear problem statement and the business outcomes the purchase must deliver.
- Involvement agreed with security, legal, and procurement for the risk-screening and contracting stages.
- The organization's procurement policy, including thresholds that require formal tender processes.
- Access to the `company-profile-research` and `expert-interview-guide` skills, and optionally `competitive-feature-matrix`.

## Inputs

- Shortlist of vendors and how each was found.
- Requirements gathered from stakeholders, separated into must-have and differentiating.
- Budget range and timeline.
- Integration landscape and data the vendor would handle (sets security depth).
- Existing contracts or incumbents being replaced.

## Steps

1. **Fix criteria and weights first.** With stakeholders, write the evaluation criteria (functional fit, integration, security and compliance, vendor viability, total cost of ownership, support and service, implementation effort, user experience) and assign weights summing to 100. Define what scores 1, 3, and 5 mean for each. Freeze them before demos to avoid fitting the criteria to a favourite.
2. **Screen must-haves.** Check each vendor against must-have requirements using public documentation. Any vendor failing a true must-have leaves the shortlist with the reason recorded.
3. **Profile each vendor.** Use `company-profile-research` to confirm the contracting legal entity, ownership, financial signals, and recent developments. Note viability risks such as recent layoffs, funding gaps, or acquisition rumours with their sources.
4. **Gather evidence consistently.** Request the same materials from every vendor: documentation, security pack (for example SOC 2 Type II report or ISO/IEC 27001 certificate where relevant), data-processing terms, service levels, pricing proposal for the same scope, and implementation plan. Track what each vendor provided and when.
5. **Run scripted demos.** Give every vendor the same scenario script built from your real use cases, and score live against the frozen criteria. Ask to see working functionality rather than slides; record anything shown as roadmap separately.
6. **Check references.** Build a short guide with `expert-interview-guide` and speak to at least two references per finalist, including at least one you found independently where possible. Ask about implementation reality, support responsiveness, and what they would do differently.
7. **Screen risk.** Hand security documentation to the security team (or `vendor-security-assessment-agent` under their supervision), and contract and data-processing terms to legal. For material relationships, request a public-records diligence pass with `due-diligence-research-agent`.
8. **Model total cost.** Compare three-year total cost: licences or fees, implementation, integration, internal staff time, training, and exit costs. Note pricing assumptions and renewal uplift terms.
9. **Score and test sensitivity.** Score each vendor per criterion with evidence references. Compute weighted totals and check whether the ranking changes under reasonable alternative weights; if it does, say so.
10. **Write the decision memo.** Use `executive-research-memo-prompt` or `decision-memo-writing` to present the recommendation, runner-up, key risks with mitigations, and conditions to negotiate.

## Decision points

- If no vendor passes all must-haves, return to stakeholders to confirm whether a requirement is truly mandatory, or recommend building, deferring, or widening the search.
- If the top two vendors are within a few weighted points and the sensitivity test flips the ranking, run a paid pilot or proof of concept rather than forcing a decision.
- If security or legal raises a blocking issue, pause that vendor until it is resolved in writing.
- If the purchase crosses a procurement threshold that requires a formal tender, stop and hand over to procurement's process.
- If a vendor's claims cannot be verified through demos, documents, or references, score them as unverified rather than accepting them.

## Expected output

```markdown
# Vendor Evaluation: <need> - recommendation for <budget owner>

## Recommendation
Vendor, rationale in three sentences, conditions to negotiate.

## Criteria and weights (frozen on <date>)
## Scorecard
| Criterion (weight) | Vendor A | Vendor B | Vendor C | Evidence refs |
## Three-year total cost of ownership
## Risk summary (company, security, legal, implementation)
## Sensitivity analysis
## Reference-check highlights
## Open items before contract
```

## Validation checklist

- [ ] Criteria and weights were frozen before demos and are recorded with the date.
- [ ] Every vendor received the same requirements, demo script, and evidence requests.
- [ ] Each score cites evidence; roadmap items are separated from shipped capability.
- [ ] Security and legal reviews are complete or explicitly listed as open.
- [ ] The contracting legal entity is confirmed for the recommended vendor.
- [ ] Total cost covers at least three years and includes internal and exit costs.
- [ ] Conflicts of interest among evaluators were declared.

## Human approval

The budget owner approves the recommendation. Security and legal sign-off are required before contract signature, and procurement owns negotiation and purchasing. No one using this routine, human or agent, contacts vendors or references, shares internal data with vendors, accepts terms, or commits spend without explicit approval from the evaluation lead and budget owner.
