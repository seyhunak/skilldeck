"""Shared, side-effect-free helpers for the Skilldeck catalog tooling.

Everything here treats contributor content as untrusted data: YAML is loaded
with ``yaml.safe_load``, Markdown is parsed as text, and nothing from a
package is ever executed.
"""
from __future__ import annotations

import hashlib
import json
import re
from dataclasses import dataclass, field
from pathlib import Path, PurePosixPath
from typing import Iterable

import yaml

try:  # jsonschema is a declared dependency, but keep a readable error if absent.
    import jsonschema
except ImportError:  # pragma: no cover
    jsonschema = None

ROOT = Path(__file__).resolve().parents[1]

ENTRYPOINTS = {
    "agent": "agent.md",
    "skill": "SKILL.md",
    "prompt": "prompt.md",
    "routine": "routine.md",
    "instruction": "instructions.md",
}

# Required H2 sections per resource type, matched case-insensitively by prefix.
REQUIRED_SECTIONS = {
    "agent": [
        "Purpose", "When to use", "Required inputs", "Operating procedure",
        "Expected output", "Supporting skills", "Example prompts",
        "Error handling", "Limitations", "Safety boundaries",
    ],
    "skill": [
        "When to use", "Inputs", "Procedure", "Expected output",
        "Constraints",
    ],
    "prompt": [
        "Intended task", "Required context", "Prompt", "Variables",
        "Output format", "Example usage", "Customization",
    ],
    "routine": [
        "Objective", "Trigger", "Prerequisites", "Inputs", "Steps",
        "Decision points", "Expected output", "Validation checklist",
        "Human approval",
    ],
    "instruction": ["Scope", "Rules"],
}

# Minimum words in the entrypoint. A quality floor, not a target.
MIN_WORDS = {"agent": 650, "skill": 400, "prompt": 300, "routine": 400, "instruction": 150}

LEVELS = ["not_supported", "unverified", "copy_paste", "generic_export",
          "file_export", "native_import", "native_install"]

ALLOWED_SUFFIXES = {".md", ".markdown", ".txt", ".yaml", ".yml", ".json", ".csv"}
MAX_FILE_BYTES = 512 * 1024
MAX_PACKAGE_BYTES = 2 * 1024 * 1024
MAX_PACKAGE_FILES = 60

# Domains whose resources must carry an explicit professional-advice disclaimer.
REGULATED_DOMAINS = {"finance-banking", "security-compliance"}
REGULATED_TAGS = {"healthcare", "medical", "legal", "law", "tax", "investment"}

PLACEHOLDER_PATTERNS = [
    re.compile(r"^\s*(?:[-*]\s*)?(?:TODO|TBD|FIXME)\b", re.M),
    re.compile(r"lorem ipsum", re.I),
    re.compile(r"replace[- ]with[- ](?:your|unique|the actual|real)", re.I),
    re.compile(r"your-github-handle|your-(?:agent|skill|prompt|routine)-id"),
]
SECRET_PATTERNS = [
    re.compile(r"sk-ant-[A-Za-z0-9_-]{20,}"),
    re.compile(r"sk-[A-Za-z0-9]{32,}"),
    re.compile(r"gh[pousr]_[A-Za-z0-9]{30,}"),
    re.compile(r"AKIA[0-9A-Z]{16}"),
    re.compile(r"xox[baprs]-[A-Za-z0-9-]{10,}"),
    re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----"),
]
UNSAFE_HTML = re.compile(r"<\s*(script|iframe|object|embed|form|style|link|meta)\b", re.I)
URL_RE = re.compile(r"\]\(([^)\s]+)\)|<(https?://[^>]+)>")
PLACEHOLDER_VAR = re.compile(r"\{\{\s*([A-Z][A-Z0-9_]*)\s*\}\}")


@dataclass
class Issue:
    level: str  # "error" | "warning"
    where: str
    message: str

    def __str__(self) -> str:
        return f"[{self.level.upper()}] {self.where}: {self.message}"


@dataclass
class Package:
    path: Path
    manifest: dict
    entry_text: str = ""
    files: list = field(default_factory=list)  # relative posix paths

    @property
    def id(self) -> str:
        return self.manifest.get("id", "")

    @property
    def type(self) -> str:
        return self.manifest.get("type", "")


# --------------------------------------------------------------------------- io

def load_yaml(path: Path):
    with path.open("r", encoding="utf-8") as fh:
        return yaml.safe_load(fh)


def load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def safe_relative_path(value: str) -> PurePosixPath:
    if not isinstance(value, str) or not value or "\\" in value or "\x00" in value:
        raise ValueError(f"Unsafe package path: {value!r}")
    p = PurePosixPath(value)
    if p.is_absolute() or ".." in p.parts or not p.parts or p.parts[0].startswith("~"):
        raise ValueError(f"Unsafe package path: {value!r}")
    return p


def iter_manifests(resource_root: Path) -> Iterable[Path]:
    if not resource_root.exists():
        return []
    return sorted(resource_root.rglob("manifest.yaml"))


def package_files(package: Path) -> list[Path]:
    return sorted(p for p in package.rglob("*") if p.is_file() or p.is_symlink())


# ----------------------------------------------------------------- markdown

