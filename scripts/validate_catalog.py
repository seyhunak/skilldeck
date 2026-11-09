#!/usr/bin/env python3
"""Validate Skilldeck resource packages, contributor profiles, and collections.

Never executes contributor content. Usage:

    python3 scripts/validate_catalog.py                 # validate everything
    python3 scripts/validate_catalog.py --only ID ...   # per-package checks for IDs, global checks for all
    python3 scripts/validate_catalog.py --changed-files changed.txt --report report.md
    python3 scripts/validate_catalog.py --root path/to/catalog/repo
"""
from __future__ import annotations

import argparse
import re
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import catalog_lib as L  # noqa: E402

DUPLICATE_CONTENT_THRESHOLD = 0.45
DUPLICATE_DESCRIPTION_THRESHOLD = 0.80


class Validator:
    def __init__(self, root: Path):
        self.root = root
        self.resource_root = root / "resources"
        self.issues: list[L.Issue] = []
        self.package_only = False
        self.packages: dict[str, L.Package] = {}
        self.taxonomy = L.load_taxonomy(root)
        self.registry = L.load_registry(root)
        self.max_levels = L.registry_max_levels(self.registry)
        self.platform_ids = {p["id"] for p in self.registry.get("platforms", [])}
        self.resource_schema = L.load_schema("resource.schema.json", root)
        self.contributor_schema = L.load_schema("contributor.schema.json", root)
        self.collections_schema = L.load_schema("collections.schema.json", root)

    # ------------------------------------------------------------ helpers
    def err(self, where, msg):
        self.issues.append(L.Issue("error", where, msg))

    def warn(self, where, msg):
        self.issues.append(L.Issue("warning", where, msg))

    # ------------------------------------------------------------ packages
    def load_packages(self):
        seen_paths = {}
        for manifest_path in L.iter_manifests(self.resource_root):
            package = manifest_path.parent
            rel = package.relative_to(self.root).as_posix()
            try:
                data = L.load_yaml(manifest_path)
            except Exception as exc:  # yaml.YAMLError and decoding errors
                self.err(rel, f"manifest.yaml is not valid YAML: {exc}")
                continue
            if not isinstance(data, dict):
                self.err(rel, "manifest.yaml must contain a YAML mapping")
                continue
            rid = data.get("id")
            if not isinstance(rid, str):
                self.err(rel, "manifest id is missing")
                continue
            if rid in seen_paths:
                self.err(rel, f"duplicate resource id '{rid}' (also at {seen_paths[rid]})")
                continue
            seen_paths[rid] = rel
            self.packages[rid] = L.Package(path=package, manifest=data)

    def validate_package(self, pkg: L.Package):
        m = pkg.manifest
        where = pkg.path.relative_to(self.root).as_posix()

        for msg in L.schema_errors(m, self.resource_schema):
            self.err(where, f"schema: {msg}")

        rtype = m.get("type")
        domain = m.get("domain")
        use_cases = m.get("use_cases") or []
        if domain not in self.taxonomy:
            self.err(where, f"unknown domain '{domain}'")
        else:
            allowed = set(self.taxonomy[domain].get("use_cases", []))
            unknown = [u for u in use_cases if u not in allowed]
            if unknown:
                self.err(where, f"unknown use cases for {domain}: {', '.join(unknown)}")

        # Directory layout: resources/<domain>/<use-case>/<id>/
        parts = pkg.path.relative_to(self.resource_root).parts
        if len(parts) != 3:
            self.err(where, "package must live at resources/<domain>/<use-case>/<id>/")
        else:
            if parts[0] != domain:
                self.err(where, "domain directory does not match manifest domain")
            if parts[1] not in use_cases:
                self.err(where, "use-case directory must appear in use_cases")
            if parts[2] != pkg.id:
                self.err(where, "package directory name must match manifest id")

        # Files and package safety.
        total = 0
        files = L.package_files(pkg.path)
        if len(files) > L.MAX_PACKAGE_FILES:
            self.err(where, f"package has more than {L.MAX_PACKAGE_FILES} files")
        rel_files = []
        for f in files:
            rel = f.relative_to(pkg.path).as_posix()
            if f.is_symlink():
                self.err(where, f"symlinks are not allowed: {rel}")
                continue
            try:
                L.safe_relative_path(rel)
            except ValueError as exc:
                self.err(where, str(exc))
            if f.name.startswith(".") and f.name != ".gitkeep":
                self.err(where, f"hidden files are not allowed: {rel}")
            if f.suffix.lower() not in L.ALLOWED_SUFFIXES:
                self.err(where, f"file type not allowed: {rel} (allowed: {', '.join(sorted(L.ALLOWED_SUFFIXES))})")
            size = f.stat().st_size
            total += size
            if size > L.MAX_FILE_BYTES:
                self.err(where, f"file exceeds {L.MAX_FILE_BYTES // 1024} KiB: {rel}")
            if f.stat().st_mode & 0o111:
                self.err(where, f"executable permission bit set: {rel}")
            rel_files.append(rel)
            if f.suffix.lower() in {".md", ".markdown", ".txt", ".yaml", ".yml", ".json", ".csv"}:
                try:
                    text = f.read_text(encoding="utf-8")
                except UnicodeDecodeError:
                    self.err(where, f"file is not UTF-8 text: {rel}")
                    continue
                self.scan_text(where, rel, text)
        if total > L.MAX_PACKAGE_BYTES:
            self.err(where, "package exceeds 2 MiB")
        pkg.files = rel_files

        content = m.get("content") or {}
        entry = content.get("entrypoint")
        expected_entry = L.ENTRYPOINTS.get(rtype)
        if expected_entry and entry != expected_entry:
            self.err(where, f"{rtype} entrypoint must be {expected_entry}")
        declared = [entry] + list(content.get("files") or [])
        for item in declared:
            if not item:
                continue
            try:
                p = L.safe_relative_path(item)
            except ValueError as exc:
                self.err(where, str(exc))
                continue
            if not pkg.path.joinpath(*p.parts).is_file():
                self.err(where, f"declared content file missing: {item}")
        undeclared = [f for f in rel_files if f not in declared and f != "manifest.yaml"]
        if undeclared:
            self.err(where, f"files present but not declared in content.files: {', '.join(undeclared)}")

        entry_path = pkg.path / (entry or "")
        if entry and entry_path.is_file():
            pkg.entry_text = entry_path.read_text(encoding="utf-8")
            self.validate_entrypoint(pkg, where)

        # Compatibility declarations against the registry.
        for comp in m.get("compatibility") or []:
            platform = comp.get("platform")
            level = comp.get("level")
            if platform not in self.platform_ids:
                self.err(where, f"unknown compatibility platform '{platform}'")
                continue
            ceiling = self.max_levels.get((platform, rtype))
            if ceiling is None:
                if level not in ("not_supported", "unverified"):
                    self.err(where, f"{platform} has no registered target for {rtype}; level must be not_supported or unverified")
            elif level in L.LEVELS and L.LEVELS.index(level) > L.LEVELS.index(ceiling):
                self.err(where, f"{platform} claims {level} but the registry allows at most {ceiling} for {rtype}")
            types = comp.get("resource_types")
            if types and rtype not in types:
                self.err(where, f"compatibility entry for {platform} does not list resource type {rtype}")

        # Safety metadata.
        safety = m.get("safety") or {}
        if safety.get("contains_scripts"):
            self.err(where, "packages containing scripts are not accepted")
        regulated = domain in L.REGULATED_DOMAINS or bool(set(m.get("tags") or []) & L.REGULATED_TAGS)
        if regulated:
            if not safety.get("professional_advice_disclaimer"):
                self.err(where, "regulated-domain resources must set safety.professional_advice_disclaimer: true")
            if len((safety.get("notes") or "").strip()) < 40:
                self.err(where, "regulated-domain resources need safety.notes of at least 40 characters")
        if L.is_published(m) and m.get("author", {}).get("github") is None:
            self.err(where, "published resources must include author.github for attribution")
        created, updated = m.get("created"), m.get("updated")
        if created and updated and updated < created:
            self.err(where, "updated date precedes created date")

    def scan_text(self, where, rel, text):
        for pat in L.SECRET_PATTERNS:
            if pat.search(text):
                self.err(where, f"possible secret or credential in {rel}")
        if rel.endswith((".md", ".markdown")):
            if UNSAFE := L.UNSAFE_HTML.search(text):
                self.err(where, f"unsafe HTML element <{UNSAFE.group(1)}> in {rel}")
            if not L.fences_balanced(text):
                self.err(where, f"unbalanced code fences in {rel}")
            for match in L.URL_RE.finditer(text):
                url = match.group(1) or match.group(2)
                if url.startswith("#") or url.startswith("mailto:"):
                    continue
                if re.match(r"^[a-z][a-z0-9+.-]*:", url, re.I) and not url.startswith("https://") and not url.startswith("http://"):
                    self.err(where, f"disallowed link scheme in {rel}: {url}")
                elif not re.match(r"^https?://", url):
                    try:
                        target = L.safe_relative_path(url.split("#")[0])
                    except ValueError:
                        self.err(where, f"link escapes package in {rel}: {url}")
                        continue
                    base = (Path(rel).parent / Path(*target.parts)).as_posix()
                    if not (self.packages[self.current_id].path / base).exists():
                        self.err(where, f"broken relative link in {rel}: {url}")
        for pat in L.PLACEHOLDER_PATTERNS:
            if pat.search(text):
                self.err(where, f"placeholder text '{pat.pattern}' found in {rel}")

    def validate_entrypoint(self, pkg: L.Package, where: str):
        rtype = pkg.type
        text = pkg.entry_text
        fm, body = L.split_frontmatter(text)
        if rtype in ("agent", "skill"):
            if fm is None:
                self.err(where, f"{L.ENTRYPOINTS[rtype]} must start with YAML frontmatter (name, description)")
            else:
                if fm.get("name") != pkg.id:
                    self.err(where, f"frontmatter name must equal the resource id '{pkg.id}'")
                desc = fm.get("description")
                if not isinstance(desc, str) or not (20 <= len(desc) <= 1024):
                    self.err(where, "frontmatter description must be 20-1024 characters")
        h1 = re.findall(r"^# \S", L.strip_fences(body), re.M)
        if len(h1) != 1:
            self.err(where, f"entrypoint must contain exactly one H1 heading (found {len(h1)})")
        secs = L.sections(body)
        for required in L.REQUIRED_SECTIONS.get(rtype, []):
            content = L.find_section(secs, required)
            if content is None:
                self.err(where, f"missing required section '## {required}'")
            elif L.word_count(content) < 12:
                self.err(where, f"section '## {required}' is too thin")
        words = L.word_count(body)
        if words < L.MIN_WORDS.get(rtype, 0):
            self.err(where, f"entrypoint has {words} words; {rtype} packages need at least {L.MIN_WORDS[rtype]}")

        if rtype == "agent":
            proc = L.find_section(secs, "Operating procedure") or ""
            if L.numbered_items(proc) < 5:
                self.err(where, "Operating procedure needs at least 5 numbered steps")
            ex = L.find_section(secs, "Example prompts") or ""
            if L.bullet_items(ex) < 3:
                self.err(where, "Example prompts needs at least 3 examples")
        elif rtype == "skill":
            proc = L.find_section(secs, "Procedure") or ""
            if L.numbered_items(proc) < 4:
                self.err(where, "Procedure needs at least 4 numbered steps")
        elif rtype == "prompt":
            prompt = L.find_section(secs, "Prompt") or ""
            block = re.search(r"```[a-z]*\n(.*?)```", prompt, re.S)
            if not block:
                self.err(where, "Prompt section must contain the copy-ready prompt in a fenced code block")
            else:
                if L.word_count(block.group(1)) < 80:
                    self.err(where, "copy-ready prompt is shorter than 80 words")
                used = set(L.PLACEHOLDER_VAR.findall(block.group(1)))
                variables = L.find_section(secs, "Variables") or ""
                if not used:
                    self.err(where, "prompt must use at least one {{PLACEHOLDER}} input")
                for var in sorted(used):
                    if var not in variables:
                        self.err(where, f"placeholder {{{{{var}}}}} is not documented in Variables")
        elif rtype == "routine":
            steps = L.find_section(secs, "Steps") or ""
            if L.numbered_items(steps) < 5:
                self.err(where, "Steps needs at least 5 numbered steps")
            checklist = L.find_section(secs, "Validation checklist") or ""
            if len(re.findall(r"^\s*- \[ \]", checklist, re.M)) < 4:
                self.err(where, "Validation checklist needs at least 4 '- [ ]' items")

    # ------------------------------------------------------------ global
    def validate_relationships(self):
        ids = set(self.packages)
        for rid, pkg in self.packages.items():
            where = pkg.path.relative_to(self.root).as_posix()
            for key in ("dependencies", "related"):
                for ref in pkg.manifest.get(key) or []:
                    if ref == rid:
                        self.err(where, f"{key} must not reference the resource itself")
                    elif ref not in ids:
                        self.err(where, f"{key} references unknown resource '{ref}'")
                    elif key == "dependencies" and L.is_published(pkg.manifest) and not L.is_published(self.packages[ref].manifest):
                        self.err(where, f"published resource depends on unpublished resource '{ref}'")
            # Supporting skills named in an agent must be declared as dependencies or related.
            if pkg.type == "agent":
                secs = L.sections(L.split_frontmatter(pkg.entry_text)[1])
                support = L.find_section(secs, "Supporting skills") or ""
                for ref in re.findall(r"`([a-z0-9]+(?:-[a-z0-9]+)+)`", support):
                    if ref in ids and ref not in (pkg.manifest.get("dependencies") or []) + (pkg.manifest.get("related") or []):
                        self.warn(where, f"supporting skill '{ref}' is not listed in dependencies or related")
        # Dependency cycles.
        graph = {rid: list(p.manifest.get("dependencies") or []) for rid, p in self.packages.items()}
        state = {}

        def visit(node, stack):
            state[node] = 1
            for nxt in graph.get(node, []):
                if state.get(nxt) == 1:
                    self.err(f"resources/{node}", f"dependency cycle: {' -> '.join(stack + [nxt])}")
                elif nxt in graph and state.get(nxt) is None:
                    visit(nxt, stack + [nxt])
            state[node] = 2

        for node in graph:
            if state.get(node) is None:
                visit(node, [node])

    def validate_duplicates(self):
        items = [(rid, p) for rid, p in self.packages.items() if p.entry_text]
        shingle_map = {rid: L.shingles(L.normalize_for_similarity(p.entry_text)) for rid, p in items}
        desc_map = {rid: set(re.findall(r"[a-z0-9]+", p.manifest.get("description", "").lower())) for rid, p in items}
        hashes = defaultdict(list)
        for rid, p in items:
            hashes[L.sha256_bytes(p.entry_text.encode())].append(rid)
        for ids in hashes.values():
            if len(ids) > 1:
                self.err("resources", f"identical entrypoint content: {', '.join(ids)}")
        names = defaultdict(list)
        for rid, p in self.packages.items():
            names[str(p.manifest.get("name", "")).strip().lower()].append(rid)
        for name, ids in names.items():
            if len(ids) > 1:
                self.err("resources", f"duplicate resource name '{name}': {', '.join(ids)}")
        rids = sorted(shingle_map)
        for i, a in enumerate(rids):
            for b in rids[i + 1:]:
                sim = L.jaccard(shingle_map[a], shingle_map[b])
                if sim >= DUPLICATE_CONTENT_THRESHOLD:
                    self.err("resources", f"near-duplicate content ({sim:.0%} overlap): {a} and {b}")
                dsim = L.jaccard(desc_map[a], desc_map[b])
                if dsim >= DUPLICATE_DESCRIPTION_THRESHOLD:
                    self.warn("resources", f"very similar descriptions ({dsim:.0%}): {a} and {b}")

    def validate_contributors(self):
        croot = self.root / "contributors"
        authors = {p.manifest.get("author", {}).get("github") for p in self.packages.values()}
        if not croot.exists():
            return
        for d in sorted(x for x in croot.iterdir() if x.is_dir()):
            profile = d / "profile.yaml"
            where = profile.relative_to(self.root).as_posix()
            if not profile.is_file():
                self.err(where, "contributor directory must contain profile.yaml")
                continue
            try:
                data = L.load_yaml(profile)
            except Exception as exc:
                self.err(where, f"invalid YAML: {exc}")
                continue
            for msg in L.schema_errors(data, self.contributor_schema):
                self.err(where, f"schema: {msg}")
            if isinstance(data, dict):
                if data.get("github") != d.name:
                    self.err(where, "github username must match the profile directory name")
                if d.name not in authors:
                    self.warn(where, "profile has no resources attributed to it yet")
                for ref in data.get("featured_resource_ids") or []:
                    pkg = self.packages.get(ref)
                    if pkg is None:
                        self.err(where, f"featured resource '{ref}' does not exist")
                    elif pkg.manifest.get("author", {}).get("github") != d.name:
                        self.err(where, f"featured resource '{ref}' is not authored by {d.name}")

    def validate_collections(self):
        path = self.root / "catalog" / "collections.yaml"
        if not path.exists():
            self.warn("catalog/collections.yaml", "no collections defined")
            return
        try:
            data = L.load_yaml(path)
        except Exception as exc:
            self.err("catalog/collections.yaml", f"invalid YAML: {exc}")
            return
        for msg in L.schema_errors(data, self.collections_schema):
            self.err("catalog/collections.yaml", f"schema: {msg}")
        seen = set()
        for col in (data or {}).get("collections", []) or []:
            cid = col.get("id")
            if cid in seen:
                self.err("catalog/collections.yaml", f"duplicate collection id '{cid}'")
            seen.add(cid)
            refs = [r.get("id") for r in col.get("resources", [])]
            if len(refs) != len(set(refs)):
                self.err("catalog/collections.yaml", f"collection '{cid}' lists a resource more than once")
            for ref in refs:
                if ref not in self.packages:
                    self.err("catalog/collections.yaml", f"collection '{cid}' references unknown resource '{ref}'")
                elif not L.is_published(self.packages[ref].manifest):
                    self.err("catalog/collections.yaml", f"collection '{cid}' references unpublished resource '{ref}'")

    # ------------------------------------------------------------ driver
    def run(self, only: set[str] | None = None):
        self.load_packages()
        for rid, pkg in self.packages.items():
            if only and rid not in only:
                # Still load entry text for global duplicate checks.
                entry = (pkg.manifest.get("content") or {}).get("entrypoint")
                if entry and (pkg.path / entry).is_file():
                    pkg.entry_text = (pkg.path / entry).read_text(encoding="utf-8")
                continue
            self.current_id = rid
            self.validate_package(pkg)
        if self.package_only:
            return self.issues
        self.validate_relationships()
        self.validate_duplicates()
        self.validate_contributors()
        self.validate_collections()
        return self.issues


