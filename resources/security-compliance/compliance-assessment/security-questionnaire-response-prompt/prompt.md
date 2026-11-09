# Security Questionnaire Response

## Intended task

Draft answers to a customer or prospect security questionnaire (SIG, CSA CAIQ, or a custom spreadsheet) using only your organisation's own evidence: policies, SOC 2 or ISO 27001 materials, an approved answer library, and architecture notes. Each answer is marked Supported, Partial, or Needs owner, and cites the evidence it relies on. The prompt is designed to stop overstatement, because questionnaire answers often become contractual representations.

## Required context

- **Questions** to answer, with their IDs, ideally pasted as rows.
- **Evidence pack**: approved previous answers, policy excerpts, the scope statement of your SOC 2 report or ISO certificate, product security documentation, and subprocessor list. Do not paste the full confidential audit report unless the tool is approved for it.
- **Product and scope**: which product, deployment model, and regions the questionnaire concerns.
- **Disclosure rules**: what may be shared before an NDA (for example, the SOC 2 report only under NDA).

## Prompt

```text
You are a security and trust analyst drafting answers to a security questionnaire on behalf of {{COMPANY_NAME}} for the product {{PRODUCT_SCOPE}}. Your answers must be accurate, consistent, and supported by the evidence provided. Never invent controls, certifications, dates, tools, percentages, or commitments. Understating is acceptable; overstating is not.

Questionnaire rows:
{{QUESTIONS}}

Evidence pack (the only permitted sources):
{{EVIDENCE}}

Disclosure rules:
{{DISCLOSURE_RULES}}

Tone and length: {{ANSWER_STYLE}}

For each question:
1. Decide the answer: Yes, No, Partial, or Not applicable. Use Not applicable only when the evidence shows the scope excludes it, and say why.
2. Write a concise answer in the requested style that states what is done, by whom or by what system, and how often, using only facts in the evidence.
3. Cite the evidence by document name and section for every factual claim.
4. Assign a status: Supported (fully backed by evidence), Partial (some backing; state what is missing), or Needs owner (no evidence; do not guess, name the likely owning team).
5. If a question asks for something the disclosure rules restrict, answer at the permitted level and add "Available under NDA" where appropriate.
6. Keep answers consistent: if two questions overlap, use consistent facts and cross-reference.
7. Flag any question whose honest answer is No or Partial for a high-impact area (encryption, MFA, incident notification, data deletion, subprocessors) in a separate review list.
Do not reproduce personal data, credentials, or internal hostnames.
```

## Variables

| Variable | Description | Required |
|---|---|---|
| `{{COMPANY_NAME}}` | Your organisation's name | Yes |
| `{{PRODUCT_SCOPE}}` | Product, deployment model, and regions in scope | Yes |
| `{{QUESTIONS}}` | Questionnaire rows with IDs and question text | Yes |
| `{{EVIDENCE}}` | Approved answer library, policy excerpts, report scope statements, documentation | Yes |
| `{{DISCLOSURE_RULES}}` | What may be shared and what requires an NDA | Yes |
| `{{ANSWER_STYLE}}` | For example "one to three sentences, formal, no marketing language" | No |

## Output format

A table with columns: Question ID, Question (shortened), Answer (Yes/No/Partial/N/A), Response text, Evidence cited, Status, Owner if Needs owner. Then two lists: **Review required** (high-impact No or Partial answers) and **Evidence gaps** (questions with no supporting source), followed by a reminder that every answer needs owner review and approval before submission.

## Example usage

Question: "Do you encrypt customer data at rest? Describe key management." Evidence: Encryption Standard section 3 says production databases and object storage use the cloud provider's KMS with AES-256 and automatic annual key rotation; no evidence about backups.

Good output: Answer Partial; response "Customer data in production databases and object storage is encrypted at rest with AES-256 using keys managed in our cloud provider's key management service, with automatic annual rotation (Encryption Standard §3)."; status Partial; note "Backup encryption not evidenced; confirm with Platform team." It does not claim that backups are encrypted, and it does not mention customer-managed keys, because the evidence does not cover them.

## Customization

- Paste your approved answer library first in the evidence so prior wording is reused.
- Change the answer vocabulary to match the questionnaire's dropdowns (for example SIG's Yes/No/N/A).
- Add a rule for your standard NDA language or trust portal link.
- Keep the no-invention rule and the Needs owner status; they are the point of the prompt.
- This is not legal advice: answers can become contractual representations and must be approved by the control owner and security or legal before submission.
