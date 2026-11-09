# Submit a resource to Skilldeck

Anyone with a GitHub account can add an agent, skill, prompt, or routine. You open a pull request, CI checks it automatically, a maintainer reviews it, and **once it's merged, it's published.** Every Skilldeck app picks it up the next time it checks for updates: at launch, and every 6 hours by default.

```text
 you: fork → add package → open PR
                              │
              CI: validate-submission (automatic, ~1 min)
                              │  ✔ schema, structure, safety, duplicates, compatibility
                              ▼
              maintainer: review → merge
                              │
              CI: release-catalog (automatic) → catalog-v1.N.0 on GitHub Releases
                              │
              Skilldeck app: checks at launch + periodically → shows it under "New in the Catalog"
```

You don't need to edit the catalog version, build anything, or touch the app.

---

## Option A: entirely in the browser (no tools needed)

1. **Fork** [seyhunak/skilldeck](https://github.com/seyhunak/skilldeck) with the **Fork** button.
2. In your fork, open the template folder for your type, e.g. [`templates/skill/`](../templates/skill). Copy the contents of `manifest.yaml` and `SKILL.md`.
3. Click **Add file → Create new file** and type the path, which creates the folders for you:
   `resources/<domain>/<use-case>/<your-id>/manifest.yaml`
   For example: `resources/software-development/code-review/sql-migration-review/manifest.yaml`
   Paste the template and fill it in (see *Filling in the manifest* below). Commit to a new branch.
4. On that branch, add the entrypoint the same way: `.../<your-id>/SKILL.md` (or `agent.md`, `prompt.md`, `routine.md`).
5. Click **Contribute → Open pull request**. Fill in the checklist in the PR template.
6. Wait for the **Validate submission** check. If this is your first contribution, GitHub holds the check until a maintainer clicks **Approve and run**. If it fails, open **Details → Summary** for the validation report, which lists every problem with its file. Fix them on the same branch and the check reruns automatically.

## Option B: locally (recommended for larger packages)

```bash
gh repo fork seyhunak/skilldeck --clone && cd skilldeck
```

```bash
python3 -m pip install -r requirements.txt
```

```bash
git checkout -b add-sql-migration-review
```

```bash
cp -R templates/skill resources/software-development/code-review/sql-migration-review
```

Edit the files, then run the same checks CI runs:

```bash
python3 scripts/validate_catalog.py --only sql-migration-review
```

```bash
python3 scripts/validate_catalog.py && python3 -m unittest discover -s tests
```

```bash
git add resources && git commit -m "Add sql-migration-review skill" && gh pr create --fill
```

---

## Filling in the manifest

| Field | What to put |
|---|---|
| `id` | Lowercase kebab-case, unique, **the same as the folder name**. Agents usually end in `-agent`, prompts in `-prompt`, routines in `-routine`. |
| `type` | `agent`, `skill`, `prompt`, or `routine` |
| `domain` / `use_cases` | Pick from [`catalog/domains.yaml`](../catalog/domains.yaml). The folder path must be `resources/<domain>/<first use case>/<id>/`. |
| `description` | 30–300 characters: what it does and when to use it. This is what people see in search. |
| `author` | Your name and **your GitHub login**. Your avatar and profile page are created automatically. |
| `version` | `1.0.0` for new resources. Bump it whenever you change one. |
| `license` | SPDX id. MIT is recommended and must be content you have the right to share. |
| `compatibility` | Copy it from the template. Don't claim more than [the registry](COMPATIBILITY.md) allows; CI rejects it if you do. |
| `status` | Leave as `submitted`. Merging publishes it. |
| `content.files` | List every extra file (e.g. `references/checklist.md`). |

Each type has required `##` sections and a minimum length. See [FORMAT.md](FORMAT.md) or open the template. The most common reasons a check fails:

- the folder path doesn't match `domain` / the first `use_cases` entry / `id`
- a required section is missing or misspelled (e.g. `## Operating procedure`)
- a `{{PLACEHOLDER}}` in a prompt isn't documented under `## Variables`
- something in angle brackets like `<form>` or `<link>` gets read as HTML; write `FORM_NAME` or put it in backticks
- the content is too similar to an existing resource (≥ 45% overlap); extend that one instead

## What reviewers look for

CI checks the structure. People check whether it's **worth installing**:

- **Concrete.** Real steps, criteria, commands, and thresholds, not "follow best practices".
- **Clear output.** A defined format someone can act on, with an example.
- **Honest.** Limitations and safety boundaries are stated. Finance, legal, and security content carries the required disclaimer.
- **Original.** It isn't a near-copy of an existing resource or a generic prompt with a new name.
- **Safe.** No secrets, scripts, binaries, or instructions to get around security controls.

Details are in the [review policy](REVIEW_POLICY.md).

## After merge

- The **Release catalog** workflow publishes a new catalog version: a minor bump when resources are added, a patch bump when they're updated. The release notes list your resource.
- Apps check at launch and periodically, verify the download's SHA-256, and show your resource under **Discover → New in the Catalog**.
- Your contributor page lists everything attributed to your GitHub login. To add a bio and featured resources, add `contributors/<your-login>/profile.yaml` from [the template](../templates/contributor/profile.yaml).

## Updating or retiring a resource

- **Update:** edit the files, bump `version`, add a `changelog` line, and open a PR.
- **Retire:** set `status: deprecated` in a PR. The resource stays in the repository but drops out of the catalog in the next release.

Questions? Open an issue with the **Resource request** template, or ask in your PR.
