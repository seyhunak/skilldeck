"""Tests for the catalog tooling. Run: python3 -m unittest discover -s tests -v

Each test builds a throwaway catalog repository in a temp directory from the real
taxonomy, schemas, registry, and a handful of real packages, then exercises the
validator, builder, and launch gate against it.
"""
from __future__ import annotations

import json
import os
import shutil
import sys
import tempfile
import unittest
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

import catalog_lib as L  # noqa: E402
import build_catalog  # noqa: E402
import check_launch_catalog  # noqa: E402
from validate_catalog import Validator, ids_from_changed_files  # noqa: E402

SAMPLE_IDS = {
    "agent": "repository-intelligence-agent",
    "skill": "git-history-forensics",
    "prompt": "explain-unfamiliar-code-prompt",
    "routine": "new-codebase-onboarding-routine",
}


def find_package(rid: str) -> Path:
    for mp in (ROOT / "resources").rglob("manifest.yaml"):
        if mp.parent.name == rid:
            return mp.parent
    raise unittest.SkipTest(f"sample package {rid} not present")


class TempRepo:
    def __init__(self, ids=SAMPLE_IDS.values()):
        self.dir = Path(tempfile.mkdtemp(prefix="skilldeck-test-"))
        for sub in ("catalog", "schemas"):
            shutil.copytree(ROOT / sub, self.dir / sub)
        (self.dir / "contributors").mkdir()
        (self.dir / "resources").mkdir()
        self.ids = list(ids)
        for rid in self.ids:
            src = find_package(rid)
            dest = self.dir / src.relative_to(ROOT)
            shutil.copytree(src, dest)
            m = L.load_yaml(dest / "manifest.yaml")
            # Keep relationships inside the temp repo resolvable.
            m["dependencies"] = [d for d in m.get("dependencies", []) if d in self.ids]
            m["related"] = [d for d in m.get("related", []) if d in self.ids]
            self.write_manifest(dest, m)
        if len(self.ids) >= 4:
            self.write_collections([{"id": "starter", "title": "Starter Kit", "description": "A collection used by the tooling tests to check references.",
                                 "audience": "Test authors and CI.", "use_cases": ["repository-analysis"], "symbol": "star", "accent": "blue",
                                     "resources": [{"id": i} for i in self.ids]}])
        else:
            self.write_collections([])

    def path(self, rid):
        for mp in (self.dir / "resources").rglob("manifest.yaml"):
            if mp.parent.name == rid:
                return mp.parent
        raise KeyError(rid)

    def manifest(self, rid):
        return L.load_yaml(self.path(rid) / "manifest.yaml")

    @staticmethod
    def write_manifest(pkg: Path, m: dict):
        import yaml
        (pkg / "manifest.yaml").write_text(yaml.safe_dump(m, sort_keys=False, allow_unicode=True), encoding="utf-8")

    def write_collections(self, cols):
        import yaml
        (self.dir / "catalog" / "collections.yaml").write_text(yaml.safe_dump({"schema_version": "1.0", "collections": cols}), encoding="utf-8")

    def validate(self, **kw):
        v = Validator(self.dir)
        v.run(**kw)
        return v, [i for i in v.issues if i.level == "error"]

    def cleanup(self):
        shutil.rmtree(self.dir, ignore_errors=True)


class Base(unittest.TestCase):
    def setUp(self):
        self.repo = TempRepo()

    def tearDown(self):
        self.repo.cleanup()

    def assertError(self, errors, fragment):
        self.assertTrue(any(fragment in e.message for e in errors), f"expected error containing {fragment!r}; got {[e.message for e in errors]}")


