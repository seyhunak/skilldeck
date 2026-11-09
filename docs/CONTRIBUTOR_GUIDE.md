# Contributor guide

> New here? The [Submission guide](SUBMISSION_GUIDE.md) walks you through your first pull request, including a browser-only path.

Thanks for helping build Skilldeck. One pull request can add or improve one or more packages, and each package is one independently useful resource.

## 1. Pick the type

- **Agent**: a complete specialist for a whole task, e.g. "review this pull request" or "threat-model this feature". Ships as a Claude Code subagent.
- **Skill**: a focused, reusable capability an agent activates when relevant, e.g. "mine git history for churn hotspots".
- **Prompt**: a single copy-ready prompt with variables.
- **Routine**: a repeatable workflow a person runs with an AI assistant, with steps, decision points, and approvals.

Search the app (or `grep -r` over `resources/`) first. The validator flags near-duplicates (≥ 45% word-shingle overlap), and reviewers reject thin variations.

## 2. Create the package

```bash
cp -R templates/skill resources/software-development/code-analysis/my-skill-id
```

- `id`: lowercase kebab-case, unique, the same as the directory name.
- `domain` and the first `use_cases` entry must match the parent directories. Both come from [`catalog/domains.yaml`](../catalog/domains.yaml).
- List every non-entrypoint file in `content.files`.
- Keep `status: submitted`. Merging the PR publishes it, so merge is the approval. `deprecated` removes a resource from the catalog.
- Only claim compatibility you have verified, and never more than [the registry](COMPATIBILITY.md) allows.

The full format is in [FORMAT.md](FORMAT.md).

## 3. Write content worth installing

Reviewers look for concrete procedures (real commands, real criteria, real thresholds), a defined output format, honest limitations, and safety boundaries. Generic advice like "be thorough" or "consider best practices" doesn't count as a procedure. Show a worked example.

## 4. Add your profile (first contribution)

```bash
mkdir -p contributors/<github-login> && cp templates/contributor/profile.yaml contributors/<github-login>/
```

## 5. Validate locally

```bash
python3 -m pip install -r requirements.txt
```

```bash
python3 scripts/validate_catalog.py --only my-skill-id
```

```bash
python3 scripts/validate_catalog.py && python3 -m unittest discover -s tests
```

`--package-only` skips cross-package checks while you draft, and `--report report.md` writes a Markdown report.

## 6. Open the pull request

Fill in the template. CI (`validate-submission.yml`) runs the validator on the files you changed plus the catalog-wide checks, the tooling tests, the launch gate, and a test build. It runs read-only with no secrets. A maintainer then reviews against the [review policy](REVIEW_POLICY.md).

## 7. After merge

The release workflow publishes a new catalog version automatically. Apps check at launch and periodically, then show your resource under **Discover → New in the Catalog**. Your contributor page lists your resources.
