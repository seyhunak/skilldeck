# Release process

## Catalog releases

1. Merge approved content to `main`.
2. Bump `catalog_version` (semver) in `catalog/catalog.yaml` in the same PR or a follow-up. Use a patch for fixes, a minor for new resources, and a major for schema changes that need a newer app (also raise `minimum_app_version`).
3. `release-catalog.yml` runs on pushes to `main` that touch `resources/`, `contributors/`, or `catalog/`, and can also be triggered manually. It:
   - gates on `validate_catalog.py` and `check_launch_catalog.py`;
   - downloads the previous `latest.json` and index so it can compute the diff;
   - builds deterministically (`SOURCE_DATE_EPOCH` = commit time);
   - **fails** if content changed but `catalog-v<version>` already exists (you forgot to bump);
   - publishes `catalog-v<version>` with `catalog.json`, `catalog-bundle.json`, `latest.json`, `packages.zip`, per-package zips, the quality report, and `CHANGES.md` as release notes;
   - uploads `latest.json` to the rolling `catalog-latest` prerelease, which is what the app polls.

Only this job gets `contents: write`. Every action is pinned to a full commit SHA.

### Rolling back a bad release

Re-upload the previous version's `latest.json` to `catalog-latest`:

```bash
gh release download catalog-v1.0.0 --pattern latest.json --dir /tmp/rb && gh release upload catalog-latest /tmp/rb/latest.json --clobber
```

Users who already updated can hit **Roll Back** in the Updates view.

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