class ValidationTests(Base):
    def test_sample_packages_are_valid(self):
        _, errors = self.repo.validate()
        self.assertEqual([], [str(e) for e in errors])

    def test_manifest_parsing_rejects_invalid_yaml(self):
        (self.repo.path(SAMPLE_IDS["skill"]) / "manifest.yaml").write_text("id: [unterminated", encoding="utf-8")
        _, errors = self.repo.validate()
        self.assertError(errors, "not valid YAML")

    def test_schema_validation_reports_missing_and_bad_fields(self):
        p = self.repo.path(SAMPLE_IDS["prompt"])
        m = self.repo.manifest(SAMPLE_IDS["prompt"])
        del m["license"]
        m["version"] = "1.0"
        self.repo.write_manifest(p, m)
        _, errors = self.repo.validate()
        self.assertError(errors, "'license' is a required property")
        self.assertError(errors, "version")

    def test_duplicate_ids_rejected(self):
        src = self.repo.path(SAMPLE_IDS["skill"])
        dup = src.parent.parent / "code-review" / src.name
        shutil.copytree(src, dup)
        _, errors = self.repo.validate()
        self.assertError(errors, "duplicate resource id")

    def test_duplicate_content_detected(self):
        src = self.repo.path(SAMPLE_IDS["skill"])
        clone = src.parent / "git-history-forensics-copy"
        shutil.copytree(src, clone)
        m = L.load_yaml(clone / "manifest.yaml")
        m["id"] = clone.name
        m["name"] = "Git History Forensics Copy"
        TempRepo.write_manifest(clone, m)
        text = (clone / "SKILL.md").read_text().replace("name: git-history-forensics", f"name: {clone.name}")
        (clone / "SKILL.md").write_text(text + "\nOne extra line.\n")
        _, errors = self.repo.validate()
        self.assertError(errors, "near-duplicate content")

    def test_missing_required_file_and_undeclared_file(self):
        p = self.repo.path(SAMPLE_IDS["agent"])
        (p / "references" / "survey-checklist.md").unlink()
        (p / "notes.md").write_text("# Notes\n\nExtra file.\n")
        _, errors = self.repo.validate()
        self.assertError(errors, "declared content file missing")
        self.assertError(errors, "not declared in content.files")

    def test_required_sections_enforced(self):
        p = self.repo.path(SAMPLE_IDS["routine"])
        text = (p / "routine.md").read_text().replace("## Human approval", "## Sign-off")
        (p / "routine.md").write_text(text)
        _, errors = self.repo.validate()
        self.assertError(errors, "missing required section '## Human approval'")

    def test_broken_references_and_self_reference(self):
        p = self.repo.path(SAMPLE_IDS["prompt"])
        m = self.repo.manifest(SAMPLE_IDS["prompt"])
        m["related"] = ["does-not-exist", SAMPLE_IDS["prompt"]]
        self.repo.write_manifest(p, m)
        _, errors = self.repo.validate()
        self.assertError(errors, "references unknown resource 'does-not-exist'")
        self.assertError(errors, "must not reference the resource itself")

    def test_dependency_cycle_detected(self):
        a, b = SAMPLE_IDS["agent"], SAMPLE_IDS["skill"]
        ma, mb = self.repo.manifest(a), self.repo.manifest(b)
        ma["dependencies"] = [b]
        mb["dependencies"] = [a]
        self.repo.write_manifest(self.repo.path(a), ma)
        self.repo.write_manifest(self.repo.path(b), mb)
        _, errors = self.repo.validate()
        self.assertError(errors, "dependency cycle")

    def test_compatibility_claims_capped_by_registry(self):
        p = self.repo.path(SAMPLE_IDS["agent"])
        m = self.repo.manifest(SAMPLE_IDS["agent"])
        m["compatibility"] = [{"platform": "codex", "level": "native_install", "resource_types": ["agent"]},
                              {"platform": "made-up-tool", "level": "copy_paste"}]
        self.repo.write_manifest(p, m)
        _, errors = self.repo.validate()
        self.assertError(errors, "registry allows at most file_export")
        self.assertError(errors, "unknown compatibility platform")

    def test_security_checks(self):
        p = self.repo.path(SAMPLE_IDS["skill"])
        (p / "install.sh").write_text("rm -rf /\n")
        os.chmod(p / "install.sh", 0o755)
        (p / "evil.md").write_text("# Evil\n\n<script>alert(1)</script>\n[x](javascript:alert(1))\n[y](../../outside.md)\n")
        (p / "creds.md").write_text("# Creds\n\nkey: AKIA" + "ABCDEFGHIJKLMNOP\n")
        os.symlink("/etc/hosts", p / "link.md")
        m = self.repo.manifest(SAMPLE_IDS["skill"])
        m["content"]["files"] = ["../escape.md"]
        self.repo.write_manifest(p, m)
        _, errors = self.repo.validate()
        for fragment in ("file type not allowed", "executable permission", "unsafe HTML", "disallowed link scheme",
                         "link escapes package", "possible secret", "Symlinks are not allowed".lower(), "Unsafe package path"):
            if fragment == "symlinks are not allowed":
                self.assertTrue(any("symlinks are not allowed" in e.message.lower() for e in errors))
            else:
                self.assertError(errors, fragment)

    def test_regulated_domain_requires_disclaimer(self):
        p = self.repo.path(SAMPLE_IDS["skill"])
        m = self.repo.manifest(SAMPLE_IDS["skill"])
        m["tags"] = m["tags"] + ["legal"]
        m["safety"].pop("professional_advice_disclaimer", None)
        self.repo.write_manifest(p, m)
        _, errors = self.repo.validate()
        self.assertError(errors, "professional_advice_disclaimer")

    def test_placeholder_text_rejected(self):
        p = self.repo.path(SAMPLE_IDS["prompt"])
        (p / "prompt.md").write_text((p / "prompt.md").read_text() + "\nTODO: finish this\n")
        _, errors = self.repo.validate()
        self.assertError(errors, "placeholder text")

    def test_prompt_placeholders_must_be_documented(self):
        p = self.repo.path(SAMPLE_IDS["prompt"])
        text = (p / "prompt.md").read_text()
        text = text.replace("```text\n", "```text\nAlso consider {{UNDOCUMENTED_INPUT}}.\n", 1)
        (p / "prompt.md").write_text(text)
        _, errors = self.repo.validate()
        self.assertError(errors, "UNDOCUMENTED_INPUT")

    def test_collection_references_validated(self):
        self.repo.write_collections([{"id": "broken", "title": "Broken", "description": "A collection that references a resource which does not exist.",
                                      "audience": "Tests only.", "use_cases": ["x"], "symbol": "star", "accent": "blue",
                                      "resources": [{"id": "nope"}, {"id": SAMPLE_IDS["agent"]}, {"id": SAMPLE_IDS["skill"]}, {"id": SAMPLE_IDS["prompt"]}]}])
        _, errors = self.repo.validate()
        self.assertError(errors, "references unknown resource 'nope'")

    def test_changed_files_mapping(self):
        ids = ids_from_changed_files(self.repo.dir, ["resources/software-development/code-review/foo-agent/agent.md", "README.md"])
        self.assertEqual({"foo-agent"}, ids)


