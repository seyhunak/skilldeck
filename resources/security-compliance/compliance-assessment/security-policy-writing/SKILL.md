---
name: security-policy-writing
description: Writes or revises information security policies, standards, and procedures with a clear document hierarchy, testable shall-statements with parameters, named owners, exception handling, review cadence, and mappings to SOC 2 criteria or ISO/IEC 27001:2022 controls. Use when drafting a new policy, fixing an audit finding about documentation, or rewriting template policies to match actual practice.
---

# Security Policy Writing

## When to use

Load this skill when an organisation needs security governance documents that staff can follow and auditors can test: a first policy set for SOC 2 or ISO 27001, a rewrite of downloaded templates that do not match reality, a new standard (for example, encryption or logging), or a procedure that operationalises an existing policy.

Do not use it to assess whether controls exist (use `compliance-gap-analysis-agent`), to write general operational SOPs unrelated to security (use `sop-writing`), or to draft legally binding employment terms without counsel.

## Inputs

- **Document type and topic** — policy, standard, or procedure, and the subject (access control, acceptable use, incident response, data classification, vendor management, change management, cryptography, logging, business continuity). Required.
- **Current practice** — how the organisation actually does this today, including tools and teams. Required: a policy that describes controls nobody operates creates audit findings and false assurance.
- **Framework targets** — SOC 2 Trust Services Criteria, ISO/IEC 27001:2022 Annex A controls, or customer contract requirements to map. Optional.
- **Organisation context** — size, roles that exist (is there a CISO, an IT team?), and existing documents to align with. Optional.

## Procedure

1. **Place the document in the hierarchy.**
   - **Policy** — management intent and principles; short (one to three pages); approved by leadership; changes rarely. Example: "Access to company systems is granted on least privilege and reviewed periodically."
   - **Standard** — mandatory, measurable requirements implementing the policy. Example: "Privileged access is reviewed quarterly; MFA is required for all remote access."
   - **Procedure** — step-by-step instructions for a specific role. Example: "How IT performs the quarterly access review."
   - **Guideline** — recommended, non-mandatory practice.
   Do not mix levels: parameters such as "90 days" belong in standards so the policy does not need re-approval every time a number changes.
2. **Use a consistent structure:** Purpose; Scope (systems, data, people, locations); Roles and responsibilities; Requirements (numbered); Exceptions; Enforcement; Related documents; Definitions; Document control (owner, approver, version, effective date, next review).
3. **Write testable requirements.** Use "shall" or "must" for mandatory, "should" for recommended, "may" for optional, and use them consistently. Each requirement names who, what, when, and how it can be evidenced. Rewrite vague text: "Passwords should be strong" becomes "User passwords shall be at least 12 characters, checked against a list of known-compromised passwords, and shall not expire on a schedule unless compromise is suspected" (consistent with NIST SP 800-63B guidance; confirm against the version the organisation follows).
4. **Match reality, then raise the bar deliberately.** Write what is true today. Where the organisation intends to improve, put the new requirement in with an effective date and a transition note, rather than claiming it already happens.
5. **Define exceptions.** Who can approve an exception, maximum duration, required compensating controls, and where exceptions are recorded. Auditors look for this.
6. **Assign ownership.** Every document has a single accountable owner (a role, not a person's name), an approver, and a review cadence (annually is typical; ISO 27001 requires policies to be reviewed at planned intervals and when significant changes occur).
7. **Map to frameworks.** Add a mapping table to the criteria or controls the document supports. Keep mapping out of the body text so the policy reads naturally.
8. **Review for usability.** Remove duplicated requirements across documents, define every acronym, keep policies short, and check that every procedure referenced exists.

## Expected output

A Markdown document using the structure in step 2, with numbered requirements (for example, `AC-3.1`), followed by:

| Requirement | Evidence an auditor could request | Framework mapping |
|---|---|---|

and a change summary when revising an existing document.

## Constraints and limitations

- Never describe controls the organisation does not operate as if they were in place.
- Do not copy copyrighted framework text; summarise requirements and cite the control identifier.
- Employment, monitoring, and disciplinary clauses vary by jurisdiction and need legal review.
- This is not legal or professional compliance advice; documents must be reviewed by the owner, approved by management, and checked by counsel where they create obligations.

## Examples

Request: "Rewrite our access control policy; the current one is a template that says we use a PAM tool we don't have."

Good response: a two-page policy stating principles (least privilege, unique accounts, MFA, periodic review, timely removal); a separate Access Control Standard with parameters (MFA for all SSO apps and all admin access; leaver access removed within one business day of HR notification; privileged access reviewed quarterly, all access semi-annually; shared accounts prohibited except documented break-glass accounts with vaulted credentials); the PAM requirement replaced with what actually exists (admin accounts separate from daily accounts, elevation requests via ticket) plus a dated roadmap item; an exceptions section; and a mapping table to SOC 2 CC6.1-CC6.3 and ISO 27001:2022 controls 5.15, 5.18, and 8.2.
