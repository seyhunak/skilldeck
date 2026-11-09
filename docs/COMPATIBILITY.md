# Compatibility

[`catalog/compatibility.yaml`](../catalog/compatibility.yaml) is the single source of truth. The validator rejects any manifest that claims a higher level than the registry allows for that platform and type, and the app only offers the install methods the registry lists. Paths were checked against each platform's public documentation on **2026-11-09**. Platforms change, so please open an issue if a path has moved.

| Level | Meaning |
|---|---|
| `native_install` | Skilldeck writes files where the tool discovers them automatically |
| `native_import` | Skilldeck produces an artifact the tool imports (e.g. a zip uploaded in settings) |
| `file_export` | Skilldeck writes a file in the tool's format; you put it in place or merge it |
| `generic_export` | Plain package folder or zip |
| `copy_paste` | Copy the text into the tool |
| `unverified` / `not_supported` | No claim |

## Where each type goes

| | Agent | Skill | Prompt | Routine |
|---|---|---|---|---|
| **Claude Code** | `native_install` → `~/.claude/agents/<id>.md` (support files in `~/.claude/skilldeck/packages/<id>/`) | `native_install` → `~/.claude/skills/<id>/` | `native_install` → `~/.claude/commands/<id>.md` | `native_install` → `~/.claude/commands/<id>.md` |
| **OpenAI Codex** | `file_export` → section for `AGENTS.md` | `native_install` → `~/.codex/skills/<id>/` | `native_install` → `~/.codex/prompts/<id>.md` (user scope only) | `copy_paste` |
| **Claude Desktop / claude.ai** | `copy_paste` (project instructions) | `native_import` → skill zip for Settings › Capabilities | `copy_paste` | `copy_paste` |
| **Agent Skills tools** | n/a | `file_export` → any skills directory | n/a | n/a |
| **Generic** | `generic_export` | `generic_export` | `generic_export` | `generic_export` |

For Claude Code, project scope swaps `~/.claude/` for `<project>/.claude/`. Custom scope writes the package folder into any directory you choose.

## Notes and limitations

- Claude Code subagents are single Markdown files. Supporting files get copied next to them but aren't loaded automatically; the agent body references them by path.
- Prompts installed as commands keep their `{{PLACEHOLDERS}}` for you to fill in, and `$ARGUMENTS` is appended so you can pass free-form context.
- Routines are guidance for a human-supervised session. They are not scheduled jobs.
- Claude Desktop doesn't read a local skills folder, so export the zip and upload it.