class ContributorTests(Base):
    def write_profile(self, login, **fields):
        d = self.repo.dir / "contributors" / login
        d.mkdir(parents=True, exist_ok=True)
        import yaml
        (d / "profile.yaml").write_text(yaml.safe_dump({"schema_version": "1.0", "github": fields.pop("github", login), **fields}))

    def test_profile_must_match_directory(self):
        self.write_profile("seyhunak", github="someone-else")
        _, errors = self.repo.validate()
        self.assertError(errors, "must match the profile directory")

    def test_profile_featured_must_be_own_resource(self):
        self.write_profile("seyhunak", featured_resource_ids=["missing-id"])
        _, errors = self.repo.validate()
        self.assertError(errors, "featured resource 'missing-id' does not exist")

    def test_aggregation_uses_manifests_and_profile(self):
        self.write_profile("seyhunak", display_name="Profile Name", bio="Bio text", featured_resource_ids=[SAMPLE_IDS["agent"]])
        out = self.repo.dir / "dist"
        payload = build_catalog.build(self.repo.dir, out, repo="example/skilldeck")
        self.assertEqual(1, payload["contributors_count"])
        c = payload["contributors"][0]
        self.assertEqual("seyhunak", c["github"])
        self.assertEqual("Profile Name", c["display_name"])
        self.assertEqual(4, c["resource_count"])
        self.assertEqual({"agent": 1, "prompt": 1, "routine": 1, "skill": 1}, c["counts_by_type"])
        self.assertEqual([SAMPLE_IDS["agent"]], c["featured_resource_ids"])
        self.assertTrue(c["has_profile"])

    def test_aggregation_without_profile_falls_back_to_manifest(self):
        payload = build_catalog.build(self.repo.dir, self.repo.dir / "dist", repo="example/skilldeck")
        c = payload["contributors"][0]
        self.assertFalse(c["has_profile"])
        self.assertEqual(self.repo.manifest(SAMPLE_IDS["agent"])["author"]["name"], c["display_name"])

    def test_avatar_url_generation(self):
        self.assertEqual("https://github.com/octocat.png?size=256", L.github_avatar_url("octocat"))
        self.assertEqual("https://github.com/octocat", L.github_profile_url("octocat"))


