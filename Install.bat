@echo off
chcp 65001 > nul
title File Extension Toggle - Install
cd /d "%~dp0"

echo ============================================
echo   File Extension Toggle  /  파일 확장자 보기 토글
echo   Install  /  설치
echo ============================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install.ps1"

echo.
pause
