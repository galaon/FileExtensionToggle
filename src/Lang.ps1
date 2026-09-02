# Lang.ps1
# OS 표시 언어에 따라 문자열을 고릅니다. 한국어면 ko, 그 외에는 en.
# Language / string table. Follows the OS display language: Korean -> ko, otherwise en.
#
# 사용법 / usage:  . (Join-Path $ScriptDir 'Lang.ps1') -Language auto
#   $LangCode 와 $L (문자열 해시테이블) 이 정의됩니다.

param(
    [ValidateSet('auto','ko','en')]
    [string]$Language = 'auto'
)

# OS 표시 언어 판별 / detect the OS display language
#   1) 사용자가 고른 표시 언어 (HKCU\Control Panel\Desktop\PreferredUILanguages)
#   2) 설치된 Windows 의 UI 언어 (InstalledUICulture)
# CurrentUICulture 는 실행 환경에 따라 바뀔 수 있어 기준으로 쓰지 않습니다.
function Get-OSDisplayLanguage {
    $pref = (Get-ItemProperty 'HKCU:\Control Panel\Desktop' -Name 'PreferredUILanguages' -ErrorAction SilentlyContinue).PreferredUILanguages
    if ($pref -and $pref.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($pref[0])) { return $pref[0] }
    return [System.Globalization.CultureInfo]::InstalledUICulture.Name
}

$LangCode =
    if ($Language -ne 'auto') { $Language }
    elseif ((Get-OSDisplayLanguage) -like 'ko*') { 'ko' }
    else { 'en' }

$Strings = @{
    ko = @{
        MenuText     = '파일 확장자 보기 토글'
        LabelFormat  = '{0} ― [현재 · {1}]'
        MissingFile  = '필수 파일이 없습니다: {0}'
        Registered   = '등록됨: {0}'
        InstallDone  = '설치 완료. 현재 상태: [{0}]'
        InstallHint1 = '바탕화면이나 폴더 빈 공간을 우클릭하면 메뉴가 보입니다.'
        InstallHint2 = 'Windows 11에서는 [추가 옵션 표시] (Shift+F10) 안에 나타납니다.'
        FilesCopied  = '설치 위치: {0}'
        Removed      = '제거됨: {0}'
        RemoveLeftover = '내용은 지웠지만 폴더가 남았습니다 (다시 실행하면 지워집니다): {0}'
        RemoveNone   = '제거할 항목이 없습니다 (이미 삭제되었거나 설치되지 않음).'
        RemoveDone   = '제거 완료 ({0} 개).'
        ErrorTitle   = '파일 확장자 보기 토글'
        ErrorPrefix  = '오류: {0}'
    }
    en = @{
        MenuText     = 'File Extension Toggle'
        LabelFormat  = '{0} ― [Current · {1}]'
        MissingFile  = 'Required file not found: {0}'
        Registered   = 'Registered: {0}'
        InstallDone  = 'Installed. Current state: [{0}]'
        InstallHint1 = 'Right-click the desktop or an empty spot in a folder to see the menu.'
        InstallHint2 = 'On Windows 11 it lives under [Show more options] (Shift+F10).'
        FilesCopied  = 'Installed to: {0}'
        Removed      = 'Removed: {0}'
        RemoveLeftover = 'Contents deleted but the folder remains (run again to clear it): {0}'
        RemoveNone   = 'Nothing to remove (already uninstalled, or never installed).'
        RemoveDone   = 'Removed {0} item(s).'
        ErrorTitle   = 'File Extension Toggle'
        ErrorPrefix  = 'Error: {0}'
    }
}

$L = $Strings[$LangCode]