class BuildTests(Base):
    def test_build_outputs_and_integrity_hashes(self):
        out = self.repo.dir / "dist"
        payload = build_catalog.build(self.repo.dir, out, repo="example/skilldeck")
        self.assertEqual(4, payload["resources_count"])
        bundle = json.loads((out / "catalog-bundle.json").read_text())
        latest = json.loads((out / "latest.json").read_text())
        self.assertEqual(L.sha256_file(out / "catalog-bundle.json"), latest["bundle"]["sha256"])
        for r in bundle["resources"]:
            for f in r["files"]:
                self.assertEqual(L.sha256_bytes(f["content"].encode()), f["sha256"])
            self.assertEqual(build_catalog.content_hash(r["files"]), r["content_sha256"])
            zpath = out / "packages" / r["package"]["filename"]
            self.assertEqual(L.sha256_file(zpath), r["package"]["sha256"])
            with zipfile.ZipFile(zpath) as zf:
                self.assertIn(f"{r['id']}/manifest.yaml", zf.namelist())
            self.assertTrue(r["package"]["url"].startswith("https://github.com/example/skilldeck/releases/download/catalog-v"))
        self.assertEqual(["starter"], bundle["resources"][0]["collections"])

    def test_build_is_deterministic(self):
        a, b = self.repo.dir / "a", self.repo.dir / "b"
        build_catalog.build(self.repo.dir, a, repo="x/y")
        build_catalog.build(self.repo.dir, b, repo="x/y")
        for name in ("catalog.json", "catalog-bundle.json", "latest.json"):
            self.assertEqual((a / name).read_bytes(), (b / name).read_bytes(), name)

    def test_deprecated_resources_are_not_published(self):
        p = self.repo.path(SAMPLE_IDS["prompt"])
        m = self.repo.manifest(SAMPLE_IDS["prompt"])
        m["status"] = "deprecated"
        self.repo.write_manifest(p, m)
        payload = build_catalog.build(self.repo.dir, self.repo.dir / "dist", repo="x/y")
        self.assertNotIn(SAMPLE_IDS["prompt"], [r["id"] for r in payload["resources"]])

    def test_merged_submissions_are_published(self):
        p = self.repo.path(SAMPLE_IDS["prompt"])
        m = self.repo.manifest(SAMPLE_IDS["prompt"])
        m["status"] = "submitted"
        self.repo.write_manifest(p, m)
        payload = build_catalog.build(self.repo.dir, self.repo.dir / "dist", repo="x/y")
        self.assertIn(SAMPLE_IDS["prompt"], [r["id"] for r in payload["resources"]])

    def test_auto_version_bumps_from_previous_release(self):
        first = build_catalog.build(self.repo.dir, self.repo.dir / "d1", repo="x/y", auto_version=True)
        prev = json.loads((self.repo.dir / "d1" / "catalog.json").read_text())
        same = build_catalog.build(self.repo.dir, self.repo.dir / "d2", previous=prev, repo="x/y", auto_version=True)
        self.assertEqual(first["catalog_version"], same["catalog_version"])
        p = self.repo.path(SAMPLE_IDS["skill"])
        m = self.repo.manifest(SAMPLE_IDS["skill"])
        m["version"] = "1.0.1"
        self.repo.write_manifest(p, m)
        patched = build_catalog.build(self.repo.dir, self.repo.dir / "d3", previous=prev, repo="x/y", auto_version=True)
        major, minor, patch = (int(x) for x in first["catalog_version"].split("."))
        self.assertEqual(f"{major}.{minor}.{patch + 1}", patched["catalog_version"])
        latest = json.loads((self.repo.dir / "d3" / "latest.json").read_text())
        self.assertIn(f"catalog-v{patched['catalog_version']}/", latest["bundle"]["url"])
        self.assertTrue(all(f"catalog-v{patched['catalog_version']}/" in r["package"]["url"] for r in patched["resources"]))
        prev["resources"] = prev["resources"][1:]  # pretend one resource is new
        added = build_catalog.build(self.repo.dir, self.repo.dir / "d4", previous=prev, repo="x/y", auto_version=True)
        self.assertEqual(f"{major}.{minor + 1}.0", added["catalog_version"])
        self.assertEqual("9.0.0", L.next_catalog_version("9.0.0", "1.4.2", {"added": ["x"]}))
        self.assertEqual("1.4.3", L.next_catalog_version("1.0.0", "1.4.2", {"metadata_changed": True}))
        self.assertEqual("1.4.2", L.next_catalog_version("1.0.0", "1.4.2", {"added": [], "updated": []}))

    def test_version_changes_detected(self):
        first = build_catalog.build(self.repo.dir, self.repo.dir / "d1", repo="x/y")
        p = self.repo.path(SAMPLE_IDS["skill"])
        m = self.repo.manifest(SAMPLE_IDS["skill"])
        m["version"] = "1.1.0"
        self.repo.write_manifest(p, m)
        prev = json.loads((self.repo.dir / "d1" / "catalog.json").read_text())
        second = build_catalog.build(self.repo.dir, self.repo.dir / "d2", previous=prev, repo="x/y")
        self.assertEqual([SAMPLE_IDS["skill"]], second["changes"]["updated"])
        self.assertEqual([], second["changes"]["added"])
        self.assertEqual(first["catalog_version"], second["changes"]["previous_version"])

    def test_semver_compare(self):
        self.assertEqual(1, L.compare_versions("1.10.0", "1.9.9"))
        self.assertEqual(0, L.compare_versions("2.0.0", "2.0.0"))
        self.assertEqual(-1, L.compare_versions("0.9.0", "1.0.0"))


