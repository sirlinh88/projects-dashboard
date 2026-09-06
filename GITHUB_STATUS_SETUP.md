# Quy trình Thiết lập & Đồng bộ Trạng thái Dự án qua GitHub Actions

Tài liệu hướng dẫn chuẩn hóa file trạng thái, bảo mật GitHub Secret và quy trình đồng bộ trạng thái an toàn từ các repository nguồn về `sirlinh88/projects-dashboard`.

---

## 1. Chuẩn hóa File Trạng thái (.dashboard/status.yml)

Mỗi repository nguồn cần duy trì file `.dashboard/status.yml` tại thư mục gốc với đúng 4 trường sau:

```yaml
status: "Đang kiểm thử tích hợp"
next_action: "Chạy UAT và chuẩn bị triển khai"
progress: 80
priority: P1
```

### Quy tắc an toàn bắt buộc:
- **Chỉ cho phép 4 trường:** `status`, `next_action`, `progress`, `priority`. Mọi trường bổ sung khác sẽ bị hệ thống từ chối (fail workflow).
- **`status`**: Chuỗi mô tả ngắn gọn trạng thái hiện tại (tối đa 200 ký tự).
- **`next_action`**: Chuỗi mô tả hành động triển khai tiếp theo (tối đa 200 ký tự).
- **`progress`**: Số nguyên từ `0` đến `100` thể hiện phần trăm hoàn thiện.
- **`priority`**: Một trong các giá trị: `P0`, `P1`, `P2`, `P3`, `Ý tưởng`, `Dọn dẹp`.
- **Nghiêm cấm dữ liệu nhạy cảm:**
  - Không chứa đường dẫn tệp cục bộ (ví dụ: `C:\`, `E:\`, `/home/`).
  - Không chứa tên tệp/phần mở rộng mã nguồn (`.ts`, `.py`, `.js`, `.env`, v.v.).
  - Không chứa Git commit hash, SHA, tên branch nội bộ.
  - Không chứa IP nội bộ, localhost hoặc URL link.
  - Không chứa secret, token, mật khẩu hay tài khoản cá nhân.

---

## 2. Thiết lập GitHub Secret (PROJECTS_DASHBOARD_PUSH_TOKEN)

Để workflow trong repo nguồn có quyền đẩy trạng thái vào `projects-dashboard`, cần một Fine-grained Personal Access Token (PAT) với quyền hạn tối thiểu:

### Bước 1: Tạo Fine-grained PAT trên GitHub
1. Đăng nhập tài khoản GitHub (`sirlinh88`).
2. Vào **Settings** (cá nhân) → **Developer Settings** → **Personal access tokens** → **Fine-grained tokens** (hoặc truy cập: `https://github.com/settings/tokens?type=beta`).
3. Bấm **Generate new token**.
4. Cấu hình token:
   - **Token name**: `PROJECTS_DASHBOARD_PUSH_TOKEN`
   - **Expiration**: Chọn thời hạn (ví dụ: 90 ngày hoặc 1 năm).
   - **Resource owner**: `sirlinh88`
   - **Repository access**: Chọn **Only select repositories** → Chọn đúng duy nhất `sirlinh88/projects-dashboard`.
   - **Permissions**:
     - **Repository permissions** → **Contents**: Chọn **Access: Read and write**.
     - Không cấp thêm bất kỳ quyền nào khác.
5. Bấm **Generate token** và sao chép mã token.

### Bước 2: Lưu Secret vào từng repo nguồn
Tại mỗi repository nguồn (`AI-STock`, `Mini-app-QLDA`, `SmartDoc-UIpath`, `Zalo-work-hub`, v.v.):
1. Vào tab **Settings** của repository.
2. Chọn **Secrets and variables** → **Actions**.
3. Bấm **New repository secret**.
4. Nhập:
   - **Name**: `PROJECTS_DASHBOARD_PUSH_TOKEN`
   - **Secret**: Dán mã token vừa tạo ở Bước 1.
5. Bấm **Add secret**.

> **LƯU Ý BẢO MẬT TUYỆT ĐỐI:**
> - Tuyệt đối **KHÔNG** dán token vào commit, code, file workflow, issues, PR hoặc gửi qua chat.
> - Token chỉ được lưu trữ duy nhất trong mục GitHub Actions Secrets.

---

## 3. Hoạt động của GitHub Action nguồn

File workflow: `.github/workflows/publish-dashboard-status.yml`
- **Kích hoạt tự động**: Khi push lên nhánh `main` hoặc `master`.
- **Kích hoạt thủ công**: Hỗ trợ `workflow_dispatch` để chạy thử nghiệm bất cứ lúc nào qua tab Actions trên GitHub.
- **Cơ chế xử lý xung đột (Retry)**:
  - Khi nhiều repo push đồng thời vào `projects-dashboard`, lệnh push có thể bị từ chối do non-fast-forward.
  - Workflow tự động fetch bản mới nhất của `main`, re-apply trạng thái, commit và retry tối đa 5 lần với thời gian chờ giãn cách (`backoff: attempt * 3s`).
- **Kiểm tra chặt chẽ**:
  - Thiếu `PROJECTS_DASHBOARD_PUSH_TOKEN` → Báo lỗi rõ ràng và dừng ngay.
  - Thiếu `.dashboard/status.yml` hoặc sai schema → Báo lỗi chi tiết và dừng ngay.

---

## 4. Cấu trúc public_status.json

Dữ liệu trạng thái công khai được lưu tại `public_status.json` trong `projects-dashboard`. Mỗi repo có dạng:

```json
{
  "state": "updated",
  "updatedAt": "2026-09-06T08:00:00Z",
  "status": "Đang kiểm thử tích hợp",
  "nextAction": "Chạy UAT và chuẩn bị triển khai",
  "progress": 80,
  "priority": "P1"
}
```

Đây là nguồn trạng thái động công khai duy nhất được xuất bản lên GitHub Pages.
- Repository đã có event: hiển thị dữ liệu thời gian thực từ `public_status.json`.
- Repository chưa có event đầu tiên: hiển thị fallback từ `public_catalog.js`.

---

## 5. Khởi tạo & Xác minh

1. **Chạy thử lần đầu**:
   - Vào từng repo nguồn → **Actions** → **Publish public dashboard status** → **Run workflow**.
2. **Kiểm tra `projects-dashboard`**:
   - Xác nhận commit mới từ `projects-dashboard[bot]`.
   - Xác nhận `public_status.json` được cập nhật đúng thông tin của repo.
3. **Kiểm tra GitHub Pages**:
   - Mở `https://sirlinh88.github.io/projects-dashboard/`.
   - Bấm nút **🔄 Quét GitHub** để làm mới dữ liệu.
   - Kiểm tra trạng thái hiển thị đúng huy hiệu `LIVE`.
   - Xác minh trang không chứa commit hash, SHA, tên branch, đường dẫn thư mục cục bộ hay danh sách tệp sửa dở.

---

## 6. Xử lý các Repository đang bị chặn

Trước khi kích hoạt workflow cho các repo này:
1. **`GPMB-SmartAuto`** và **`Smart`**:
   - Hiện trỏ remote về tài khoản `linhnguyen88vn`.
   - Cần cập nhật remote về đúng tài khoản hoặc cấp quyền truy cập push/secret trước khi đồng bộ.
2. **`law-wiki-bidding-v2`**:
   - Hiện trỏ remote về `phongsun01/law-wiki-bidding-v2`.
   - Cần quyền ghi (collaborator/write access) cho tài khoản đang dùng trước khi push workflow và cấu hình secret.
