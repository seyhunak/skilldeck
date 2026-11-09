# Release process

## Catalog releases

Releases are built automatically, but **nothing reaches the app until the repository owner or an authorized maintainer approves it.**

1. Merge a reviewed pull request into `main`.
2. `release-catalog.yml` runs on pushes to `main` that touch `resources/`, `contributors/`, or `catalog/`, and can also be triggered manually. Its read-only **build** job:
   - gates on `validate_catalog.py` and `check_launch_catalog.py`;
   - downloads the previous `latest.json` and index so it can compute the diff;
   - builds deterministically (`SOURCE_DATE_EPOCH` = commit time) with `--auto-version`. The new version is the previous release's version with a **minor** bump when resources were added or removed, and a **patch** bump when resources, collections, or contributor profiles changed. With no changes nothing is published;
   - to force a version (e.g. `2.0.0` for a schema change that needs a newer app, together with `minimum_app_version`), raise `catalog_version` in `catalog/catalog.yaml`. A higher configured version always wins;
   - writes the release candidate (version, resource count, bundle SHA-256, and the added/updated/removed list) to the run summary, and uploads it as an artifact.
3. The **publish** job runs in the `catalog-release` environment and waits for approval. Reviewers get a notification. Open the run (**Actions → Release catalog**), read the summary, and click **Review deployments → Approve and deploy**, or **Reject**. Only after approval, it re-checks the candidate's hashes and:
   - publishes `catalog-v<version>` with `catalog.json`, `catalog-bundle.json`, `latest.json`, `packages.zip`, per-package zips, the quality report, and `CHANGES.md` as release notes;
   - uploads `latest.json` to the rolling `catalog-latest` prerelease, which is what the app polls.

Only the publish job gets `contents: write`, and only after approval. A rejected or ignored candidate expires after 30 days and changes nothing: the app keeps reading the last approved `latest.json`. Every action is pinned to a full commit SHA.

### Who can approve

Approvers are the **Required reviewers** of the `catalog-release` environment (**Settings → Environments → catalog-release**). It's currently the repository owner. To authorize another maintainer, add them (or a team) there; GitHub allows up to six. The environment only deploys from protected branches, so a release can only come from `main`.

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
