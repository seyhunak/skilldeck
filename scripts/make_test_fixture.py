#!/usr/bin/env python3
"""Regenerate the small catalog fixture used by the Swift tests.

    python3 scripts/make_test_fixture.py
"""
import os
import shutil
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
import build_catalog  # noqa: E402
import catalog_lib as L  # noqa: E402
import yaml  # noqa: E402

IDS = ["repository-intelligence-agent", "git-history-forensics", "explain-unfamiliar-code-prompt",
       "new-codebase-onboarding-routine", "code-complexity-analysis", "rag-evaluation-agent"]
OUT = ROOT / "app" / "Tests" / "SkilldeckCoreTests" / "Fixtures"


def main():
    os.environ.setdefault("SOURCE_DATE_EPOCH", "1794182400")
    tmp = Path(tempfile.mkdtemp())
    try:
        for sub in ("catalog", "schemas", "contributors"):
            shutil.copytree(ROOT / sub, tmp / sub)
        for mp in (ROOT / "resources").rglob("manifest.yaml"):
            if mp.parent.name in IDS:
                dest = tmp / mp.parent.relative_to(ROOT)
                shutil.copytree(mp.parent, dest)
                m = L.load_yaml(dest / "manifest.yaml")
                m["dependencies"] = [d for d in m.get("dependencies") or [] if d in IDS]
                m["related"] = [d for d in m.get("related") or [] if d in IDS]
                (dest / "manifest.yaml").write_text(yaml.safe_dump(m, sort_keys=False, allow_unicode=True))
        meta = L.load_yaml(tmp / "catalog" / "catalog.yaml")
        (tmp / "catalog" / "collections.yaml").write_text(yaml.safe_dump({"schema_version": "1.0", "collections": [{
            "id": "fixture-toolkit", "title": "Fixture Toolkit", "description": "Collection used by the Swift test fixture catalog.",
            "audience": "Tests", "use_cases": ["repository-analysis"], "symbol": "hammer", "accent": "blue",
            "resources": [{"id": i, "step": n + 1} for n, i in enumerate(IDS)]}]}))
        for version in ("1.0.0", "1.1.0"):
            meta["catalog_version"] = version
            (tmp / "catalog" / "catalog.yaml").write_text(yaml.safe_dump(meta, sort_keys=False))
            build_catalog.build(tmp, tmp / f"dist-{version}", repo="seyhunak/skilldeck")
        OUT.mkdir(parents=True, exist_ok=True)
        shutil.copy(tmp / "dist-1.0.0" / "catalog-bundle.json", OUT / "catalog-1.0.0.json")
        shutil.copy(tmp / "dist-1.1.0" / "catalog-bundle.json", OUT / "catalog-1.1.0.json")
        print(f"Wrote fixtures to {OUT}")
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    main()
