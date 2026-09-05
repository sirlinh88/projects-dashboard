@echo off
chcp 65001 > nul
cd /d "%~dp0"
title Tắt máy chủ Dashboard - E:\App AI
cls
echo =======================================================================
echo   🛑 ĐANG DỪNG MÁY CHỦ DASHBOARD (PORT 8088)...
echo =======================================================================
echo.

for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8088') do (
    taskkill /F /PID %%a 2>nul
)

echo.
echo =======================================================================
echo   ✅ ĐÃ TẮT MÁY CHỦ DASHBOARD THÀNH CÔNG.
echo =======================================================================
echo.
timeout /t 3 >nul