def ids_from_changed_files(root: Path, changed: list[str]) -> set[str]:
    ids = set()
    for line in changed:
        parts = Path(line.strip()).parts
        if len(parts) >= 4 and parts[0] == "resources":
            ids.add(parts[3])
    return ids


def render_report(validator: Validator, only: set[str] | None) -> str:
    errors = [i for i in validator.issues if i.level == "error"]
    warnings = [i for i in validator.issues if i.level == "warning"]
    lines = ["## Skilldeck catalog validation", ""]
    lines.append(f"**Result:** {'❌ failed' if errors else '✅ passed'} — "
                 f"{len(validator.packages)} packages scanned, {len(errors)} error(s), {len(warnings)} warning(s).")
    if only:
        lines.append("")
        lines.append("**Changed resources:** " + ", ".join(f"`{i}`" for i in sorted(only)))
    if errors:
        lines += ["", "### Errors", ""] + [f"- `{i.where}` — {i.message}" for i in errors[:200]]
    if warnings:
        lines += ["", "### Warnings", ""] + [f"- `{i.where}` — {i.message}" for i in warnings[:100]]
    lines.append("")
    lines.append("Passing CI means the package is structurally valid. Maintainers still review quality, licensing, and safety before merging.")
    return "\n".join(lines) + "\n"


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--root", type=Path, default=L.ROOT)
    ap.add_argument("--only", nargs="*", help="limit per-package checks to these resource ids")
    ap.add_argument("--changed-files", type=Path, help="file with changed paths, one per line")
    ap.add_argument("--report", type=Path, help="write a Markdown report here")
    ap.add_argument("--strict", action="store_true", help="treat warnings as errors")
    ap.add_argument("--quiet", action="store_true")
    ap.add_argument("--package-only", action="store_true",
                    help="skip cross-package checks (relationships, duplicates, collections); for drafting")
    args = ap.parse_args(argv)

    only = set(args.only) if args.only else None
    if args.changed_files:
        only = ids_from_changed_files(args.root, args.changed_files.read_text().splitlines()) or None
    v = Validator(args.root.resolve())
    v.package_only = args.package_only
    issues = v.run(only)
    errors = [i for i in issues if i.level == "error"]
    warnings = [i for i in issues if i.level == "warning"]
    if not args.quiet:
        for issue in issues:
            print(issue)
    counts = defaultdict(int)
    for p in v.packages.values():
        counts[p.type] += 1
    summary = ", ".join(f"{counts[t]} {t}s" for t in ("agent", "skill", "prompt", "routine") if counts[t])
    print(f"\nScanned {len(v.packages)} package(s) ({summary or 'none'}): {len(errors)} error(s), {len(warnings)} warning(s).")
    if args.report:
        args.report.write_text(render_report(v, only), encoding="utf-8")
    if errors or (args.strict and warnings):
        print("VALIDATION FAILED")
        return 1
    print("VALIDATION PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
