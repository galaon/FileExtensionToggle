# ToggleFileExt.ps1
# Windows 탐색기의 "알려진 파일 형식의 파일 확장명 숨기기" 설정을 ON/OFF 토글합니다.
#   HideFileExt = 1  ->  확장자 숨김   (메뉴: [현재 · OFF] + 회색 아이콘)
#   HideFileExt = 0  ->  확장자 표시   (메뉴: [현재 · ON]  + 파란 아이콘)
#
# 토글 후 하는 일:
#   1) SHChangeNotify 로 열려 있는 탐색기 창을 즉시 갱신 (새로고침 불필요)
#   2) 우클릭 메뉴의 라벨과 아이콘을 새 상태에 맞게 다시 기록
#
# 성공 시 아무 창도 띄우지 않고 조용히 끝납니다. 오류가 났을 때만 알립니다.

$ErrorActionPreference = 'Stop'

$AdvKey       = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$MenuKeyName  = 'FileExtensionToggle'
$DefaultLabel = '파일 확장자 표시/숨김'
$ScriptDir    = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }
$MenuBases = @(
    'HKCU:\Software\Classes\Directory\Background\shell'
    'HKCU:\Software\Classes\DesktopBackground\Shell'
    'HKCU:\Software\Classes\Directory\shell'
)

try {
    # --- 현재 값 읽기 (없으면 Windows 기본값인 1 = 숨김으로 간주) ---
    $current = (Get-ItemProperty -Path $AdvKey -Name 'HideFileExt' -ErrorAction SilentlyContinue).HideFileExt
    if ($null -eq $current) { $current = 1 }

    # --- 반전 ---
    $new = if ($current -eq 0) { 1 } else { 0 }
    Set-ItemProperty -Path $AdvKey -Name 'HideFileExt' -Value $new -Type DWord

    # --- 탐색기 즉시 갱신 (재시작·수동 새로고침 없이 반영) ---
    if (-not ('Win32.Shell32Notify' -as [type])) {
        Add-Type -Namespace Win32 -Name Shell32Notify -MemberDefinition @'
[System.Runtime.InteropServices.DllImport("shell32.dll", CharSet = System.Runtime.InteropServices.CharSet.Auto)]
public static extern void SHChangeNotify(int eventId, uint flags, System.IntPtr item1, System.IntPtr item2);
'@
    }
    # SHCNE_ASSOCCHANGED = 0x08000000
    # SHCNF_IDLIST = 0x0000, SHCNF_FLUSH = 0x1000 (알림이 처리될 때까지 대기 -> 즉시 반영)
    [Win32.Shell32Notify]::SHChangeNotify(0x08000000, 0x1000, [System.IntPtr]::Zero, [System.IntPtr]::Zero)

    # --- 우클릭 메뉴의 라벨 + 아이콘을 새 상태로 갱신 ---
    # Explorer 는 메뉴를 열 때마다 라벨과 아이콘을 레지스트리에서 다시 읽으므로,
    # 여기서 값을 바꿔두면 다음 우클릭에 바뀐 상태가 그대로 보입니다.
    $state = if ($new -eq 0) { 'ON' } else { 'OFF' }
    $icon  = Join-Path $ScriptDir $(if ($new -eq 0) { 'icon-on.ico' } else { 'icon-off.ico' })

    foreach ($base in $MenuBases) {
        $key = Join-Path $base $MenuKeyName
        if (-not (Test-Path -LiteralPath $key)) { continue }

        $baseText = (Get-ItemProperty -Path $key -Name 'BaseMenuText' -ErrorAction SilentlyContinue).BaseMenuText
        if ([string]::IsNullOrWhiteSpace($baseText)) { $baseText = $DefaultLabel }

        Set-ItemProperty -Path $key -Name '(Default)' -Value ('{0} ― [현재 · {1}]' -f $baseText, $state)
        if (Test-Path -LiteralPath $icon) {
            Set-ItemProperty -Path $key -Name 'Icon' -Value $icon
        }
    }

    exit 0
}
catch {
    $sh = New-Object -ComObject WScript.Shell
    [void]$sh.Popup("오류: $($_.Exception.Message)", 6, '파일 확장자 토글', 0x10)
    exit 1
}
