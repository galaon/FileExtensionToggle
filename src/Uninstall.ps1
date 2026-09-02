# Uninstall.ps1
# Install.ps1 로 등록한 우클릭 메뉴 항목을 모두 제거합니다.
# Removes every right-click menu item registered by Install.ps1.
# 탐색기의 HideFileExt 설정 값 자체는 건드리지 않습니다. / The HideFileExt setting itself is left alone.

param(
    [ValidateSet('auto','ko','en')]
    [string]$Language = 'auto'
)

$ErrorActionPreference = 'Stop'

$KeyName   = 'FileExtensionToggle'
$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }

. (Join-Path $ScriptDir 'Lang.ps1') -Language $Language

$Bases = @(
    'HKCU:\Software\Classes\Directory\Background\shell'
    'HKCU:\Software\Classes\DesktopBackground\Shell'
    'HKCU:\Software\Classes\Directory\shell'
)

$removed = 0
foreach ($base in $Bases) {
    $key = Join-Path $base $KeyName
    if (Test-Path -LiteralPath $key) {
        Remove-Item -LiteralPath $key -Recurse -Force
        Write-Host ($L.Removed -f $key)
        $removed++
    }
}

# 설치 때 복사해 둔 파일 정리 / clean up the installed copy
# 이 스크립트가 설치 폴더 안에서 실행 중이면 Uninstall.bat 과 폴더 자체는 남겨 둡니다.
# 실행 중인 배치 파일을 여기서 지우면 cmd 가 남은 줄을 읽지 못해 오류가 납니다.
# 그 마지막 정리는 Uninstall.bat 이 스스로 처리합니다.
#
# When running from inside the install folder, Uninstall.bat and the folder itself are
# left alone - deleting the running batch here would break cmd's line-by-line reading.
# Uninstall.bat cleans those up on its own as its very last step.
$InstallRoot = Join-Path $env:LOCALAPPDATA 'FileExtensionToggle'

if (Test-Path -LiteralPath $InstallRoot) {
    Set-Location -LiteralPath $env:SystemRoot
    if ($ScriptDir -like "$InstallRoot*") {
        foreach ($sub in @('src', 'icons')) {
            Remove-Item -LiteralPath (Join-Path $InstallRoot $sub) -Recurse -Force -ErrorAction SilentlyContinue
        }
    } else {
        Remove-Item -LiteralPath $InstallRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host ($L.Removed -f $InstallRoot)
}

if ($removed -eq 0) {
    Write-Host $L.RemoveNone
} else {
    Write-Host ''
    Write-Host ($L.RemoveDone -f $removed)
}
