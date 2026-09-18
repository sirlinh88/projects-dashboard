import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from scripts import build_public_site
from scripts.build_public_site import validate_public_projects


def public_script(project):
    return (
        "window.LAST_SCAN = '';\n"
        "window.MACHINE_NAME = '';\n"
        f"window.PROJECTS_DATA = {json.dumps([project])};\n"
    )


class PublicArtifactTests(unittest.TestCase):
    def test_minimal_project_metadata_is_accepted(self):
        validate_public_projects(public_script({
            "Name": "Example",
            "Priority": "P1",
            "Category": "active",
            "Progress": 50,
            "Health": "pending",
        }))

    def test_local_git_metadata_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "non-public"):
            validate_public_projects(public_script({
                "Name": "Example",
                "Priority": "P1",
                "Category": "active",
                "Progress": 50,
                "Health": "pending",
                "LastCommitMsg": "private work",
            }))

    def test_machine_name_is_rejected(self):
        source = public_script({
            "Name": "Example",
            "Priority": "P1",
            "Category": "active",
            "Progress": 50,
            "Health": "pending",
        }).replace("MACHINE_NAME = ''", "MACHINE_NAME = 'workstation'")
        with self.assertRaisesRegex(ValueError, "empty MACHINE_NAME"):
            validate_public_projects(source)

    def test_artifact_contains_only_reviewed_public_files(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "projects_data.js").write_text(public_script({
                "Name": "Example",
                "Priority": "P1",
                "Category": "active",
                "Progress": 50,
                "Health": "pending",
            }), encoding="utf-8")
            (root / "public_status.json").write_text(
                json.dumps({"schemaVersion": 1, "repositories": {}}), encoding="utf-8"
            )
            (root / "index.html").write_text("<h1>Dashboard</h1>", encoding="utf-8")
            (root / "public_catalog.js").write_text("window.PUBLIC_CATALOG = {};", encoding="utf-8")
            (root / "private.txt").write_text("private", encoding="utf-8")
            with patch.object(build_public_site, "ROOT", root), patch.object(
                build_public_site, "OUTPUT", root / "_site"
            ):
                build_public_site.main()
            self.assertEqual(
                {path.name for path in (root / "_site").iterdir()},
                set(build_public_site.PUBLIC_FILES),
            )


if __name__ == "__main__":
    unittest.main()
