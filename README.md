<p align="center">
  <img src="docs/assets/icon.png" width="128" height="128" alt="Skilldeck icon">
</p>

<h1 align="center">Skilldeck</h1>

<p align="center">
  <strong>An open, local-first library of AI agents, skills, prompts, and routines, with a native macOS app to browse, install, and export them.</strong>
</p>

<p align="center">
  <a href="https://github.com/seyhunak/skilldeck/actions/workflows/validate-submission.yml"><img alt="Validate submission" src="https://github.com/seyhunak/skilldeck/actions/workflows/validate-submission.yml/badge.svg"></a>
  <a href="https://github.com/seyhunak/skilldeck/actions/workflows/build-catalog.yml"><img alt="Build catalog" src="https://github.com/seyhunak/skilldeck/actions/workflows/build-catalog.yml/badge.svg"></a>
  <a href="https://github.com/seyhunak/skilldeck/actions/workflows/macos-app.yml"><img alt="macOS app" src="https://github.com/seyhunak/skilldeck/actions/workflows/macos-app.yml/badge.svg"></a>
  <a href="https://github.com/seyhunak/skilldeck/releases"><img alt="Catalog release" src="https://img.shields.io/github/v/release/seyhunak/skilldeck?filter=catalog-v*&label=catalog"></a>
  <br>
  <img alt="Resources" src="https://img.shields.io/badge/resources-250-6E56CF">
  <img alt="Platform" src="https://img.shields.io/badge/macOS-15%2B-000000?logo=apple">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-6-F05138?logo=swift&logoColor=white">
  <img alt="Python" src="https://img.shields.io/badge/tooling-Python%203.12-3776AB?logo=python&logoColor=white">
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-green"></a>
  <a href="docs/CONTRIBUTOR_GUIDE.md"><img alt="PRs welcome" src="https://img.shields.io/badge/PRs-welcome-brightgreen"></a>
  <a href="https://claude.com/claude-code"><img alt="Proudly powered by Claude" src="https://img.shields.io/badge/proudly%20powered%20by-Claude-D97757?logo=anthropic&logoColor=white"></a>
</p>

<p align="center">
  <img src="docs/assets/screenshot-discover.png" alt="Skilldeck Discover screen" width="900">
</p>

---

Skilldeck is two things that live in one repository:

1. **A community content platform.** Agents, skills, prompts, and routines are plain Markdown + YAML packages under `resources/`. Every pull request is validated (schema, structure, safety, duplicate detection, compatibility claims) and every merge to `main` builds a versioned, checksummed catalog that is published as a GitHub Release.
2. **A native macOS app.** Skilldeck ships with the whole catalog bundled, so it works fully offline from first launch. It lets you discover, search, and read resources, then install them into **Claude Code**, **OpenAI Codex**, **Claude Desktop**, the **Agent Skills** format, or any folder you choose, with a preview of every file it will write.

## What's in the catalog

