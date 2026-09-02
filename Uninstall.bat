@echo off
chcp 65001 > nul
title File Extension Toggle - Uninstall
rem 삭제 대상 폴더를 현재 디렉터리로 잡고 있으면 지울 수 없으므로 밖으로 나갑니다.
rem Move out of the folder we may be deleting, otherwise it cannot be removed.
cd /d "%SystemRoot%"

echo ============================================
echo   File Extension Toggle  /  파일 확장자 보기 토글
echo   Uninstall  /  제거
echo ============================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0src\Uninstall.ps1"

echo.
pause

rem 이 배치가 설치 폴더 안에 있다면(= 설치본), 마지막으로 자기 자신과 폴더를 지웁니다.
rem 내려받은 폴더에서 실행한 경우에는 아무것도 지우지 않습니다.
rem If this batch lives inside the install folder, it removes itself and the folder last.
rem When run from the downloaded folder, nothing here is touched.
if /i not "%~dp0"=="%LOCALAPPDATA%\FileExtensionToggle\" goto :eof
(goto) 2>nul & del /q "%~f0" >nul 2>&1 & rd /s /q "%LOCALAPPDATA%\FileExtensionToggle" >nul 2>&1
