# Install.ps1
# 마우스 우클릭 메뉴에 "파일 확장자 표시/숨김 ― [현재 · ON/OFF]" 항목을 등록합니다.
# HKCU에만 쓰므로 관리자 권한이 필요 없습니다.

param(
    [string]$MenuText = '파일 확장자 표시/숨김'
)

$ErrorActionPreference = 'Stop'

$KeyName   = 'FileExtensionToggle'
$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }
$Launcher  = Join-Path $ScriptDir 'Run-Hidden.vbs'
$Toggle    = Join-Path $ScriptDir 'ToggleFileExt.ps1'
$IconOn    = Join-Path $ScriptDir 'icon-on.ico'      # 확장자 표시(ON)  - 파랑
$IconOff   = Join-Path $ScriptDir 'icon-off.ico'     # 확장자 숨김(OFF) - 회색

foreach ($f in @($Launcher, $Toggle, $IconOn, $IconOff)) {
    if (-not (Test-Path -LiteralPath $f)) {
        throw "필수 파일이 없습니다: $f"
    }
}

$Command = '"{0}" "{1}"' -f (Join-Path $env:SystemRoot 'System32\wscript.exe'), $Launcher

# 현재 확장자 표시 상태를 읽어 라벨에 반영 (HideFileExt: 0 = 표시 = ON)
$AdvKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$hide   = (Get-ItemProperty -Path $AdvKey -Name 'HideFileExt' -ErrorAction SilentlyContinue).HideFileExt
if ($null -eq $hide) { $hide = 1 }
$state  = if ($hide -eq 0) { 'ON' } else { 'OFF' }
$Label  = '{0} ― [현재 · {1}]' -f $MenuText, $state
$Icon   = if ($hide -eq 0) { $IconOn } else { $IconOff }

# 등록 위치: 폴더 빈 공간 / 바탕화면 / 폴더 자체
$Targets = @(
    'HKCU:\Software\Classes\Directory\Background\shell'
    'HKCU:\Software\Classes\DesktopBackground\Shell'
    'HKCU:\Software\Classes\Directory\shell'
)

foreach ($base in $Targets) {
    $key = Join-Path $base $KeyName
    $cmd = Join-Path $key 'command'

    New-Item -Path $cmd -Force | Out-Null

    Set-ItemProperty -Path $key -Name '(Default)'    -Value $Label
    Set-ItemProperty -Path $key -Name 'BaseMenuText' -Value $MenuText   # 토글 스크립트가 라벨을 다시 만들 때 사용
    Set-ItemProperty -Path $key -Name 'Icon'         -Value $Icon
    Set-ItemProperty -Path $cmd -Name '(Default)'    -Value $Command

    Write-Host "등록됨: $key"
}

Write-Host ''
Write-Host "설치 완료. 현재 상태: [$state]"
Write-Host '바탕화면이나 폴더 빈 공간을 우클릭하면 메뉴가 보입니다.'
Write-Host 'Windows 11에서는 [추가 옵션 표시] (Shift+F10) 안에 나타납니다.'
