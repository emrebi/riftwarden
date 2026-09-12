<#
.SYNOPSIS
    RIFTWARDEN arayuz worker'ini (Antigravity CLI) bir brief dosyasiyla calistirir.

.DESCRIPTION
    Sabit bayraklarla cagirir ve ciktiyi hem ekrana hem loga yazar. Amac her
    turda ayni kosullarin gecerli olmasi -- model, efor ve izin modu elle
    verilirse turdan ture degisir ve sonuclar karsilastirilamaz hale gelir.

    Izin modu bilincli olarak `accept-edits`: dosya duzenlemeyi otomatik
    onaylar ama terminal komutu calistirmasina IZIN VERMEZ.
    `--dangerously-skip-permissions` kullanilmaz.

.PARAMETER Brief
    docs/ui_briefs/ altindaki brief dosyasinin adi (uzantisiz) veya tam yolu.

.PARAMETER Continue
    Onceki agy oturumunu surdurur. Duzeltme turlarinda kullanilir; brief'i
    tekrar gondermeye gerek kalmaz, baglam korunur.

.PARAMETER Model
    Varsayilan gemini-3.8-flash-medium. Zor tasarim isleri icin
    gemini-3.1-pro-high denenebilir.

.EXAMPLE
    ./tools/agy-task.ps1 design-system
    ./tools/agy-task.ps1 design-system -Continue
#>
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Brief,

    [switch]$Continue,

    [string]$Model = 'gemini-3.8-flash-medium',

    [ValidateSet('low', 'medium', 'high')]
    [string]$Effort = 'medium'
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot

# Brief yolu: cikplak ad verildiyse docs/ui_briefs/ altinda ara.
$briefPath = if (Test-Path $Brief) {
    (Resolve-Path $Brief).Path
} else {
    Join-Path $repoRoot "docs/ui_briefs/$Brief.md"
}

if (-not (Test-Path $briefPath)) {
    Write-Error "Brief bulunamadi: $briefPath"
    exit 1
}

$logDir = Join-Path $repoRoot '.agy/logs'
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
}
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$logPath = Join-Path $logDir "$([IO.Path]::GetFileNameWithoutExtension($briefPath))_$stamp.log"

Write-Host "brief : $briefPath"
Write-Host "model : $Model (effort=$Effort)"
Write-Host "log   : $logPath"
Write-Host ''

Push-Location $repoRoot
try {
    $started = Get-Date

    $agyArgs = @(
        '--model', $Model,
        '--effort', $Effort,
        '--mode', 'accept-edits',
        '--output-format', 'text',
        '--print-timeout', '15m'
    )
    if ($Continue) { $agyArgs += '--continue' }

    # Brief'i stdin yerine -p ile veriyoruz: agy print modunda stdin'i
    # prompt'a ekliyor ama uzun metinlerde -p daha guvenilir davraniyor.
    $briefText = Get-Content $briefPath -Raw
    $agyArgs += @('-p', $briefText)

    & agy @agyArgs 2>&1 | Tee-Object -FilePath $logPath

    $elapsed = [int]((Get-Date) - $started).TotalSeconds
    Write-Host ''
    Write-Host "sure: ${elapsed}s"
}
finally {
    Pop-Location
}
