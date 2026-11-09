# Diátaxis Page Patterns

Diátaxis (diataxis.fr, by Daniele Procida) separates documentation by two axes: action versus cognition, and acquisition (study) versus application (work). The four resulting types each have a distinct job. The patterns below are practical skeletons for each.

## Quick classifier

| If the reader is... | And needs... | Write a... |
|---|---|---|
| New, learning by doing | A safe, guaranteed path to a first success | Tutorial |
| Competent, at work | Steps to reach a specific goal | How-to guide |
| At work, looking something up | Accurate, complete facts | Reference |
| Studying, stepping back | Understanding of why and how | Explanation |

## Tutorial skeleton

```markdown
# Build your first <thing>
In this tutorial you will <concrete outcome>. It takes about <n> minutes.
## Before you begin
## Step 1: <action>
<command or action>
You should see: <expected output>
## Step 2: ...
## What you built
## Next steps  (links to how-to guides)
```
Rules: no options or alternatives, every step yields visible output, minimal explanation (link out instead), tested from a clean start.

## How-to skeleton

```markdown
# <Verb> <thing>   (for example "Rotate an API key")
Use this guide when <situation>.
## Prerequisites
## Steps
1. ...
## Variations   (for example "If you use SSO")
## Troubleshooting
## Related reference
```
Rules: assumes competence, focused on one goal, may branch for real-world variations, no teaching.

## Reference skeleton

```markdown
# <Component> reference
## <item name>
**Type:** · **Default:** · **Required:** · **Since:** <version>
Description in one or two sentences.
Example:
```
Rules: same structure for every item, mirrors the structure of the product, austere, generated or checked against source.

## Explanation skeleton

```markdown
# About <topic>
## Context and problem
## How it works
## Design choices and trade-offs
## Alternatives considered
## Further reading   (decision records, specs)
```
Rules: may contain opinion and history, no step-by-step instructions, connects concepts.

## Common mixing failures

- Tutorial that pauses for a page of architecture: move the architecture to an explanation and link it.
- Reference entries containing "first, you should...": move the procedure to a how-to.
- How-to that starts with installation from zero: link to the tutorial or a dedicated install how-to.
- Explanation with commands to copy: the commands belong in a how-to.