class LaunchGateTests(Base):
    def test_small_catalog_fails_launch_gate(self):
        failures, summary = check_launch_catalog.check(self.repo.dir)
        self.assertEqual(4, summary["total"])
        self.assertTrue(any("total published complete resources 4 < 250" in f for f in failures))
        self.assertTrue(any("required collection missing" in f for f in failures))

    def test_real_catalog_launch_gate(self):
        failures, summary = check_launch_catalog.check(ROOT)
        if summary["total"] < 250:
            self.skipTest(f"real catalog incomplete ({summary['total']} resources)")
        self.assertEqual([], failures)


class LifecycleTests(unittest.TestCase):
    """Submission -> validation -> merge (publish) -> build -> contributor aggregation."""

    def test_submission_lifecycle(self):
        repo = TempRepo(ids=[SAMPLE_IDS["skill"]])
        try:
            # 1. A new contributor (octocat) submits a distinct skill package from the template conventions.
            src = find_package("commit-message-writing")
            new = repo.dir / src.relative_to(ROOT)
            shutil.copytree(src, new)
            m = L.load_yaml(new / "manifest.yaml")
            m.update({"status": "submitted", "author": {"name": "Octo Cat", "github": "octocat"},
                      "related": [SAMPLE_IDS["skill"]], "dependencies": []})
            TempRepo.write_manifest(new, m)
            # 2. Validation of the changed package passes cleanly.
            v, errors = repo.validate(only={"commit-message-writing"})
            self.assertEqual([], [str(e) for e in errors])
            # 3. A deprecated package stays out of the catalog.
            m["status"] = "deprecated"
            TempRepo.write_manifest(new, m)
            payload = build_catalog.build(repo.dir, repo.dir / "dist", repo="x/y")
            self.assertNotIn("commit-message-writing", [r["id"] for r in payload["resources"]])
            # 4. Merged as submitted, it is published; contributor is aggregated without a profile file.
            m["status"] = "submitted"
            TempRepo.write_manifest(new, m)
            payload = build_catalog.build(repo.dir, repo.dir / "dist", repo="x/y")
            ids = [r["id"] for r in payload["resources"]]
            self.assertIn("commit-message-writing", ids)
            octo = next(c for c in payload["contributors"] if c["github"] == "octocat")
            self.assertEqual(["commit-message-writing"], octo["resource_ids"])
            self.assertEqual("https://github.com/octocat.png?size=256", octo["avatar_url"])
        finally:
            repo.cleanup()


if __name__ == "__main__":
    unittest.main()
