# Contributing to Skilldeck

Thanks for helping! There are two ways to contribute:

- **Resources** (agents, skills, prompts, routines): follow the [Submission guide](../docs/SUBMISSION_GUIDE.md) and read the [Contributor Guide](../docs/CONTRIBUTOR_GUIDE.md) and the [package format](../docs/FORMAT.md), copy a template from `templates/`, and run `python3 scripts/validate_catalog.py` before opening a PR.
- **App or tooling**: see [Development & testing](../docs/DEVELOPMENT.md). Run `cd app && swift test` and `python3 -m unittest discover -s tests` before opening a PR.

Ground rules:

- Only submit work you can license (the catalog default is MIT).
- No credentials, personal data, binaries, or scripts in packages.
- Compatibility claims must be ones you've verified, and never above the [registry](../docs/COMPATIBILITY.md).
- Leave `status: submitted`. After merge, the resource ships in the next catalog release a maintainer approves.
- Be kind. Reviews focus on usefulness, accuracy, and safety ([review policy](../docs/REVIEW_POLICY.md)).
