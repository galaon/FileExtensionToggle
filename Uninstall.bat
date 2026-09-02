@echo off
chcp 65001 > nul
title 파일 확장자 토글 - 제거
cd /d "%~dp0"

echo ============================================
echo   파일 확장자 토글 - 우클릭 메뉴 제거
echo ============================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Uninstall.ps1"

if errorlevel 1 (
    echo.
    echo [실패] 제거 중 오류가 발생했습니다. 위 메시지를 확인하십시오.
) else (
    echo.
    echo [완료] 우클릭 메뉴 항목이 제거되었습니다.
)

echo.
pause
