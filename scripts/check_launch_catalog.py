#!/usr/bin/env python3
"""Launch gate: fail unless the published, valid catalog meets catalog/launch_requirements.yaml.

Only published packages that pass full validation are counted. This script must
never be weakened to make an incomplete catalog pass.

    python3 scripts/check_launch_catalog.py
"""
from __future__ import annotations

import argparse
import sys
from collections import Counter
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import catalog_lib as L  # noqa: E402
from validate_catalog import Validator  # noqa: E402


def check(root: Path) -> tuple[list[str], dict]:
    req = L.load_yaml(root / "catalog" / "launch_requirements.yaml")
    v = Validator(root)
    issues = v.run()
    errors_by_package = Counter()
    for issue in issues:
        if issue.level == "error":
            errors_by_package[issue.where] += 1
    failures: list[str] = []
    global_errors = [i for i in issues if i.level == "error" and not i.where.startswith("resources/")]
    if global_errors:
        failures.append(f"{len(global_errors)} catalog-level validation error(s) (collections, contributors, duplicates)")

    complete = {}
    for rid, pkg in v.packages.items():
        where = pkg.path.relative_to(root).as_posix()
        if not L.is_published(pkg.manifest):
            continue
        if errors_by_package.get(where):
            failures.append(f"{rid}: {errors_by_package[where]} validation error(s); not counted")
            continue
        complete[rid] = pkg

    by_type = Counter(p.type for p in complete.values())
    by_domain_type = Counter((p.manifest["domain"], p.type) for p in complete.values())
    total = len(complete)
    if total < req["minimum_total"]:
        failures.append(f"total published complete resources {total} < {req['minimum_total']}")
    for rtype, minimum in req["minimum_by_type"].items():
        if by_type[rtype] < minimum:
            failures.append(f"{rtype}s: {by_type[rtype]} < {minimum}")
    for domain, targets in req["domain_distribution"].items():
        for rtype, minimum in targets.items():
            have = by_domain_type[(domain, rtype)]
            if have < minimum:
                failures.append(f"{domain} {rtype}s: {have} < {minimum}")

    cols = (L.load_yaml(root / "catalog" / "collections.yaml") or {}).get("collections", []) if (root / "catalog" / "collections.yaml").exists() else []
    col_ids = {c["id"] for c in cols}
    if len(cols) < req["minimum_collections"]:
        failures.append(f"collections: {len(cols)} < {req['minimum_collections']}")
    for cid in req["required_collections"]:
        if cid not in col_ids:
            failures.append(f"required collection missing: {cid}")
    for c in cols:
        missing = [r["id"] for r in c["resources"] if r["id"] not in complete]
        if missing:
            failures.append(f"collection {c['id']} references incomplete/unknown resources: {', '.join(missing)}")

    summary = {"total": total, "by_type": dict(by_type), "collections": len(cols),
               "by_domain_type": {f"{d}/{t}": n for (d, t), n in sorted(by_domain_type.items())}}
    return failures, summary


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--root", type=Path, default=L.ROOT)
    args = ap.parse_args(argv)
    failures, summary = check(args.root.resolve())
    print("Skilldeck launch catalog check")
    print(f"  published & complete: {summary['total']}")
    for t in ("agent", "skill", "prompt", "routine"):
        print(f"  {t + 's':<9} {summary['by_type'].get(t, 0)}")
    print(f"  collections: {summary['collections']}")
    if failures:
        print(f"\nLAUNCH CHECK FAILED ({len(failures)} problem(s)):")
        for f in failures[:300]:
            print(f"  - {f}")
        return 1
    print("\nLAUNCH CHECK PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
