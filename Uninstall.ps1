# Uninstall.ps1
# Install.ps1 로 등록한 우클릭 메뉴 항목을 모두 제거합니다.
# 탐색기의 HideFileExt 설정 값 자체는 건드리지 않습니다.

$ErrorActionPreference = 'Stop'

$KeyName = 'FileExtensionToggle'
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
        Write-Host "제거됨: $key"
        $removed++
    }
}

if ($removed -eq 0) {
    Write-Host '제거할 항목이 없습니다 (이미 삭제되었거나 설치되지 않음).'
} else {
    Write-Host ''
    Write-Host "제거 완료 ($removed 개)."
}
