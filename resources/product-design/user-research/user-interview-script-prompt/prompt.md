# User Interview Script

## Intended task

Generate a complete, non-leading interview script for a 30-60 minute qualitative user interview. The script focuses on specific past behavior rather than opinions or predictions, which are notoriously unreliable ("would you use...?" answers are almost always polite yeses). It includes screener criteria, an introduction with consent reminder, warm-up, story-based core questions with probes, an optional concept section, and a wrap-up, plus a bias check of the script itself. Use it for problem discovery, switch interviews, and pre-design research; it is not a usability test plan.

## Required context

- **Research goal and questions** — what decision the research informs and the two to four questions it must answer.
- **Participant profile** — who you will talk to, including the behavior that qualifies them (for example "exported data to a spreadsheet in the last 30 days").
- **Session length and format** — remote or in person, minutes available.
- **Concept to show (optional)** — only if you intend to show a prototype or idea at the end; the script keeps it separate so it does not contaminate the behavioral part.
- **Interview type** — problem discovery, switch (why they changed products), or workflow deep-dive.

## Prompt

```text
You are a senior UX researcher writing an interview script for a product team. Your scripts are known for producing evidence, not opinions: they ask about specific past events, use neutral wording, and leave room for the participant to talk.

Research goal: {{RESEARCH_GOAL}}
Research questions to answer:
{{RESEARCH_QUESTIONS}}
Participants: {{PARTICIPANT_PROFILE}}
Interview type: {{INTERVIEW_TYPE}}
Session length: {{SESSION_LENGTH}} minutes, {{SESSION_FORMAT}}
Concept to show at the end (optional, may be "none"): {{CONCEPT}}

Write the script with these rules:
1. Anchor core questions in a specific recent instance: "Tell me about the last time you..." then walk through it step by step. Never ask participants to predict future behavior, rate hypothetical features, or say whether they would pay.
2. Use open, neutral questions. No leading wording ("how frustrating was..."), no double-barrelled questions, no yes/no questions in the core section, no mention of our solution before the concept section.
3. For each core question add two to four probes, such as "What happened just before that?", "What did you try next?", "How did you decide?", "Can you show me?", "What did that cost you in time or money?".
4. For switch interviews, cover first thought, passive and active looking, deciding, and first use, and probe for push, pull, anxiety, and habit.
5. Allocate minutes per section so the total fits the session length, leaving at least 10% buffer.
6. Include a short introduction with a consent and recording reminder, a statement that there are no right answers, and that we are not testing them.
7. If a concept is shown, place it last, ask for reactions in their own words first, and ask how it compares with what they do today, never "do you like it".
8. After the script, add a bias check: list any question that could still be leading and how you neutralized it.

Output format:
- Screener: 4-6 qualifying criteria and 2-3 disqualifiers, with screener questions that do not reveal the qualifying answer.
- Script by section, with timings, interviewer notes in brackets, and probes indented under each question.
- Note-taking template: columns for timestamp, observation, quote, behavior or opinion, and follow-up.
- Bias check.
```

## Variables

| Variable | Description | Required |
|---|---|---|
| `{{RESEARCH_GOAL}}` | The decision or learning goal the research supports | Yes |
| `{{RESEARCH_QUESTIONS}}` | Two to four specific questions the interviews must answer | Yes |
| `{{PARTICIPANT_PROFILE}}` | Who to recruit, including the qualifying recent behavior | Yes |
| `{{INTERVIEW_TYPE}}` | Problem discovery, switch interview, or workflow deep-dive | Yes |
| `{{SESSION_LENGTH}}` | Total minutes available, for example 45 | Yes |
| `{{SESSION_FORMAT}}` | Remote video, phone, or in person | Yes |
| `{{CONCEPT}}` | Optional prototype or idea to show at the end, or "none" | No |

## Output format

A Markdown document with four parts: screener, timed script (introduction, warm-up, core story questions with probes, optional concept reaction, wrap-up), a note-taking table template, and a bias check listing potentially leading questions with the neutralized version. The core section should contain roughly five to eight main questions; more usually means the interview will feel rushed and the participant's story gets cut short.

## Example usage

Filled variables: goal "understand how finance teams prepare month-end cash reports, to decide whether to build an automated report"; questions "what steps and tools are involved", "where does time go", "who consumes the report and how"; participants "finance managers at companies with 50-500 employees who prepared a cash report in the last 30 days"; type "workflow deep-dive"; 45 minutes; remote video; concept "none".

A good response opens the core section with "Tell me about the last time you prepared the month-end cash report — when was that?" followed by a step-by-step walkthrough with probes such as "Where did that number come from?" and "What did you do when it didn't match?", allocates about 25 minutes to that story, and its bias check flags and rewrites a draft question like "Would an automated report save you time?" into "What did you do the last time the report took longer than expected?".

## Customization

- Swap the interview type rules: for switch interviews keep rule 4 and the forces probes; for workflow deep-dives emphasize artifacts ("can you show me the spreadsheet?").
- Adjust the probe list to your domain's vocabulary, but keep probes open-ended.
- For B2B, add a section on how decisions are made and who else is involved.
- Add your organization's consent wording in the introduction; do not remove the consent reminder.
- If you must run a concept test, consider a separate usability session instead, so behavioral evidence stays clean.
