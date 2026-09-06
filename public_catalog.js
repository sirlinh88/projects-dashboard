// Public, manually maintained project context. Do not add internal links or sensitive data.
window.PUBLIC_CATALOG = Object.freeze({
  'AI-Space': {
    summary: 'Không gian thử nghiệm cục bộ, chưa có mã nguồn triển khai.',
    status: 'Tạm dừng / local-only.',
    nextAction: 'Quyết định dùng lại làm workspace thử nghiệm hoặc lưu trữ.'
  },
  'AI-STock': {
    summary: 'Nền tảng phân tích dữ liệu thị trường và báo cáo nghiên cứu.',
    status: 'Đang phát triển; chờ GitHub event đầu tiên để xác nhận trạng thái từ xa.',
    nextAction: 'Thêm Secret dashboard và xác nhận workflow GitHub Actions chạy thành công.'
  },
  'Data-Hub': {
    summary: 'Nguồn dữ liệu chuẩn (SSOT) cho thông tin master dự án và pipeline trích xuất dữ liệu.',
    status: 'Đang vận hành Data Hub API v2 và đồng bộ master dự án.',
    nextAction: 'Thêm Secret dashboard và hoàn tất kiểm thử tích hợp với QLDA.'
  },
  'GPMB-SmartAuto': {
    summary: 'Blueprint tự động hóa hồ sơ giải phóng mặt bằng.',
    status: 'Khởi tạo, chưa có phần mềm triển khai.',
    nextAction: 'Khôi phục quyền truy cập remote, sau đó xác định phạm vi nghiệp vụ và kiến trúc.'
  },
  'law-wiki-bidding-v2': {
    summary: 'Kho tri thức pháp lý phục vụ tra cứu đấu thầu.',
    status: 'Đang duy trì nội dung; chưa thể gửi GitHub event từ tài khoản hiện tại.',
    nextAction: 'Cấp quyền ghi remote, sau đó hoàn thiện liên kết nội dung và giao diện tra cứu.'
  },
  'Mini-app-QLDA': {
    summary: 'Ứng dụng Web và Zalo Mini App quản lý dự án đầu tư công.',
    status: 'Đang phát triển và tích hợp dữ liệu.',
    nextAction: 'Thêm Secret dashboard, rồi tiếp tục các bước xác thực và triển khai theo kế hoạch dự án.'
  },
  'personal-agentkit': {
    summary: 'Kho quản lý quy tắc, agents và skills cục bộ.',
    status: 'Local-only.',
    nextAction: 'Tạo remote GitHub nếu cần theo dõi trạng thái từ xa.'
  },
  'Phan mem kiem tra ho so XD': {
    summary: 'Ý tưởng phần mềm kiểm tra hồ sơ xây dựng.',
    status: 'Chưa khởi tạo mã nguồn.',
    nextAction: 'Chốt phạm vi nghiệp vụ, tiêu chuẩn kiểm tra và công nghệ triển khai.'
  },
  'Skills': {
    summary: 'Kho tài liệu kỹ năng thô.',
    status: 'Đang chờ chuẩn hóa.',
    nextAction: 'Chuyển các kỹ năng cần dùng sang cấu trúc chuẩn và có kiểm thử.'
  },
  'Smart': {
    summary: 'Repository cũ hoặc stub của SmartDoc.',
    status: 'Cần dọn dẹp; remote hiện chưa truy cập được.',
    nextAction: 'Khôi phục remote để xác nhận nguồn gốc, rồi lưu trữ hoặc loại bỏ theo quyết định quản trị.'
  },
  'SmartDoc-UIpath': {
    summary: 'Hệ thống tạo tài liệu và Word Add-in.',
    status: 'Đang phát triển chức năng template.',
    nextAction: 'Thêm Secret dashboard và hoàn tất kiểm thử chấp nhận trước khi mở rộng triển khai.'
  },
  'Zalo-work-hub': {
    summary: 'Nền tảng điều phối công việc và nhắc việc qua Zalo.',
    status: 'Đang phát triển tác vụ vận hành và tích hợp.',
    nextAction: 'Thêm Secret dashboard, sau đó kiểm chứng triển khai trên môi trường vận hành.'
  }
});
