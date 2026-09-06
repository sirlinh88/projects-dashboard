"""Update one safe, public dashboard status entry from a GitHub Action."""

from __future__ import annotations

import argparse
import json
from datetime import datetime, timezone
from pathlib import Path


ALLOWED_PROJECTS = {
    "AI-STock",
    "GPMB-SmartAuto",
    "law-wiki-bidding-v2",
    "Mini-app-QLDA",
    "Smart",
    "SmartDoc-UIpath",
    "Zalo-work-hub",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--file", type=Path, required=True)
    parser.add_argument("--project", choices=sorted(ALLOWED_PROJECTS), required=True)
    parser.add_argument("--updated-at", required=True)
    return parser.parse_args()


def validate_timestamp(value: str) -> str:
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError as error:
        raise ValueError("updated-at must be an ISO-8601 timestamp") from error

    if parsed.tzinfo is None:
        raise ValueError("updated-at must include a timezone")
    return parsed.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")


def main() -> None:
    args = parse_args()
    updated_at = validate_timestamp(args.updated_at)
    document = json.loads(args.file.read_text(encoding="utf-8"))

    if document.get("schemaVersion") != 1 or not isinstance(document.get("repositories"), dict):
        raise ValueError("public status file has an unsupported schema")

    document["repositories"][args.project] = {
        "state": "updated",
        "updatedAt": updated_at,
    }
    document["generatedAt"] = updated_at
    args.file.write_text(json.dumps(document, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
