# Resource package format (manifest schema 1.1)

Each package lives at `resources/<domain>/<use-case>/<id>/`. It contains one `manifest.yaml`, one entrypoint file, and optionally `references/` and `examples/`. The authoritative definition is [`schemas/resource.schema.json`](../schemas/resource.schema.json). Schema `1.0` manifests are still accepted.

Allowed file types are `.md .markdown .txt .yaml .yml .json .csv`. Packages can't contain executables, symlinks, binaries, or scripts.

## Manifest

```yaml
schema_version: "1.1"
id: git-history-forensics            # kebab-case, globally unique, == directory name
name: Git History Forensics
type: skill                          # agent | skill | prompt | routine
description: 30-300 chars; what it does and when to use it.
purpose: >                           # why it exists (optional but recommended)
  ...
version: 1.0.0                       # semver; bump on every content change
author: {name: Your Name, github: your-login}
license: MIT                         # SPDX
domain: software-development         # from catalog/domains.yaml
use_cases: [code-analysis]           # first entry should match the parent directory
tags: [git, churn]
created: "2026-11-09"
updated: "2026-11-09"
content:
  entrypoint: SKILL.md
  files: [references/commands.md]    # every other file, listed explicitly
compatibility:                       # capped by catalog/compatibility.yaml
  - {platform: claude-code, level: native_install, resource_types: [skill]}
requirements: []                     # tools or access the user needs
dependencies: []                     # resource ids this one needs
related: []                          # resource ids worth seeing alongside
featured: false                      # maintainers only
safety:
  contains_scripts: false            # must be false
  network_access: false
  handles_sensitive_data: false
  notes: Boundaries the user should know about.
status: submitted                    # maintainers set approved on merge
tested: false
tested_with: []
changelog: ["1.0.0: Initial submission."]
```

Compatibility levels, from weakest to strongest: `not_supported`, `unverified`, `copy_paste`, `generic_export`, `file_export`, `native_import`, `native_install`. See [COMPATIBILITY.md](COMPATIBILITY.md).

## Entrypoints

Every entrypoint starts with one `# Title` H1. Sections are H2 headings, and those in **bold** below are required, in any order. Headings inside fenced code don't count. Minimum lengths exclude code.

### Agent: `agent.md` (≥ 650 words)

YAML frontmatter with `name` (== id) and `description`, so the file can be dropped straight into `~/.claude/agents/` as a Claude Code subagent. The body opens with the system prompt ("You are …"), followed by:
**Purpose**, **When to use**, **Required inputs**, **Operating procedure**, **Expected output**, **Supporting skills**, **Example prompts**, **Error handling**, **Limitations**, **Safety boundaries**.

### Skill: `SKILL.md` (≥ 400 words)

[Agent Skills](https://agentskills.io) format: frontmatter `name` (== id) and `description` (what it does plus when to activate). Required sections: **When to use**, **Inputs**, **Procedure**, **Expected output**, **Constraints**.

### Prompt: `prompt.md` (≥ 300 words)

Required sections: **Intended task**, **Required context**, **Prompt** (the copy-ready prompt in the first fenced block), **Variables** (every `{{UPPER_SNAKE}}` placeholder used in the prompt has to be documented here), **Output format**, **Example usage**, **Customization**.

### Routine: `routine.md` (≥ 400 words)

Required sections: **Objective**, **Trigger**, **Prerequisites**, **Inputs**, **Steps** (numbered), **Decision points**, **Expected output**, **Validation checklist** (`- [ ]` items), **Human approval**.

## Regulated domains

Packages in `finance-banking` and `security-compliance` (or tagged accordingly) must say in `safety.notes` and in their limitations that they aren't professional financial, legal, or security advice, and must name who signs off.
