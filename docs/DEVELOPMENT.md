# Development & testing

## Requirements

- macOS 15+, Xcode 16+ (Swift 6 toolchain; the package uses Swift 5 language mode), [XcodeGen](https://github.com/yonaskolb/XcodeGen)
- Python 3.12 with `pip install -r requirements.txt`

## Catalog tooling

```bash
python3 scripts/validate_catalog.py
```

```bash
python3 scripts/check_launch_catalog.py
```

```bash
python3 -m unittest discover -s tests -v
```

```bash
SOURCE_DATE_EPOCH=1794182400 python3 scripts/build_catalog.py --out dist
```

```bash
python3 scripts/quality_report.py
```

The tooling tests (`tests/test_catalog_tooling.py`) build throwaway repositories in temp dirs. They cover each validation rule, the compatibility caps, duplicate detection, deterministic builds and hashing, diffs against a previous catalog, and the submit → validate → approve → build lifecycle.

## macOS app

```bash
cd app && swift test
```

```bash
cd app && xcodegen generate && open Skilldeck.xcodeproj
```

The Xcode project is generated from `app/project.yml` and isn't committed. A pre-build phase fails if `Skilldeck/Resources/catalog-bundle.json` is missing.

`SkilldeckCoreTests` runs against small fixture catalogs (`scripts/make_test_fixture.py`) and against the real bundled catalog:

- catalog decoding, hash verification, tamper quarantine, `minimum_app_version` gating, the Swift/Python hash formula matching
- search ranking, filters, sorting, suggestions
- Markdown sections, prompt extraction, placeholders, nested fences, HTML never interpreted
- path safety (traversal, absolute, symlinks), URL safety, zip validity (`unzip -t`), SemVer
- library persistence, corrupt-file recovery, the recents cap
- install into an isolated temp `$HOME` for every platform and scope, conflicts, backup-and-replace, reinstall, modified-file detection, uninstall that keeps edited files, refusal of scripts and unsafe paths, exports
- updates through a mock HTTP client: apply, hash mismatch, corrupt download, offline, insecure URL, rollback
- GitHub profiles: cache, offline fallback, rate-limit backoff, invalid logins
- end to end: the real 250-resource catalog verifies, every reference resolves, search → detail → install → verify on disk, and every skill installs cleanly

Tests never touch your real `~/.claude` or `~/.codex`. The installer takes an injected `home`.

## Manual QA checklist

- [ ] First launch with networking off shows 250 resources
- [ ] <kbd>⌘K</kbd> search, filters, and suggestions
- [ ] Install a skill and an agent into Claude Code (user scope), check the files and the Installed view
- [ ] Edit an installed file: the Updates view flags it as "Locally modified", and uninstall keeps it
- [ ] Install over an existing file: the conflict prompt appears, and backup-and-replace leaves a backup
- [ ] Export a skill zip for Claude Desktop and the complete catalog
- [ ] `open skilldeck://resource/threat-modeling-agent` opens the detail page
- [ ] After a catalog update, Updates › Roll Back / Use Bundled Catalog
