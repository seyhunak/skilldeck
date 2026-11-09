# Architecture

Skilldeck is a monorepo with two halves that meet at one artifact: the **catalog bundle**.

```text
 contributors ──PR──▶ resources/ ──validate──▶ main ──build──▶ catalog-bundle.json ──release──▶ GitHub Releases
                                                                       │                              │
                                                                       ▼                              ▼
                                                     app/Skilldeck/Resources (bundled)   catalog-latest/latest.json
                                                                       │                              │
                                                                       └──────────▶ Skilldeck.app ◀───┘
```

## Content platform (repository root)

| Path | Role |
|---|---|
| `resources/<domain>/<use-case>/<id>/` | One package per resource: `manifest.yaml` + entrypoint (`agent.md`, `SKILL.md`, `prompt.md`, `routine.md`) + optional `references/`, `examples/` |
| `catalog/catalog.yaml` | Catalog identity, `catalog_version`, `minimum_app_version` |
| `catalog/domains.yaml` | The 10 domains and their use cases |
| `catalog/collections.yaml` | Curated collections (ordered steps, symbol, accent colour) |
| `catalog/compatibility.yaml` | **Compatibility registry**: the single source of truth for where each type installs per platform. Manifests can't claim more than it allows. |
| `catalog/launch_requirements.yaml` | Launch gate: exact type distribution and required collections |
| `contributors/<login>/profile.yaml` | Contributor profiles |
| `schemas/*.schema.json` | JSON Schemas (draft 2020-12) for manifests, profiles, collections |

### Tooling (`scripts/`, Python 3.12, PyYAML + jsonschema, no network)

- **`validate_catalog.py`**: schema, layout (directory == domain/use-case/id), allowed file types, size limits, symlinks, executable bits, secret patterns, unsafe HTML, external links, leftover placeholders, required sections and minimum length per type, prompt variables documented, routine steps and checklist, compatibility claims vs registry, disclaimers for regulated domains, dependency/related integrity and cycles, near-duplicate detection (word-shingle Jaccard), contributor and collection integrity. It never executes contributor content.
- **`build_catalog.py`**: deterministic build (`SOURCE_DATE_EPOCH`, fixed zip timestamps, sorted keys) of `catalog.json` (index), `catalog-bundle.json` (index + all file contents), `latest.json` (update pointer with bundle SHA-256), `packages/<id>.zip`, and `CHANGES.md` (diff against `--previous`).
- **`check_launch_catalog.py`**: enforces `launch_requirements.yaml`.
- **`quality_report.py`**: heuristic scoring report (`reports/quality-report.md`).

**Integrity.** Each file carries a SHA-256. Each resource carries `content_sha256 = sha256("".join(f"{path}\0{sha256}\n" for files sorted by path))`. `latest.json` carries the SHA-256 and size of the bundle. The Swift `Hashing.packageHash` reimplements the same formula, and a test checks the two agree.

## macOS app (`app/`)

```text
app/
├── Package.swift              SkilldeckCore library + tests (swift test)
├── Sources/SkilldeckCore/     UI-free logic, fully unit tested
├── Skilldeck/                 SwiftUI app target (XcodeGen: project.yml)
└── Tests/SkilldeckCoreTests/  47 XCTest cases + fixture catalogs
```

### SkilldeckCore

| File | Responsibility |
|---|---|
| `Models.swift` | `Catalog`, `Resource`, `Platform`/`PlatformTarget`, `Contributor`, `ResourceCollection`; `CatalogIndex` (lookups, reverse references, related resources) |
| `CatalogStore.swift` | Loads downloaded → bundled catalog; verifies every resource hash and quarantines mismatches; `install` (stage → verify → swap, keeping `previous/`), `rollback`, `resetToBundled`; `UpdateService` (check `latest.json`, download, verify SHA-256 and size, diff) behind an injectable `HTTPClient` |
| `Installer.swift` | Plans installs from the registry (user/project/custom scope), detects conflicts (only unrecorded or locally modified files count), executes via staging with backup-and-replace and rollback on failure, verifies hashes after writing, tracks modifications, uninstalls to Trash keeping edited files, exports folders and zips and `AGENTS.md` sections |
| `Search.swift` | Weighted multi-term search, filters, sorts, suggestions |
| `Markdown.swift` | Frontmatter, H2 sections, nested-fence-aware block parser (no HTML rendering), prompt extraction, `{{PLACEHOLDER}}` discovery |
| `Persistence.swift` | `AppPaths` (Application Support/Skilldeck), `LibraryStore` (favorites, recents, collections, install records, update history) as atomic JSON; corrupt files are moved aside |
| `GitHubProfiles.swift` | `actor` fetching `api.github.com/users/<login>` and avatars, with 24h memory and disk cache, offline fallback, and rate-limit backoff |
| `Utilities.swift` | `SemVer`, `Hashing`, `PathSafety` (relative-path validation, containment, symlink refusal), `ZipWriter` (STORE + CRC32), `URLSafety` |

### App target

An `@Observable @MainActor AppModel` owns the catalog index, library store, installer, and update service. The views are `NavigationSplitView` (sidebar → browser → detail) with `Discover`, a resource browser (search, filter, sort, grid/list), detail tabs per type, an install sheet, collections, contributors, Installed (`Table`), Updates, and Settings. Deep links use `skilldeck://resource|collection|contributor|search|section/<value>`.

The app is **not sandboxed** because it has to write to `~/.claude`, `~/.codex`, and project folders the user picks. It uses the hardened runtime and never spawns processes or executes package content.

### Offline-first behaviour

1. First launch: the bundled `catalog-bundle.json` is verified and loaded, with no network needed.
2. If updates are enabled, the app fetches `releases/download/catalog-latest/latest.json`. A newer version gets downloaded, its SHA-256 and size are checked, it's decoded and every resource hash verified, then it's swapped in atomically. The old copy stays in `previous/`.
3. Rollback restores `previous/`, or the bundle if `previous/` is missing. If a download is corrupt or tampered with, the current catalog stays in place.
