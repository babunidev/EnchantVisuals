[CmdletBinding()]
param([string]$ClientPath, [switch]$Uninstall)
$ErrorActionPreference = 'Stop'
if (Get-Process WoW -ErrorAction SilentlyContinue) { throw 'Fully close WoW before installing or uninstalling.' }
if ([string]::IsNullOrWhiteSpace($ClientPath)) { $ClientPath = Read-Host 'Full path to the folder containing WoW.exe' }
$clientRoot = (Resolve-Path -LiteralPath $ClientPath).Path
$dllName = 'OctoEnchantVisualsDiagnostic.dll'
$iniName = 'OctoEnchantVisualsDiagnostic.ini'
$goodHash = '70D6B81BF77393925BDEAB9C3813679FC36EE29A9F3460303039E95D245AE4D5'
$oldHash = '265EF069B9827339E3BBF6DC611E85CF3900DBB242F785C5746EB97EAEB926C7'
$dllPath = Join-Path $clientRoot $dllName
$oldPath = Join-Path $clientRoot 'OctoEnchantVisuals.dll'
$loaderPath = Join-Path $clientRoot 'dlls.txt'
$iniPath = Join-Path $clientRoot $iniName
$utf8 = [Text.UTF8Encoding]::new($false, $true)
foreach ($candidate in @(@($dllPath, $goodHash), @($oldPath, $oldHash))) {
    if ((Test-Path -LiteralPath $candidate[0]) -and (Get-FileHash -LiteralPath $candidate[0] -Algorithm SHA256).Hash -ne $candidate[1]) {
        throw "Unrecognized DLL at $($candidate[0]); no files changed."
    }
}
if (-not $Uninstall) {
    if ((Get-FileHash -LiteralPath (Join-Path $clientRoot 'WoW.exe') -Algorithm SHA256).Hash -ne '183CD1128BCB9FA7D1BC7B3EAAA3AB384F71FDAADFA1BE3AD8D458E93587D4BD') {
        throw 'Unsupported client executable; no files changed.'
    }
    if ((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $dllName) -Algorithm SHA256).Hash -ne $goodHash) {
        throw 'Package DLL checksum mismatch; no files changed.'
    }
}
$originalBytes = [IO.File]::ReadAllBytes($loaderPath)
$text = $utf8.GetString($originalBytes)
# Keep every unrelated loader entry in its existing order.
$text = [regex]::Replace($text, '(?im)^[ \t]*OctoEnchantVisuals(?:Diagnostic)?\.dll[ \t]*\r?\n?', '')
$backup = Join-Path $PSScriptRoot ('backups\' + [guid]::NewGuid().ToString('N'))
[IO.Directory]::CreateDirectory($backup) | Out-Null
foreach ($path in @($loaderPath, $dllPath, $oldPath, $iniPath)) {
    if (Test-Path -LiteralPath $path) { Copy-Item -LiteralPath $path -Destination $backup }
}
if ($Uninstall) {
    [IO.File]::WriteAllBytes($loaderPath, $utf8.GetBytes($text))
    foreach ($path in @($dllPath, $oldPath, $iniPath)) {
        if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path }
    }
    Write-Output "Octo Enchant Visuals uninstalled. Backups: $backup"
} else {
    if (-not (Test-Path -LiteralPath $dllPath)) { Copy-Item -LiteralPath (Join-Path $PSScriptRoot $dllName) -Destination $dllPath }
    [IO.File]::WriteAllText($iniPath, "[Diagnostic]`r`nEnableHooks=1`r`n", $utf8)
    if ($text.Length -gt 0 -and -not $text.EndsWith("`n")) { $text += "`r`n" }
    $text += "$dllName`r`n"
    [IO.File]::WriteAllBytes($loaderPath, $utf8.GetBytes($text))
    if (Test-Path -LiteralPath $oldPath) { Remove-Item -LiteralPath $oldPath }
    Write-Output "Octo Enchant Visuals 1.0 installed; one mod DLL remains. Backups: $backup"
}
