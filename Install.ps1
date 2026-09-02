# Install.ps1
# 마우스 우클릭 메뉴에 "파일 확장자 보기 토글 ― [현재 · ON/OFF]" 항목을 등록합니다.
# Registers a "File Extension Toggle ― [Current · ON/OFF]" item in the right-click menu.
# HKCU 에만 쓰므로 관리자 권한이 필요 없습니다. / Writes to HKCU only, no admin rights needed.
#
#   -Language  auto(기본, OS 표시 언어를 따름) / ko / en
#   -MenuText  메뉴 이름을 직접 지정 (생략하면 언어에 맞는 기본 이름)

param(
    [ValidateSet('auto','ko','en')]
    [string]$Language = 'auto',

    [string]$MenuText
)

$ErrorActionPreference = 'Stop'

$KeyName   = 'FileExtensionToggle'
$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }

. (Join-Path $ScriptDir 'Lang.ps1') -Language $Language
if ([string]::IsNullOrWhiteSpace($MenuText)) { $MenuText = $L.MenuText }

$Launcher = Join-Path $ScriptDir 'Run-Hidden.vbs'
$Toggle   = Join-Path $ScriptDir 'ToggleFileExt.ps1'
$IconOn   = Join-Path $ScriptDir 'icon-on.ico'      # 확장자 표시(ON)  - 파랑 / shown - blue
$IconOff  = Join-Path $ScriptDir 'icon-off.ico'     # 확장자 숨김(OFF) - 회색 / hidden - gray

foreach ($f in @($Launcher, $Toggle, $IconOn, $IconOff)) {
    if (-not (Test-Path -LiteralPath $f)) {
        throw ($L.MissingFile -f $f)
    }
}

$Command = '"{0}" "{1}"' -f (Join-Path $env:SystemRoot 'System32\wscript.exe'), $Launcher

# 현재 확장자 표시 상태를 읽어 라벨에 반영 (HideFileExt: 0 = 표시 = ON)
$AdvKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$hide   = (Get-ItemProperty -Path $AdvKey -Name 'HideFileExt' -ErrorAction SilentlyContinue).HideFileExt
if ($null -eq $hide) { $hide = 1 }
$state  = if ($hide -eq 0) { 'ON' } else { 'OFF' }
$Label  = $L.LabelFormat -f $MenuText, $state
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
    Set-ItemProperty -Path $key -Name 'BaseMenuText' -Value $MenuText   # 토글 시 라벨 재조립용
    Set-ItemProperty -Path $key -Name 'LangCode'     -Value $LangCode   # 토글 시 같은 언어 유지
    Set-ItemProperty -Path $key -Name 'Icon'         -Value $Icon
    Set-ItemProperty -Path $cmd -Name '(Default)'    -Value $Command

    Write-Host ($L.Registered -f $key)
}

Write-Host ''
Write-Host ($L.InstallDone -f $state)
Write-Host $L.InstallHint1
Write-Host $L.InstallHint2
