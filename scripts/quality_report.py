#!/usr/bin/env python3
"""Score every resource against objective quality criteria and write a Markdown report.

Criteria (each 0-4, see docs/REVIEW_POLICY.md):
  specificity    concrete artefacts: numbered steps, tables, templates, named methods
  completeness   required sections present and substantive
  usefulness     a copy-ready deliverable template or prompt exists
  reusability    no environment-specific assumptions; inputs are declared
  distinctiveness  maximum content overlap with any other resource
  output_clarity expected output is structured (template, table, or schema)
  error_handling failure modes and limitations are spelled out
  safety         safety boundaries / human approval language present
  compatibility  declared compatibility matches the registry

These are heuristics that flag resources for human review; they do not replace it.

    python3 scripts/quality_report.py --out reports/quality-report.md
"""
from __future__ import annotations

import argparse
import re
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import catalog_lib as L  # noqa: E402

CRITERIA = ["specificity", "completeness", "usefulness", "reusability", "distinctiveness",
            "output_clarity", "error_handling", "safety", "compatibility"]
SAFETY_WORDS = re.compile(r"\b(approval|approve|consent|never|do not|must not|read-only|confirm|sign-off|human)\b", re.I)
ERROR_WORDS = re.compile(r"\b(if|when|missing|incomplete|fail|unavailable|ambiguous|conflict|limitation)\b", re.I)


def clamp(x: float) -> int:
    return max(0, min(4, int(round(x))))


def score(pkg: L.Package, overlap: float, max_levels: dict) -> dict:
    text = pkg.entry_text
    _, body = L.split_frontmatter(text)
    secs = L.sections(body)
    rtype = pkg.type
    req = L.REQUIRED_SECTIONS.get(rtype, [])
    present = [r for r in req if (L.find_section(secs, r) or "") and L.word_count(L.find_section(secs, r)) >= 25]
    steps = L.numbered_items(body)
    tables = len(re.findall(r"^\|.*\|\s*$", body, re.M))
    fences = sum(1 for line in body.splitlines() if line.lstrip().startswith("```")) // 2
    s = {}
    s["specificity"] = clamp(steps / 5 + tables / 6 + fences)
    s["completeness"] = clamp(4 * len(present) / max(1, len(req)))
    s["usefulness"] = 4 if fences >= 1 else (2 if tables else 1)
    inputs = L.find_section(secs, "Required inputs") or L.find_section(secs, "Inputs") or L.find_section(secs, "Required context") or ""
    s["reusability"] = clamp(1 + L.bullet_items(inputs) / 2 + (1 if pkg.manifest.get("dependencies") is not None else 0))
    s["distinctiveness"] = 4 if overlap < 0.10 else 3 if overlap < 0.20 else 2 if overlap < 0.30 else 1
    out = L.find_section(secs, "Expected output") or L.find_section(secs, "Output format") or ""
    s["output_clarity"] = clamp(("```" in out) * 2 + ("|" in out) + (L.word_count(out) > 60) + (L.bullet_items(out) >= 3))
    errs = " ".join(filter(None, [L.find_section(secs, h) for h in ("Error handling", "Limitations", "Constraints", "Decision points")]))
    s["error_handling"] = clamp(len(ERROR_WORDS.findall(errs)) / 4)
    saf = " ".join(filter(None, [L.find_section(secs, h) for h in ("Safety boundaries", "Constraints", "Human approval", "Limitations", "Customization")]))
    s["safety"] = clamp(len(SAFETY_WORDS.findall(saf)) / 2 + (1 if (pkg.manifest.get("safety") or {}).get("notes") else 0))
    comp_ok = all(L.LEVELS.index(c["level"]) <= L.LEVELS.index(max_levels.get((c["platform"], rtype), "unverified"))
                  for c in pkg.manifest.get("compatibility") or [])
    s["compatibility"] = 4 if comp_ok else 0
    s["total"] = sum(s[c] for c in CRITERIA)
    s["words"] = L.word_count(body)
    return s


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--root", type=Path, default=L.ROOT)
    ap.add_argument("--out", type=Path, default=None)
    ap.add_argument("--min-score", type=int, default=24, help="flag resources scoring below this (max 36)")
    args = ap.parse_args(argv)
    root = args.root.resolve()
    registry = L.load_registry(root)
    max_levels = L.registry_max_levels(registry)
    pkgs = []
    for mp in L.iter_manifests(root / "resources"):
        m = L.load_yaml(mp)
        entry = mp.parent / m["content"]["entrypoint"]
        pkgs.append(L.Package(mp.parent, m, entry.read_text(encoding="utf-8") if entry.exists() else ""))
    sh = {p.id: L.shingles(L.normalize_for_similarity(p.entry_text)) for p in pkgs}
    overlap = defaultdict(float)
    nearest = {}
    ids = sorted(sh)
    for i, a in enumerate(ids):
        for b in ids[i + 1:]:
            j = L.jaccard(sh[a], sh[b])
            if j > overlap[a]:
                overlap[a], nearest[a] = j, b
            if j > overlap[b]:
                overlap[b], nearest[b] = j, a
    rows = [(p, score(p, overlap[p.id], max_levels)) for p in pkgs]
    rows.sort(key=lambda r: (r[0].manifest["domain"], r[0].type, r[0].id))
    flagged = [(p, s) for p, s in rows if s["total"] < args.min_score]

    lines = ["# Skilldeck content quality report", "",
             f"Resources scored: **{len(rows)}** · Flagged below {args.min_score}/36: **{len(flagged)}**", "",
             "Heuristic scores (0-4 per criterion) highlight resources that need human review. "
             "They complement, not replace, the maintainer review in docs/REVIEW_POLICY.md.", ""]
    by_type = defaultdict(list)
    for p, s in rows:
        by_type[p.type].append(s["total"])
    lines += ["## Averages by type", "", "| Type | Count | Avg score | Min | Avg words |", "|---|---:|---:|---:|---:|"]
    for t, totals in sorted(by_type.items()):
        words = [s["words"] for p, s in rows if p.type == t]
        lines.append(f"| {t} | {len(totals)} | {sum(totals)/len(totals):.1f} | {min(totals)} | {sum(words)//len(words)} |")
    lines += ["", "## Flagged for review", ""]
    lines += [f"- `{p.id}` ({p.type}) — {s['total']}/36; weakest: " +
              ", ".join(c for c in CRITERIA if s[c] <= 1) for p, s in flagged] or ["- None"]
    lines += ["", "## All resources", "",
              "| Resource | Type | Domain | Words | " + " | ".join(c.replace("_", " ") for c in CRITERIA) + " | Total | Nearest (overlap) |",
              "|---|---|---|---:|" + "---:|" * len(CRITERIA) + "---:|---|"]
    for p, s in rows:
        near = f"{nearest.get(p.id, '-')} ({overlap[p.id]:.0%})"
        lines.append(f"| `{p.id}` | {p.type} | {p.manifest['domain']} | {s['words']} | " +
                     " | ".join(str(s[c]) for c in CRITERIA) + f" | {s['total']} | {near} |")
    report = "\n".join(lines) + "\n"
    if args.out:
        args.out.parent.mkdir(parents=True, exist_ok=True)
        args.out.write_text(report, encoding="utf-8")
        print(f"Wrote {args.out} ({len(rows)} resources, {len(flagged)} flagged)")
    else:
        print(report)
    return 0


if __name__ == "__main__":
    sys.exit(main())
