import unittest
from pathlib import Path

from scripts.publish_repository_status import load_yaml_status, validate_status_data

ROOT = Path(__file__).resolve().parents[1]


class PublicStatusValidationTests(unittest.TestCase):
    def test_legacy_status_remains_valid_without_completed_summary(self):
        result = validate_status_data({
            "status": "Đang kiểm thử",
            "next_action": "Chạy UAT",
            "progress": 80,
            "priority": "P1",
        })
        self.assertNotIn("completed", result)

    def test_example_status_summary_can_be_published(self):
        source = ROOT / ".dashboard" / "status.yml.example"
        result = validate_status_data(load_yaml_status(source))
        self.assertTrue(result["completed"])
        self.assertTrue(result["nextAction"])

    def test_completed_summary_rejects_local_path(self):
        with self.assertRaisesRegex(ValueError, "prohibited local filesystem drive path"):
            validate_status_data({
                "status": "Đang kiểm thử",
                "completed": "Đã chạy trên E:\\private\\machine",
                "next_action": "Chạy UAT",
                "progress": 80,
                "priority": "P1",
            })

    def test_null_completed_summary_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "non-empty string"):
            validate_status_data({
                "status": "Đang kiểm thử",
                "completed": None,
                "next_action": "Chạy UAT",
                "progress": 80,
                "priority": "P1",
            })

    def test_unapproved_field_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "Prohibited/extra fields"):
            validate_status_data({
                "status": "Đang kiểm thử",
                "completed": "Đã kiểm tra luồng nội bộ",
                "next_action": "Chạy UAT",
                "progress": 80,
                "priority": "P1",
                "private_notes": "internal",
            })


if __name__ == "__main__":
    unittest.main()
