@echo off
chcp 65001 > nul
title 파일 확장자 토글 - 설치
cd /d "%~dp0"

echo ============================================
echo   파일 확장자 토글 - 우클릭 메뉴 설치
echo ============================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install.ps1"

if errorlevel 1 (
    echo.
    echo [실패] 설치 중 오류가 발생했습니다. 위 메시지를 확인하십시오.
) else (
    echo.
    echo [완료] 이제 바탕화면이나 폴더 빈 공간을 우클릭해 보십시오.
)

echo.
pause
