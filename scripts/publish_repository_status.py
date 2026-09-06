"""Update one safe, public dashboard status entry from a GitHub Action."""

from __future__ import annotations

import argparse
import json
import re
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict


ALLOWED_PROJECTS = {
    "AI-STock",
    "Data-Hub",
    "GPMB-SmartAuto",
    "law-wiki-bidding-v2",
    "Mini-app-QLDA",
    "Smart",
    "SmartDoc-UIpath",
    "Zalo-work-hub",
}

ALLOWED_PRIORITIES = {"P0", "P1", "P2", "P3", "Ý tưởng", "Dọn dẹp"}

PROHIBITED_PATTERNS = [
    (r"[a-zA-Z]:[\\/]", "local filesystem drive path"),
    (r"/(?:Users|home|root|var|etc|opt|tmp)/", "local absolute path"),
    (r"\b(?:127\.0\.0\.1|localhost|192\.168\.\d+\.\d+|10\.\d+\.\d+\.\d+)\b", "internal IP/host"),
    (r"https?://", "URL link"),
    (r"\b[0-9a-f]{40}\b", "git commit SHA"),
    (r"\.(?:ts|js|py|ps1|bat|sh|json|yml|yaml|env|toml)\b", "filename extension"),
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--file", type=Path, required=True, help="Path to public_status.json")
    parser.add_argument("--project", choices=sorted(ALLOWED_PROJECTS), required=True, help="Repository name")
    parser.add_argument("--updated-at", required=True, help="ISO-8601 timestamp in UTC")
    parser.add_argument("--status-file", type=Path, default=None, help="Path to .dashboard/status.yml")
    parser.add_argument("--status", type=str, default=None, help="Project status string")
    parser.add_argument("--next-action", type=str, default=None, help="Next action string")
    parser.add_argument("--progress", type=int, default=None, help="Progress percentage (0-100)")
    parser.add_argument("--priority", type=str, default=None, help="Priority level (P0-P3)")
    return parser.parse_args()


def validate_timestamp(value: str) -> str:
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError as error:
        raise ValueError(f"updated-at must be an ISO-8601 timestamp (got '{value}')") from error

    if parsed.tzinfo is None:
        raise ValueError("updated-at must include a timezone")
    return parsed.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")


def load_yaml_status(path: Path) -> Dict[str, Any]:
    if not path.is_file():
        raise FileNotFoundError(f"Status file not found: {path}")

    content = path.read_text(encoding="utf-8")

    # Try PyYAML if available
    try:
        import yaml
        parsed = yaml.safe_load(content)
        if isinstance(parsed, dict):
            return parsed
    except ImportError:
        pass

    # Built-in fallback parser for simple key-value YAML
    data: Dict[str, Any] = {}
    for line_num, line in enumerate(content.splitlines(), start=1):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if ":" not in line:
            raise ValueError(f"Invalid YAML syntax at line {line_num}: '{line}'")
        key, val = line.split(":", 1)
        key = key.strip()
        val = val.strip()
        if (val.startswith('"') and val.endswith('"')) or (val.startswith("'") and val.endswith("'")):
            val = val[1:-1]
        elif val.isdigit():
            val = int(val)
        data[key] = val

    return data


def validate_status_data(data: Dict[str, Any]) -> Dict[str, Any]:
    allowed_keys = {"status", "next_action", "progress", "priority"}
    if not isinstance(data, dict):
        raise ValueError("Status content must be a mapping/dictionary")

    actual_keys = set(data.keys())
    if actual_keys != allowed_keys:
        missing = allowed_keys - actual_keys
        extra = actual_keys - allowed_keys
        errors = []
        if missing:
            errors.append(f"Missing required fields: {', '.join(sorted(missing))}")
        if extra:
            errors.append(f"Prohibited/extra fields: {', '.join(sorted(extra))}")
        raise ValueError(f"Status file schema violation: {'; '.join(errors)}")

    status = data.get("status")
    if not isinstance(status, str) or not status.strip():
        raise ValueError("Field 'status' must be a non-empty string")
    status = status.strip()
    if len(status) > 200:
        raise ValueError(f"Field 'status' too long ({len(status)} chars, max 200)")

    next_action = data.get("next_action")
    if not isinstance(next_action, str) or not next_action.strip():
        raise ValueError("Field 'next_action' must be a non-empty string")
    next_action = next_action.strip()
    if len(next_action) > 200:
        raise ValueError(f"Field 'next_action' too long ({len(next_action)} chars, max 200)")

    raw_progress = data.get("progress")
    if isinstance(raw_progress, bool) or not isinstance(raw_progress, (int, float, str)):
        raise ValueError("Field 'progress' must be an integer between 0 and 100")
    try:
        progress = int(raw_progress)
    except (ValueError, TypeError):
        raise ValueError(f"Field 'progress' must be an integer (got '{raw_progress}')")
    if not (0 <= progress <= 100):
        raise ValueError(f"Field 'progress' must be between 0 and 100 (got {progress})")

    priority = str(data.get("priority", "")).strip()
    if priority not in ALLOWED_PRIORITIES:
        raise ValueError(f"Field 'priority' must be one of {sorted(ALLOWED_PRIORITIES)} (got '{priority}')")

    # Prohibited pattern scan
    for field_name, value in [("status", status), ("next_action", next_action)]:
        for pattern, desc in PROHIBITED_PATTERNS:
            if re.search(pattern, value, re.IGNORECASE):
                raise ValueError(f"Field '{field_name}' contains prohibited {desc}: '{value}'")

    return {
        "status": status,
        "nextAction": next_action,
        "progress": progress,
        "priority": priority,
    }


def main() -> None:
    args = parse_args()
    updated_at = validate_timestamp(args.updated_at)

    if args.status_file:
        raw_data = load_yaml_status(args.status_file)
    elif args.status is not None and args.next_action is not None and args.progress is not None and args.priority is not None:
        raw_data = {
            "status": args.status,
            "next_action": args.next_action,
            "progress": args.progress,
            "priority": args.priority,
        }
    else:
        raise ValueError("Either --status-file or all 4 status arguments (--status, --next-action, --progress, --priority) must be provided")

    validated = validate_status_data(raw_data)

    if not args.file.is_file():
        raise FileNotFoundError(f"Target status file not found: {args.file}")

    document = json.loads(args.file.read_text(encoding="utf-8"))
    if document.get("schemaVersion") != 1 or not isinstance(document.get("repositories"), dict):
        raise ValueError("public status file has an unsupported schema (expected schemaVersion=1)")

    document["repositories"][args.project] = {
        "state": "updated",
        "updatedAt": updated_at,
        "status": validated["status"],
        "nextAction": validated["nextAction"],
        "progress": validated["progress"],
        "priority": validated["priority"],
    }
    document["generatedAt"] = updated_at
    args.file.write_text(json.dumps(document, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Successfully updated {args.project} in {args.file}")


if __name__ == "__main__":
    main()
