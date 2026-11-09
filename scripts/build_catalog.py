#!/usr/bin/env python3
"""Build the distributable Skilldeck catalog from approved resource packages.

Outputs (in --out, default dist/):
  catalog.json          index: metadata, hashes, contributors, collections (no file bodies)
  catalog-bundle.json   the same plus every file's text content - what the app bundles and downloads
  latest.json           release pointer with bundle hash and changelog, polled by the app
  packages/<id>-<version>.zip   one deterministic ZIP per resource
  CHANGES.md            human-readable changelog for the release notes

The build is deterministic: identical inputs produce byte-identical outputs.
Set SOURCE_DATE_EPOCH to pin generated_at; otherwise the newest `updated` date is used.
Never executes contributor content.
"""
from __future__ import annotations

import argparse
import io
import json
import os
import shutil
import sys
import zipfile
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import catalog_lib as L  # noqa: E402

CATALOG_FORMAT = "1.1"
ZIP_EPOCH = (1980, 1, 1, 0, 0, 0)


def deterministic_zip(package: Path, rid: str, files: list[str]) -> bytes:
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        for rel in sorted(files):
            info = zipfile.ZipInfo(f"{rid}/{rel}", date_time=ZIP_EPOCH)
            info.external_attr = 0o100644 << 16
            info.compress_type = zipfile.ZIP_DEFLATED
            info.create_system = 3
            zf.writestr(info, (package / rel).read_bytes())
    return buf.getvalue()


def content_hash(files: list[dict]) -> str:
    """Package integrity hash: SHA-256 over sorted 'path\\0sha256\\n' lines."""
    lines = "".join(f"{f['path']}\0{f['sha256']}\n" for f in sorted(files, key=lambda f: f["path"]))
    return L.sha256_bytes(lines.encode("utf-8"))


def search_text(m: dict, domain_name: str) -> str:
    parts = [m.get("name", ""), m.get("description", ""), m.get("purpose", ""), domain_name,
             " ".join(m.get("use_cases") or []), " ".join(m.get("tags") or []),
             m.get("author", {}).get("name", ""), m.get("author", {}).get("github", ""), m.get("type", ""),
             " ".join(c.get("platform", "") for c in m.get("compatibility") or [])]
    return " ".join(p.replace("-", " ") for p in parts if p).lower()


