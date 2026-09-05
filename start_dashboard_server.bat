@echo off
chcp 65001 > nul
cd /d "%~dp0"
title Bảng Điều Khiển Repository - E:\App AI
cls
echo =======================================================================
echo   🚀 MÁY CHỦ BẢNG ĐIỀU KHIỂN REPOSITORY ĐANG KHỞI CHẠY
echo =======================================================================
echo.
echo   📱 Xem trên máy tính này:
echo      👉 http://localhost:8088/projects_dashboard.html
echo.
echo   🌐 Xem từ Điện thoại / Laptop khác trong cùng mạng Wi-Fi/LAN:
echo      👉 http://192.168.1.151:8088/projects_dashboard.html
echo.
echo =======================================================================
echo   ⚡ Tích hợp sẵn API Quét tự động: Bấm nút "Quét lại ngay" trên web
echo      sẽ tự động chạy PowerShell cập nhật trạng thái Git tức thì!
echo   Nhấn Ctrl + C để dừng máy chủ bất cứ lúc nào.
echo =======================================================================
echo.

start "" "http://localhost:8088/projects_dashboard.html"
python dashboard_server.py 8088
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [!] Máy chủ bị dừng hoặc xảy ra lỗi khi khởi chạy.
    pause
)
