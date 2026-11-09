---
name: atomic-note-writing
description: Writes Zettelkasten-style atomic notes - one idea per note, in your own words, with a claim-style title, source reference, and explicit links to related notes - and builds structure notes that tie clusters together. Use when processing reading, research, or meeting material into a personal or team knowledge base (Obsidian, Logseq, Notion, plain Markdown).
---

# Atomic Note Writing

The Zettelkasten method, popularised from Niklas Luhmann's slip-box and described for modern tools in Sönke Ahrens' "How to Take Smart Notes", rests on a few simple rules: one idea per note, written in your own words, connected deliberately to other notes. The value is in the links and in the act of reformulating, not in collecting quotes. This skill produces notes that stay useful years later, out of context.

## When to use

- Processing a book, paper, article, talk, or course into lasting notes.
- Turning fleeting notes or highlights into permanent notes.
- Splitting long, mixed-topic notes into atomic ones during a vault clean-up.
- Building a structure note (also called a map of content or hub) for a growing cluster.

Not appropriate for meeting minutes, project task lists, or reference material that must stay whole (a procedure, a contract summary). Those are project or reference notes, not atomic notes.

## Inputs

- Source material or highlights, with bibliographic details (author, title, year, page or timestamp, URL if any).
- The existing note collection or a list of note titles, so links point at real notes.
- The user's conventions: tool, file naming (for example timestamp IDs like 202611091430), tag style, link syntax (`[[wikilinks]]` or Markdown links).

## Procedure

1. **Separate note types.** Distinguish fleeting notes (raw captures, to be processed and discarded), literature notes (brief, in your own words, tied to one source with page references), and permanent notes (one idea, standalone, linked). Work toward permanent notes; keep literature notes short.
2. **Find the ideas.** From the material, list the distinct claims, concepts, or questions worth keeping. Ask of each: would this still be interesting in a different project? Discard what is only trivia or already captured.
3. **Write one idea per note.** If you need "and" to state the idea, it is probably two notes. A useful heuristic is a note that fits on one screen, often under about 300 words.
4. **Title as a claim or precise concept.** "Spaced retrieval beats re-reading for long-term retention" rather than "Memory". The title should let someone predict the content and link to it in a sentence.
5. **Write in your own words.** Explain the idea as if to a smart colleague without the source in front of them. Quote only when the exact wording matters, mark quotes clearly, and keep them short.
6. **Add provenance.** Cite the source with page or timestamp. Separate what the source claims from your own interpretation or critique.
7. **Link deliberately.** Connect the note to two or more existing notes, and say why in the sentence around each link: supports, contradicts, extends, is an example of, is a prerequisite for. Bare link lists without context decay quickly. Add a backlink from at least one older note if the tool does not show backlinks.
8. **Tag sparingly.** Use a small controlled set of tags for status or type (for example `#seed`, `#evergreen`, `#question`), not topics that links already express.
9. **Maintain structure notes.** When a cluster reaches roughly 7 to 10 linked notes, write a structure note that orders them into an argument or outline with one line per linked note. Structure notes are entry points, not folders.
10. **Validate.** Each note: single idea, claim-like title, standalone readable, source cited, at least two contextual links, no orphan.

## Expected output

```markdown
---
id: 202611091430
title: Spaced retrieval beats re-reading for long-term retention
tags: [evergreen]
source: "Author, Title (Year), p. 42"
---

# Spaced retrieval beats re-reading for long-term retention

<Idea in your own words, 3–8 sentences. What it claims, why it holds, where it applies.>

**From the source:** <what the source states, with page>
**My take:** <interpretation, limits, disagreement>

## Links
- Extends [[Desirable difficulties make learning feel slower but stick better]] — retrieval is one such difficulty.
- Contradicts [[Highlighting is an effective study strategy]] — evidence points the other way.
- Example in practice: [[Flashcard review schedule]]
```

## Constraints and limitations

- Do not fabricate source details, page numbers, or quotes; leave a visible gap if they are missing.
- Do not link to notes that do not exist unless the user wants new placeholder notes created; list proposed new notes instead.
- Respect copyright: summarise, keep quotations short.
- The method rewards regular review; notes written once and never linked again become a pile, not a network.

## Examples

Highlight: "Testing is not just assessment, it is a learning event. Retrieval strengthens memory more than additional study."

Poor note: title "Testing", body is the pasted quote, no links.

Atomic note: title "Retrieval practice strengthens memory more than restudying", body explains the idea in two sentences in the user's words, cites the source page, links to "Spaced repetition schedules" (applies this) and "Feeling of fluency misleads learners" (explains why people prefer restudying).