def resolve_generated_at(resources: list[dict]) -> str:
    epoch = os.environ.get("SOURCE_DATE_EPOCH")
    if epoch:
        return datetime.fromtimestamp(int(epoch), tz=timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    dates = [r.get("updated") or r.get("created") for r in resources if r.get("updated") or r.get("created")]
    return f"{max(dates)}T00:00:00Z" if dates else "1970-01-01T00:00:00Z"


def aggregate_contributors(root: Path, resources: list[dict]) -> list[dict]:
    by_user: dict[str, list[dict]] = defaultdict(list)
    for r in resources:
        gh = r["author"].get("github")
        if gh:
            by_user[gh].append(r)
    contributors = []
    for gh in sorted(by_user, key=str.lower):
        items = by_user[gh]
        profile_path = root / "contributors" / gh / "profile.yaml"
        profile = L.load_yaml(profile_path) if profile_path.is_file() else {}
        names = Counter(r["author"]["name"] for r in items)
        featured = [i for i in (profile.get("featured_resource_ids") or []) if any(r["id"] == i for r in items)]
        contributors.append({
            "github": gh,
            "display_name": profile.get("display_name") or names.most_common(1)[0][0],
            "bio": (profile.get("bio") or "").strip() or None,
            "website": profile.get("website"),
            "location": profile.get("location"),
            "social_links": profile.get("social_links") or [],
            "avatar_url": L.github_avatar_url(gh),
            "profile_url": L.github_profile_url(gh),
            "has_profile": profile_path.is_file(),
            "resource_ids": sorted(r["id"] for r in items),
            "resource_count": len(items),
            "counts_by_type": dict(sorted(Counter(r["type"] for r in items).items())),
            "domains": sorted({r["domain"] for r in items}),
            "first_published": min(r.get("created") or "" for r in items) or None,
            "last_updated": max(r.get("updated") or "" for r in items) or None,
            "featured_resource_ids": featured,
        })
    contributors.sort(key=lambda c: (-c["resource_count"], c["github"].lower()))
    return contributors


def diff_catalogs(previous: dict | None, resources: list[dict]) -> dict:
    if not previous:
        return {"previous_version": None, "added": sorted(r["id"] for r in resources), "updated": [], "removed": []}
    old = {r["id"]: r for r in previous.get("resources", [])}
    new = {r["id"]: r for r in resources}
    added = sorted(set(new) - set(old))
    removed = sorted(set(old) - set(new))
    updated = sorted(i for i in set(new) & set(old)
                     if new[i]["version"] != old[i].get("version") or new[i]["content_sha256"] != old[i].get("content_sha256"))
    return {"previous_version": previous.get("catalog_version"), "added": added, "updated": updated, "removed": removed}


def build(root: Path, out: Path, previous: dict | None = None, repo: str | None = None) -> dict:
    meta = L.load_yaml(root / "catalog" / "catalog.yaml")
    taxonomy = L.load_taxonomy(root)
    registry = L.load_registry(root)
    repo = repo or os.environ.get("GITHUB_REPOSITORY") or meta.get("repository", "OWNER/REPO")
    version = meta["catalog_version"]
    release_base = f"https://github.com/{repo}/releases/download/catalog-v{version}"

    collections_doc = L.load_yaml(root / "catalog" / "collections.yaml") if (root / "catalog" / "collections.yaml").exists() else {"collections": []}
    membership = defaultdict(list)
    for col in collections_doc.get("collections", []):
        for item in col.get("resources", []):
            membership[item["id"]].append(col["id"])

    if out.exists():
        shutil.rmtree(out)
    (out / "packages").mkdir(parents=True)

    resources, bundle_resources = [], []
    for manifest_path in L.iter_manifests(root / "resources"):
        package = manifest_path.parent
        m = L.load_yaml(manifest_path)
        if not isinstance(m, dict) or m.get("status") != "approved":
            continue
        rid = m["id"]
        rels = sorted(p.relative_to(package).as_posix() for p in package.rglob("*") if p.is_file() and not p.is_symlink())
        files, bodies = [], []
        for rel in rels:
            data = (package / rel).read_bytes()
            files.append({"path": rel, "size": len(data), "sha256": L.sha256_bytes(data)})
            bodies.append(data.decode("utf-8"))
        archive = deterministic_zip(package, rid, rels)
        archive_name = f"{rid}-{m['version']}.zip"
        (out / "packages" / archive_name).write_bytes(archive)
        domain_name = taxonomy.get(m["domain"], {}).get("name", m["domain"])
        entry = {
            "id": rid,
            "type": m["type"],
            "name": m["name"],
            "description": " ".join(m["description"].split()),
            "purpose": " ".join((m.get("purpose") or "").split()) or None,
            "version": m["version"],
            "license": m["license"],
            "domain": m["domain"],
            "use_cases": m["use_cases"],
            "tags": m["tags"],
            "author": {k: v for k, v in m["author"].items()},
            "created": m.get("created"),
            "updated": m.get("updated"),
            "featured": bool(m.get("featured", False)),
            "dependencies": m.get("dependencies") or [],
            "related": m.get("related") or [],
            "compatibility": m["compatibility"],
            "safety": m.get("safety") or {},
            "tested": bool(m.get("tested", False)),
            "tested_with": m.get("tested_with") or [],
            "changelog": m.get("changelog") or [],
            "entrypoint": m["content"]["entrypoint"],
            "collections": sorted(membership.get(rid, [])),
            "source_path": package.relative_to(root).as_posix(),
            "files": files,
            "content_sha256": content_hash(files),
            "package": {"filename": archive_name, "size": len(archive), "sha256": L.sha256_bytes(archive),
                        "url": f"{release_base}/{archive_name}"},
            "search_text": search_text(m, domain_name),
        }
        resources.append(entry)
        bundle_entry = json.loads(json.dumps(entry))
        for f, body in zip(bundle_entry["files"], bodies):
            f["content"] = body
        bundle_resources.append(bundle_entry)

    resources.sort(key=lambda r: r["id"])
    bundle_resources.sort(key=lambda r: r["id"])
    contributors = aggregate_contributors(root, resources)
    collections = []
    for col in collections_doc.get("collections", []):
        c = dict(col)
        c["resources"] = [dict(r) for r in col["resources"] if any(x["id"] == r["id"] for x in resources)]
        c["featured"] = bool(col.get("featured", False))
        collections.append(c)
    changes = diff_catalogs(previous, resources)
    generated_at = resolve_generated_at(resources)

    payload = {
        "schema_version": CATALOG_FORMAT,
        "catalog_id": meta["catalog_id"],
        "name": meta["name"],
        "description": meta["description"],
        "catalog_version": version,
        "generated_at": generated_at,
        "minimum_app_version": meta.get("minimum_app_version", "1.0.0"),
        "repository": f"https://github.com/{repo}",
        "resources_count": len(resources),
        "contributors_count": len(contributors),
        "collections_count": len(collections),
        "stats": {
            "by_type": dict(sorted(Counter(r["type"] for r in resources).items())),
            "by_domain": dict(sorted(Counter(r["domain"] for r in resources).items())),
        },
        "changes": changes,
        "domains": [{"id": d["id"], "name": d["name"], "symbol": d.get("symbol", "square.grid.2x2"),
                     "use_cases": d.get("use_cases", [])} for d in taxonomy.values()],
        "platforms": registry.get("platforms", []),
        "resources": resources,
        "contributors": contributors,
        "collections": collections,
    }
    index_bytes = (json.dumps(payload, indent=2, ensure_ascii=False, sort_keys=False) + "\n").encode("utf-8")
    (out / "catalog.json").write_bytes(index_bytes)
    bundle = dict(payload, resources=bundle_resources)
    bundle_bytes = (json.dumps(bundle, ensure_ascii=False, separators=(",", ":")) + "\n").encode("utf-8")
    (out / "catalog-bundle.json").write_bytes(bundle_bytes)

    latest = {
        "schema_version": CATALOG_FORMAT,
        "catalog_id": meta["catalog_id"],
        "catalog_version": version,
        "generated_at": generated_at,
        "minimum_app_version": payload["minimum_app_version"],
        "resources_count": len(resources),
        "bundle": {"url": f"{release_base}/catalog-bundle.json", "sha256": L.sha256_bytes(bundle_bytes), "size": len(bundle_bytes)},
        "index": {"url": f"{release_base}/catalog.json", "sha256": L.sha256_bytes(index_bytes), "size": len(index_bytes)},
        "release_notes_url": f"https://github.com/{repo}/releases/tag/catalog-v{version}",
        "changes": changes,
    }
    (out / "latest.json").write_text(json.dumps(latest, indent=2) + "\n", encoding="utf-8")

    notes = [f"# Skilldeck Catalog {version}", "",
             f"{len(resources)} resources · {len(contributors)} contributor(s) · {len(collections)} collections", ""]
    for key, label in (("added", "Added"), ("updated", "Updated"), ("removed", "Removed")):
        ids = changes[key]
        notes.append(f"## {label} ({len(ids)})")
        notes += [f"- `{i}`" for i in ids[:400]] or ["- None"]
        notes.append("")
    (out / "CHANGES.md").write_text("\n".join(notes), encoding="utf-8")
    return payload


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--root", type=Path, default=L.ROOT)
    ap.add_argument("--out", type=Path, default=None)
    ap.add_argument("--previous", type=Path, help="previous release's catalog.json, for the changelog")
    ap.add_argument("--repo", help="owner/name used in download URLs")
    args = ap.parse_args(argv)
    root = args.root.resolve()
    out = (args.out or root / "dist").resolve()
    previous = L.load_json(args.previous) if args.previous and args.previous.exists() else None
    payload = build(root, out, previous, args.repo)
    print(f"Built catalog {payload['catalog_version']}: {payload['resources_count']} resources, "
          f"{payload['contributors_count']} contributors, {payload['collections_count']} collections -> {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