def split_frontmatter(text: str) -> tuple[dict | None, str]:
    if not text.startswith("---\n"):
        return None, text
    end = text.find("\n---", 4)
    if end == -1:
        return None, text
    raw = text[4:end]
    body = text[end + 4:].lstrip("\n")
    try:
        data = yaml.safe_load(raw)
    except yaml.YAMLError:
        return None, text
    return (data if isinstance(data, dict) else None), body


def sections(markdown: str) -> dict[str, str]:
    """Return {h2 heading: body} for a Markdown document, ignoring fenced code."""
    result: dict[str, str] = {}
    current = None
    buf: list[str] = []
    in_fence = False
    for line in markdown.splitlines():
        if line.lstrip().startswith("```"):
            in_fence = not in_fence
        if not in_fence and line.startswith("## "):
            if current is not None:
                result[current] = "\n".join(buf).strip()
            current = line[3:].strip()
            buf = []
        elif current is not None:
            buf.append(line)
    if current is not None:
        result[current] = "\n".join(buf).strip()
    return result


def find_section(secs: dict[str, str], wanted: str) -> str | None:
    w = wanted.lower()
    for heading, body in secs.items():
        if heading.lower().startswith(w):
            return body
    return None


def strip_fences(text: str) -> str:
    out, in_fence = [], False
    for line in text.splitlines():
        if line.lstrip().startswith("```"):
            in_fence = not in_fence
            continue
        if not in_fence:
            out.append(line)
    return "\n".join(out)


def word_count(text: str) -> int:
    return len(re.findall(r"[A-Za-z0-9][A-Za-z0-9'’-]*", text))


def numbered_items(text: str) -> int:
    return len(re.findall(r"^\s*\d+\.\s+\S", text, re.M))


def bullet_items(text: str) -> int:
    return len(re.findall(r"^\s*(?:[-*]|\d+\.)\s+\S", text, re.M))


def fences_balanced(text: str) -> bool:
    return sum(1 for line in text.splitlines() if line.lstrip().startswith("```")) % 2 == 0


def normalize_for_similarity(text: str) -> list[str]:
    _, body = split_frontmatter(text)
    body = re.sub(r"^#+ .*$", " ", body, flags=re.M)
    return re.findall(r"[a-z0-9]+", body.lower())


def shingles(words: list[str], k: int = 6) -> set[int]:
    return {hash(" ".join(words[i:i + k])) for i in range(max(0, len(words) - k + 1))}


def jaccard(a: set, b: set) -> float:
    if not a or not b:
        return 0.0
    return len(a & b) / len(a | b)


# --------------------------------------------------------------- reference data

def load_taxonomy(root: Path = ROOT) -> dict[str, dict]:
    data = load_yaml(root / "catalog" / "domains.yaml") or {}
    return {d["id"]: d for d in data.get("domains", [])}


def load_registry(root: Path = ROOT) -> dict:
    return load_yaml(root / "catalog" / "compatibility.yaml") or {}


def registry_max_levels(registry: dict) -> dict[tuple[str, str], str]:
    out = {}
    for platform in registry.get("platforms", []):
        for target in platform.get("targets", []):
            out[(platform["id"], target["resource_type"])] = target["level"]
    return out


def load_schema(name: str, root: Path = ROOT) -> dict:
    return load_json(root / "schemas" / name)


def schema_errors(instance, schema) -> list[str]:
    if jsonschema is None:
        return ["jsonschema is not installed; run: python3 -m pip install -r requirements.txt"]
    validator = jsonschema.Draft202012Validator(schema)
    msgs = []
    for err in sorted(validator.iter_errors(instance), key=lambda e: list(e.path)):
        loc = "/".join(str(p) for p in err.path) or "(root)"
        msgs.append(f"{loc}: {err.message}")
    return msgs


def github_avatar_url(username: str, size: int = 256) -> str:
    return f"https://github.com/{username}.png?size={size}"


def github_profile_url(username: str) -> str:
    return f"https://github.com/{username}"


def compare_versions(a: str, b: str) -> int:
    pa = tuple(int(x) for x in a.split("."))
    pb = tuple(int(x) for x in b.split("."))
    return (pa > pb) - (pa < pb)


# Merging a pull request into main is the approval gate: every package on main
# with one of these statuses is published. `deprecated` keeps a package in the
# repository but removes it from the catalog.
PUBLISHED_STATUSES = frozenset({"submitted", "approved"})


def is_published(manifest) -> bool:
    return isinstance(manifest, dict) and manifest.get("status") in PUBLISHED_STATUSES


def next_catalog_version(configured: str, previous: str | None, changes: dict) -> str:
    """Pick the version for a build.

    A maintainer-set catalog_version above the previous release wins. Otherwise,
    when content changed, bump the previous release: minor for added/removed
    resources, patch for updates or collection/contributor changes. With no changes the previous version is kept.
    """
    if not previous or compare_versions(configured, previous) > 0:
        return configured
    if changes.get("added") or changes.get("removed"):
        major, minor, _ = (int(x) for x in previous.split(".")[:3])
        return f"{major}.{minor + 1}.0"
    if changes.get("updated") or changes.get("metadata_changed"):
        major, minor, patch = (int(x) for x in previous.split(".")[:3])
        return f"{major}.{minor}.{patch + 1}"
    return previous
