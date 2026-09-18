"""Build the GitHub Pages artifact from reviewed public files only."""

from __future__ import annotations

import json
import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "_site"
PUBLIC_FILES = ("index.html", "projects_data.js", "public_catalog.js", "public_status.json")
PUBLIC_PROJECT_KEYS = {"Name", "Priority", "Category", "Progress", "Health"}


def validate_public_projects(source: str) -> None:
    for variable in ("LAST_SCAN", "MACHINE_NAME"):
        if not re.search(rf"window\.{variable}\s*=\s*['\"]['\"]\s*;", source):
            raise ValueError(f"projects_data.js must have an empty {variable}")

    match = re.fullmatch(
        r"(?:\s*// Public dashboard metadata\. GitHub Actions updates public_status\.json only\.\s*)?"
        r"window\.LAST_SCAN\s*=\s*['\"]['\"]\s*;\s*"
        r"window\.MACHINE_NAME\s*=\s*['\"]['\"]\s*;\s*"
        r"window\.PROJECTS_DATA\s*=\s*(\[[\s\S]*\])\s*;\s*",
        source,
    )
    if not match:
        raise ValueError("projects_data.js must contain a JSON project array")
    projects = json.loads(match.group(1))
    if not isinstance(projects, list):
        raise TypeError("Public project data must be a list")
    for project in projects:
        if not isinstance(project, dict) or set(project) != PUBLIC_PROJECT_KEYS:
            raise ValueError("projects_data.js contains non-public or missing project fields")


def main() -> None:
    validate_public_projects((ROOT / "projects_data.js").read_text(encoding="utf-8-sig"))
    status = json.loads((ROOT / "public_status.json").read_text(encoding="utf-8"))
    if status.get("schemaVersion") != 1 or not isinstance(status.get("repositories"), dict):
        raise ValueError("public_status.json has an invalid schema")

    if OUTPUT.exists() and any(OUTPUT.iterdir()):
        raise ValueError("_site must be empty before building the public artifact")
    OUTPUT.mkdir(exist_ok=True)
    for filename in PUBLIC_FILES:
        shutil.copyfile(ROOT / filename, OUTPUT / filename)
    print(f"Prepared {len(PUBLIC_FILES)} public files in {OUTPUT}")


if __name__ == "__main__":
    main()
