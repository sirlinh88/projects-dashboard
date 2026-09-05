<#
.SYNOPSIS
    Quét tình trạng các repo và đẩy thẳng lên GitHub Pages (https://sirlinh88.github.io/projects-dashboard/).
#>
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ParentDir = "E:\App AI"
$DashboardDir = Join-Path $ParentDir "projects-dashboard"
$ScannerScript = Join-Path $ParentDir "scan_repos_status.ps1"

Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host " ☁️ ĐỒNG BỘ BẢNG ĐIỀU KHIỂN LÊN GITHUB PAGES (CLOUD)" -ForegroundColor Yellow
Write-Host " Thiết bị: $env:COMPUTERNAME | Thời gian: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Gray
Write-Host "========================================================`n" -ForegroundColor Cyan

# 1. Chạy quét trạng thái mới nhất
Write-Host "[1/3] Đang quét trạng thái các repositories..." -ForegroundColor Green
& powershell -NoProfile -ExecutionPolicy Bypass -File $ScannerScript

# 2. Cập nhật các file vào thư mục projects-dashboard
Write-Host "`n[2/3] Cập nhật file dữ liệu vào projects-dashboard..." -ForegroundColor Green
Copy-Item (Join-Path $ParentDir "projects_data.js") -Destination (Join-Path $DashboardDir "projects_data.js") -Force
Copy-Item (Join-Path $ParentDir "projects_dashboard.html") -Destination (Join-Path $DashboardDir "index.html") -Force
Copy-Item (Join-Path $ParentDir "PROJECTS_TRACKER.md") -Destination (Join-Path $DashboardDir "README.md") -Force
Copy-Item (Join-Path $ParentDir "dashboard_server.py") -Destination (Join-Path $DashboardDir "dashboard_server.py") -Force
Copy-Item (Join-Path $ParentDir "scan_repos_status.ps1") -Destination (Join-Path $DashboardDir "scan_repos_status.ps1") -Force
Copy-Item (Join-Path $ParentDir "start_dashboard_server.bat") -Destination (Join-Path $DashboardDir "start_dashboard_server.bat") -Force
Copy-Item (Join-Path $ParentDir "start_background_service.vbs") -Destination (Join-Path $DashboardDir "start_background_service.vbs") -Force
Copy-Item (Join-Path $ParentDir "stop_dashboard_server.bat") -Destination (Join-Path $DashboardDir "stop_dashboard_server.bat") -Force
Copy-Item (Join-Path $ParentDir "scan_now.bat") -Destination (Join-Path $DashboardDir "scan_now.bat") -Force


# 3. Đẩy lên GitHub
Write-Host "`n[3/3] Đẩy mã nguồn lên GitHub Pages..." -ForegroundColor Green
git -C $DashboardDir add .
$changes = (git -C $DashboardDir status --porcelain | Measure-Object).Count
if ($changes -gt 0) {
    $commitMsg = "sync: update status from $env:COMPUTERNAME at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    git -C $DashboardDir commit -m $commitMsg
    git -C $DashboardDir push -u origin main
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n========================================================" -ForegroundColor Green
        Write-Host " ✅ ĐỒNG BỘ THÀNH CÔNG LÊN GITHUB PAGES!" -ForegroundColor Green
        Write-Host " 🌐 Mở xem mọi lúc tại: https://sirlinh88.github.io/projects-dashboard/" -ForegroundColor Yellow
        Write-Host "========================================================" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "[!] Lỗi khi push lên GitHub." -ForegroundColor Yellow
        Write-Host "    Hãy chắc chắn bạn đã tạo repository mới tên là 'projects-dashboard' trên GitHub (https://github.com/new)!" -ForegroundColor White
    }
} else {
    Write-Host ""
    Write-Host "[i] Không có thay đổi mới, dữ liệu trên GitHub Pages đã là mới nhất." -ForegroundColor Cyan
    Write-Host " 🌐 Xem tại: https://sirlinh88.github.io/projects-dashboard/" -ForegroundColor Yellow
    Write-Host ""
}