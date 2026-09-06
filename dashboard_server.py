# -*- coding: utf-8 -*-
"""
Dashboard Server with Automated Git Scanner API
Serves static files for projects_dashboard.html and provides /api/scan endpoint
to trigger scan_repos_status.ps1 automatically when the user clicks 'Quét lại ngay'.
"""

import http.server
import json
import os
import subprocess
import sys
import threading
from pathlib import Path

# Ensure UTF-8 output on Windows console
try:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    if hasattr(sys.stderr, "reconfigure"):
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8088
BASE_DIR = Path(__file__).resolve().parent
SCANNER_SCRIPT = BASE_DIR / "scan_repos_status.ps1"
SYNC_SCRIPT = BASE_DIR / "sync_dashboard.ps1"

def run_scanner():
    """Runs scan_repos_status.ps1 and returns (success: bool, message: str)"""
    if not SCANNER_SCRIPT.exists():
        return False, f"Không tìm thấy file: {SCANNER_SCRIPT}"
    
    try:
        cmd = [
            "powershell",
            "-NoProfile",
            "-ExecutionPolicy", "Bypass",
            "-File", str(SCANNER_SCRIPT)
        ]
        result = subprocess.run(
            cmd,
            cwd=str(BASE_DIR),
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=180
        )
        if result.returncode == 0:
            return True, "Quét và cập nhật trạng thái repository thành công!"
        else:
            err = result.stderr.strip() or result.stdout.strip()
            return False, f"Lỗi thực thi PowerShell (code {result.returncode}): {err}"
    except subprocess.TimeoutExpired:
        return False, "Quá thời gian quét (Timeout 180s)!"
    except Exception as e:
        return False, f"Ngoại lệ khi thực thi quét: {str(e)}"


class DashboardRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(BASE_DIR), **kwargs)

    def end_headers(self):
        # Prevent caching of dynamic data
        if self.path.endswith(".js") or self.path.startswith("/api/"):
            self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
            self.send_header("Pragma", "no-cache")
            self.send_header("Expires", "0")
        super().end_headers()

    def do_OPTIONS(self):
        self.send_error(405, "Cross-origin API access is not supported")

    def do_GET(self):
        if self.path.startswith("/api/"):
            self.send_error(405, "Dashboard APIs accept POST only")
        elif self.path == "/" or self.path == "":
            self.send_response(302)
            self.send_header("Location", "/index.html")
            self.end_headers()
        else:
            super().do_GET()

    def do_POST(self):
        if self.path.startswith("/api/scan"):
            self.handle_scan()
        elif self.path.startswith("/api/sync"):
            self.handle_sync()
        else:
            self.send_error(404, "Endpoint not found")

    def handle_scan(self):
        if not self.is_local_api_request():
            return
        print("\n[API] Nhận yêu cầu quét lại từ Dashboard...")
        success, message = run_scanner()
        
        response_data = {
            "success": success,
            "message": message,
            "path": str(BASE_DIR)
        }
        
        body = json.dumps(response_data, ensure_ascii=False).encode("utf-8")
        status_code = 200 if success else 500
        
        self.send_response(status_code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)
        print(f"[API] Kết quả quét: {'Thành công' if success else 'Thất bại'} - {message}")

    def is_local_api_request(self):
        if self.client_address[0] in {"127.0.0.1", "::1"}:
            return True
        self.send_error(403, "Dashboard scan APIs are available only from localhost")
        return False

    def handle_sync(self):
        if not self.is_local_api_request():
            return
        print("\n[API] Nhận yêu cầu quét và xuất bản Dashboard...")
        if not SYNC_SCRIPT.exists():
            body = json.dumps({"success": False, "message": "Không tìm thấy sync_dashboard.ps1"}, ensure_ascii=False).encode("utf-8")
            self.send_response(404)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return

        cmd = ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(SYNC_SCRIPT)]
        try:
            res = subprocess.run(cmd, cwd=str(BASE_DIR), capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=240)
            success = (res.returncode == 0)
            msg = "Đã quét và xuất bản lên GitHub Pages!" if success else "Lỗi khi quét hoặc xuất bản Dashboard."
        except Exception as e:
            success = False
            msg = f"Không thể chạy đồng bộ: {str(e)}"

        body = json.dumps({"success": success, "message": msg}, ensure_ascii=False).encode("utf-8")
        self.send_response(200 if success else 500)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


def main():
    os.chdir(str(BASE_DIR))
    server_address = ("", PORT)
    
    # Run an initial scan in background when server starts up
    def startup_scan():
        print("[Startup] Đang quét trạng thái repositories ban đầu...")
        success, msg = run_scanner()
        print(f"[Startup] Quét ban đầu hoàn tất: {msg}")

    scan_thread = threading.Thread(target=startup_scan, daemon=True)
    scan_thread.start()

    with http.server.ThreadingHTTPServer(server_address, DashboardRequestHandler) as httpd:
        print("=" * 70)
        print(f"🚀 REPOSITORY DASHBOARD SERVER ĐANG CHẠY TẠI PORT {PORT}")
        print("=" * 70)
        print(f"👉 Mở xem: http://localhost:{PORT}/index.html")
        print(f"👉 API quét/xuất bản: http://localhost:{PORT}/api/sync")
        print("=" * 70)
        print("Nhấn Ctrl + C để dừng máy chủ.\n")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nĐang tắt máy chủ...")


if __name__ == "__main__":
    main()
