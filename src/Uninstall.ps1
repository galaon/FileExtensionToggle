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

if ($removed -eq 0) {
    Write-Host $L.RemoveNone
} else {
    Write-Host ''
    Write-Host ($L.RemoveDone -f $removed)
}
