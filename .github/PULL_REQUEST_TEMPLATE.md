<!-- First time? See docs/SUBMISSION_GUIDE.md. Once merged, your resource is published automatically. -->

## What does this PR do?

<!-- New resource(s), improvement to existing resources, app change, or tooling change. -->

**Resource ID(s):**

## Resource checklist (skip for app/tooling PRs)

- [ ] Package lives at `resources/<domain>/<use-case>/<id>/` and the directory name matches `id`
- [ ] All required sections are present; the procedure is concrete, not generic advice
- [ ] `status: submitted`; `version` bumped if this edits an existing resource
- [ ] Compatibility claims are ones I've verified and within `catalog/compatibility.yaml`
- [ ] No credentials, personal data, binaries, scripts, or symlinks
- [ ] I have the right to license this content under the declared license
- [ ] `python3 scripts/validate_catalog.py` passes locally

## How was it tested?

<!-- Which tool/model, what input, what you checked in the output. -->

## App / tooling checklist

- [ ] `cd app && swift test` passes
- [ ] `python3 -m unittest discover -s tests` passes
