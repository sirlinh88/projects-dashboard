@echo off
chcp 65001 > nul
cd /d "%~dp0"
title Quét tình trạng Repository - E:\App AI
cls
echo =======================================================================
echo   🔍 ĐANG QUÉT TOÀN BỘ REPOSITORY TRONG E:\App AI...
echo =======================================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scan_repos_status.ps1"

echo.
echo =======================================================================
echo   ✅ HOÀN TẤT QUÉT! Dữ liệu đã được lưu vào projects_data.js.
echo =======================================================================
echo.
pause
