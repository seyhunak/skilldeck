# Release process

## Catalog releases

Releases are automatic: **merge a PR and the catalog is published.**

1. Merge a reviewed pull request into `main`.
2. `release-catalog.yml` runs on pushes to `main` that touch `resources/`, `contributors/`, or `catalog/`, and can also be triggered manually. It:
   - gates on `validate_catalog.py` and `check_launch_catalog.py`;
   - downloads the previous `latest.json` and index so it can compute the diff;
   - builds deterministically (`SOURCE_DATE_EPOCH` = commit time) with `--auto-version`. The new version is the previous release's version with a **minor** bump when resources were added or removed, and a **patch** bump when resources, collections, or contributor profiles changed. With no changes nothing is published;
   - to force a version (e.g. `2.0.0` for a schema change that needs a newer app, together with `minimum_app_version`), raise `catalog_version` in `catalog/catalog.yaml`. A higher configured version always wins;
   - publishes `catalog-v<version>` with `catalog.json`, `catalog-bundle.json`, `latest.json`, `packages.zip`, per-package zips, the quality report, and `CHANGES.md` as release notes;
   - uploads `latest.json` to the rolling `catalog-latest` prerelease, which is what the app polls.

Only this job gets `contents: write`. Every action is pinned to a full commit SHA.

### Rolling back a bad release

Re-upload the previous version's `latest.json` to `catalog-latest`:

```bash
gh release download catalog-v1.0.0 --pattern latest.json --dir /tmp/rb && gh release upload catalog-latest /tmp/rb/latest.json --clobber
```

Users who already updated can hit **Roll Back** in the Updates view.

## How apps receive releases

The app checks `catalog-latest/latest.json` at launch, every 6 hours while running (configurable: 1h/6h/12h/24h), and when it becomes active after the interval has passed. By default it downloads and installs a newer catalog automatically after verifying the SHA-256, and shows added resources under **Discover → New in the Catalog** until the user marks them as seen. Users can turn off automatic install (they're then notified in Updates) or turn off checks entirely in Settings. Catalog updates never modify resources a user has already installed into their tools.

## Updating the bundled catalog in the app

The app ships a catalog snapshot so it works offline. Refresh it before an app release:

```bash
python3 scripts/build_catalog.py --out dist && cp dist/catalog-bundle.json app/Skilldeck/Resources/
```

```bash
python3 scripts/make_test_fixture.py
```

## App releases

Bump `MARKETING_VERSION` in `app/project.yml`. The `macos-app.yml` workflow builds and tests on every change and uploads an ad-hoc signed `Skilldeck.zip` artifact. Signing with a Developer ID and notarizing need maintainer credentials and aren't automated yet.
