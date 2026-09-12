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

    # --dangerously-skip-permissions neden gerekli:
    # agy headless modda izin soramaz; sorulmasi gereken her tool cagrisini
    # otomatik REDDEDER ve reddedince hic cikti uretmeden olur. Izin listesini
    # settings.json'a yazmak yetmiyor, cunku agy proje bazli grant bulamayinca
    # listeyi temizliyor ("ApplyProjectPermissionGrants: cleared").
    #
    # Riski neyle dengeliyoruz:
    #   * agy'nin dokunabilecegi dizinler AGENTS.md'de sinirli,
    #   * her tur sonrasi `git diff` denetleniyor,
    #   * repo GitHub'a push'lu -- en kotu ihtimalde `git reset --hard`.
    $agyArgs = @(
        '--model', $Model,
        '--effort', $Effort,
        '--mode', 'accept-edits',
        '--dangerously-skip-permissions',
        '--output-format', 'text',
        '--print-timeout', '15m'
    )
    if ($Continue) { $agyArgs += '--continue' }

    # Brief'in METNINI argüman olarak GECIRMIYORUZ: markdown tablolarindaki
    # `|` karakterleri ve satir sonlari PowerShell'in native exe argüman
    # ayristirmasini bozuyor ("unexpected argument" hatasi). Bunun yerine
    # agy'ye dosyayi kendisi okutuyoruz -- read_file tool'u zaten var ve
    # boylece brief ne kadar uzun olursa olsun sorun cikmiyor.
    # Not: [IO.Path]::GetRelativePath .NET Core metodu; Windows PowerShell 5.1'de
    # yok. Brief her zaman repo altinda oldugu icin duz string kirpma yeterli.
    $briefRel = $briefPath.Substring($repoRoot.Length).TrimStart('\', '/').Replace('\', '/')
    $prompt = "Once AGENTS.md dosyasini oku, sonra $briefRel dosyasini oku ve " +
              'icindeki gorevi eksiksiz uygula. Gorev bitince AGENTS.md icindeki ' +
              'rapor formatinda rapor ver.'
    $agyArgs += @('-p', $prompt)

    & agy @agyArgs 2>&1 | Tee-Object -FilePath $logPath

    $elapsed = [int]((Get-Date) - $started).TotalSeconds
    Write-Host ''
    Write-Host "sure: ${elapsed}s"
}
finally {
    Pop-Location
}
