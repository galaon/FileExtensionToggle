# ToggleFileExt.ps1
# 탐색기의 "알려진 파일 형식의 파일 확장명 숨기기" 설정을 ON/OFF 토글합니다.
# Toggles Explorer's "Hide extensions for known file types" setting.
#   HideFileExt = 1  ->  확장자 숨김 / hidden   ([현재 · OFF] + 회색 아이콘 / gray icon)
#   HideFileExt = 0  ->  확장자 표시 / shown    ([현재 · ON]  + 파란 아이콘 / blue icon)
#
# 토글 후 하는 일 / after toggling:
#   1) SHChangeNotify 로 열려 있는 탐색기 창을 즉시 갱신 (새로고침 불필요)
#   2) 우클릭 메뉴의 라벨과 아이콘을 새 상태에 맞게 다시 기록
#
# 성공 시 아무 창도 띄우지 않습니다. 오류가 났을 때만 알립니다.
# Silent on success; only errors raise a popup.

$ErrorActionPreference = 'Stop'

$AdvKey      = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$MenuKeyName = 'FileExtensionToggle'
$ScriptDir   = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }
# 설치 시 복사해 둔 아이콘 폴더. 없으면 프로젝트 폴더의 원본을 씁니다.
# The icon folder created at install time; falls back to the project's own copy.
$IconDir     = Join-Path $env:LOCALAPPDATA 'FileExtensionToggle\icons'
if (-not (Test-Path -LiteralPath $IconDir)) {
    $IconDir = Join-Path (Split-Path -Parent $ScriptDir) 'icons'
}
$MenuBases = @(
    'HKCU:\Software\Classes\Directory\Background\shell'
    'HKCU:\Software\Classes\DesktopBackground\Shell'
    'HKCU:\Software\Classes\Directory\shell'
)

. (Join-Path $ScriptDir 'Lang.ps1')   # OS 표시 언어 기준 기본값 / defaults from OS display language

try {
    # --- 현재 값 읽기 (없으면 Windows 기본값인 1 = 숨김으로 간주) ---
    $current = (Get-ItemProperty -Path $AdvKey -Name 'HideFileExt' -ErrorAction SilentlyContinue).HideFileExt
    if ($null -eq $current) { $current = 1 }

    # --- 반전 / flip ---
    $new = if ($current -eq 0) { 1 } else { 0 }
    Set-ItemProperty -Path $AdvKey -Name 'HideFileExt' -Value $new -Type DWord

    # --- 탐색기 즉시 갱신 / refresh open Explorer windows right away ---
    if (-not ('Win32.Shell32Notify' -as [type])) {
        Add-Type -Namespace Win32 -Name Shell32Notify -MemberDefinition @'
[System.Runtime.InteropServices.DllImport("shell32.dll", CharSet = System.Runtime.InteropServices.CharSet.Auto)]
public static extern void SHChangeNotify(int eventId, uint flags, System.IntPtr item1, System.IntPtr item2);
'@
    }
    # SHCNE_ASSOCCHANGED = 0x08000000
    # SHCNF_IDLIST = 0x0000, SHCNF_FLUSH = 0x1000 (알림 처리까지 대기 -> 즉시 반영)
    [Win32.Shell32Notify]::SHChangeNotify(0x08000000, 0x1000, [System.IntPtr]::Zero, [System.IntPtr]::Zero)

    # --- 우클릭 메뉴의 라벨 + 아이콘 갱신 ---
    # Explorer 는 메뉴를 열 때마다 라벨과 아이콘을 레지스트리에서 다시 읽습니다.
    # Explorer re-reads both from the registry every time the menu opens.
    $state = if ($new -eq 0) { 'ON' } else { 'OFF' }
    $icon  = Join-Path $IconDir $(if ($new -eq 0) { 'icon-on.ico' } else { 'icon-off.ico' })

    foreach ($base in $MenuBases) {
        $key = Join-Path $base $MenuKeyName
        if (-not (Test-Path -LiteralPath $key)) { continue }

        $props = Get-ItemProperty -Path $key -ErrorAction SilentlyContinue

        # 설치할 때 쓴 언어와 이름을 그대로 유지 / keep the language and name chosen at install time
        $fmt = $L.LabelFormat
        if ($props.LangCode -and $Strings.ContainsKey($props.LangCode)) {
            $fmt = $Strings[$props.LangCode].LabelFormat
        }
        $baseText = $props.BaseMenuText
        if ([string]::IsNullOrWhiteSpace($baseText)) { $baseText = $L.MenuText }

        Set-ItemProperty -Path $key -Name '(Default)' -Value ($fmt -f $baseText, $state)
        if (Test-Path -LiteralPath $icon) {
            Set-ItemProperty -Path $key -Name 'Icon' -Value $icon
        }
    }

    exit 0
}
catch {
    $sh = New-Object -ComObject WScript.Shell
    [void]$sh.Popup(($L.ErrorPrefix -f $_.Exception.Message), 6, $L.ErrorTitle, 0x10)
    exit 1
}