| Type | Count | What it is | Installs as |
|---|---:|---|---|
| **Agents** | 100 | Complete task-oriented specialists with a system prompt, procedure, output format, and quality bar | Claude Code subagents (`~/.claude/agents/`) |
| **Skills** | 100 | Reusable capabilities in the open [Agent Skills](https://agentskills.io) `SKILL.md` format | Claude Code / Codex skills, Claude Desktop skill zips |
| **Prompts** | 30 | Copy-ready prompts with documented `{{PLACEHOLDERS}}` | Claude Code commands, Codex custom prompts |
| **Routines** | 20 | Repeatable human-guided workflows with steps and checklists | Claude Code commands |

That's 250 resources across 10 domains: software development, AI & machine learning, product & design, data & analytics, marketing & growth, research & intelligence, finance & banking, security & compliance, operations & productivity, and strategy & leadership. They're grouped into 12 curated collections such as *RAG Development Toolkit* and *Complete Software Development Toolkit*.

<p align="center">
  <img src="docs/assets/screenshot-detail.png" alt="Resource detail page" width="440">
  <img src="docs/assets/screenshot-collection.png" alt="Collection page" width="440">
</p>

## App features

- **Discover**: featured resources, shelves by goal, most-referenced resources, and curated collections.
- **Search** across names, descriptions, tags, use cases, and content, with suggestions, filters (type, domain, use case, platform, compatibility level, author, installed state, featured), sorting, and grid/list views. Press <kbd>⌘K</kbd> to search.
- **Detail pages** rendered from the package Markdown: purpose, inputs, procedure, outputs, examples, limitations, safety notes, related resources, and a prompt panel that fills in placeholders before you copy.
- **Install** with a dry-run plan that shows every destination file. Existing files are never overwritten silently: you choose cancel, or back up and replace. You can install for your user, a project folder, or a custom directory, and every file is hash-checked after writing.
- **Installed** view that detects local edits, updates resources when the catalog has a newer version, and uninstalls to the Trash. Files you've modified are kept.
- **Export** a single package as a folder or zip, a Claude Desktop skill zip, an `AGENTS.md` section for Codex, or the complete catalog.
- **Favorites, recents, and personal collections**, stored locally in JSON.
- **Contributors**: profile pages with GitHub avatar, bio, and featured work, cached for 24h and resilient to rate limits.
- **Catalog updates**: checks for new community resources at launch and periodically (every 6 hours by default) against the rolling `catalog-latest` release, installs them automatically (optional), highlights them under *New in the Catalog*, verifies SHA-256 for the bundle and every package, shows a diff of added, updated, and removed resources before applying, and lets you roll back to the previous version or the bundled catalog in one click.
- **Deep links** such as `skilldeck://resource/threat-modeling-agent`, `skilldeck://collection/rag-development-toolkit`, and `skilldeck://search/postmortem`.

## Install the app

**From source** (macOS 15+, Xcode 16+):

```bash
brew install xcodegen
```

```bash
git clone https://github.com/seyhunak/skilldeck.git && cd skilldeck/app && xcodegen generate
```

```bash
xcodebuild -project Skilldeck.xcodeproj -scheme Skilldeck -configuration Release -derivedDataPath build/DerivedData build
```

```bash
open build/DerivedData/Build/Products/Release/Skilldeck.app
```

**Prebuilt:** every run of the [macOS app workflow](https://github.com/seyhunak/skilldeck/actions/workflows/macos-app.yml) uploads a `Skilldeck-app` zip. Builds are ad-hoc signed and not notarized, so on first launch right-click the app and choose **Open**.

**Without the app:** every resource is plain files. Copy a skill folder into `~/.claude/skills/`, or download `packages/<id>.zip` from the [latest catalog release](https://github.com/seyhunak/skilldeck/releases).

## Contribute a resource

```bash
python3 -m pip install -r requirements.txt
```

```bash
cp -R templates/skill resources/<domain>/<use-case>/<your-skill-id>
```

```bash
python3 scripts/validate_catalog.py --only <your-skill-id>
```

Then open a pull request. CI runs the same validator, and a maintainer reviews it for usefulness, accuracy, and safety. **Once it's merged, a release candidate is built automatically. When the repository owner or an authorized maintainer approves it**, it's published, and every Skilldeck app picks it up at launch or on its next periodic check, listing it under *New in the Catalog*.

👉 **Start with the [Submission guide](docs/SUBMISSION_GUIDE.md)**, which works entirely in the browser if you like. Then see the [Contributor guide](docs/CONTRIBUTOR_GUIDE.md) and the [package format](docs/FORMAT.md).

## Repository layout

```text
resources/<domain>/<use-case>/<id>/   250 packages: manifest.yaml + agent.md | SKILL.md | prompt.md | routine.md
catalog/                              domains, collections, compatibility registry, launch requirements
contributors/<login>/profile.yaml     contributor profiles
schemas/                              JSON Schemas for manifests, profiles, collections
templates/                            starting points for each resource type
scripts/                              validate, build, launch gate, quality report (Python, no network)
tests/                                tooling tests (unittest)
app/                                  macOS app: SkilldeckCore Swift package + SwiftUI app (XcodeGen)
.github/workflows/                    PR validation, catalog build, catalog release, macOS app CI
docs/                                 architecture, format, compatibility, security, release process
```

## Documentation

- [Architecture](docs/ARCHITECTURE.md): how the catalog pipeline and the app fit together
- [Package format](docs/FORMAT.md): manifest v1.1 and the entrypoint format for each type
- [Compatibility](docs/COMPATIBILITY.md): where each type installs, per platform
- [Submission guide](docs/SUBMISSION_GUIDE.md) · [Contributor guide](docs/CONTRIBUTOR_GUIDE.md) · [Review policy](docs/REVIEW_POLICY.md)
- [Security model](docs/SECURITY.md) · [Release process](docs/RELEASE_PROCESS.md) · [Development & testing](docs/DEVELOPMENT.md)
- [Quality report](reports/quality-report.md): heuristic scores for every resource

## Security

Catalog content is treated as untrusted data. The app never executes anything from a package. Packages that declare scripts are refused, and install paths are validated against traversal and symlinks. Every file is checked against the catalog's SHA-256 before and after writing, and any resource whose hash doesn't match is quarantined. Please report vulnerabilities privately through [GitHub Security Advisories](https://github.com/seyhunak/skilldeck/security/advisories/new). See [SECURITY.md](docs/SECURITY.md).

## Proudly powered by Claude

Skilldeck was designed and built with [Claude](https://claude.com) using [Claude Code](https://claude.com/claude-code): the macOS app, the validation and release tooling, and the launch catalog of 250 resources. Every resource was written for real day-to-day use, then held to the same validator and review bar as community submissions.

## License

[MIT](LICENSE) © Seyhun Akyürek and contributors. Each resource declares its own license in `manifest.yaml`. All launch resources are MIT.
