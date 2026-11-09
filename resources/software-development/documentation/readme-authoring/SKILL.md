---
name: readme-authoring
description: Writes or rewrites a project README with a clear one-paragraph pitch, a quickstart that has been verified to work from a clean environment, usage examples, configuration reference, honest badges, troubleshooting for real failure modes, and contribution and license sections. Use when creating a README for a new repository, fixing one that misleads newcomers, or preparing a project for open-source release.
---

# README Authoring

The README is the first and often only document people read. Its job is to answer, in order: what is this, should I care, how do I get it running in five minutes, and where do I go next. The most common failure is a quickstart that does not work. This skill writes READMEs from verified commands, not from memory.

## When to use

- A new repository needs a README.
- An existing README is stale, wrong, or a wall of text.
- A project is being open-sourced or handed to another team.

Not for: architecture documentation or design rationale (`architecture-decision-records`, `technical-design-doc-prompt`), API reference generation (`openapi-spec-authoring`), or onboarding plans for new team members (`new-codebase-onboarding-routine`).

## Inputs

- The repository: manifests, build files, CI workflow, existing docs, entry points, example configs.
- Audience: library users, CLI users, self-hosters, contributors, or internal team members. The answer changes the emphasis.
- Supported platforms and runtime versions.
- License and contribution policy (if absent, flag it — do not pick a license for the owner).

## Procedure

1. **Extract facts from the repo, not assumptions.** Read the package manifest for name, version, runtime requirement, and scripts; the CI workflow for the real install/build/test commands and versions; `.env.example` or config schema for settings; the CLI definition or public exports for usage. Note every discrepancy with the current README.

2. **Write the top section for a 30-second reader.** Project name, a one-sentence description of what it does and for whom, and a short paragraph on why it exists or how it differs from alternatives. Optionally a screenshot or terminal recording for UI/CLI tools. No marketing adjectives; concrete capabilities instead.

3. **Write a quickstart that works from zero.** Prerequisites with exact versions (`Node.js 20+`, `Python 3.11+`, `Docker 24+`). Then the minimum copy-pasteable sequence to see something working: install, configure, run, and the expected output. Each code block should be runnable as-is; put placeholders in a clearly named form (`YOUR_API_BASE_URL`) and say where to obtain them. Prefer one path; move alternatives (Docker, from source, Homebrew) to an Installation section.

4. **Verify the quickstart.** Run it in a clean environment — a fresh clone in a new directory, a container (`docker run --rm -it -v "$PWD":/src -w /src node:20 bash`), or a CI job. Record any step that failed and fix the README or the project. If you cannot execute commands, mark the quickstart "unverified" and list exactly what needs checking.

5. **Add usage beyond hello-world.** Two to four task-oriented examples ("Export a report as CSV", "Run behind a proxy"), each with input and expected output. For libraries, show the most common API calls with imports.

6. **Document configuration as a table.** Name, type, default, required, description — environment variables, config file keys, and CLI flags. Mark secrets and say how to provide them safely.

7. **Add troubleshooting from real failures.** Use issues, support threads, CI failures, and your own verification run. Each entry: the exact error text a user would see, the cause, and the fix. Three good entries beat ten guesses.

8. **Add the supporting sections.** Development (how to run tests and lint), Contributing (link to CONTRIBUTING.md and code of conduct if present), Roadmap or status (if maturity matters: alpha/beta/stable), License (name and link to LICENSE file), and support/security contact (link SECURITY.md for vulnerability reports).

9. **Use badges sparingly and honestly.** CI status, latest version, license, and perhaps coverage — each must link to a live source (shields.io or the CI provider). Remove badges for services the project no longer uses.

10. **Final pass.** Headings form a scannable outline; a table of contents only if the README is long; relative links resolve; commands use the correct package name; nothing promises features that do not exist.

## Expected output

```markdown
# project-name
One-sentence description.
<badges>
<why / how it differs — short paragraph>
## Quickstart
### Prerequisites
### Install and run
## Usage
## Configuration
| Variable | Type | Default | Required | Description |
## Troubleshooting
## Development
## Contributing
## License
```

Plus a short note to the requester: verified/unverified status of the quickstart, discrepancies found between the old README and the code, and open questions (license, support policy).

## Constraints and limitations

- Never claim a quickstart works unless it was executed; say what was run and where.
- Do not invent benchmarks, adoption numbers, or compatibility claims.
- Do not choose a license or add a code of conduct on the owner's behalf; recommend and ask.
- Keep long reference material (full API docs, architecture) in separate docs linked from the README.

## Examples

**Situation:** a Python CLI whose README says `pip install tool && tool run`, but `pyproject.toml` defines the console script as `toolctl` and requires Python 3.11.
**Result:** quickstart rewritten as `pipx install toolname` then `toolctl init` and `toolctl run --dry-run`, with the expected output shown; prerequisites list Python 3.11+; a troubleshooting entry for `command not found: toolctl` explaining `pipx ensurepath`; the requester is told the old command name was wrong and that the quickstart was verified in a `python:3.11-slim` container.
